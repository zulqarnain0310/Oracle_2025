--------------------------------------------------------
--  DDL for Procedure BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" 
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
    v_SQLERRM VARCHAR(1000);
    v_SQLCODE VARCHAR(1000);
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
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..GTT_temp_3') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_temp_3 ';
            END IF;
            IF utils.object_id('TempDB..GTT_temp_31') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1 ';
            END IF;
            DELETE FROM GTT_temp_3;
            UTILS.IDENTITY_RESET('GTT_temp_3');

            INSERT INTO GTT_temp_3 ( 
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
                    ' '
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
                             ' ' 

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
                             ' '
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
            	  GROUP BY A.EntityKey,A.BucketWiseAcceleratedProvisionEntityID,A.AcceProDuration,A.AcceProDurationDescription,A.EffectiveDate,A.Secured_Unsecured,A.Secured_UnsecuredDescription,A.AdditionalProvision,A.BucketExceptCC,A.BucketExceptCCDescription,A.BucketCreditCard,A.BucketCreditCardCDescription,SegmentName,AssetClassNameAlt_key,CurrentProvisionPer,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.AuthorisationStatus_1,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst);
            MERGE INTO GTT_temp_3 A
            USING (SELECT A.ROWID row_id, A.SegmentName
            FROM GTT_temp_3 A) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
            --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
            MERGE INTO GTT_temp_3 A
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM GTT_temp_3 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            MERGE INTO GTT_temp_3 A
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM GTT_temp_3 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'Secured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            MERGE INTO GTT_temp_3 A
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM GTT_temp_3 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'UnSecured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SchemecodeTypeMaster' TableName  ,
                               ENTITYKEY,	BUCKETWISEACCELERATEDPROVISIONENTITYID,	ACCEPRODURATION,	ACCEPRODURATIONDESCRIPTION,	EFFECTIVEDATE,	SECURED_UNSECURED,	SECURED_UNSECUREDDESCRIPTION,	ADDITIONALPROVISION,	BUCKETEXCEPTCC,	BUCKETEXCEPTCCDESCRIPTION,	BUCKETCREDITCARD,	BUCKETCREDITCARDCDESCRIPTION,	SEGMENTNAME,	ASSETCLASSNAMEALT_KEY,	CURRENTPROVISIONPER,	SEGMENTDESCRIPTION,	ASSETCLASSNAME,	PROVISONSECURED_UNSECURED,	AUTHORISATIONSTATUS,	AUTHORISATIONSTATUS_1,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	APPROVEDBY,	DATEAPPROVED,	MODIFIEDBY,	DATEMODIFIED,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	MODAPPBYFIRST,	MODAPPDATEFIRST,	CHANGEFIELD
                        FROM ( SELECT * 
                               FROM GTT_temp_3 A ) 
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
               IF utils.object_id('TempDB..GTT_temp_316') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_temp_3 ';
               END IF;
               DELETE FROM GTT_temp_3;
               UTILS.IDENTITY_RESET('GTT_temp_3');

               INSERT INTO GTT_temp_3 ( 
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
               MERGE INTO GTT_temp_3 A 
               USING (SELECT A.ROWID row_id, A.SegmentName
               FROM GTT_temp_3 A ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
               --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
               MERGE INTO GTT_temp_3 A 
               USING (SELECT A.ROWID row_id, C.AssetClassName
               FROM GTT_temp_3 A
                      JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
               MERGE INTO GTT_temp_3 A  
               USING (SELECT A.ROWID row_id, B.ProvisionSecured
               FROM GTT_temp_3 A
                      JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
                WHERE Secured_Unsecured = 'Secured') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
               MERGE INTO GTT_temp_3 A 
               USING (SELECT A.ROWID row_id, B.ProvisionSecured
               FROM GTT_temp_3 A
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
                                  ENTITYKEY,	BUCKETWISEACCELERATEDPROVISIONENTITYID,	ACCEPRODURATION,	ACCEPRODURATIONDESCRIPTION,	EFFECTIVEDATE,	SECURED_UNSECURED,	SECURED_UNSECUREDDESCRIPTION,	ADDITIONALPROVISION,	BUCKETEXCEPTCC,	BUCKETEXCEPTCCDESCRIPTION,	BUCKETCREDITCARD,	BUCKETCREDITCARDCDESCRIPTION,	SEGMENTNAME,	ASSETCLASSNAMEALT_KEY,	CURRENTPROVISIONPER,	SEGMENTDESCRIPTION,	ASSETCLASSNAME,	PROVISONSECURED_UNSECURED,	AUTHORISATIONSTATUS,	AUTHORISATIONSTATUS_1,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	APPROVEDBY,	DATEAPPROVED,	MODIFIEDBY,	DATEMODIFIED,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	MODAPPBYFIRST,	MODAPPDATEFIRST,	CHANGEFIELD
                           FROM ( SELECT * 
                                  FROM GTT_temp_3 A ) 
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
            IF utils.object_id('TempDB..GTT_temp_320') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_temp_3 ';
            END IF;
            DELETE FROM GTT_temp_3;
            UTILS.IDENTITY_RESET('GTT_temp_3');

            INSERT INTO GTT_temp_3 ( 
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
            MERGE INTO GTT_temp_3 A 
            USING (SELECT A.ROWID row_id, A.SegmentName
            FROM GTT_temp_3 A ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.SegmentName;
            --INNER JOIN DimAcBuSegment C ON C.AcBuSegmentAlt_Key=A.SegmentName
            MERGE INTO GTT_temp_3 A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM GTT_temp_3 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            MERGE INTO GTT_temp_3 A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM GTT_temp_3 A
                   JOIN DimProvision_Seg B   ON A.segmentDescription = B.Segment 
             WHERE Secured_Unsecured = 'Secured') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonSecured_Unsecured = src.ProvisionSecured;
            MERGE INTO GTT_temp_3 A 
            USING (SELECT A.ROWID row_id, B.ProvisionSecured
            FROM GTT_temp_3 A
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
                               ENTITYKEY,	BUCKETWISEACCELERATEDPROVISIONENTITYID,	ACCEPRODURATION,	ACCEPRODURATIONDESCRIPTION,	EFFECTIVEDATE,	SECURED_UNSECURED,	SECURED_UNSECUREDDESCRIPTION,	ADDITIONALPROVISION,	BUCKETEXCEPTCC,	BUCKETEXCEPTCCDESCRIPTION,	BUCKETCREDITCARD,	BUCKETCREDITCARDCDESCRIPTION,	SEGMENTNAME,	ASSETCLASSNAMEALT_KEY,	CURRENTPROVISIONPER,	SEGMENTDESCRIPTION,	ASSETCLASSNAME,	PROVISONSECURED_UNSECURED,	AUTHORISATIONSTATUS,	AUTHORISATIONSTATUS_1,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	APPROVEDBY,	DATEAPPROVED,	MODIFIEDBY,	DATEMODIFIED,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	MODAPPBYFIRST,	MODAPPDATEFIRST,	CHANGEFIELD
                        FROM ( SELECT * 
                               FROM GTT_temp_3 A ) 
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
    v_SQLERRM:=SQLERRM;
    v_SQLCODE:=SQLCODE;
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
      INSERT INTO RBL_MISDB_PROD.Error_Log(ERRORLINE,	ERRORMESSAGE,	ERRORNUMBER,	ERRORPROCEDURE,	ERRORSEVERITY,	ERRORSTATE,	ERRORDATETIME)
        ( SELECT utils.error_line ErrorLine  ,
                 v_SQLERRM ErrorMessage  ,
                 v_SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT v_SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;
   --RETURN -1
   OPEN  v_cursor FOR
      SELECT ENTITYKEY,	MENUID,	SCREENNAME,	CTRLNAME,	RESOURCEKEY,	FLDDATATYPE,	COL_LG,	COL_MD,	COL_SM,	MINLENGTH,	MAXLENGTH,	ERRORCHECK,	DATASEQ,	FLDGRIDVIEW,	CRITICALERRORTYPE,	SCREENFIELDNO,	ISEDITABLE,	ISVISIBLE,	ISUPPER,	ISMANDATORY,	ALLOWCHAR,	DISALLOWCHAR,	DEFAULTVALUE,	ALLOWTOOLTIP,	REFERENCECOLUMNNAME,	REFERENCETABLENAME,	MOC_FLAG,	USERID,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	SCREENFIELDGROUP,	HIGHERLEVELEDIT,	APPLICABLEFORWORKFLOW,	ISEXTRACTEDEDITABLE,	ISMOCVISIBLE,
             'SchemeCodeMaster' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'Scheme Master' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
