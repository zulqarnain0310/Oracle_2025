--------------------------------------------------------
--  DDL for Function ACCELERATEDPROVISION_MASTERSEARCHLIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" 
--USE YES_MISDB
 --AcceleratedProvision_MasterSearchList '8090001371','','',1
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_Account_ID IN VARCHAR2 DEFAULT ' ' ,
  v_Customer_ID IN VARCHAR2 DEFAULT ' ' ,
  v_UCIC_ID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14551 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
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
   IF ( NVL(v_Account_ID, ' ') <> ' '
     AND v_OperationFlag = 1 ) THEN

   BEGIN
      SELECT COUNT(1)  

        INTO v_Count
        FROM RBL_MISDB_PROD.AdvAcBasicDetail 
       WHERE  CustomerACID = v_Account_ID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      IF ( v_Count <= 0 ) THEN

      BEGIN
         v_Result := 6 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;
   IF ( NVL(v_Customer_ID, ' ') <> ' '
     AND v_OperationFlag = 1 ) THEN

   BEGIN
      SELECT COUNT(1)  

        INTO v_Count
        FROM RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  CustomerId = v_Customer_ID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      IF ( v_Count <= 0 ) THEN

      BEGIN
         v_Result := 6 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;
   IF ( NVL(v_UCIC_ID, ' ') <> ' '
     AND v_OperationFlag = 1 ) THEN

   BEGIN
      SELECT COUNT(1)  

        INTO v_Count
        FROM RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  UCIF_ID = v_UCIC_ID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      IF ( v_Count <= 0 ) THEN

      BEGIN
         v_Result := 6 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;
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
            IF utils.object_id('TempDB..tt_temp_11') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_11 ';
            END IF;
            DELETE FROM tt_temp_11;
            UTILS.IDENTITY_RESET('tt_temp_11');

            INSERT INTO tt_temp_11 ( 
            	SELECT A.AcceleratedProvisionEntityID ,
                    A.CustomerId ,
                    A.AccountId ,
                    A.UCICID ,
                    A.AcceProDuration ,
                    A.EffectiveDate ,
                    A.Secured_Unsecured ,
                    A.AdditionalProvision ,
                    A.AdditionalProvACCT ,
                    A.AccountEntityId ,
                    A.CustomerEntityId ,
                    A.UcifEntityID ,
                    A.BorrowerName ,
                    A.segmentDescription ,
                    A.AssetClassName ,
                    A.ProvisonSecured_Unsecured ,
                    A.ProvisonPointer ,
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
                    A.SegmentNameAlt_key ,
                    A.AssetClassNameAlt_key 
            	  FROM ( SELECT A.AcceleratedProvisionEntityID ,
                             A.CustomerId ,
                             A.AccountId ,
                             A.UCICID ,
                             A.AcceProDuration ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             A.AdditionalProvision ,
                             A.AdditionalProvACCT ,
                             A.AccountEntityId ,
                             A.CustomerEntityId ,
                             A.UcifEntityID ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) BorrowerName  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             CurrentProvisionPer ProvisonSecured_Unsecured  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',10) ProvisonPointer  ,
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
                             A.SegmentNameAlt_key ,
                             A.AssetClassNameAlt_key 

                      --select *
                      FROM AcceleratedProvision A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.AcceleratedProvisionEntityID ,
                             A.CustomerId ,
                             A.AccountId ,
                             A.UCICID ,
                             A.AcceProDuration ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             A.AdditionalProvision ,
                             A.AdditionalProvACCT ,
                             A.AccountEntityId ,
                             A.CustomerEntityId ,
                             A.UcifEntityID ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) BorrowerName  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             CurrentProvisionPer ProvisonSecured_Unsecured  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',10) ProvisonPointer  ,
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
                             NVL(A.ApprovedByFirstLevel, A.CreatedBy) ModAppByFirst  ,
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  ,
                             A.SegmentNameAlt_key ,
                             A.AssetClassNameAlt_key 
                      FROM AcceleratedProvision_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND NVL(A.ScreenFlag, ' ') = 'S'
                                AND A.AcceleratedProvisionEntityID IN ( SELECT MAX(AcceleratedProvisionEntityID)  
                                                                        FROM AcceleratedProvision_Mod 
                                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                                          GROUP BY AcceleratedProvisionEntityID )
                     ) A
            	  GROUP BY A.AcceleratedProvisionEntityID,A.CustomerId,A.AccountId,A.UCICID,A.AcceProDuration,A.EffectiveDate,A.Secured_Unsecured,A.AdditionalProvision,A.AdditionalProvACCT,A.AccountEntityId,A.CustomerEntityId,A.UcifEntityID,A.BorrowerName,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.ProvisonPointer,A.AuthorisationStatus_1,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.SegmentNameAlt_key,A.AssetClassNameAlt_key );
            --Select 'tt_temp_11',* from tt_temp_11
            ---------------------Account-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.CustomerName
            FROM A ,tt_temp_11 A
                   JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId 
             WHERE A.AccountId IS NOT NULL
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              AND c.EffectiveFromTimeKey <= v_TimeKey
              AND c.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp_11 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp_11 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            --Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.AccountId iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.AccountId iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '2'
            FROM A ,tt_temp_11 A 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '2';
            -------------------------------------------------------------------------------------------------
            ---------------------Customer-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.CustomerName
            FROM A ,tt_temp_11 A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerId = B.CustomerId 
             WHERE A.CustomerId IS NOT NULL
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp_11 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp_11 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.CustomerId iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.CustomerId iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '1'
            FROM A ,tt_temp_11 A 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '1';
            -----------------------------------------------------------------------------------------
            ---------------------UCIC-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.CustomerName
            FROM A ,tt_temp_11 A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.UCICID = B.UCIF_ID 
             WHERE A.UCICID IS NOT NULL
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp_11 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp_11 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.UCICID iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.UCICID iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '4'
            FROM A ,tt_temp_11 A 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '4';
            -----------------------------------------------------------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, 'STANDARD'
            FROM A ,tt_temp_11 A 
             WHERE NVL(A.AssetClassName, ' ') = ' ') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = 'STANDARD';
            -----------------------------------------------------------
            IF utils.object_id('TempDB..tt_temp_1111') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp11 ';
            END IF;
            IF ( NVL(v_Customer_ID, ' ') <> ' '
              OR NVL(v_Account_ID, ' ') <> ' '
              OR NVL(v_UCIC_ID, ' ') <> ' ' ) THEN

            BEGIN
               DELETE FROM tt_temp11;
               UTILS.IDENTITY_RESET('tt_temp11');

               INSERT INTO tt_temp11 ( 
               	SELECT * 
               	  FROM tt_temp_11 
               	 WHERE  ( ( CustomerId = v_Customer_ID )
                          OR ( UCICID = v_UCIC_ID )
                          OR ( AccountId = v_Account_ID ) ) );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AcceleratedProvisionMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp11 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               RETURN 0;

            END;
            END IF;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'AcceleratedProvisionMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_11 A ) 
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
               IF utils.object_id('TempDB..tt_temp_1116') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_4 ';
               END IF;
               DELETE FROM tt_temp16_4;
               UTILS.IDENTITY_RESET('tt_temp16_4');

               INSERT INTO tt_temp16_4 ( 
               	SELECT A.AcceleratedProvisionEntityID ,
                       A.CustomerId ,
                       A.AccountId ,
                       A.UCICID ,
                       A.AcceProDuration ,
                       A.EffectiveDate ,
                       A.Secured_Unsecured ,
                       A.AdditionalProvision ,
                       A.AdditionalProvACCT ,
                       A.AccountEntityId ,
                       A.CustomerEntityId ,
                       A.UcifEntityID ,
                       A.BorrowerName ,
                       A.segmentDescription ,
                       A.AssetClassName ,
                       A.ProvisonSecured_Unsecured ,
                       A.ProvisonPointer ,
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
                       A.SegmentNameAlt_key ,
                       A.AssetClassNameAlt_key 
               	  FROM ( SELECT A.AcceleratedProvisionEntityID ,
                                A.CustomerId ,
                                A.AccountId ,
                                A.UCICID ,
                                A.AcceProDuration ,
                                A.EffectiveDate ,
                                A.Secured_Unsecured ,
                                A.AdditionalProvision ,
                                A.AdditionalProvACCT ,
                                A.AccountEntityId ,
                                A.CustomerEntityId ,
                                A.UcifEntityID ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',80) BorrowerName  ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                                CurrentProvisionPer ProvisonSecured_Unsecured  ,
                                UTILS.CONVERT_TO_VARCHAR2(' ',10) ProvisonPointer  ,
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
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) ModAppByFirst  ,
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  ,
                                A.SegmentNameAlt_key ,
                                A.AssetClassNameAlt_key 
                         FROM AcceleratedProvision_Mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.ScreenFlag, ' ') = 'S'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND A.AcceleratedProvisionEntityID IN ( SELECT MAX(AcceleratedProvisionEntityID)  
                                                                           FROM AcceleratedProvision_Mod 
                                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                                     AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                                             GROUP BY AcceleratedProvisionEntityID )
                        ) A
               	  GROUP BY A.AcceleratedProvisionEntityID,A.CustomerId,A.AccountId,A.UCICID,A.AcceProDuration,A.EffectiveDate,A.Secured_Unsecured,A.AdditionalProvision,A.AdditionalProvACCT,A.AccountEntityId,A.CustomerEntityId,A.UcifEntityID,A.BorrowerName,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.ProvisonPointer,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.SegmentNameAlt_key,A.AssetClassNameAlt_key );
               ---------------------Account-------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.CustomerName
               FROM A ,tt_temp16_4 A
                      JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId 
                WHERE A.AccountId IS NOT NULL
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey
                 AND c.EffectiveFromTimeKey <= v_TimeKey
                 AND c.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
               FROM A ,tt_temp16_4 A
                      JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
                WHERE A.AccountId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AssetClassName
               FROM A ,tt_temp16_4 A
                      JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
                WHERE A.AccountId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
               --Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='Secured'
               -- And  A.AccountId iS NOT NULL
               -- Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='UnSecured'
               -- And  A.AccountId iS NOT NULL
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, '2'
               FROM A ,tt_temp16_4 A 
                WHERE A.AccountId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '2';
               -------------------------------------------------------------------------------------------------
               ---------------------Customer-------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.CustomerName
               FROM A ,tt_temp16_4 A
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerId = B.CustomerId 
                WHERE A.CustomerId IS NOT NULL
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
               FROM A ,tt_temp16_4 A
                      JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
                WHERE A.CustomerId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AssetClassName
               FROM A ,tt_temp16_4 A
                      JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
                WHERE A.CustomerId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
               -- Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='Secured'
               -- And  A.CustomerId iS NOT NULL
               -- Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='UnSecured'
               -- And  A.CustomerId iS NOT NULL
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, '1'
               FROM A ,tt_temp16_4 A 
                WHERE A.CustomerId IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '1';
               -----------------------------------------------------------------------------------------
               ---------------------UCIC-------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.CustomerName
               FROM A ,tt_temp16_4 A
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.UCICID = B.UCIF_ID 
                WHERE A.UCICID IS NOT NULL
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
               FROM A ,tt_temp16_4 A
                      JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
                WHERE A.UCICID IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.AssetClassName
               FROM A ,tt_temp16_4 A
                      JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
                WHERE A.UCICID IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
               -- Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='Secured'
               -- And  A.UCICID iS NOT NULL
               -- Update A
               --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
               --From tt_temp_11 A
               --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
               --      Where  Secured_Unsecured='UnSecured'
               -- And  A.UCICID iS NOT NULL
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, '4'
               FROM A ,tt_temp16_4 A 
                WHERE A.UCICID IS NOT NULL) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '4';
               -----------------------------------------------------------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, 'STANDARD'
               FROM A ,tt_temp16_4 A 
                WHERE A.AssetClassName = ' ') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassName = 'STANDARD';
               -----------------------------------------------------------------------------
               IF utils.object_id('TempDB..tt_temp_11161') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp161 ';
               END IF;
               IF ( NVL(v_Customer_ID, ' ') <> ' '
                 OR NVL(v_Account_ID, ' ') <> ' '
                 OR NVL(v_UCIC_ID, ' ') <> ' ' ) THEN

               BEGIN
                  DELETE FROM tt_temp161;
                  UTILS.IDENTITY_RESET('tt_temp161');

                  INSERT INTO tt_temp161 ( 
                  	SELECT * 
                  	  FROM tt_temp_11 
                  	 WHERE  ( ( CustomerId = v_Customer_ID )
                             OR ( UCICID = v_UCIC_ID )
                             OR ( AccountId = v_Account_ID ) ) );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'AcceleratedProvisionMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp161 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY DataPointOwner.DateCreated DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);
                  RETURN 0;

               END;
               END IF;
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AcceleratedProvisionMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_4 A ) 
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
            IF utils.object_id('TempDB..tt_temp_1120') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_4 ';
            END IF;
            DELETE FROM tt_temp20_4;
            UTILS.IDENTITY_RESET('tt_temp20_4');

            INSERT INTO tt_temp20_4 ( 
            	SELECT A.AcceleratedProvisionEntityID ,
                    A.CustomerId ,
                    A.AccountId ,
                    A.UCICID ,
                    A.AcceProDuration ,
                    A.EffectiveDate ,
                    A.Secured_Unsecured ,
                    A.AdditionalProvision ,
                    A.AdditionalProvACCT ,
                    A.AccountEntityId ,
                    A.CustomerEntityId ,
                    A.UcifEntityID ,
                    A.BorrowerName ,
                    A.segmentDescription ,
                    A.AssetClassName ,
                    A.ProvisonSecured_Unsecured ,
                    A.ProvisonPointer ,
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
                    A.SegmentNameAlt_key ,
                    A.AssetClassNameAlt_key 
            	  FROM ( SELECT A.AcceleratedProvisionEntityID ,
                             A.CustomerId ,
                             A.AccountId ,
                             A.UCICID ,
                             A.AcceProDuration ,
                             A.EffectiveDate ,
                             A.Secured_Unsecured ,
                             A.AdditionalProvision ,
                             A.AdditionalProvACCT ,
                             A.AccountEntityId ,
                             A.CustomerEntityId ,
                             A.UcifEntityID ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) BorrowerName  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',80) segmentDescription  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',50) AssetClassName  ,
                             CurrentProvisionPer ProvisonSecured_Unsecured  ,
                             UTILS.CONVERT_TO_VARCHAR2(' ',10) ProvisonPointer  ,
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
                             NVL(A.ApprovedBy, A.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(A.DateApproved, A.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             NVL(A.ApprovedByFirstLevel, A.CreatedBy) ModAppByFirst  ,
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  ,
                             A.SegmentNameAlt_key ,
                             A.AssetClassNameAlt_key 
                      FROM AcceleratedProvision_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.ScreenFlag, ' ') = 'S'
                                AND NVL(AuthorisationStatus, 'A') IN ( '1A','D1' )

                                AND A.AcceleratedProvisionEntityID IN ( SELECT MAX(AcceleratedProvisionEntityID)  
                                                                        FROM AcceleratedProvision_Mod 
                                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                                  AND NVL(AuthorisationStatus, 'A') IN ( '1A','D1' )


                                                                        --                     
                                                                        GROUP BY AcceleratedProvisionEntityID )
                     ) A
            	  GROUP BY A.AcceleratedProvisionEntityID,A.CustomerId,A.AccountId,A.UCICID,A.AcceProDuration,A.EffectiveDate,A.Secured_Unsecured,A.AdditionalProvision,A.AdditionalProvACCT,A.BorrowerName,A.AccountEntityId,A.CustomerEntityId,A.UcifEntityID,A.segmentDescription,A.AssetClassName,A.ProvisonSecured_Unsecured,A.ProvisonPointer,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst,A.SegmentNameAlt_key,A.AssetClassNameAlt_key );
            ---------------------Account-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.CustomerName
            FROM A ,tt_temp20_4 A
                   JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId 
             WHERE A.AccountId IS NOT NULL
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              AND c.EffectiveFromTimeKey <= v_TimeKey
              AND c.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp20_4 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp20_4 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            --Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.AccountId iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.AccountId iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '2'
            FROM A ,tt_temp20_4 A 
             WHERE A.AccountId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '2';
            -------------------------------------------------------------------------------------------------
            ---------------------Customer-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.CustomerName
            FROM A ,tt_temp20_4 A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerId = B.CustomerId 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp20_4 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp20_4 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.CustomerId iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.CustomerId iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '1'
            FROM A ,tt_temp20_4 A 
             WHERE A.CustomerId IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '1';
            -----------------------------------------------------------------------------------------
            ---------------------UCIC-------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.CustomerName
            FROM A ,tt_temp20_4 A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.UCICID = B.UCIF_ID 
             WHERE A.UCICID IS NOT NULL
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.BorrowerName = src.CustomerName;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AcBuSegmentDescription
            FROM A ,tt_temp20_4 A
                   JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuRevisedSegmentCode 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.segmentDescription = src.AcBuSegmentDescription;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.AssetClassName
            FROM A ,tt_temp20_4 A
                   JOIN DimAssetClass C   ON A.AssetClassNameAlt_key = C.AssetClassAlt_Key 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = src.AssetClassName;
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='Secured'
            -- And  A.UCICID iS NOT NULL
            -- Update A
            --SET A.ProvisonSecured_Unsecured=B.ProvisionSecured
            --From tt_temp_11 A
            --INNER JOIN DimProvision_Seg B ON A.segmentDescription=B.Segment
            --      Where  Secured_Unsecured='UnSecured'
            -- And  A.UCICID iS NOT NULL
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, '4'
            FROM A ,tt_temp20_4 A 
             WHERE A.UCICID IS NOT NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ProvisonPointer = '4';
            -----------------------------------------------------------------------------------------
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, 'STANDARD'
            FROM A ,tt_temp20_4 A 
             WHERE A.AssetClassName = ' ') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassName = 'STANDARD';
            ---------------------------------------------------------------------------------------------
            IF utils.object_id('TempDB..tt_temp_11201') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp201 ';
            END IF;
            IF ( NVL(v_Customer_ID, ' ') <> ' '
              OR NVL(v_Account_ID, ' ') <> ' '
              OR NVL(v_UCIC_ID, ' ') <> ' ' ) THEN

            BEGIN
               DELETE FROM tt_temp201;
               UTILS.IDENTITY_RESET('tt_temp201');

               INSERT INTO tt_temp201 ( 
               	SELECT * 
               	  FROM tt_temp_11 
               	 WHERE  ( ( CustomerId = v_Customer_ID )
                          OR ( UCICID = v_UCIC_ID )
                          OR ( AccountId = v_Account_ID ) ) );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AcceleratedProvisionMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp201 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               RETURN 0;

            END;
            END IF;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcceleratedProvisionEntityID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'AcceleratedProvisionMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp20_4 A ) 
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
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1
      --SELECT *, 'SchemeCodeMaster' AS TableName FROM  MetaScreenFieldDetail where ScreenName = 'Scheme Master'

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_MASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
