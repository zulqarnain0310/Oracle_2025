--------------------------------------------------------
--  DDL for Procedure UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" 
--Exec Update_proj_PUI_SearchList @OperationFlag=1

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 24705 
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
         --select * from 	SysCRisMacMenu where menucaption like '%PUI%'					
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_297') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_297 ';
            END IF;
            DELETE FROM tt_temp_297;
            UTILS.IDENTITY_RESET('tt_temp_297');

            INSERT INTO tt_temp_297 ( 
            	SELECT A.CustomerID ,
                    A.AccountID ,
                    A.ChangeinProjectScope ,
                    A.ChangeinProjectScopeDESC ,
                    A.FreshOriginalDCCO ,
                    A.RevisedDCCO ,
                    A.CourtCaseArbitration ,
                    A.CourtCaseArbitrationDESC ,
                    A.ChangeinOwnerShip ,
                    A.ChangeinOwnerShipDESC ,
                    A.CIOReferenceDate ,
                    A.CIODCCO ,
                    A.CostOverRunDESC ,
                    A.CostOverRun ,
                    A.RevisedProjectCost ,
                    A.RevisedDebt ,
                    A.RevisedDebt_EquityRatio ,
                    A.TakeOutFinance ,
                    A.TakeOutFinanceDESC ,
                    A.AssetClassSellerBook ,
                    A.AssetClassSellerBookAlt_key ,
                    A.NPADateSellerBook ,
                    A.Restructuring ,
                    A.RestructuringDESC ,
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
                    A.ModAppDate 
            	  FROM ( SELECT A.CustomerID ,
                             A.AccountID ,
                             A.ChangeinProjectScope ,
                             CASE 
                                  WHEN A.ChangeinProjectScope = 1 THEN 'Y'
                             ELSE 'N'
                                END ChangeinProjectScopeDESC  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                             A.CourtCaseArbitration ,
                             CASE 
                                  WHEN A.CourtCaseArbitration = 1 THEN 'Y'
                             ELSE 'N'
                                END CourtCaseArbitrationDESC  ,
                             A.ChangeinOwnerShip ,
                             CASE 
                                  WHEN A.ChangeinOwnerShip = 1 THEN 'Y'
                             ELSE 'N'
                                END ChangeinOwnerShipDESC  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                             CASE 
                                  WHEN A.CostOverRun = 1 THEN 'Y'
                             ELSE 'N'
                                END CostOverRunDESC  ,
                             A.CostOverRun ,
                             A.RevisedProjectCost ,
                             A.RevisedDebt ,
                             A.RevisedDebt_EquityRatio ,
                             A.TakeOutFinance ,
                             CASE 
                                  WHEN A.TakeOutFinance = 1 THEN 'Y'
                             ELSE 'N'
                                END TakeOutFinanceDESC  ,
                             CASE 
                                  WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                             ELSE 'NPA'
                                END AssetClassSellerBook  ,
                             A.AssetClassSellerBookAlt_key ,
                             UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) NPADateSellerBook  ,
                             A.Restructuring ,
                             CASE 
                                  WHEN A.Restructuring = 1 THEN 'Y'
                             ELSE 'N'
                                END RestructuringDESC  ,
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
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM AdvAcPUIDetailSub A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CustomerID ,
                             A.AccountID ,
                             A.ChangeinProjectScope ,
                             CASE 
                                  WHEN A.ChangeinProjectScope = 1 THEN 'Y'
                             ELSE 'N'
                                END ChangeinProjectScopeDESC  ,
                             --,A.FreshOriginalDCCO
                             UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                             A.CourtCaseArbitration ,
                             CASE 
                                  WHEN A.CourtCaseArbitration = 1 THEN 'Y'
                             ELSE 'N'
                                END CourtCaseArbitrationDESC  ,
                             A.ChangeinOwnerShip ,
                             CASE 
                                  WHEN A.ChangeinOwnerShip = 1 THEN 'Y'
                             ELSE 'N'
                                END ChangeinOwnerShipDESC  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                             CASE 
                                  WHEN A.CostOverRun = 1 THEN 'Y'
                             ELSE 'N'
                                END CostOverRunDESC  ,
                             A.CostOverRun ,
                             A.RevisedProjectCost ,
                             A.RevisedDebt ,
                             A.RevisedDebt_EquityRatio ,
                             A.TakeOutFinance ,
                             CASE 
                                  WHEN A.TakeOutFinance = 1 THEN 'Y'
                             ELSE 'N'
                                END TakeOutFinanceDESC  ,
                             CASE 
                                  WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                             ELSE 'NPA'
                                END AssetClassSellerBook  ,
                             A.AssetClassSellerBookAlt_key ,
                             UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) NPADateSellerBook  ,
                             A.Restructuring ,
                             CASE 
                                  WHEN A.Restructuring = 1 THEN 'Y'
                             ELSE 'N'
                                END RestructuringDESC  ,
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
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM AdvAcPUIDetailSub_mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM AdvAcPUIDetailSub_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope,A.ChangeinProjectScopeDESC,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration,A.CourtCaseArbitrationDESC,A.ChangeinOwnerShip,A.ChangeinOwnerShipDESC,A.CIOReferenceDate,A.CIODCCO,A.CostOverRunDESC,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance,A.TakeOutFinanceDESC,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADateSellerBook,A.Restructuring,A.RestructuringDESC,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'UpdatePUI' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_297 A ) 
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
               IF utils.object_id('TempDB..tt_temp_29716') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_242 ';
               END IF;
               DELETE FROM tt_temp16_242;
               UTILS.IDENTITY_RESET('tt_temp16_242');

               INSERT INTO tt_temp16_242 ( 
               	SELECT A.CustomerID ,
                       A.AccountID ,
                       A.ChangeinProjectScope ,
                       A.ChangeinProjectScopeDESC ,
                       A.FreshOriginalDCCO ,
                       A.RevisedDCCO ,
                       A.CourtCaseArbitration ,
                       A.CourtCaseArbitrationDESC ,
                       A.ChangeinOwnerShip ,
                       A.ChangeinOwnerShipDESC ,
                       A.CIOReferenceDate ,
                       A.CIODCCO ,
                       A.CostOverRunDESC ,
                       A.CostOverRun ,
                       A.RevisedProjectCost ,
                       A.RevisedDebt ,
                       A.RevisedDebt_EquityRatio ,
                       A.TakeOutFinance ,
                       A.TakeOutFinanceDESC ,
                       A.AssetClassSellerBook ,
                       A.AssetClassSellerBookAlt_key ,
                       A.NPADateSellerBook ,
                       A.Restructuring ,
                       A.RestructuringDESC ,
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
                       A.ModAppDate 
               	  FROM ( SELECT A.CustomerID ,
                                A.AccountID ,
                                A.ChangeinProjectScope ,
                                CASE 
                                     WHEN A.ChangeinProjectScope = 1 THEN 'Y'
                                ELSE 'N'
                                   END ChangeinProjectScopeDESC  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                                A.CourtCaseArbitration ,
                                CASE 
                                     WHEN A.CourtCaseArbitration = 1 THEN 'Y'
                                ELSE 'N'
                                   END CourtCaseArbitrationDESC  ,
                                A.ChangeinOwnerShip ,
                                CASE 
                                     WHEN A.ChangeinOwnerShip = 1 THEN 'Y'
                                ELSE 'N'
                                   END ChangeinOwnerShipDESC  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                                CASE 
                                     WHEN A.CostOverRun = 1 THEN 'Y'
                                ELSE 'N'
                                   END CostOverRunDESC  ,
                                A.CostOverRun ,
                                A.RevisedProjectCost ,
                                A.RevisedDebt ,
                                A.RevisedDebt_EquityRatio ,
                                A.TakeOutFinance ,
                                CASE 
                                     WHEN A.TakeOutFinance = 1 THEN 'Y'
                                ELSE 'N'
                                   END TakeOutFinanceDESC  ,
                                CASE 
                                     WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                                ELSE 'NPA'
                                   END AssetClassSellerBook  ,
                                A.AssetClassSellerBookAlt_key ,
                                UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) NPADateSellerBook  ,
                                A.Restructuring ,
                                CASE 
                                     WHEN A.Restructuring = 1 THEN 'Y'
                                ELSE 'N'
                                   END RestructuringDESC  ,
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
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  
                         FROM AdvAcPUIDetailSub_mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM AdvAcPUIDetailSub_mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope,A.ChangeinProjectScopeDESC,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration,A.CourtCaseArbitrationDESC,A.ChangeinOwnerShip,A.ChangeinOwnerShipDESC,A.CIOReferenceDate,A.CIODCCO,A.CostOverRunDESC,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance,A.TakeOutFinanceDESC,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADateSellerBook,A.Restructuring,A.RestructuringDESC,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'UpdatePUI' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_242 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_29720') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_207 ';
                  END IF;
                  DELETE FROM tt_temp20_207;
                  UTILS.IDENTITY_RESET('tt_temp20_207');

                  INSERT INTO tt_temp20_207 ( 
                  	SELECT A.CustomerID ,
                          A.AccountID ,
                          A.ChangeinProjectScope ,
                          A.ChangeinProjectScopeDESC ,
                          A.FreshOriginalDCCO ,
                          A.RevisedDCCO ,
                          A.CourtCaseArbitration ,
                          A.CourtCaseArbitrationDESC ,
                          A.ChangeinOwnerShip ,
                          A.ChangeinOwnerShipDESC ,
                          A.CIOReferenceDate ,
                          A.CIODCCO ,
                          A.CostOverRunDESC ,
                          A.CostOverRun ,
                          A.RevisedProjectCost ,
                          A.RevisedDebt ,
                          A.RevisedDebt_EquityRatio ,
                          A.TakeOutFinance ,
                          A.TakeOutFinanceDESC ,
                          A.AssetClassSellerBook ,
                          A.AssetClassSellerBookAlt_key ,
                          A.NPADateSellerBook ,
                          A.Restructuring ,
                          A.RestructuringDESC ,
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
                          A.ModAppDate 
                  	  FROM ( SELECT A.CustomerID ,
                                   A.AccountID ,
                                   A.ChangeinProjectScope ,
                                   CASE 
                                        WHEN A.ChangeinProjectScope = 1 THEN 'Y'
                                   ELSE 'N'
                                      END ChangeinProjectScopeDESC  ,
                                   --,A.FreshOriginalDCCO
                                   UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                                   A.CourtCaseArbitration ,
                                   CASE 
                                        WHEN A.CourtCaseArbitration = 1 THEN 'Y'
                                   ELSE 'N'
                                      END CourtCaseArbitrationDESC  ,
                                   A.ChangeinOwnerShip ,
                                   CASE 
                                        WHEN A.ChangeinOwnerShip = 1 THEN 'Y'
                                   ELSE 'N'
                                      END ChangeinOwnerShipDESC  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                                   CASE 
                                        WHEN A.CostOverRun = 1 THEN 'Y'
                                   ELSE 'N'
                                      END CostOverRunDESC  ,
                                   A.CostOverRun ,
                                   A.RevisedProjectCost ,
                                   A.RevisedDebt ,
                                   A.RevisedDebt_EquityRatio ,
                                   A.TakeOutFinance ,
                                   CASE 
                                        WHEN A.TakeOutFinance = 1 THEN 'Y'
                                   ELSE 'N'
                                      END TakeOutFinanceDESC  ,
                                   CASE 
                                        WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                                   ELSE 'NPA'
                                      END AssetClassSellerBook  ,
                                   A.AssetClassSellerBookAlt_key ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) NPADateSellerBook  ,
                                   A.Restructuring ,
                                   CASE 
                                        WHEN A.Restructuring = 1 THEN 'Y'
                                   ELSE 'N'
                                      END RestructuringDESC  ,
                                   A.AuthorisationStatus AuthorisationStatus  ,
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
                                   NVL(A.DateApproved, A.DateModified) ModAppDate  
                            FROM AdvAcPUIDetailSub_mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM AdvAcPUIDetailSub_mod 
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
                  	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope,A.ChangeinProjectScopeDESC,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration,A.CourtCaseArbitrationDESC,A.ChangeinOwnerShip,A.ChangeinOwnerShipDESC,A.CIOReferenceDate,A.CIODCCO,A.CostOverRunDESC,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance,A.TakeOutFinanceDESC,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADateSellerBook,A.Restructuring,A.RestructuringDESC,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'UpdatePUI' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_207 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
