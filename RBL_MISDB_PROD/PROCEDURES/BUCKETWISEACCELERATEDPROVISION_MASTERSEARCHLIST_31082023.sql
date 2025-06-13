--------------------------------------------------------
--  DDL for Procedure BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" 
--USE YES_MISDB
 --AcceleratedProvision_MasterSearchList '8090001371','','',1
 --sp_rename 'BucketWiseAcceleratedProvision_MasterSearchList','BucketWiseAcceleratedProvision_MasterSearchList_30032022'
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_MenuID IN NUMBER DEFAULT 14551 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_Count NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551

BEGIN

   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..tt_temp_22') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_22 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_221') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_3 ';
            END IF;
            DELETE FROM tt_temp_22;
            UTILS.IDENTITY_RESET('tt_temp_22');

            INSERT INTO tt_temp_22 ( 
            	SELECT A.EntityKey ,
                    A.BucketWiseAcceleratedProvisionEntityID ,
                    A.AcceProDuration ,
                    A.AcceProDurationDescription ,
                    A.EffectiveDate ,
                    A.Secured_Unsecured ,
                    A.Secured_UnsecuredDescription ,
                    A.AdditionalProvision ,
                    A.BucketExceptCC ,
                    A.BucketExceptCCDescription ,
                    A.BucketCreditCard ,
                    A.BucketCreditCardCDescription ,
                    SegmentName ,
                    AssetClassNameAlt_key ,
                    CurrentProvisionPer ,
                    A.segmentDescription ,
                    A.AssetClassName ,
                    A.ProvisonSecured_Unsecured ,
                    A.AuthorisationStatus ,
                    A.AuthorisationStatus_1 ,
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
                    A.ModAppDate ,
                    A.ModAppByFirst ,
                    A.ModAppDateFirst ,
                    A.changeField 
            	  FROM ( SELECT A.EntityKey ,
                             A.BucketWiseAcceleratedProvisionEntityID ,
                             A.AcceProDuration ,
                             B.ParameterName AcceProDurationDescription  ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             C.ParameterName Secured_UnsecuredDescription  ,
                             A.AdditionalProvision ,
                             A.BucketExceptCC ,
                             D.ParameterName BucketExceptCCDescription  ,
                             A.BucketCreditCard ,
                             E.ParameterName BucketCreditCardCDescription  ,
                             SegmentName ,
                             AssetClassNameAlt_key ,
                             CurrentProvisionPer ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             UTILS.CONVERT_TO_NUMBER('0',5,2) ProvisonSecured_Unsecured  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             CASE 
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus_1  ,
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
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             NVL(A.ModifiedBy, A.CreatedBy) ModAppByFirst  ,
                             NVL(A.DateModified, A.DateCreated) ModAppDateFirst  ,
                             ' ' changeField  

                      --select *
                      FROM BucketWiseAcceleratedProvision A
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'AcceleratedProvisionDuration' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimAccProvDuration'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceProDuration = B.ParameterAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'SecureUnsecureMaster' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimExposureType'
                                                   AND ParameterName NOT IN ( 'Derived' )

                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.Secured_Unsecured = C.ParameterName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketExceptCC' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimBucketExceptCC'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.BucketExceptCC = D.ParameterShortName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketCreditCard' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'BucketCreditCard'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.BucketCreditCard = E.ParameterShortName
                       WHERE  NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.EntityKey ,
                             A.BucketWiseAcceleratedProvisionEntityID ,
                             A.AcceProDuration ,
                             B.ParameterName AcceProDuration  ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             C.ParameterName Secured_UnsecuredDescription  ,
                             A.AdditionalProvision ,
                             A.BucketExceptCC ,
                             D.ParameterName BucketExceptCCDescription  ,
                             A.BucketCreditCard ,
                             E.ParameterName BucketCreditCardCDescription  ,
                             SegmentName ,
                             AssetClassNameAlt_key ,
                             CurrentProvisionPer ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             UTILS.CONVERT_TO_NUMBER('0',5,2) ProvisonSecured_Unsecured  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             CASE 
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus_1  ,
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
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             NVL(A.FirstLevelApprovedBy, A.CreatedBy) ModAppByFirst  ,
                             NVL(A.FirstLevelDateApproved, A.DateCreated) ModAppDateFirst  ,
                             NVL(changeField, ' ') changeField  
                      FROM BucketWiseAcceleratedProvision_Mod A
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'AcceleratedProvisionDuration' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimAccProvDuration'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceProDuration = B.ParameterAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'SecureUnsecureMaster' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimExposureType'
                                                   AND ParameterName NOT IN ( 'Derived' )

                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.Secured_Unsecured = C.ParameterName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketExceptCC' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimBucketExceptCC'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.BucketExceptCC = D.ParameterShortName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketCreditCard' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'BucketCreditCard'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.BucketCreditCard = E.ParameterShortName
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, ' ') IN ( 'NP','MP','DP','RM','1A' )

                                AND A.EntityKey IN ( SELECT --*
                                                      MAX(EntityKey)  
                                                     FROM BucketWiseAcceleratedProvision_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, ' ') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.BucketWiseAcceleratedProvisionEntityID,A.AcceProDuration,A.AcceProDurationDescription,A.EffectiveDate,A.Secured_Unsecured,A.Secured_UnsecuredDescription,A.AdditionalProvision,A.BucketExceptCC,A.BucketExceptCCDescription,A.BucketCreditCard,A.BucketCreditCardCDescription,SegmentName,AssetClassNameAlt_key,CurrentProvisionPer,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.AuthorisationStatus_1,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.ChangeField );
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, A.SegmentName
            FROM A ,tt_temp_22 A ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
            --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp_22 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM A ,tt_temp_22 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'Secured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM A ,tt_temp_22 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'UnSecured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SchemecodeTypeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_22 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_2216') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_15 ';
               END IF;
               DELETE FROM tt_temp16_15;
               UTILS.IDENTITY_RESET('tt_temp16_15');

               INSERT INTO tt_temp16_15 ( 
               	SELECT A.EntityKey ,
                       A.BucketWiseAcceleratedProvisionEntityID ,
                       A.AcceProDuration ,
                       A.AcceProDurationDescription ,
                       A.EffectiveDate ,
                       A.Secured_Unsecured ,
                       A.Secured_UnsecuredDescription ,
                       A.AdditionalProvision ,
                       A.BucketExceptCC ,
                       A.BucketExceptCCDescription ,
                       A.BucketCreditCard ,
                       A.BucketCreditCardCDescription ,
                       SegmentName ,
                       AssetClassNameAlt_key ,
                       CurrentProvisionPer ,
                       A.segmentDescription ,
                       A.AssetClassName ,
                       A.ProvisonSecured_Unsecured ,
                       A.AuthorisationStatus ,
                       A.AuthorisationStatus_1 ,
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
                       A.ModAppDate ,
                       A.ModAppByFirst ,
                       A.ModAppDateFirst ,
                       A.changeField 
               	  FROM ( SELECT A.EntityKey ,
                                A.BucketWiseAcceleratedProvisionEntityID ,
                                A.AcceProDuration ,
                                B.ParameterName AcceProDurationDescription  ,
                                A.EffectiveDate ,
                                A.Secured_Unsecured ,
                                C.ParameterName Secured_UnsecuredDescription  ,
                                A.AdditionalProvision ,
                                A.BucketExceptCC ,
                                D.ParameterName BucketExceptCCDescription  ,
                                A.BucketCreditCard ,
                                E.ParameterName BucketCreditCardCDescription  ,
                                A.SegmentName ,
                                A.AssetClassNameAlt_key ,
                                CurrentProvisionPer ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                                UTILS.CONVERT_TO_NUMBER('0',5,2) ProvisonSecured_Unsecured  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
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
                                NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) ModAppByFirst  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) ModAppDateFirst  ,
                                NVL(changeField, ' ') changeField  
                         FROM BucketWiseAcceleratedProvision_Mod A
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'AcceleratedProvisionDuration' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'DimAccProvDuration'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceProDuration = B.ParameterAlt_Key
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'SecureUnsecureMaster' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'DimExposureType'
                                                      AND ParameterName NOT IN ( 'Derived' )

                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.Secured_Unsecured = C.ParameterName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   ParameterShortName ,
                                                   'DimBucketExceptCC' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'DimBucketExceptCC'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.BucketExceptCC = D.ParameterShortName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   ParameterShortName ,
                                                   'DimBucketCreditCard' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'BucketCreditCard'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.BucketCreditCard = E.ParameterShortName
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM BucketWiseAcceleratedProvision_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.EntityKey,A.BucketWiseAcceleratedProvisionEntityID,A.AcceProDuration,A.AcceProDurationDescription,A.EffectiveDate,A.Secured_Unsecured,A.Secured_UnsecuredDescription,A.AdditionalProvision,A.BucketExceptCC,A.BucketExceptCCDescription,A.BucketCreditCard,A.BucketCreditCardCDescription,SegmentName,AssetClassNameAlt_key,CurrentProvisionPer,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.ChangeField );
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, A.SegmentName
               FROM A ,tt_temp16_15 A ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
               --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AssetClassName
               FROM A ,tt_temp16_15 A
                      JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.ProvisionSecured
               FROM A ,tt_temp16_15 A
                      JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
                WHERE Secured_Unsecured = 'Secured') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.ProvisionSecured
               FROM A ,tt_temp16_15 A
                      JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
                WHERE Secured_Unsecured = 'UnSecured') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
               -----------------------------------------------------------------------------------------
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SchemecodeTypeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_15 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize)
         IF ( v_OperationFlag IN ( 20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_2220') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_15 ';
            END IF;
            DELETE FROM tt_temp20_15;
            UTILS.IDENTITY_RESET('tt_temp20_15');

            INSERT INTO tt_temp20_15 ( 
            	SELECT A.EntityKey ,
                    A.BucketWiseAcceleratedProvisionEntityID ,
                    A.AcceProDuration ,
                    A.AcceProDurationDescription ,
                    A.EffectiveDate ,
                    A.Secured_Unsecured ,
                    A.Secured_UnsecuredDescription ,
                    A.AdditionalProvision ,
                    A.BucketExceptCC ,
                    A.BucketExceptCCDescription ,
                    A.BucketCreditCard ,
                    A.BucketCreditCardCDescription ,
                    SegmentName ,
                    AssetClassNameAlt_key ,
                    CurrentProvisionPer ,
                    A.segmentDescription ,
                    A.AssetClassName ,
                    A.ProvisonSecured_Unsecured ,
                    A.AuthorisationStatus ,
                    A.AuthorisationStatus_1 ,
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
                    A.ModAppDate ,
                    A.ModAppByFirst ,
                    A.ModAppDateFirst ,
                    A.changeField 
            	  FROM ( SELECT A.EntityKey ,
                             A.BucketWiseAcceleratedProvisionEntityID ,
                             A.AcceProDuration ,
                             B.ParameterName AcceProDurationDescription  ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             C.ParameterName Secured_UnsecuredDescription  ,
                             A.AdditionalProvision ,
                             A.BucketExceptCC ,
                             D.ParameterName BucketExceptCCDescription  ,
                             A.BucketCreditCard ,
                             E.ParameterName BucketCreditCardCDescription  ,
                             SegmentName ,
                             AssetClassNameAlt_key ,
                             CurrentProvisionPer ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             UTILS.CONVERT_TO_NUMBER('0',5,2) ProvisonSecured_Unsecured  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             CASE 
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus_1  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated DateCreated  ,
                             A.ApprovedBy ApprovedBy  ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.FirstLevelApprovedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.FirstLevelDateApproved) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             NVL(A.FirstLevelApprovedBy, A.CreatedBy) ModAppByFirst  ,
                             NVL(A.FirstLevelDateApproved, A.DateCreated) ModAppDateFirst  ,
                             NVL(changeField, ' ') changeField  
                      FROM BucketWiseAcceleratedProvision_Mod A
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'AcceleratedProvisionDuration' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimAccProvDuration'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceProDuration = B.ParameterAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'SecureUnsecureMaster' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimExposureType'
                                                   AND ParameterName NOT IN ( 'Derived' )

                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.Secured_Unsecured = C.ParameterName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketExceptCC' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimBucketExceptCC'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.BucketExceptCC = D.ParameterShortName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                ParameterShortName ,
                                                'DimBucketCreditCard' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'BucketCreditCard'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.BucketCreditCard = E.ParameterShortName
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM BucketWiseAcceleratedProvision_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( '1A','D1' )


                                                     --                      AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')

                                                     --	THEN 1 

                                                     --         when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')

                                                     --	THEN 1

                                                     --	ELSE 0									

                                                     --	END

                                                     --)=1
                                                     GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.BucketWiseAcceleratedProvisionEntityID,A.AcceProDuration,A.AcceProDurationDescription,A.EffectiveDate,A.Secured_Unsecured,A.Secured_UnsecuredDescription,A.AdditionalProvision,A.BucketExceptCC,A.BucketExceptCCDescription,A.BucketCreditCard,A.BucketCreditCardCDescription,A.SegmentName,A.AssetClassNameAlt_key,CurrentProvisionPer,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.ChangeField );
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, A.SegmentName
            FROM A ,tt_temp20_15 A ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
            --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp20_15 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM A ,tt_temp20_15 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'Secured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM A ,tt_temp20_15 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'UnSecured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            -----------------------------------------------------------------------------------------
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SchemecodeTypeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp20_15 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
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
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;
   --RETURN -1
   OPEN  v_cursor FOR
      SELECT * ,
             'SchemeCodeMaster' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'Scheme Master' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
