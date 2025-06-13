--------------------------------------------------------
--  DDL for Procedure PUI_SEARCHLIST_31082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_MenuID IN NUMBER DEFAULT 20 
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
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_207') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_207 ';
            END IF;
            DELETE FROM tt_temp_207;
            UTILS.IDENTITY_RESET('tt_temp_207');

            INSERT INTO tt_temp_207 ( 
            	SELECT A.CustomerID ,
                    A.UCIFID ,
                    A.AccountID ,
                    A.AccountEntityId ,
                    A.CustomerName ,
                    A.ProjectCategoryAlt_Key ,
                    A.ProjectCategoryDesc ,
                    A.ProjectSubCategoryAlt_key ,
                    A.ProjectCategorySubTypeDesc ,
                    A.ProjectSubCatDescription ,
                    A.ProjectOwnerShipAlt_Key ,
                    A.ProjectOwnerShipDesc ,
                    A.ProjectAuthorityAlt_key ,
                    A.ProjectAuthorityDesc ,
                    A.OriginalDCCO ,
                    A.OriginalProjectCost ,
                    A.OriginalDebt ,
                    A.Debt_EquityRatio ,
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
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.ChangeFields 
            	  FROM ( SELECT A.CustomerID ,
                             A.UCIFID ,
                             A.AccountID ,
                             A.AccountEntityId ,
                             A.CustomerName ,
                             A.ProjectCategoryAlt_Key ,
                             --,PC.ProjectCategoryDescription  ProjectCategoryDesc
                             CASE 
                                  WHEN A.ProjectCategoryAlt_Key = 1 THEN 'CRE / CRE-RH'
                                  WHEN A.ProjectCategoryAlt_Key = 2 THEN 'Infra'
                                  WHEN A.ProjectCategoryAlt_Key = 3 THEN 'Non-Infra'
                             ELSE ' '
                                END ProjectCategoryDesc  ,
                             A.ProjectSubCategoryAlt_key ,
                             PCS.ProjectCategorySubTypeDescription ProjectCategorySubTypeDesc  ,
                             A.ProjectSubCatDescription ,
                             A.ProjectOwnerShipAlt_Key ,
                             CASE 
                                  WHEN ProjectOwnerShipAlt_Key = 1 THEN 'Private'
                                  WHEN ProjectOwnerShipAlt_Key = 2 THEN 'Public'
                                  WHEN ProjectOwnerShipAlt_Key = 3 THEN 'Public-Private'
                             ELSE ' '
                                END ProjectOwnerShipDesc  ,
                             A.ProjectAuthorityAlt_key ,
                             CASE 
                                  WHEN ProjectAuthorityAlt_key = 1 THEN 'NA'
                                  WHEN ProjectAuthorityAlt_key = 2 THEN 'NHAI'
                                  WHEN ProjectAuthorityAlt_key = 3 THEN 'HUDCO'
                                  WHEN ProjectAuthorityAlt_key = 4 THEN 'Others'
                             ELSE ' '
                                END ProjectAuthorityDesc  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.OriginalDCCO,20,p_style=>103) OriginalDCCO  ,
                             A.OriginalProjectCost ,
                             A.OriginalDebt ,
                             A.Debt_EquityRatio ,
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
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                             ' ' ChangeFields  
                      FROM AdvAcPUIDetailMain A
                             JOIN ProjectCategory PC   ON PC.ProjectCategoryAltKey = A.ProjectCategoryAlt_Key
                             AND PC.EffectiveFromTimeKey <= v_Timekey
                             AND PC.EffectiveToTimeKey >= v_Timekey
                             LEFT JOIN ProjectCategorySubType PCS   ON PCS.ProjectCategorySubTypeAltKey = A.ProjectSubCategoryAlt_key
                             AND PC.ProjectCategoryAltKey = PCS.ProjectCategoryTypeAltKey
                             AND PCS.EffectiveFromTimeKey <= v_Timekey
                             AND PCS.EffectiveToTimeKey >= v_Timekey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CustomerID ,
                             A.UCIFID ,
                             A.AccountID ,
                             A.AccountEntityId ,
                             A.CustomerName ,
                             A.ProjectCategoryAlt_Key ,
                             CASE 
                                  WHEN A.ProjectCategoryAlt_Key = 1 THEN 'CRE / CRE-RH'
                                  WHEN A.ProjectCategoryAlt_Key = 2 THEN 'Infra'
                                  WHEN A.ProjectCategoryAlt_Key = 3 THEN 'Non-Infra'
                             ELSE ' '
                                END ProjectCategoryDesc  ,
                             A.ProjectSubCategoryAlt_key ,
                             PCS.ProjectCategorySubTypeDescription ProjectCategorySubTypeDesc  ,
                             A.ProjectSubCatDescription ,
                             A.ProjectOwnerShipAlt_Key ,
                             CASE 
                                  WHEN ProjectOwnerShipAlt_Key = 1 THEN 'Private'
                                  WHEN ProjectOwnerShipAlt_Key = 2 THEN 'Public'
                                  WHEN ProjectOwnerShipAlt_Key = 3 THEN 'Public-Private'
                             ELSE ' '
                                END ProjectOwnerShipDesc  ,
                             A.ProjectAuthorityAlt_key ,
                             CASE 
                                  WHEN ProjectAuthorityAlt_key = 1 THEN 'NA'
                                  WHEN ProjectAuthorityAlt_key = 2 THEN 'NHAI'
                                  WHEN ProjectAuthorityAlt_key = 3 THEN 'HUDCO'
                                  WHEN ProjectAuthorityAlt_key = 4 THEN 'Others'
                             ELSE ' '
                                END ProjectAuthorityDesc  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.OriginalDCCO,20,p_style=>103) OriginalDCCO  ,
                             A.OriginalProjectCost ,
                             A.OriginalDebt ,
                             A.Debt_EquityRatio ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             --,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
                             --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                             --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
                             --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
                             --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
                             --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                             A.ChangeFields 
                      FROM AdvAcPUIDetailMain_Mod A
                             JOIN ProjectCategory PC   ON PC.ProjectCategoryAltKey = A.ProjectCategoryAlt_Key
                             AND PC.EffectiveFromTimeKey <= v_Timekey
                             AND PC.EffectiveToTimeKey >= v_Timekey
                             LEFT JOIN ProjectCategorySubType PCS   ON PCS.ProjectCategorySubTypeAltKey = A.ProjectSubCategoryAlt_key
                             AND PC.ProjectCategoryAltKey = PCS.ProjectCategoryTypeAltKey
                             AND PCS.EffectiveFromTimeKey <= v_Timekey
                             AND PCS.EffectiveToTimeKey >= v_Timekey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM AdvAcPUIDetailMain_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.CustomerID,A.UCIFID,A.AccountID,A.AccountEntityId,A.CustomerName,A.ProjectCategoryAlt_Key,A.ProjectCategoryDesc,A.ProjectSubCategoryAlt_key,A.ProjectCategorySubTypeDesc,A.ProjectSubCatDescription,A.ProjectOwnerShipAlt_Key,A.ProjectOwnerShipDesc,A.ProjectAuthorityAlt_key,A.ProjectAuthorityDesc,A.OriginalDCCO,A.OriginalProjectCost,A.OriginalDebt,A.Debt_EquityRatio,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProjectCategoryAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'PUI' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_207 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_20716') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_162 ';
               END IF;
               DELETE FROM tt_temp16_162;
               UTILS.IDENTITY_RESET('tt_temp16_162');

               INSERT INTO tt_temp16_162 ( 
               	SELECT A.CustomerID ,
                       A.UCIFID ,
                       A.AccountID ,
                       A.AccountEntityId ,
                       A.CustomerName ,
                       A.ProjectCategoryAlt_Key ,
                       A.ProjectCategoryDesc ,
                       A.ProjectSubCategoryAlt_key ,
                       A.ProjectCategorySubTypeDesc ,
                       A.ProjectSubCatDescription ,
                       A.ProjectOwnerShipAlt_Key ,
                       A.ProjectOwnerShipDesc ,
                       A.ProjectAuthorityAlt_key ,
                       A.ProjectAuthorityDesc ,
                       A.OriginalDCCO ,
                       A.OriginalProjectCost ,
                       A.OriginalDebt ,
                       A.Debt_EquityRatio ,
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
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.ChangeFields 
               	  FROM ( SELECT A.CustomerID ,
                                A.UCIFID ,
                                A.AccountID ,
                                A.AccountEntityId ,
                                A.CustomerName ,
                                A.ProjectCategoryAlt_Key ,
                                CASE 
                                     WHEN A.ProjectCategoryAlt_Key = 1 THEN 'CRE / CRE-RH'
                                     WHEN A.ProjectCategoryAlt_Key = 2 THEN 'Infra'
                                     WHEN A.ProjectCategoryAlt_Key = 3 THEN 'Non-Infra'
                                ELSE ' '
                                   END ProjectCategoryDesc  ,
                                A.ProjectSubCategoryAlt_key ,
                                PCS.ProjectCategorySubTypeDescription ProjectCategorySubTypeDesc  ,
                                A.ProjectSubCatDescription ,
                                A.ProjectOwnerShipAlt_Key ,
                                CASE 
                                     WHEN ProjectOwnerShipAlt_Key = 1 THEN 'Private'
                                     WHEN ProjectOwnerShipAlt_Key = 2 THEN 'Public'
                                     WHEN ProjectOwnerShipAlt_Key = 3 THEN 'Public-Private'
                                ELSE ' '
                                   END ProjectOwnerShipDesc  ,
                                A.ProjectAuthorityAlt_key ,
                                CASE 
                                     WHEN ProjectAuthorityAlt_key = 1 THEN 'NA'
                                     WHEN ProjectAuthorityAlt_key = 2 THEN 'NHAI'
                                     WHEN ProjectAuthorityAlt_key = 3 THEN 'HUDCO'
                                     WHEN ProjectAuthorityAlt_key = 4 THEN 'Others'
                                ELSE ' '
                                   END ProjectAuthorityDesc  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.OriginalDCCO,20,p_style=>103) OriginalDCCO  ,
                                A.OriginalProjectCost ,
                                A.OriginalDebt ,
                                A.Debt_EquityRatio ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                --,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
                                --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                                --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
                                --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
                                --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
                                --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                A.ChangeFields 
                         FROM AdvAcPUIDetailMain_Mod A
                                JOIN ProjectCategory PC   ON PC.ProjectCategoryAltKey = A.ProjectCategoryAlt_Key
                                AND PC.EffectiveFromTimeKey <= v_Timekey
                                AND PC.EffectiveToTimeKey >= v_Timekey
                                LEFT JOIN ProjectCategorySubType PCS   ON PCS.ProjectCategorySubTypeAltKey = A.ProjectSubCategoryAlt_key
                                AND PC.ProjectCategoryAltKey = PCS.ProjectCategoryTypeAltKey
                                AND PCS.EffectiveFromTimeKey <= v_Timekey
                                AND PCS.EffectiveToTimeKey >= v_Timekey
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM AdvAcPUIDetailMain_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.CustomerID,A.UCIFID,A.AccountID,A.AccountEntityId,A.CustomerName,A.ProjectCategoryAlt_Key,A.ProjectCategoryDesc,A.ProjectSubCategoryAlt_key,A.ProjectCategorySubTypeDesc,A.ProjectSubCatDescription,A.ProjectOwnerShipAlt_Key,A.ProjectOwnerShipDesc,A.ProjectAuthorityAlt_key,A.ProjectAuthorityDesc,A.OriginalDCCO,A.OriginalProjectCost,A.OriginalDebt,A.Debt_EquityRatio,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProjectCategoryAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'PUI' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_162 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_20720') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_127 ';
                  END IF;
                  DELETE FROM tt_temp20_127;
                  UTILS.IDENTITY_RESET('tt_temp20_127');

                  INSERT INTO tt_temp20_127 ( 
                  	SELECT A.CustomerID ,
                          A.UCIFID ,
                          A.AccountID ,
                          A.AccountEntityId ,
                          A.CustomerName ,
                          A.ProjectCategoryAlt_Key ,
                          A.ProjectCategoryDesc ,
                          A.ProjectSubCategoryAlt_key ,
                          A.ProjectCategorySubTypeDesc ,
                          A.ProjectSubCatDescription ,
                          A.ProjectOwnerShipAlt_Key ,
                          A.ProjectOwnerShipDesc ,
                          A.ProjectAuthorityAlt_key ,
                          A.ProjectAuthorityDesc ,
                          A.OriginalDCCO ,
                          A.OriginalProjectCost ,
                          A.OriginalDebt ,
                          A.Debt_EquityRatio ,
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
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate ,
                          A.ChangeFields 
                  	  FROM ( SELECT A.CustomerID ,
                                   A.UCIFID ,
                                   A.AccountID ,
                                   A.AccountEntityId ,
                                   A.CustomerName ,
                                   A.ProjectCategoryAlt_Key ,
                                   CASE 
                                        WHEN A.ProjectCategoryAlt_Key = 1 THEN 'CRE / CRE-RH'
                                        WHEN A.ProjectCategoryAlt_Key = 2 THEN 'Infra'
                                        WHEN A.ProjectCategoryAlt_Key = 3 THEN 'Non-Infra'
                                   ELSE ' '
                                      END ProjectCategoryDesc  ,
                                   A.ProjectSubCategoryAlt_key ,
                                   PCS.ProjectCategorySubTypeDescription ProjectCategorySubTypeDesc  ,
                                   A.ProjectSubCatDescription ,
                                   A.ProjectOwnerShipAlt_Key ,
                                   CASE 
                                        WHEN ProjectOwnerShipAlt_Key = 1 THEN 'Private'
                                        WHEN ProjectOwnerShipAlt_Key = 2 THEN 'Public'
                                        WHEN ProjectOwnerShipAlt_Key = 3 THEN 'Public-Private'
                                   ELSE ' '
                                      END ProjectOwnerShipDesc  ,
                                   A.ProjectAuthorityAlt_key ,
                                   CASE 
                                        WHEN ProjectAuthorityAlt_key = 1 THEN 'NA'
                                        WHEN ProjectAuthorityAlt_key = 2 THEN 'NHAI'
                                        WHEN ProjectAuthorityAlt_key = 3 THEN 'HUDCO'
                                        WHEN ProjectAuthorityAlt_key = 4 THEN 'Others'
                                   ELSE ' '
                                      END ProjectAuthorityDesc  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.OriginalDCCO,20,p_style=>103) OriginalDCCO  ,
                                   A.OriginalProjectCost ,
                                   A.OriginalDebt ,
                                   A.Debt_EquityRatio ,
                                   A.AuthorisationStatus AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   --,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
                                   --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                                   --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
                                   --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
                                   --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
                                   --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                   A.ChangeFields 
                            FROM AdvAcPUIDetailMain_Mod A
                                   JOIN ProjectCategory PC   ON PC.ProjectCategoryAltKey = A.ProjectCategoryAlt_Key
                                   AND PC.EffectiveFromTimeKey <= v_Timekey
                                   AND PC.EffectiveToTimeKey >= v_Timekey
                                   LEFT JOIN ProjectCategorySubType PCS   ON PCS.ProjectCategorySubTypeAltKey = A.ProjectSubCategoryAlt_key
                                   AND PC.ProjectCategoryAltKey = PCS.ProjectCategoryTypeAltKey
                                   AND PCS.EffectiveFromTimeKey <= v_Timekey
                                   AND PCS.EffectiveToTimeKey >= v_Timekey
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM AdvAcPUIDetailMain_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.CustomerID,A.UCIFID,A.AccountID,A.AccountEntityId,A.CustomerName,A.ProjectCategoryAlt_Key,A.ProjectCategoryDesc,A.ProjectSubCategoryAlt_key,A.ProjectCategorySubTypeDesc,A.ProjectSubCatDescription,A.ProjectOwnerShipAlt_Key,A.ProjectOwnerShipDesc,A.ProjectAuthorityAlt_key,A.ProjectAuthorityDesc,A.OriginalDCCO,A.OriginalProjectCost,A.OriginalDebt,A.Debt_EquityRatio,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProjectCategoryAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'PUI' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_127 A ) 
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
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;
   --RETURN -1
   OPEN  v_cursor FOR
      SELECT * ,
             'PUICreateProjectStatus' tableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'CreateProjectStatusPUI' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
