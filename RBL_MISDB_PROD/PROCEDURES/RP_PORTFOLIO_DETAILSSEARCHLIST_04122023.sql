--------------------------------------------------------
--  DDL for Procedure RP_PORTFOLIO_DETAILSSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" 
(
  --Declare
  v_PAN_No IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
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
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_227') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_227 ';
            END IF;
            DELETE FROM tt_temp_227;
            UTILS.IDENTITY_RESET('tt_temp_227');

            INSERT INTO tt_temp_227 ( 
            	SELECT A.PAN_No ,
                    A.UCIC_ID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.BankingArrangementAlt_Key ,
                    A.ArrangementDescription ,
                    A.BorrowerDefaultDate ,
                    A.LeadBankAlt_Key ,
                    A.BankName ,
                    A.DefaultStatusAlt_Key ,
                    A.DefaultStatus ,
                    A.ExposureBucketAlt_Key ,
                    A.BucketName ,
                    A.ReferenceDate ,
                    A.ReviewExpiryDate ,
                    A.RP_ApprovalDate ,
                    A.RPNatureAlt_Key ,
                    A.RpDescription ,
                    A.If_Other ,
                    A.RP_ExpiryDate ,
                    A.RP_ImplDate ,
                    A.RP_ImplStatusAlt_Key ,
                    A.RP_ImplStatus ,
                    A.RP_failed ,
                    A.Revised_RP_Expiry_Date ,
                    A.Actual_Impl_Date ,
                    A.RP_OutOfDateAllBanksDeadline ,
                    A.IsBankExposure ,
                    A.AssetClassAlt_Key ,
                    A.AssetClassName ,
                    A.RiskReviewExpiryDate ,
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
            	  FROM ( SELECT A.PAN_No ,
                             A.UCIC_ID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.BankingArrangementAlt_Key ,
                             C.ArrangementDescription ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(BorrowerDefaultDate,20,p_style=>103)
                                END) BorrowerDefaultDate  ,
                             A.LeadBankAlt_Key ,
                             B.BankName ,
                             A.DefaultStatusAlt_Key ,
                             H.ParameterName DefaultStatus  ,
                             A.ExposureBucketAlt_Key ,
                             D.BucketName ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReferenceDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,20,p_style=>103)
                                END) ReferenceDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReviewExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(ReviewExpiryDate,20,p_style=>103)
                                END) ReviewExpiryDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ApprovalDate,20,p_style=>103)
                                END) RP_ApprovalDate  ,
                             A.RPNatureAlt_Key ,
                             E.RPDescription ,
                             A.If_Other ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ExpiryDate,20,p_style=>103)
                                END) RP_ExpiryDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ImplDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ImplDate,20,p_style=>103)
                                END) RP_ImplDate  ,
                             A.RP_ImplStatusAlt_Key ,
                             I.ParameterName RP_ImplStatus  ,
                             A.RP_failed ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.Revised_RP_Expiry_Date,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(Revised_RP_Expiry_Date,20,p_style=>103)
                                END) Revised_RP_Expiry_Date  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(Actual_Impl_Date,20,p_style=>103)
                                END) Actual_Impl_Date  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                                END) RP_OutOfDateAllBanksDeadline  ,
                             A.IsBankExposure ,
                             A.AssetClassAlt_Key ,
                             G.AssetClassName ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RiskReviewExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RiskReviewExpiryDate,20,p_style=>103)
                                END) RiskReviewExpiryDate  ,
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
                      FROM RP_Portfolio_Details A
                             JOIN DimBankRP B   ON A.LeadBankAlt_Key = B.BankRPAlt_Key
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimBankingArrangement C   ON A.BankingArrangementAlt_Key = C.BankingArrangementAlt_Key
                             AND C.EffectiveFromTimeKey <= v_Timekey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimExposureBucket D   ON A.ExposureBucketAlt_Key = D.ExposureBucketAlt_Key
                             AND D.EffectiveFromTimeKey <= v_Timekey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimResolutionPlanNature E   ON A.RPNatureAlt_Key = E.RPNatureAlt_Key
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimAssetClass G   ON A.AssetClassAlt_Key = G.AssetClassAlt_Key
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'BorrowerDefaultStatus' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ImplementationStatus' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ImplementationStatus'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                                AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
                               ) )
                      UNION 

                      -- AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))

                      --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                      SELECT A.PAN_No ,
                             A.UCIC_ID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.BankingArrangementAlt_Key ,
                             C.ArrangementDescription ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(BorrowerDefaultDate,20,p_style=>103)
                                END) BorrowerDefaultDate  ,
                             A.LeadBankAlt_Key ,
                             B.BankName ,
                             A.DefaultStatusAlt_Key ,
                             H.ParameterName DefaultStatus  ,
                             A.ExposureBucketAlt_Key ,
                             D.BucketName ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReferenceDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,20,p_style=>103)
                                END) ReferenceDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReviewExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(ReviewExpiryDate,20,p_style=>103)
                                END) ReviewExpiryDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ApprovalDate,20,p_style=>103)
                                END) RP_ApprovalDate  ,
                             A.RPNatureAlt_Key ,
                             E.RPDescription ,
                             A.If_Other ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ExpiryDate,20,p_style=>103)
                                END) RP_ExpiryDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ImplDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ImplDate,20,p_style=>103)
                                END) RP_ImplDate  ,
                             A.RP_ImplStatusAlt_Key ,
                             I.ParameterName RP_ImplStatus  ,
                             A.RP_failed ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.Revised_RP_Expiry_Date,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(Revised_RP_Expiry_Date,20,p_style=>103)
                                END) Revised_RP_Expiry_Date  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(Actual_Impl_Date,20,p_style=>103)
                                END) Actual_Impl_Date  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                                END) RP_OutOfDateAllBanksDeadline  ,
                             A.IsBankExposure ,
                             A.AssetClassAlt_Key ,
                             G.AssetClassName ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(A.RiskReviewExpiryDate,200) = ' ' THEN NULL
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RiskReviewExpiryDate,20,p_style=>103)
                                END) RiskReviewExpiryDate  ,
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
                      FROM RP_Portfolio_Details_Mod A
                             JOIN DimBankRP B   ON A.LeadBankAlt_Key = B.BankRPAlt_Key
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimBankingArrangement C   ON A.BankingArrangementAlt_Key = C.BankingArrangementAlt_Key
                             AND C.EffectiveFromTimeKey <= v_Timekey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimExposureBucket D   ON A.ExposureBucketAlt_Key = D.ExposureBucketAlt_Key
                             AND D.EffectiveFromTimeKey <= v_Timekey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimResolutionPlanNature E   ON A.RPNatureAlt_Key = E.RPNatureAlt_Key
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimAssetClass G   ON A.AssetClassAlt_Key = G.AssetClassAlt_Key
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'BorrowerDefaultStatus' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ImplementationStatus' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ImplementationStatus'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                                AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
                               ) )

                                --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))

                                --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM RP_Portfolio_Details_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY CustomerID )
                     ) A
            	  GROUP BY A.PAN_No,A.UCIC_ID,A.CustomerID,A.CustomerName,A.BankingArrangementAlt_Key,A.ArrangementDescription,A.BorrowerDefaultDate,A.LeadBankAlt_Key,A.BankName,A.DefaultStatusAlt_Key,A.DefaultStatus,A.ExposureBucketAlt_Key,A.BucketName,A.ReferenceDate,A.ReviewExpiryDate,A.RP_ApprovalDate,A.RPNatureAlt_Key,A.RpDescription,A.If_Other,A.RP_ExpiryDate,A.RP_ImplDate,A.RP_ImplStatusAlt_Key,A.RP_ImplStatus,A.RP_failed,A.Revised_RP_Expiry_Date,A.Actual_Impl_Date,A.RP_OutOfDateAllBanksDeadline,A.IsBankExposure,A.AssetClassAlt_Key,A.AssetClassName,A.RiskReviewExpiryDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'AutomationMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_227 A
                                WHERE  NVL(PAN_No, ' ') LIKE '%' || v_PAN_No || '%'
                                         AND NVL(CustomerID, ' ') LIKE '%' || v_CustomerID || '%' ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag = 16 ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_22716') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_180 ';
               END IF;
               DELETE FROM tt_temp16_180;
               UTILS.IDENTITY_RESET('tt_temp16_180');

               INSERT INTO tt_temp16_180 ( 
               	SELECT A.PAN_No ,
                       A.UCIC_ID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.BankingArrangementAlt_Key ,
                       A.ArrangementDescription ,
                       A.BorrowerDefaultDate ,
                       A.LeadBankAlt_Key ,
                       A.BankName ,
                       A.DefaultStatusAlt_Key ,
                       A.DefaultStatus ,
                       A.ExposureBucketAlt_Key ,
                       A.BucketName ,
                       A.ReferenceDate ,
                       A.ReviewExpiryDate ,
                       A.RP_ApprovalDate ,
                       A.RPNatureAlt_Key ,
                       A.RpDescription ,
                       A.If_Other ,
                       A.RP_ExpiryDate ,
                       A.RP_ImplDate ,
                       A.RP_ImplStatusAlt_Key ,
                       A.RP_ImplStatus ,
                       A.RP_failed ,
                       A.Revised_RP_Expiry_Date ,
                       A.Actual_Impl_Date ,
                       A.RP_OutOfDateAllBanksDeadline ,
                       A.IsBankExposure ,
                       A.AssetClassAlt_Key ,
                       A.AssetClassName ,
                       A.RiskReviewExpiryDate ,
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
               	  FROM ( SELECT A.PAN_No ,
                                A.UCIC_ID ,
                                A.CustomerID ,
                                A.CustomerName ,
                                A.BankingArrangementAlt_Key ,
                                C.ArrangementDescription ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(BorrowerDefaultDate,20,p_style=>103)
                                   END) BorrowerDefaultDate  ,
                                A.LeadBankAlt_Key ,
                                B.BankName ,
                                A.DefaultStatusAlt_Key ,
                                H.ParameterName DefaultStatus  ,
                                A.ExposureBucketAlt_Key ,
                                D.BucketName ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReferenceDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,20,p_style=>103)
                                   END) ReferenceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReviewExpiryDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(ReviewExpiryDate,20,p_style=>103)
                                   END) ReviewExpiryDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ApprovalDate,20,p_style=>103)
                                   END) RP_ApprovalDate  ,
                                A.RPNatureAlt_Key ,
                                E.RPDescription ,
                                A.If_Other ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ExpiryDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ExpiryDate,20,p_style=>103)
                                   END) RP_ExpiryDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ImplDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ImplDate,20,p_style=>103)
                                   END) RP_ImplDate  ,
                                A.RP_ImplStatusAlt_Key ,
                                I.ParameterName RP_ImplStatus  ,
                                A.RP_failed ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.Revised_RP_Expiry_Date,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(Revised_RP_Expiry_Date,20,p_style=>103)
                                   END) Revised_RP_Expiry_Date  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(Actual_Impl_Date,20,p_style=>103)
                                   END) Actual_Impl_Date  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                                   END) RP_OutOfDateAllBanksDeadline  ,
                                A.IsBankExposure ,
                                A.AssetClassAlt_Key ,
                                G.AssetClassName ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(A.RiskReviewExpiryDate,200) = ' ' THEN NULL
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RiskReviewExpiryDate,20,p_style=>103)
                                   END) RiskReviewExpiryDate  ,
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
                         FROM RP_Portfolio_Details_Mod A
                                JOIN DimBankRP B   ON A.LeadBankAlt_Key = B.BankRPAlt_Key
                                AND B.EffectiveFromTimeKey <= v_Timekey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimBankingArrangement C   ON A.BankingArrangementAlt_Key = C.BankingArrangementAlt_Key
                                AND C.EffectiveFromTimeKey <= v_Timekey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimExposureBucket D   ON A.ExposureBucketAlt_Key = D.ExposureBucketAlt_Key
                                AND D.EffectiveFromTimeKey <= v_Timekey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimResolutionPlanNature E   ON A.RPNatureAlt_Key = E.RPNatureAlt_Key
                                AND E.EffectiveFromTimeKey <= v_Timekey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass G   ON A.AssetClassAlt_Key = G.AssetClassAlt_Key
                                AND G.EffectiveFromTimeKey <= v_Timekey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'BorrowerDefaultStatus' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'ImplementationStatus' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'ImplementationStatus'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                                   AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
                                  ) )

                                   --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))

                                   --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM RP_Portfolio_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY CustomerID )
                        ) A
               	  GROUP BY A.PAN_No,A.UCIC_ID,A.CustomerID,A.CustomerName,A.BankingArrangementAlt_Key,A.ArrangementDescription,A.BorrowerDefaultDate,A.LeadBankAlt_Key,A.BankName,A.DefaultStatusAlt_Key,A.DefaultStatus,A.ExposureBucketAlt_Key,A.BucketName,A.ReferenceDate,A.ReviewExpiryDate,A.RP_ApprovalDate,A.RPNatureAlt_Key,A.RpDescription,A.If_Other,A.RP_ExpiryDate,A.RP_ImplDate,A.RP_ImplStatusAlt_Key,A.RP_ImplStatus,A.RP_failed,A.Revised_RP_Expiry_Date,A.Actual_Impl_Date,A.RP_OutOfDateAllBanksDeadline,A.IsBankExposure,A.AssetClassAlt_Key,A.AssetClassName,A.RiskReviewExpiryDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AutomationMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_180 A
                                   WHERE  NVL(PAN_No, ' ') LIKE '%' || v_PAN_No || '%'
                                            AND NVL(CustomerID, ' ') LIKE '%' || v_CustomerID || '%' ) DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_22720') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_145 ';
                  END IF;
                  DELETE FROM tt_temp20_145;
                  UTILS.IDENTITY_RESET('tt_temp20_145');

                  INSERT INTO tt_temp20_145 ( 
                  	SELECT A.PAN_No ,
                          A.UCIC_ID ,
                          A.CustomerID ,
                          A.CustomerName ,
                          A.BankingArrangementAlt_Key ,
                          A.ArrangementDescription ,
                          A.BorrowerDefaultDate ,
                          A.LeadBankAlt_Key ,
                          A.BankName ,
                          A.DefaultStatusAlt_Key ,
                          A.DefaultStatus ,
                          A.ExposureBucketAlt_Key ,
                          A.BucketName ,
                          A.ReferenceDate ,
                          A.ReviewExpiryDate ,
                          A.RP_ApprovalDate ,
                          A.RPNatureAlt_Key ,
                          A.RpDescription ,
                          A.If_Other ,
                          A.RP_ExpiryDate ,
                          A.RP_ImplDate ,
                          A.RP_ImplStatusAlt_Key ,
                          A.RP_ImplStatus ,
                          A.RP_failed ,
                          A.Revised_RP_Expiry_Date ,
                          A.Actual_Impl_Date ,
                          A.RP_OutOfDateAllBanksDeadline ,
                          A.IsBankExposure ,
                          A.AssetClassAlt_Key ,
                          A.AssetClassName ,
                          A.RiskReviewExpiryDate ,
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
                  	  FROM ( SELECT A.PAN_No ,
                                   A.UCIC_ID ,
                                   A.CustomerID ,
                                   A.CustomerName ,
                                   A.BankingArrangementAlt_Key ,
                                   C.ArrangementDescription ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(BorrowerDefaultDate,20,p_style=>103)
                                      END) BorrowerDefaultDate  ,
                                   A.LeadBankAlt_Key ,
                                   B.BankName ,
                                   A.DefaultStatusAlt_Key ,
                                   H.ParameterName DefaultStatus  ,
                                   A.ExposureBucketAlt_Key ,
                                   D.BucketName ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReferenceDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,20,p_style=>103)
                                      END) ReferenceDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.ReviewExpiryDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(ReviewExpiryDate,20,p_style=>103)
                                      END) ReviewExpiryDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ApprovalDate,20,p_style=>103)
                                      END) RP_ApprovalDate  ,
                                   A.RPNatureAlt_Key ,
                                   E.RPDescription ,
                                   A.If_Other ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ExpiryDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ExpiryDate,20,p_style=>103)
                                      END) RP_ExpiryDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_ImplDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RP_ImplDate,20,p_style=>103)
                                      END) RP_ImplDate  ,
                                   A.RP_ImplStatusAlt_Key ,
                                   I.ParameterName RP_ImplStatus  ,
                                   A.RP_failed ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.Revised_RP_Expiry_Date,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(Revised_RP_Expiry_Date,20,p_style=>103)
                                      END) Revised_RP_Expiry_Date  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(Actual_Impl_Date,20,p_style=>103)
                                      END) Actual_Impl_Date  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                                      END) RP_OutOfDateAllBanksDeadline  ,
                                   A.IsBankExposure ,
                                   A.AssetClassAlt_Key ,
                                   G.AssetClassName ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(A.RiskReviewExpiryDate,200) = ' ' THEN NULL
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RiskReviewExpiryDate,20,p_style=>103)
                                      END) RiskReviewExpiryDate  ,
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
                            FROM RP_Portfolio_Details_Mod A
                                   JOIN DimBankRP B   ON A.LeadBankAlt_Key = B.BankRPAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_Timekey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimBankingArrangement C   ON A.BankingArrangementAlt_Key = C.BankingArrangementAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_Timekey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimExposureBucket D   ON A.ExposureBucketAlt_Key = D.ExposureBucketAlt_Key
                                   AND D.EffectiveFromTimeKey <= v_Timekey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimResolutionPlanNature E   ON A.RPNatureAlt_Key = E.RPNatureAlt_Key
                                   AND E.EffectiveFromTimeKey <= v_Timekey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAssetClass G   ON A.AssetClassAlt_Key = G.AssetClassAlt_Key
                                   AND G.EffectiveFromTimeKey <= v_Timekey
                                   AND G.EffectiveToTimeKey >= v_TimeKey
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'BorrowerDefaultStatus' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'ImplementationStatus' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'ImplementationStatus'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                                      AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
                                     ) )
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM RP_Portfolio_Details_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY CustomerID )
                           ) A
                  	  GROUP BY A.PAN_No,A.UCIC_ID,A.CustomerID,A.CustomerName,A.BankingArrangementAlt_Key,A.ArrangementDescription,A.BorrowerDefaultDate,A.LeadBankAlt_Key,A.BankName,A.DefaultStatusAlt_Key,A.DefaultStatus,A.ExposureBucketAlt_Key,A.BucketName,A.ReferenceDate,A.ReviewExpiryDate,A.RP_ApprovalDate,A.RPNatureAlt_Key,A.RpDescription,A.If_Other,A.RP_ExpiryDate,A.RP_ImplDate,A.RP_ImplStatusAlt_Key,A.RP_ImplStatus,A.RP_failed,A.Revised_RP_Expiry_Date,A.Actual_Impl_Date,A.RP_OutOfDateAllBanksDeadline,A.IsBankExposure,A.AssetClassAlt_Key,A.AssetClassName,A.RiskReviewExpiryDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'AutomationMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_145 A
                                      WHERE  NVL(PAN_No, ' ') LIKE '%' || v_PAN_No || '%'
                                               AND NVL(CustomerID, ' ') LIKE '%' || v_CustomerID || '%' ) DataPointOwner ) DataPointOwner ;
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
   DECLARE
      v_Cust_Id VARCHAR2(20) := ( SELECT CustomerID 
        FROM RP_Portfolio_Details A
               JOIN ( SELECT ParameterAlt_Key ,
                             ParameterName ,
                             'BorrowerDefaultStatus' Tablename  
                      FROM DimParameter 
                       WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                AND EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
               JOIN ( SELECT ParameterAlt_Key ,
                             ParameterName ,
                             'ImplementationStatus' Tablename  
                      FROM DimParameter 
                       WHERE  DimParameterName = 'ImplementationStatus'
                                AND EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND A.PAN_No = v_PAN_No
                AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
               ) ) );
   --RETURN -1

   BEGIN
      --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
      --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
      RPLenderDetailsSelect(v_CustomerID => v_Cust_Id) ;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
