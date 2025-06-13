--------------------------------------------------------
--  DDL for Procedure UPDATE_PROJ_PUI_SEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" 
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
            IF utils.object_id('TempDB..tt_temp_294') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_294 ';
            END IF;
            DELETE FROM tt_temp_294;
            UTILS.IDENTITY_RESET('tt_temp_294');

            INSERT INTO tt_temp_294 ( 
            	SELECT A.CustomerID ,
                    A.AccountID ,
                    A.ChangeinProjectScope ,
                    --,A.ChangeinProjectScopeDESC
                    A.FreshOriginalDCCO ,
                    A.RevisedDCCO ,
                    A.CourtCaseArbitration ,
                    -- ,A.CourtCaseArbitrationDESC
                    A.ChangeinOwnerShip ,
                    -- ,A.ChangeinOwnerShipDESC
                    A.CIOReferenceDate ,
                    A.CIODCCO ,
                    -- ,A.CostOverRunDESC
                    A.CostOverRun ,
                    A.RevisedProjectCost ,
                    A.RevisedDebt ,
                    A.RevisedDebt_EquityRatio ,
                    A.TakeOutFinance ,
                    -- ,A.TakeOutFinanceDESC
                    A.AssetClassSellerBook ,
                    A.AssetClassSellerBookAlt_key ,
                    A.NPADtClsSellBook ,
                    A.Restructuring ,
                    --,A.RestructuringDESC
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
                    A.InitialExtenstion ,
                    A.ExtnReason_BCP ,
                    A.Npa_date ,
                    A.Npa_Reason ,
                    A.AssetClassAlt_Key ,
                    A.ActualDCCO_Achieved ,
                    A.ActualDCCO_Date ,
                    A.ChangeFields 
            	  FROM ( SELECT A.CustomerID ,
                             A.AccountID ,
                             A.ChangeinProjectScope ,
                             -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                             UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                             A.CourtCaseArbitration ,
                             -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                             A.ChangeinOwnerShip ,
                             --  ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                             UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                             -- ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                             A.CostOverRun ,
                             A.RevisedProjectCost ,
                             A.RevisedDebt ,
                             A.RevisedDebt_EquityRatio ,
                             A.TakeOutFinance ,
                             -- ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                             CASE 
                                  WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                             ELSE 'NPA'
                                END AssetClassSellerBook  ,
                             A.AssetClassSellerBookAlt_key ,
                             CASE 
                                  WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                                   THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                                END NPADtClsSellBook  ,
                             NVL(C.Restructuring, 'N') Restructuring  ,
                             --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC
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
                             A.InitialExtenstion ,
                             --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                             A.ExtnReason_BCP ,
                             UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                             C.DEFAULT_REASON Npa_Reason  ,
                             C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                             A.ActualDCCO_Achieved ,
                             UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  ,
                             ' ' ChangeFields  
                      FROM AdvAcPUIDetailSub A
                             JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CustomerID ,
                             A.AccountID ,
                             A.ChangeinProjectScope ,
                             -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                             --,A.FreshOriginalDCCO
                             UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                             A.CourtCaseArbitration ,
                             -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                             A.ChangeinOwnerShip ,
                             -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                             UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                             --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                             A.CostOverRun ,
                             A.RevisedProjectCost ,
                             A.RevisedDebt ,
                             A.RevisedDebt_EquityRatio ,
                             A.TakeOutFinance ,
                             --,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                             CASE 
                                  WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                             ELSE 'NPA'
                                END AssetClassSellerBook  ,
                             A.AssetClassSellerBookAlt_key ,
                             --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
                             CASE 
                                  WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                                   THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                                END NPADtClsSellBook  ,
                             NVL(C.Restructuring, 'N') Restructuring  ,
                             --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
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
                             A.InitialExtenstion ,
                             --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                             A.ExtnReason_BCP ,
                             UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                             C.DEFAULT_REASON Npa_Reason  ,
                             C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                             A.ActualDCCO_Achieved ,
                             UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  ,
                             A.ChangeFields 
                      FROM AdvAcPUIDetailSub_mod A
                             JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
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
            	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope
                        -- ,A.ChangeinProjectScopeDESC
                        ,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration
                        -- ,A.CourtCaseArbitrationDESC
                        ,A.ChangeinOwnerShip
                        -- ,A.ChangeinOwnerShipDESC
                        ,A.CIOReferenceDate,A.CIODCCO
                        -- ,A.CostOverRunDESC
                        ,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance
                        -- ,A.TakeOutFinanceDESC
                        ,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADtClsSellBook,A.Restructuring
                        --,A.RestructuringDESC,
                        ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.InitialExtenstion,A.ExtnReason_BCP,A.Npa_date,A.Npa_Reason,A.AssetClassAlt_Key,A.ActualDCCO_Achieved,A.ActualDCCO_Date,A.ChangeFields );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'UpdatePUI' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_294 A ) 
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
               IF utils.object_id('TempDB..tt_temp_29416') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_239 ';
               END IF;
               DELETE FROM tt_temp16_239;
               UTILS.IDENTITY_RESET('tt_temp16_239');

               INSERT INTO tt_temp16_239 ( 
               	SELECT A.CustomerID ,
                       A.AccountID ,
                       A.ChangeinProjectScope ,
                       -- ,A.ChangeinProjectScopeDESC
                       A.FreshOriginalDCCO ,
                       A.RevisedDCCO ,
                       A.CourtCaseArbitration ,
                       -- ,A.CourtCaseArbitrationDESC
                       A.ChangeinOwnerShip ,
                       -- ,A.ChangeinOwnerShipDESC
                       A.CIOReferenceDate ,
                       A.CIODCCO ,
                       --,A.CostOverRunDESC
                       A.CostOverRun ,
                       A.RevisedProjectCost ,
                       A.RevisedDebt ,
                       A.RevisedDebt_EquityRatio ,
                       A.TakeOutFinance ,
                       -- ,A.TakeOutFinanceDESC
                       A.AssetClassSellerBook ,
                       A.AssetClassSellerBookAlt_key ,
                       A.NPADtClsSellBook ,
                       A.Restructuring ,
                       -- ,A.RestructuringDESC,
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
                       A.InitialExtenstion ,
                       A.ExtnReason_BCP ,
                       A.Npa_date ,
                       A.Npa_Reason ,
                       A.AssetClassAlt_Key ,
                       A.ActualDCCO_Achieved ,
                       A.ActualDCCO_Date ,
                       A.ChangeFields 
               	  FROM ( SELECT A.CustomerID ,
                                A.AccountID ,
                                A.ChangeinProjectScope ,
                                --  ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                                A.CourtCaseArbitration ,
                                -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                A.ChangeinOwnerShip ,
                                -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                                --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                A.CostOverRun ,
                                A.RevisedProjectCost ,
                                A.RevisedDebt ,
                                A.RevisedDebt_EquityRatio ,
                                A.TakeOutFinance ,
                                --  ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                                CASE 
                                     WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                                ELSE 'NPA'
                                   END AssetClassSellerBook  ,
                                A.AssetClassSellerBookAlt_key ,
                                --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
                                CASE 
                                     WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                                      THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                                   END NPADtClsSellBook  ,
                                NVL(C.Restructuring, 'N') Restructuring  ,
                                -- ,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
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
                                A.InitialExtenstion ,
                                --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                                A.ExtnReason_BCP ,
                                UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                                C.DEFAULT_REASON Npa_Reason  ,
                                C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                                A.ActualDCCO_Achieved ,
                                UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  ,
                                A.ChangeFields 
                         FROM AdvAcPUIDetailSub_mod A
                                JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
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
               	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope
                           -- ,A.ChangeinProjectScopeDESC
                           ,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration
                           --,A.CourtCaseArbitrationDESC
                           ,A.ChangeinOwnerShip
                           -- ,A.ChangeinOwnerShipDESC
                           ,A.CIOReferenceDate,A.CIODCCO
                           -- ,A.CostOverRunDESC
                           ,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance
                           -- ,A.TakeOutFinanceDESC
                           ,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADtClsSellBook,A.Restructuring
                           --  ,A.RestructuringDESC,
                           ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.InitialExtenstion,A.ExtnReason_BCP,A.Npa_date,A.Npa_Reason,A.AssetClassAlt_Key,A.ActualDCCO_Achieved,A.ActualDCCO_Date,A.ChangeFields );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'UpdatePUI' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_239 A ) 
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
                  DBMS_OUTPUT.PUT_LINE('Sac');
                  IF utils.object_id('TempDB..tt_temp_29420') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_204 ';
                  END IF;
                  DELETE FROM tt_temp20_204;
                  UTILS.IDENTITY_RESET('tt_temp20_204');

                  INSERT INTO tt_temp20_204 ( 
                  	SELECT A.CustomerID ,
                          A.AccountID ,
                          A.ChangeinProjectScope ,
                          --  ,A.ChangeinProjectScopeDESC
                          A.FreshOriginalDCCO ,
                          A.RevisedDCCO ,
                          A.CourtCaseArbitration ,
                          -- ,A.CourtCaseArbitrationDESC
                          A.ChangeinOwnerShip ,
                          -- ,A.ChangeinOwnerShipDESC
                          A.CIOReferenceDate ,
                          A.CIODCCO ,
                          --,A.CostOverRunDESC
                          A.CostOverRun ,
                          A.RevisedProjectCost ,
                          A.RevisedDebt ,
                          A.RevisedDebt_EquityRatio ,
                          A.TakeOutFinance ,
                          -- ,A.TakeOutFinanceDESC
                          A.AssetClassSellerBook ,
                          A.AssetClassSellerBookAlt_key ,
                          A.NPADtClsSellBook ,
                          A.Restructuring ,
                          --,A.RestructuringDESC,
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
                          A.InitialExtenstion ,
                          A.ExtnReason_BCP ,
                          A.Npa_date ,
                          A.Npa_Reason ,
                          A.AssetClassAlt_Key ,
                          A.ActualDCCO_Achieved ,
                          A.ActualDCCO_Date ,
                          A.ChangeFields 
                  	  FROM ( SELECT A.CustomerID ,
                                   A.AccountID ,
                                   A.ChangeinProjectScope ,
                                   -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                   --,A.FreshOriginalDCCO
                                   UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                                   A.CourtCaseArbitration ,
                                   -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                   A.ChangeinOwnerShip ,
                                   -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                   UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                                   --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                   A.CostOverRun ,
                                   A.RevisedProjectCost ,
                                   A.RevisedDebt ,
                                   A.RevisedDebt_EquityRatio ,
                                   A.TakeOutFinance ,
                                   -- ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                                   CASE 
                                        WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                                   ELSE 'NPA'
                                      END AssetClassSellerBook  ,
                                   A.AssetClassSellerBookAlt_key ,
                                   --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
                                   CASE 
                                        WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                                         THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                                      END NPADtClsSellBook  ,
                                   NVL(C.Restructuring, 'N') Restructuring  ,
                                   -- ,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
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
                                   A.InitialExtenstion ,
                                   --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                                   A.ExtnReason_BCP ,
                                   UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                                   C.DEFAULT_REASON Npa_Reason  ,
                                   C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                                   A.ActualDCCO_Achieved ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  ,
                                   A.ChangeFields 
                            FROM AdvAcPUIDetailSub_mod A
                                   JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM AdvAcPUIDetailSub_mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope
                              -- ,A.ChangeinProjectScopeDESC
                              ,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration
                              --,A.CourtCaseArbitrationDESC
                              ,A.ChangeinOwnerShip
                              --  ,A.ChangeinOwnerShipDESC
                              ,A.CIOReferenceDate,A.CIODCCO
                              -- ,A.CostOverRunDESC
                              ,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance
                              -- ,A.TakeOutFinanceDESC
                              ,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADtClsSellBook,A.Restructuring
                              --,A.RestructuringDESC,
                              ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.InitialExtenstion,A.ExtnReason_BCP,A.Npa_date,A.Npa_Reason,A.AssetClassAlt_Key,A.ActualDCCO_Achieved,A.ActualDCCO_Date,A.ChangeFields );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AssetClassSellerBookAlt_key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'UpdatePUI' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_204 A ) 
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
             'PUIUpdateProjectStatus' tableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'UpdateProjectStatusPUI' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
