--------------------------------------------------------
--  DDL for Procedure INVESTMENTDETAILSELECT_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" 
--exec InvestmentDetailSelect @CustomerEntityId=601,@CustType=N'',@TimeKey=25999,@BranchCode=N'0',@OperationFlag=2
 --go
 --Sp_helptext InvestmentDetailSelect
 -------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 --exec [InvestmentDetailSelect]  @CustomerEntityID =1001190 	,@TimeKey	=49999	,@BranchCode ='',@OperationFlag =16
 -- =============================================

(
  --DECLARE
  v_PanNo IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT 'RAM' ,
  v_InvID IN VARCHAR2 DEFAULT ' ' ,
  v_InstrTypeAlt_key IN VARCHAR2 DEFAULT ' ' ,
  v_ISIN IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_IssuerEntityID IN NUMBER DEFAULT 0 ,
  v_InvEntityID IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 49999 
)
AS
   v_InvestmentBasic CHAR(1) := 'N';
   v_InvestmentFin CHAR(1) := 'N';
   v_InvestmentIssuer CHAR(1) := 'N';
   v_InvestmentBasicCrMod VARCHAR2(20) := ' ';
   v_InvestmentFinCrMod VARCHAR2(20) := ' ';
   v_InvestmentIssuerCrMod VARCHAR2(20) := ' ';
   v_cursor SYS_REFCURSOR;
   v_FromTimekey NUMBER(10,0);
   v_ToTimekey NUMBER(10,0);
   v_FromDate VARCHAR2(10);
   v_ToDate VARCHAR2(10);
   v_temp NUMBER(1, 0) := 0;

BEGIN

   --UPDATE CustomerBasicDetail SET CustType = 'Borrower' WHERE CustType IS NULL
   /*-- CREATE TABP TABLE FOR SELECT THE DATA*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE utils.object_id('Tempdb..InvestmentDetailSelect') IS NOT NULL;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_InvestmentDetailSelect_4 ';
   END IF;
   DELETE FROM tt_InvestmentDetailSelect_4;
   --select * from tt_InvestmentDetailSelect_4
   /*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
   DBMS_OUTPUT.PUT_LINE(1);
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_InvestmentBasic,
          v_InvestmentBasicCrMod
     FROM InvestmentBasicDetail_mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM InvestmentBasicDetail_mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.InvEntityId = v_InvEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.InvEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.InvEntityId = v_InvEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_InvestmentFin,
          v_InvestmentFinCrMod
     FROM InvestmentFinancialDetail_mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM InvestmentFinancialDetail_mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.InvEntityId = v_InvEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.InvEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.InvEntityId = v_InvEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_InvestmentIssuer,
          v_InvestmentIssuer
     FROM InvestmentIssuerDetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM InvestmentIssuerDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.IssuerEntityId = v_IssuerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.IssuerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.IssuerEntityId = v_IssuerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   ----SELECT 	@CustComm,	@CustRel,	@CustNPA	,@CustOth	,@CustNonFin	,@CustFin  ,@CustBasic
   /*	CUSTOMER BASICDETAIL  */
   --SELECT * FROM tt_InvestmentDetailSelect_4
   DBMS_OUTPUT.PUT_LINE(2);
   IF v_InvestmentBasic = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_InvestmentDetailSelect_4
        ( EntityKey, BranchCode, InvEntityId, IssuerEntityId, ISIN, InstrTypeAlt_Key, InstrumenttypeName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
        ( SELECT A.EntityKey ,
                 A.BranchCode ,
                 A.InvEntityId ,
                 A.IssuerEntityId ,
                 A.ISIN ,
                 A.InstrTypeAlt_Key ,
                 A.InstrName ,
                 A.InvestmentNature ,
                 A.InternalRating ,
                 A.InRatingDate ,
                 A.InRatingExpiryDate ,
                 A.ExRating ,
                 A.ExRatingAgency ,
                 A.ExRatingDate ,
                 A.ExRatingExpiryDate ,
                 A.Sector ,
                 A.Industry_AltKey ,
                 A.ListedStkExchange ,
                 A.ExposureType ,
                 A.SecurityValue ,
                 A.MaturityDt ,
                 A.ReStructureDate ,
                 A.MortgageStatus ,
                 A.NHBStatus ,
                 A.ResiPurpose ,
                 A.AuthorisationStatus ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.CreatedBy ,
                 A.DateCreated ,
                 A.ModifiedBy ,
                 A.DateModified ,
                 A.ApprovedBy ,
                 A.DateApproved 
          FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail A
                 LEFT JOIN DimIndustry H   ON A.Industry_AltKey = H.IndustryAlt_Key
                 LEFT JOIN DimInstrumentType G   ON A.InstrTypeAlt_Key = G.InstrumentTypeAlt_Key
           WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
                    AND A.issuerEntityID = v_IssuerEntityID
                    AND NVL(A.AuthorisationStatus, 'A') = 'A' );

   END;
   END IF;
   IF v_InvestmentBasic = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_InvestmentDetailSelect_4
        ( EntityKey, BranchCode, InvEntityId, IssuerEntityId, ISIN, InstrTypeAlt_Key, InstrumenttypeName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
        ( SELECT A.EntityKey ,
                 A.BranchCode ,
                 A.InvEntityId ,
                 A.IssuerEntityId ,
                 A.ISIN ,
                 A.InstrTypeAlt_Key ,
                 A.InstrName ,
                 A.InvestmentNature ,
                 A.InternalRating ,
                 A.InRatingDate ,
                 A.InRatingExpiryDate ,
                 A.ExRating ,
                 A.ExRatingAgency ,
                 A.ExRatingDate ,
                 A.ExRatingExpiryDate ,
                 A.Sector ,
                 A.Industry_AltKey ,
                 A.ListedStkExchange ,
                 A.ExposureType ,
                 A.SecurityValue ,
                 A.MaturityDt ,
                 A.ReStructureDate ,
                 A.MortgageStatus ,
                 A.NHBStatus ,
                 A.ResiPurpose ,
                 A.AuthorisationStatus ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.CreatedBy ,
                 A.DateCreated ,
                 A.ModifiedBy ,
                 A.DateModified ,
                 A.ApprovedBy ,
                 A.DateApproved 
          FROM InvestmentBasicDetail_mod A
                 LEFT JOIN DimIndustry H   ON A.Industry_AltKey = H.IndustryAlt_Key
                 LEFT JOIN DimInstrumentType G   ON A.InstrTypeAlt_Key = G.InstrumentTypeAlt_Key
                 JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                        FROM InvestmentBasicDetail_mod C
                         WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                  AND C.EffectiveToTimeKey >= v_TimeKey )
                                  AND C.InvEntityId = v_InvEntityID
                                  AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                          GROUP BY C.InvEntityId ) Z   ON z.EntityKey = A.EntityKey
                 AND ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
                 AND ( A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                )
                 AND A.InvEntityId = v_InvEntityID

                 -- LEFT JOIN DIMSOURCEDB DS ON C.SourceSystemAlt_Key=DS.SourceAlt_Key --Sachin
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey );--Sachin 

   END;
   END IF;
   --LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key
   --LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) 
   --AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key			
   --SELECT * FROM tt_InvestmentDetailSelect_4
   /*	Investment FINANCIAL DETAIL */
   DBMS_OUTPUT.PUT_LINE(3);
   IF v_InvestmentFin = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(22222);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, P.ParameterAlt_Key, A.HoldingNature, A.CurrencyAlt_Key, Q.CurrencyName, A.CurrencyConvRate, A.BookType, A.BookValue, A.BookValueINR, A.MTMValue, A.MTMValueINR, A.EncumberedMTM, A.AssetClass_AltKey, R.AssetClassName, A.NPIDt, A.DBTDate, A.LatestBSDate, A.Interest_DividendDueDate, A.Interest_DividendDueAmount, A.PartialRedumptionDueDate, A.PartialRedumptionSettledY_N, A.TotalProvison, A.AuthorisationStatus
      FROM T ,tt_InvestmentDetailSelect_4 T
             JOIN CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A   ON ( A.EffectiveFromTimeKey <= v_TimeKey
             AND A.EffectiveToTimeKey >= v_TimeKey )
             AND T.InvEntityId = A.InvEntityId
             AND NVL(A.AuthorisationStatus, 'A') = 'A'
             LEFT JOIN DimParameter P   ON A.HoldingNature = P.ParameterName
             LEFT JOIN DimCurrency Q   ON A.CurrencyAlt_Key = Q.CurrencyAlt_Key
             LEFT JOIN DimAssetClass R   ON A.AssetClass_AltKey = R.AssetClassAlt_Key ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.Holding_AltKey = src.ParameterAlt_Key,
                                   T.HoldingNature = src.HoldingNature,
                                   T.CurrencyAlt_Key = src.CurrencyAlt_Key,
                                   T.CurrencyName = src.CurrencyName,
                                   T.CurrencyConvRate = src.CurrencyConvRate,
                                   T.BookType = src.BookType,
                                   T.BookValue = src.BookValue,
                                   T.BookValueINR = src.BookValueINR,
                                   T.MTMValue = src.MTMValue,
                                   T.MTMValueINR = src.MTMValueINR,
                                   T.EncumberedMTM = src.EncumberedMTM,
                                   T.AssetClass_AltKey = src.AssetClass_AltKey,
                                   T.AssetClassName = src.AssetClassName,
                                   T.NPIDt = src.NPIDt,
                                   T.DBTDate = src.DBTDate,
                                   T.LatestBSDate = src.LatestBSDate,
                                   T.Interest_DividendDueDate = src.Interest_DividendDueDate,
                                   T.Interest_DividendDueAmount = src.Interest_DividendDueAmount,
                                   T.PartialRedumptionDueDate = src.PartialRedumptionDueDate,
                                   T.PartialRedumptionSettledY_N = src.PartialRedumptionSettledY_N,
                                   T.TotalProvison = src.TotalProvison,
                                   T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   IF v_InvestmentFin = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(23333);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, P.ParameterAlt_Key, A.HoldingNature, A.CurrencyAlt_Key, Q.CurrencyName, A.CurrencyConvRate, A.BookType, A.BookValue, A.BookValueINR, A.MTMValue, A.MTMValueINR, A.EncumberedMTM, A.AssetClass_AltKey, R.AssetClassName, A.NPIDt, A.TotalProvison, A.AuthorisationStatus
      FROM T ,tt_InvestmentDetailSelect_4 T
             JOIN ( SELECT A.InvEntityId ,
                           A.HoldingNature ,
                           A.CurrencyAlt_Key ,
                           A.CurrencyConvRate ,
                           A.BookType ,
                           A.BookValue ,
                           A.BookValueINR ,
                           A.MTMValue ,
                           A.MTMValueINR ,
                           A.EncumberedMTM ,
                           A.AssetClass_AltKey ,
                           A.NPIDt ,
                           A.TotalProvison ,
                           A.AuthorisationStatus 
                    FROM InvestmentFinancialDetail_mod A
                           JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                  FROM InvestmentFinancialDetail_mod A
                                   WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                            AND A.EffectiveToTimeKey >= v_TimeKey )
                                            AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND A.InvEntityId = v_InvEntityID
                                    GROUP BY A.InvEntityId ) C   ON A.EntityKey = C.EntityKey
                           AND ( A.EffectiveFromTimeKey <= v_TimeKey
                           AND A.EffectiveToTimeKey >= v_TimeKey )
                           AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND A.InvEntityId = v_InvEntityID ) A   ON T.InvEntityId = A.InvEntityId
             LEFT JOIN DimParameter P   ON A.HoldingNature = P.ParameterName
             LEFT JOIN DimCurrency Q   ON A.CurrencyAlt_Key = Q.CurrencyAlt_Key
             LEFT JOIN DimAssetClass R   ON A.AssetClass_AltKey = R.AssetClassAlt_Key ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.Holding_AltKey = src.ParameterAlt_Key,
                                   T.HoldingNature = src.HoldingNature,
                                   T.CurrencyAlt_Key = src.CurrencyAlt_Key,
                                   T.CurrencyName = src.CurrencyName,
                                   T.CurrencyConvRate = src.CurrencyConvRate,
                                   T.BookType = src.BookType,
                                   T.BookValue = src.BookValue,
                                   T.BookValueINR = src.BookValueINR,
                                   T.MTMValue = src.MTMValue,
                                   T.MTMValueINR = src.MTMValueINR,
                                   T.EncumberedMTM = src.EncumberedMTM,
                                   T.AssetClass_AltKey = src.AssetClass_AltKey,
                                   T.AssetClassName = src.AssetClassName,
                                   T.NPIDt = src.NPIDt,
                                   T.TotalProvison = src.TotalProvison,
                                   T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   /*	Issuer DETAIL */
   DBMS_OUTPUT.PUT_LINE(3);
   IF v_InvestmentFin = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(22222);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, A.IssuerID, A.IssuerName, A.IssuerAccpRating, A.IssuerAccpRatingDt, A.IssuerRatingAgency, A.Ref_Txn_Sys_Cust_ID, A.Issuer_Category_Code, A.GrpEntityOfBank, A.AuthorisationStatus
      FROM T ,tt_InvestmentDetailSelect_4 T
             JOIN CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail A   ON ( A.EffectiveFromTimeKey <= v_TimeKey
             AND A.EffectiveToTimeKey >= v_TimeKey )
             AND T.IssuerEntityId = A.IssuerEntityId
             AND NVL(A.AuthorisationStatus, 'A') = 'A' ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IssuerID = src.IssuerID,
                                   T.IssuerName = src.IssuerName,
                                   T.IssuerAccpRating = src.IssuerAccpRating,
                                   T.IssuerAccpRatingDt = src.IssuerAccpRatingDt,
                                   T.IssuerRatingAgency = src.IssuerRatingAgency,
                                   T.Ref_Txn_Sys_Cust_ID = src.Ref_Txn_Sys_Cust_ID,
                                   T.Issuer_Category_Code = src.Issuer_Category_Code,
                                   T.GrpEntityOfBank = src.GrpEntityOfBank,
                                   T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   IF v_InvestmentFin = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(23333);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, A.IssuerID, A.IssuerName, A.IssuerAccpRating, A.IssuerAccpRatingDt, A.IssuerRatingAgency, A.Ref_Txn_Sys_Cust_ID, A.Issuer_Category_Code, A.GrpEntityOfBank, A.AuthorisationStatus
      FROM T ,tt_InvestmentDetailSelect_4 T
             JOIN ( SELECT A.IssuerEntityId ,
                           A.IssuerID ,
                           A.IssuerName ,
                           A.IssuerAccpRating ,
                           A.IssuerAccpRatingDt ,
                           A.IssuerRatingAgency ,
                           A.Ref_Txn_Sys_Cust_ID ,
                           A.Issuer_Category_Code ,
                           A.GrpEntityOfBank ,
                           A.AuthorisationStatus 
                    FROM InvestmentIssuerDetail_Mod A
                           JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                  FROM InvestmentIssuerDetail_Mod A
                                   WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                            AND A.EffectiveToTimeKey >= v_TimeKey )
                                            AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND A.IssuerEntityId = v_IssuerEntityID
                                    GROUP BY A.IssuerEntityId ) C   ON A.EntityKey = C.EntityKey
                           AND ( A.EffectiveFromTimeKey <= v_TimeKey
                           AND A.EffectiveToTimeKey >= v_TimeKey )
                           AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND A.IssuerEntityId = v_IssuerEntityId ) A   ON T.IssuerEntityId = A.IssuerEntityId ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IssuerID = src.IssuerID,
                                   T.IssuerName = src.IssuerName,
                                   T.IssuerAccpRating = src.IssuerAccpRating,
                                   T.IssuerAccpRatingDt = src.IssuerAccpRatingDt,
                                   T.IssuerRatingAgency = src.IssuerRatingAgency,
                                   T.Ref_Txn_Sys_Cust_ID = src.Ref_Txn_Sys_Cust_ID,
                                   T.Issuer_Category_Code = src.Issuer_Category_Code,
                                   T.GrpEntityOfBank = src.GrpEntityOfBank,
                                   T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(8);
   IF 'Y' IN ( v_InvestmentBasic,v_InvestmentFin,v_InvestmentIssuer )
    THEN
    DECLARE
      v_CreateModifyBy VARCHAR2(20);

   BEGIN
      SELECT CrModBy 

        INTO v_CreateModifyBy
        FROM ( SELECT v_iNVESTMENTBasicCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_iNVESTMENTFinCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_iNVESTMENTissuerCrMod CrModBy  
                 FROM DUAL  ) A
       WHERE  NVL(CrModBy, ' ') <> ' ';
      UPDATE tt_InvestmentDetailSelect_4
         SET IsMainTable = 'N',
             CreateModifyBy = v_CreateModifyBy;

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_InvestmentDetailSelect_4  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   SELECT MAX(TimeKey)  

     INTO v_FromTimekey
     FROM ( SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
             WHERE  InvEntityId = v_InvEntityId
            UNION 
            SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail 
             WHERE  InvEntityId = v_InvEntityId
            UNION 
            SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
             WHERE  IssuerEntityId = v_IssuerEntityId ) K;
   SELECT Timekey 

     INTO v_ToTimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --Select @FromTimekey
   --select @ToTimeKey
   SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 

     INTO v_FromDate
     FROM SysDayMatrix 
    WHERE  TimeKey = v_FromTimekey;
   SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 

     INTO v_ToDate
     FROM SysDayMatrix 
    WHERE  TimeKey = v_ToTimeKey;
   --	if(@OperationFlag = 2)
   --select @FromDate,@ToDate
   --if exists(select EffectiveFromTimekey from tt_InvestmentDetailSelect_4 )

   BEGIN
      OPEN  v_cursor FOR
         SELECT TimeKey ,
                UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) AvailableDate  ,
                v_FromDate MinDate  ,
                v_ToDate MaxDate  
           FROM SysDayMatrix 
          WHERE  TimeKey BETWEEN v_FromTimeKey AND v_ToTimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT EffectiveFromTimekey 
                      FROM tt_InvestmentDetailSelect_4  );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      --Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select EffectiveFromTimekey from tt_InvestmentDetailSelect_4)
      --Select TimeKey
      --,Convert(varchar(10),[Date],103) as [AvailableDate]
      --,@FromDate as MinDate
      --,@ToDate as MaxDate
      --from SysDayMatrix SD
      --inner join tt_InvestmentDetailSelect_4 c
      --  on C.EffectiveFromTimeKey= SD.TimeKey
      -- select @FromDate
      SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 

        INTO v_FromDate
        FROM SysDayMatrix 
       WHERE  TimeKey = ( SELECT MAX(EffectiveFromTimekey)  
                          FROM tt_InvestmentDetailSelect_4  );
      OPEN  v_cursor FOR
         SELECT TimeKey ,
                UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) AvailableDate  ,
                v_FromDate MinDate  ,
                v_ToDate MaxDate  ,
                'DateData' TableName  
           FROM SysDayMatrix 
          WHERE  TimeKey BETWEEN v_FromTimeKey AND v_ToTimeKey 
           FETCH FIRST 1 ROWS ONLY ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--else
      --BEGIN
      --Select 
      --TimeKey
      --,Convert(varchar(10),[Date],103) as [AvailableDate]
      --,@FromDate as MinDate
      --,@ToDate as MaxDate
      --from SysDayMatrix
      --where TimeKey Between @FromTimeKey AND @ToTimeKey
      --END
      --	exec InvestmentDetailSelect @CustomerEntityId=1001884,@CustType=N'BORROWER',@TimeKey=24583,@BranchCode=N'0',@OperationFlag=2

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTDETAILSELECT_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
