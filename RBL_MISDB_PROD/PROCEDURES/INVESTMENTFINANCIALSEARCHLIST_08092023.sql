--------------------------------------------------------
--  DDL for Procedure INVESTMENTFINANCIALSEARCHLIST_08092023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" /****** Object:  StoredProcedure [dbo].[InvestmentFinancialSearchList]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[InvestmentFinancialSearchList]
 --GO
 --/****** Object:  StoredProcedure [dbo].[InvestmentFinancialSearchList]    Script Date: 9/24/2021 8:20:04 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare				 
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT ' ' ,
  v_Pan IN VARCHAR2 DEFAULT ' ' ,
  v_InvID IN VARCHAR2 DEFAULT ' ' ,
  v_InstrumentTypeAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_ISIN IN VARCHAR2 DEFAULT ' ' ,
  --,@InvID				Varchar (100)		= ''--,@InstrTypeAlt_key	Varchar (100)		= ''--,@ISIN				varchar (100)		= ''
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
--@OperationFlag  INT         = 1

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
            IF utils.object_id('TempDB..tt_temp_173') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_173 ';
            END IF;
            DELETE FROM tt_temp_173;
            UTILS.IDENTITY_RESET('tt_temp_173');

            INSERT INTO tt_temp_173 ( 
            	SELECT A.EntityKey ,
                    A.InvEntityId ,
                    A.BranchCode ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.RefInvID ,
                    A.RefIssuerID ,
                    A.IssuerName ,
                    A.HoldingNature ,
                    A.CurrencyAlt_Key ,
                    A.CurrencyName ,
                    A.CurrencyConvRate ,
                    A.BookType ,
                    A.BookValue ,
                    A.BookValueINR ,
                    A.MTMValue ,
                    A.MTMValueINR ,
                    A.EncumberedMTM ,
                    A.AssetClass_AltKey ,
                    A.AssetClassName ,
                    A.NPIDt ,
                    A.TotalProvison ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.DBTDate ,
                    A.LatestBSDate ,
                    A.Interest_DividendDueDate ,
                    A.Interest_DividendDueAmount ,
                    A.PartialRedumptionDueDate ,
                    A.PartialRedumptionSettledY_N ,
                    pANnO ,
                    ISIN ,
                    InstrumentTypeAlt_Key ,
                    InstrumentTypeName ,
                    InvestmentNature ,
                    Sector ,
                    a.Industry_AltKey ,
                    IndustryName ,
                    ExposureType ,
                    SecurityValue ,
                    UcifId ,
                    FLGDEG ,
                    DEGREASON ,
                    DPD ,
                    FLGUPG ,
                    UpgDate 
            	  FROM ( SELECT A.EntityKey ,
                             A.InvEntityId ,
                             Y.BranchCode ,
                             Y.SourceAlt_Key ,
                             O.SourceName ,
                             A.RefInvID ,
                             A.RefIssuerID ,
                             Y.IssuerName ,
                             A.HoldingNature ,
                             A.CurrencyAlt_Key ,
                             B.CurrencyName ,
                             A.CurrencyConvRate ,
                             A.BookType ,
                             A.BookValue ,
                             A.BookValueINR ,
                             A.MTMValue ,
                             A.MTMValueINR ,
                             A.EncumberedMTM ,
                             A.AssetClass_AltKey ,
                             C.AssetClassName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,10,p_style=>103) NPIDt  ,
                             A.TotalProvison ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             --A.DBTDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.DBTDate,10,p_style=>103) DBTDate  ,
                             --A.LatestBSDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.LatestBSDate,10,p_style=>103) LatestBSDate  ,
                             --A.Interest_DividendDueDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.Interest_DividendDueDate,10,p_style=>103) Interest_DividendDueDate  ,
                             A.Interest_DividendDueAmount ,
                             --A.PartialRedumptionDueDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.PartialRedumptionDueDate,10,p_style=>103) PartialRedumptionDueDate  ,
                             A.PartialRedumptionSettledY_N ,
                             pANnO ,
                             A.ISIN ,
                             InstrumentTypeAlt_Key ,
                             Z.InstrumentTypeName ,
                             InvestmentNature ,
                             Sector ,
                             x.Industry_AltKey ,
                             IndustryName ,
                             ExposureType ,
                             SecurityValue ,
                             Y.UcifId ,
                             (CASE 
                                   WHEN FLGDEG = 'Y' THEN 'Yes'
                                   WHEN FLGDEG = 'N' THEN 'No'   END) FLGDEG  ,
                             DEGREASON ,
                             DPD ,
                             (CASE 
                                   WHEN FLGUPG = 'Y' THEN 'Yes'
                                   WHEN FLGUPG = 'N' THEN 'No'   END) FLGUPG  ,
                             UpgDate 
                      FROM CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A
                             LEFT JOIN CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail Y   ON A.RefIssuerID = Y.IssuerID
                             LEFT JOIN CurDat_RBL_MISDB_PROD.InvestmentBasicDetail X   ON A.RefInvID = X.InvID
                             LEFT JOIN DimCurrency B   ON A.CurrencyAlt_Key = B.CurrencyAlt_Key
                             LEFT JOIN DimAssetClass C   ON A.AssetClass_AltKey = C.AssetClassAlt_Key
                             LEFT JOIN DimInstrumentType z   ON x.InstrTypeAlt_Key = z.InstrumentTypeAlt_Key
                             LEFT JOIN DIMSOURCEDB O   ON Y.SourceAlt_key = O.SourceAlt_Key
                             LEFT JOIN DimIndustry Q   ON x.Industry_AltKey = Q.IndustryAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND NVL(X.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.EntityKey ,
                             A.InvEntityId ,
                             Y.BranchCode ,
                             Y.SourceAlt_Key ,
                             O.SourceName ,
                             A.RefInvID ,
                             A.RefIssuerID ,
                             Y.IssuerName ,
                             A.HoldingNature ,
                             A.CurrencyAlt_Key ,
                             B.CurrencyName ,
                             A.CurrencyConvRate ,
                             A.BookType ,
                             A.BookValue ,
                             A.BookValueINR ,
                             A.MTMValue ,
                             A.MTMValueINR ,
                             A.EncumberedMTM ,
                             A.AssetClass_AltKey ,
                             C.AssetClassName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,10,p_style=>103) NPIDt  ,
                             A.TotalProvison ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             --A.DBTDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.DBTDate,10,p_style=>103) DBTDate  ,
                             --A.LatestBSDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.LatestBSDate,10,p_style=>103) LatestBSDate  ,
                             --A.Interest_DividendDueDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.Interest_DividendDueDate,10,p_style=>103) Interest_DividendDueDate  ,
                             A.Interest_DividendDueAmount ,
                             --A.PartialRedumptionDueDate,
                             UTILS.CONVERT_TO_VARCHAR2(A.PartialRedumptionDueDate,10,p_style=>103) PartialRedumptionDueDate  ,
                             A.PartialRedumptionSettledY_N ,
                             pANnO ,
                             ISIN ,
                             InstrumentTypeAlt_Key ,
                             InstrumentTypeName ,
                             InvestmentNature ,
                             Sector ,
                             x.Industry_AltKey ,
                             IndustryName ,
                             ExposureType ,
                             SecurityValue ,
                             Y.UcifId ,
                             (CASE 
                                   WHEN FLGDEG = 'Y' THEN 'Yes'
                                   WHEN FLGDEG = 'N' THEN 'No'   END) FLGDEG  ,
                             DEGREASON ,
                             DPD ,
                             (CASE 
                                   WHEN FLGUPG = 'Y' THEN 'Yes'
                                   WHEN FLGUPG = 'N' THEN 'No'   END) FLGUPG  ,
                             UpgDate 
                      FROM InvestmentFinancialDetail_mod A
                             LEFT JOIN InvestmentIssuerDetail_Mod Y   ON A.RefIssuerID = Y.IssuerID
                             LEFT JOIN InvestmentBasicDetail_mod X   ON A.RefInvID = X.InvID
                             LEFT JOIN DimCurrency B   ON A.CurrencyAlt_Key = B.CurrencyAlt_Key
                             LEFT JOIN DimAssetClass C   ON A.AssetClass_AltKey = C.AssetClassAlt_Key
                             LEFT JOIN DimInstrumentType z   ON x.InstrTypeAlt_Key = z.InstrumentTypeAlt_Key
                             LEFT JOIN DIMSOURCEDB O   ON Y.SourceAlt_key = O.SourceAlt_Key
                             LEFT JOIN DimIndustry Q   ON X.Industry_AltKey = Q.IndustryAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND A.InvEntityId IN ( SELECT MAX(InvEntityId)  
                                                       FROM InvestmentFinancialDetail_mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                                 AND NVL(X.AuthorisationStatus, 'A') = 'A'
                                                         GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.InvEntityId,A.BranchCode,A.SourceAlt_Key,A.SourceName,A.RefInvID,A.RefIssuerID,A.IssuerName,A.HoldingNature,A.CurrencyAlt_Key,A.CurrencyName,A.CurrencyConvRate,A.BookType,A.BookValue,A.BookValueINR,A.MTMValue,A.MTMValueINR,A.EncumberedMTM,A.AssetClass_AltKey,A.AssetClassName,A.NPIDt,A.TotalProvison,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.DBTDate,A.LatestBSDate,A.Interest_DividendDueDate,A.Interest_DividendDueAmount,A.PartialRedumptionDueDate,A.PartialRedumptionSettledY_N,pANnO,ISIN,InstrumentTypeAlt_Key,InstrumentTypeName,InvestmentNature,Sector,a.Industry_AltKey,IndustryName,ExposureType,SecurityValue,UcifId,FLGDEG,DEGREASON,DPD,FLGUPG,UpgDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'InvestmentFinanacialMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_173 A
                                WHERE  ( NVL(RefInvID, ' ') LIKE '%' || v_InvID || '%'
                                         AND NVL(rEFIssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                         AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                         AND NVL(InstrumentTypeAlt_Key, ' ') LIKE '%' || v_InstrumentTypeAlt_Key || '%'
                                         AND NVL(ISIN, ' ') LIKE '%' || v_ISIN || '%'
                                         AND NVL(pANnO, ' ') LIKE '%' || v_Pan || '%' ) ) 
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
               IF utils.object_id('TempDB..tt_temp_17316') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_132 ';
               END IF;
               DELETE FROM tt_temp16_132;
               UTILS.IDENTITY_RESET('tt_temp16_132');

               INSERT INTO tt_temp16_132 ( 
               	SELECT A.EntityKey ,
                       A.InvEntityId ,
                       A.BranchCode ,
                       A.SourceAlt_Key ,
                       A.SourceName ,
                       A.RefInvID ,
                       A.RefIssuerID ,
                       A.IssuerName ,
                       A.HoldingNature ,
                       A.CurrencyAlt_Key ,
                       A.CurrencyName ,
                       A.CurrencyConvRate ,
                       A.BookType ,
                       A.BookValue ,
                       A.BookValueINR ,
                       A.MTMValue ,
                       A.MTMValueINR ,
                       A.EncumberedMTM ,
                       A.AssetClass_AltKey ,
                       A.AssetClassName ,
                       A.NPIDt ,
                       A.TotalProvison ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.DBTDate ,
                       A.LatestBSDate ,
                       A.Interest_DividendDueDate ,
                       A.Interest_DividendDueAmount ,
                       A.PartialRedumptionDueDate ,
                       A.PartialRedumptionSettledY_N ,
                       pANnO ,
                       ISIN ,
                       InstrumentTypeAlt_Key ,
                       InstrumentTypeName ,
                       InvestmentNature ,
                       Sector ,
                       a.Industry_AltKey ,
                       IndustryName ,
                       ExposureType ,
                       SecurityValue ,
                       UcifId ,
                       FLGDEG ,
                       DEGREASON ,
                       DPD ,
                       FLGUPG ,
                       UpgDate 
               	  FROM ( SELECT A.EntityKey ,
                                A.InvEntityId ,
                                Y.BranchCode ,
                                Y.SourceAlt_key ,
                                O.SourceName ,
                                A.RefInvID ,
                                A.RefIssuerID ,
                                Y.IssuerName ,
                                A.HoldingNature ,
                                A.CurrencyAlt_Key ,
                                B.CurrencyName ,
                                A.CurrencyConvRate ,
                                A.BookType ,
                                A.BookValue ,
                                A.BookValueINR ,
                                A.MTMValue ,
                                A.MTMValueINR ,
                                A.EncumberedMTM ,
                                A.AssetClass_AltKey ,
                                C.AssetClassName ,
                                UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,10,p_style=>103) NPIDt  ,
                                A.TotalProvison ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                --A.DBTDate,
                                UTILS.CONVERT_TO_VARCHAR2(A.DBTDate,10,p_style=>103) DBTDate  ,
                                --A.LatestBSDate,
                                UTILS.CONVERT_TO_VARCHAR2(A.LatestBSDate,10,p_style=>103) LatestBSDate  ,
                                --A.Interest_DividendDueDate,
                                UTILS.CONVERT_TO_VARCHAR2(A.Interest_DividendDueDate,10,p_style=>103) Interest_DividendDueDate  ,
                                A.Interest_DividendDueAmount ,
                                --A.PartialRedumptionDueDate,
                                UTILS.CONVERT_TO_VARCHAR2(A.PartialRedumptionDueDate,10,p_style=>103) PartialRedumptionDueDate  ,
                                A.PartialRedumptionSettledY_N ,
                                pANnO ,
                                ISIN ,
                                InstrumentTypeAlt_Key ,
                                InstrumentTypeName ,
                                InvestmentNature ,
                                Sector ,
                                x.Industry_AltKey ,
                                IndustryName ,
                                ExposureType ,
                                SecurityValue ,
                                Y.UcifId ,
                                (CASE 
                                      WHEN FLGDEG = 'Y' THEN 'Yes'
                                      WHEN FLGDEG = 'N' THEN 'No'   END) FLGDEG  ,
                                DEGREASON ,
                                DPD ,
                                (CASE 
                                      WHEN FLGUPG = 'Y' THEN 'Yes'
                                      WHEN FLGUPG = 'N' THEN 'No'   END) FLGUPG  ,
                                UpgDate 
                         FROM InvestmentFinancialDetail_mod A
                                LEFT JOIN InvestmentIssuerDetail_Mod Y   ON A.RefIssuerID = Y.IssuerID
                                LEFT JOIN InvestmentBasicDetail_mod X   ON A.RefInvID = X.InvID
                                LEFT JOIN DimCurrency B   ON A.CurrencyAlt_Key = B.CurrencyAlt_Key
                                LEFT JOIN DimAssetClass C   ON A.AssetClass_AltKey = C.AssetClassAlt_Key
                                LEFT JOIN DimInstrumentType z   ON x.InstrTypeAlt_Key = z.InstrumentTypeAlt_Key
                                LEFT JOIN DIMSOURCEDB O   ON Y.SourceAlt_key = O.SourceAlt_Key
                                LEFT JOIN DimIndustry Q   ON X.Industry_AltKey = Q.IndustryAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND A.InvEntityId IN ( SELECT MAX(InvEntityId)  
                                                          FROM InvestmentFinancialDetail_mod 
                                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                                    AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                                    AND NVL(X.Authorisationstatus, 'A') IN ( 'A' )

                                                            GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.EntityKey,A.InvEntityId,A.BranchCode,A.SourceAlt_Key,A.SourceName,A.RefInvID,A.RefIssuerID,A.IssuerName,A.HoldingNature,A.CurrencyAlt_Key,A.CurrencyName,A.CurrencyConvRate,A.BookType,A.BookValue,A.BookValueINR,A.MTMValue,A.MTMValueINR,A.EncumberedMTM,A.AssetClass_AltKey,A.AssetClassName,A.NPIDt,A.TotalProvison,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.DBTDate,A.LatestBSDate,A.Interest_DividendDueDate,A.Interest_DividendDueAmount,A.PartialRedumptionDueDate,A.PartialRedumptionSettledY_N,pANnO,ISIN,InstrumentTypeAlt_Key,InstrumentTypeName,InvestmentNature,Sector,a.Industry_AltKey,IndustryName,ExposureType,SecurityValue,UcifId,FLGDEG,DEGREASON,DPD,FLGUPG,UpgDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'InvestmentFinanacialMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_132 A
                                   WHERE  ( NVL(RefInvID, ' ') LIKE '%' || v_InvID || '%'
                                            AND NVL(RefIssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                            AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                            AND NVL(InstrumentTypeAlt_Key, ' ') LIKE '%' || v_InstrumentTypeAlt_Key || '%'
                                            AND NVL(ISIN, ' ') LIKE '%' || v_ISIN || '%'
                                            AND NVL(pANnO, ' ') LIKE '%' || v_Pan || '%' ) ) 
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
                  IF utils.object_id('TempDB..tt_temp_17320') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_97 ';
                  END IF;
                  DELETE FROM tt_temp20_97;
                  UTILS.IDENTITY_RESET('tt_temp20_97');

                  INSERT INTO tt_temp20_97 ( 
                  	SELECT A.EntityKey ,
                          A.InvEntityId ,
                          A.BranchCode ,
                          A.SourceAlt_Key ,
                          A.SourceName ,
                          A.RefInvID ,
                          A.RefIssuerID ,
                          A.IssuerName ,
                          A.HoldingNature ,
                          A.CurrencyAlt_Key ,
                          A.CurrencyName ,
                          A.CurrencyConvRate ,
                          A.BookType ,
                          A.BookValue ,
                          A.BookValueINR ,
                          A.MTMValue ,
                          A.MTMValueINR ,
                          A.EncumberedMTM ,
                          A.AssetClass_AltKey ,
                          A.AssetClassName ,
                          A.NPIDt ,
                          A.TotalProvison ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.DBTDate ,
                          A.LatestBSDate ,
                          A.Interest_DividendDueDate ,
                          A.Interest_DividendDueAmount ,
                          A.PartialRedumptionDueDate ,
                          A.PartialRedumptionSettledY_N ,
                          pANnO ,
                          ISIN ,
                          InstrumentTypeAlt_Key ,
                          InstrumentTypeName ,
                          InvestmentNature ,
                          Sector ,
                          a.Industry_AltKey ,
                          IndustryName ,
                          ExposureType ,
                          SecurityValue UcifId  ,
                          FLGDEG ,
                          DEGREASON ,
                          DPD ,
                          FLGUPG ,
                          UpgDate 
                  	  FROM ( SELECT A.EntityKey ,
                                   A.InvEntityId ,
                                   Y.BranchCode ,
                                   Y.SourceAlt_key ,
                                   O.SourceName ,
                                   A.RefInvID ,
                                   A.RefIssuerID ,
                                   Y.IssuerName ,
                                   A.HoldingNature ,
                                   A.CurrencyAlt_Key ,
                                   B.CurrencyName ,
                                   A.CurrencyConvRate ,
                                   A.BookType ,
                                   A.BookValue ,
                                   A.BookValueINR ,
                                   A.MTMValue ,
                                   A.MTMValueINR ,
                                   A.EncumberedMTM ,
                                   A.AssetClass_AltKey ,
                                   C.AssetClassName ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,10,p_style=>103) NPIDt  ,
                                   A.TotalProvison ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   --A.DBTDate,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DBTDate,10,p_style=>103) DBTDate  ,
                                   --A.LatestBSDate,
                                   UTILS.CONVERT_TO_VARCHAR2(A.LatestBSDate,10,p_style=>103) LatestBSDate  ,
                                   --A.Interest_DividendDueDate,
                                   UTILS.CONVERT_TO_VARCHAR2(A.Interest_DividendDueDate,10,p_style=>103) Interest_DividendDueDate  ,
                                   A.Interest_DividendDueAmount ,
                                   --A.PartialRedumptionDueDate,
                                   UTILS.CONVERT_TO_VARCHAR2(A.PartialRedumptionDueDate,10,p_style=>103) PartialRedumptionDueDate  ,
                                   A.PartialRedumptionSettledY_N ,
                                   pANnO ,
                                   ISIN ,
                                   InstrumentTypeAlt_Key ,
                                   InstrumentTypeName ,
                                   InvestmentNature ,
                                   Sector ,
                                   x.Industry_AltKey ,
                                   IndustryName ,
                                   ExposureType ,
                                   SecurityValue ,
                                   Y.UcifId ,
                                   (CASE 
                                         WHEN FLGDEG = 'Y' THEN 'Yes'
                                         WHEN FLGDEG = 'N' THEN 'N'   END) FLGDEG  ,
                                   DEGREASON ,
                                   DPD ,
                                   (CASE 
                                         WHEN FLGUPG = 'Y' THEN 'Yes'
                                         WHEN FLGUPG = 'N' THEN 'N'   END) FLGUPG  ,
                                   UpgDate 
                            FROM InvestmentFinancialDetail_mod A
                                   LEFT JOIN InvestmentIssuerDetail_Mod Y   ON A.RefIssuerID = Y.IssuerID
                                   LEFT JOIN InvestmentBasicDetail_mod X   ON A.RefInvID = X.InvID
                                   LEFT JOIN DimCurrency B   ON A.CurrencyAlt_Key = B.CurrencyAlt_Key
                                   LEFT JOIN DimAssetClass C   ON A.AssetClass_AltKey = C.AssetClassAlt_Key
                                   LEFT JOIN DimInstrumentType z   ON x.InstrTypeAlt_Key = z.InstrumentTypeAlt_Key
                                   LEFT JOIN DIMSOURCEDB O   ON Y.SourceAlt_key = O.SourceAlt_Key
                                   LEFT JOIN DimIndustry Q   ON X.Industry_AltKey = Q.IndustryAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND NVL(X.AuthorisationStatus, 'A') = 'A'
                                      AND A.InvEntityId IN ( SELECT MAX(InvEntityId)  
                                                             FROM InvestmentFinancialDetail_mod 
                                                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey
                                                                       AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                                                       AND NVL(x.AuthorisationStatus, 'A') = 'A'
                                                               GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.EntityKey,A.InvEntityId,A.BranchCode,A.SourceAlt_Key,A.SourceName,A.RefInvID,A.RefIssuerID,A.IssuerName,A.HoldingNature,A.CurrencyAlt_Key,A.CurrencyName,A.CurrencyConvRate,A.BookType,A.BookValue,A.BookValueINR,A.MTMValue,A.MTMValueINR,A.EncumberedMTM,A.AssetClass_AltKey,A.AssetClassName,A.NPIDt,A.TotalProvison,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.DBTDate,A.LatestBSDate,A.Interest_DividendDueDate,A.Interest_DividendDueAmount,A.PartialRedumptionDueDate,A.PartialRedumptionSettledY_N,pANnO,ISIN,InstrumentTypeAlt_Key,InstrumentTypeName,InvestmentNature,Sector,a.Industry_AltKey,IndustryName,ExposureType,SecurityValue,UcifId,FLGDEG,DEGREASON,DPD,FLGUPG,UpgDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'InvestmentFinanacialMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_97 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTFINANCIALSEARCHLIST_08092023" TO "ADF_CDR_RBL_STGDB";
