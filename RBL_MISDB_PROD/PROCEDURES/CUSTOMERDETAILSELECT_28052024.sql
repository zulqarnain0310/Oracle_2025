--------------------------------------------------------
--  DDL for Procedure CUSTOMERDETAILSELECT_28052024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" 
--exec CustomerDetailSelect @CustomerEntityId=601,@CustType=N'',@TimeKey=25999,@BranchCode=N'0',@OperationFlag=2
 --go
 --Sp_helptext CustomerDetailSelect
 -------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 --exec [CustomerDetailSelect]  @CustomerEntityID =1001190 	,@TimeKey	=49999	,@BranchCode ='',@OperationFlag =16
 -- =============================================

(
  --DECLARE
  v_CustomerEntityID IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 49999 ,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_CustType IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_CustBasic CHAR(1) := 'N';
   v_CustFin CHAR(1) := 'N';
   v_CustNonFin CHAR(1) := 'N';
   v_CustOth CHAR(1) := 'N';
   v_CustNPA CHAR(1) := 'N';
   v_CustRel CHAR(1) := 'N';
   v_CustComm CHAR(1) := 'N';
   v_Profession CHAR(1) := 'N';
   v_CustBasicCrMod VARCHAR2(20) := ' ';
   v_CustFinCrMod VARCHAR2(20) := ' ';
   v_CustNonFinCrMod VARCHAR2(20) := ' ';
   v_CustOthCrMod VARCHAR2(20) := ' ';
   v_CustNPACrMod VARCHAR2(20) := ' ';
   v_CustRelCrMod VARCHAR2(20) := ' ';
   v_CustCommCrMod VARCHAR2(20) := ' ';
   v_ProfessionalMod CHAR(1);
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
       WHERE utils.object_id('Tempdb..CustomerDetailSelect') IS NOT NULL;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerDetailSelect_8 ';
   END IF;
   DELETE FROM tt_CustomerDetailSelect_8;
   --,BorrowerGroupAlt_key         INT
   --,LEI							varchar(500)
   --SMALLINT,
   --SMALLINT,	
   ------
   ---PermiNatureID
   --PermiNatureID			    smallint,  --Triloki Added 23/02/2017
   --,DefaultReason1Alt_Key		smallint
   --,DefaultReason2Alt_Key       smallint
   --select * from tt_CustomerDetailSelect_8
   /*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
   DBMS_OUTPUT.PUT_LINE(1);
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustBasic,
          v_CustBasicCrMod
     FROM CustomerBasicDetail_Mod C
            JOIN ( SELECT MAX(C.Customer_Key)  Customer_Key  
                   FROM CustomerBasicDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.Customer_Key = C.Customer_Key
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustFin,
          v_CustFinCrMod
     FROM AdvCustFinancialDetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustFinancialDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustNonFin,
          v_CustNonFinCrMod
     FROM AdvCustNonFinancialDetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustNonFinancialDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustOth,
          v_CustOthCrMod
     FROM AdvCustOtherDetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustOtherDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustNPA,
          v_CustNPACrMod
     FROM AdvCustNPAdetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustNPAdetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustRel,
          v_CustRelCrMod
     FROM AdvCustRelationship_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustRelationship_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityID 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' ,
          NVL(C.ModifiedBy, C.CreatedBy) 

     INTO v_CustComm,
          v_CustCommCrMod
     FROM AdvCustCommunicationDetail_Mod C
            JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                   FROM AdvCustCommunicationDetail_Mod C
                    WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey )
                             AND C.CustomerEntityId = v_CustomerEntityID
                             AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                     GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
            AND ( C.EffectiveFromTimeKey <= v_TimeKey
            AND C.EffectiveToTimeKey >= v_TimeKey )
            AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
           )
            AND C.CustomerEntityId = v_CustomerEntityId 
     FETCH FIRST 1 ROWS ONLY;
   ----SELECT 	@CustComm,	@CustRel,	@CustNPA	,@CustOth	,@CustNonFin	,@CustFin  ,@CustBasic
   /*	CUSTOMER BASICDETAIL  */
   --SELECT * FROM tt_CustomerDetailSelect_8
   DBMS_OUTPUT.PUT_LINE(2);
   IF v_CustBasic = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_CustomerDetailSelect_8
        ( CustomerEntityId, CustomerID, UCIF_ID, Remark, ConstitutionAlt_Key, CustSalutationAlt_Key, CustomerName, ParentBranchCode, CustomerSinceDt, ReligionAlt_Key, CasteAlt_Key, OccupationAlt_Key, FarmerCatAlt_Key, CurrentAssetClassAlt_Key, AuthorisationStatus, AlwaysSTDNPAStatus, SourceSystemAlt_Key --Sachin
       )
        ( 
          --CustType,ServProviderAlt_Key,

          --NonCustTypeAlt_Key,

          --ServProvider,NonCustType
          SELECT C.CustomerEntityId ,
                 C.CustomerID ,
                 C.UCIF_ID ,
                 C.Remark ,
                 DC.ConstitutionName ,
                 C.CustSalutationAlt_Key ,
                 C.CustomerName ,
                 C.ParentBranchCode ,--, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)

                 CustomerSinceDt ,
                 --, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)
                 NULLIF(C.ReligionAlt_Key, 97) ,
                 NULLIF(C.CasteAlt_Key, 97) ,
                 NULLIF(C.OccupationAlt_Key, 111) CustomerSinceDt  ,
                 NULLIF(C.FarmerCatAlt_Key, 97) ,
                 --,ISNULL(C.AssetClass,1)
                 --,ISNULL(DA.AssetClassName,'STANDARD') AS CurrentAssetClassAlt_Key
                 --Added by Prashant--18042024--------
                 CASE 
                      WHEN ES.CustomerID IS NOT NULL THEN 'NPA Charge OFF'
                 ELSE NVL(DA.AssetClassName, 'STANDARD')
                    END CurrentAssetClassAlt_Key  ,
                 C.AuthorisationStatus ,
                 C.AssetClass ,
                 DS.SourceName --Sachin


          --,C.CustType,C.ServProviderAlt_Key,C.NonCustTypeAlt_Key,

          --,N.LegalNatureOfActivityName,M.LegalMiscSuitName
          FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail C
                 LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail AC   ON AC.CustomerEntityId = C.CustomerEntityId
                 AND AC.EffectiveFromTimeKey <= v_TimeKey
                 AND AC.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN DimConstitution DC   ON DC.ConstitutionAlt_Key = C.ConstitutionAlt_Key
                 AND DC.EffectiveFromTimeKey <= v_TimeKey
                 AND DC.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AC.Cust_AssetClassAlt_Key
                 LEFT JOIN DIMSOURCEDB DS   ON C.SourceSystemAlt_Key = DS.SourceAlt_Key --Sachin  

                 AND DS.EffectiveFromTimeKey <= v_TimeKey
                 AND DS.EffectiveToTimeKey >= v_TimeKey --Sachin  

                 LEFT JOIN ExceptionFinalStatusType ES   ON C.CustomerId = ES.CustomerID
                 AND ES.EffectiveFromTimeKey <= v_TimeKey
                 AND ES.EffectiveToTimeKey >= v_TimeKey
                 AND ES.StatusType = 'Charge Off'

          --LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key

          --LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key
          WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                   AND C.EffectiveToTimeKey >= v_TimeKey )
                   AND C.CustomerEntityID = v_CustomerEntityID
                   AND NVL(C.AuthorisationStatus, 'A') = 'A' );

   END;
   END IF;
   --AND CustType=@CustType  --COMMENT BY HAMID ON 18 MAY 2018
   --AND ISNULL(CustType,'') =ISNULL(@CustType,'')
   --SELECT * FROM tt_CustomerDetailSelect_8
   IF v_CustBasic = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_CustomerDetailSelect_8
        ( CustomerEntityId, CustomerID, UCIF_ID, Remark, ConstitutionAlt_Key, EffectiveFromTimeKey, CustSalutationAlt_Key, CustomerName, ParentBranchCode, CustomerSinceDt, ReligionAlt_Key, CasteAlt_Key, OccupationAlt_Key, FarmerCatAlt_Key, CurrentAssetClassAlt_Key, GuardianType, GaurdianSalutationAlt_Key, AuthorisationStatus, AlwaysSTDNPAStatus, SourceSystemAlt_Key --Sachin
       )
        ( 
          --,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,ServProvider,NonCustType
          SELECT C.CustomerEntityId ,
                 C.CustomerId ,
                 C.UCIF_ID ,
                 C.Remark ,
                 DC.ConstitutionName ,
                 C.EffectiveFromTimeKey ,
                 C.CustSalutationAlt_Key ,
                 C.CustomerName ,
                 C.ParentBranchCode ,
                 --, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)
                 CustomerSinceDt ,
                 NULLIF(C.ReligionAlt_Key, 97) ,
                 NULLIF(C.CasteAlt_Key, 97) ,
                 NULLIF(C.OccupationAlt_Key, 111) ,
                 NULLIF(C.FarmerCatAlt_Key, 97) ,
                 --C.AssetClass
                 DA.AssetClassName CurrentAssetClassAlt_Key  ,
                 C.GuardianType ,
                 C.GaurdianSalutationAlt_Key ,
                 C.AuthorisationStatus ,
                 C.AssetClass ,
                 DS.SourceName --Sachin


          --,C.CustType,C.ServProviderAlt_Key,C.NonCustTypeAlt_Key,N.LegalNatureOfActivityName,M.LegalMiscSuitName
          FROM CustomerBasicDetail_Mod C
                 LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail AC   ON AC.CustomerEntityId = C.CustomerEntityId
                 AND AC.EffectiveFromTimeKey <= v_TimeKey
                 AND AC.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN DimConstitution DC   ON DC.ConstitutionAlt_Key = C.ConstitutionAlt_Key
                 AND DC.EffectiveFromTimeKey <= v_TimeKey
                 AND DC.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AC.Cust_AssetClassAlt_Key
                 JOIN ( SELECT MAX(C.Customer_Key)  Customer_Key  
                        FROM CustomerBasicDetail_Mod C
                         WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                  AND C.EffectiveToTimeKey >= v_TimeKey )
                                  AND C.CustomerEntityId = v_CustomerEntityID
                                  AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )


                        --AND CustType=@CustType	
                        GROUP BY C.CustomerEntityId ) A   ON A.Customer_Key = C.Customer_Key
                 AND ( C.EffectiveFromTimeKey <= v_TimeKey
                 AND C.EffectiveToTimeKey >= v_TimeKey )
                 AND ( C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                )
                 AND C.CustomerEntityId = v_CustomerEntityID
                 LEFT JOIN DIMSOURCEDB DS   ON C.SourceSystemAlt_Key = DS.SourceAlt_Key --Sachin

                 AND DS.EffectiveFromTimeKey <= v_TimeKey
                 AND DS.EffectiveToTimeKey >= v_TimeKey );--Sachin 

   END;
   END IF;
   --LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key
   --LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) 
   --AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key			
   --SELECT * FROM tt_CustomerDetailSelect_8
   /*	CUST FINANCIAL DETAIL */
   DBMS_OUTPUT.PUT_LINE(3);
   IF v_CustFin = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(22222);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, DU.UserLocation, C.AuthorisationStatus
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN CurDat_RBL_MISDB_PROD.ADVCUSTFINANCIALDETAIL C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey )
             AND T.CustomerEntityId = C.CustomerEntityId
             AND BranchCode = v_BranchCode
             AND NVL(C.AuthorisationStatus, 'A') = 'A'
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustFinCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET
      --T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
       T.Userlocation = src.UserLocation,
       T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   IF v_CustFin = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(23333);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, DU.UserLocation, C.AuthorisationStatus
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN ( SELECT C.Cust_AssetClassAlt_Key ,
                           C.CustomerEntityId ,
                           C.AuthorisationStatus ,
                           C.CreatedBy ,
                           C.ModifiedBy 
                    FROM AdvCustFinancialDetail_Mod C
                           JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                                  FROM AdvCustFinancialDetail_Mod C
                                   WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                            AND C.EffectiveToTimeKey >= v_TimeKey )
                                            AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND C.CustomerEntityId = v_CustomerEntityID
                                            AND C.BranchCode = v_BranchCode
                                    GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
                           AND ( C.EffectiveFromTimeKey <= v_TimeKey
                           AND C.EffectiveToTimeKey >= v_TimeKey )
                           AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND C.CustomerEntityId = v_CustomerEntityID
                           AND C.BranchCode = v_BranchCode ) C   ON T.CustomerEntityId = C.CustomerEntityId
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustFinCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET
      --T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
       T.Userlocation = src.UserLocation,
       T.AuthorisationStatus = src.AuthorisationStatus;

   END;
   END IF;
   /* ProfessionalDetail */
   /*	CUST NPA DETAIL */
   DBMS_OUTPUT.PUT_LINE(4);
   IF v_CustNPA = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(22222222);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, CASE 
      WHEN ES.CustomerID IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(ES.StatusDate,10,p_style=>103)
      ELSE UTILS.CONVERT_TO_VARCHAR2(C.NPADt,10,p_style=>103)
         END AS pos_2, UTILS.CONVERT_TO_VARCHAR2(C.DbtDt,10,p_style=>103) AS pos_3, C.StaffAccountability
      --T.WillfulDefault=C.WillfulDefault,
       --T.WillfulDefaultReasonAlt_Key=C.WillfulDefaultReasonAlt_Key,
       --T.WillfulRemark=C.WillfulRemark	,
      , DU.UserLocation, C.AuthorisationStatus
      --,T.WillfulDefaultDate=CONVERT(VARCHAR(10),C.WillfulDefaultDate,103)
       --,T.DefaultReason1Alt_Key=C.DefaultReason1Alt_Key
       --,T.DefaultReason2Alt_Key=C.DefaultReason2Alt_Key
      , C.NPA_Reason
      FROM T ,tt_CustomerDetailSelect_8 T
             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey )
             AND T.CustomerEntityId = C.CustomerEntityId
             AND NVL(C.AuthorisationStatus, 'A') = 'A'
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustNPACrMod
           --Added by Prashant--18042024--------

             LEFT JOIN ExceptionFinalStatusType ES   ON T.CustomerID = ES.CustomerID
             AND ES.EffectiveFromTimeKey <= v_TimeKey
             AND ES.EffectiveToTimeKey >= v_TimeKey
             AND ES.StatusType = 'Charge Off' ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET
      --T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
       --T.FCRA_YN=C.FCRA_YN,
       --T.NPA_Date=convert(varchar(10),C.NPADt,103),
       --Added by Prashant--18042024--------
       T.NPA_Date = pos_2,
       T.DbtDt = pos_3,
       T.StaffAccountability = src.StaffAccountability,
       T.Userlocation = src.UserLocation,
       T.AuthorisationStatus = src.AuthorisationStatus,
       T.NPA_Reason = src.NPA_Reason;

   END;
   END IF;
   IF v_CustNPA = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(2);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.FCRA_YN, UTILS.CONVERT_TO_VARCHAR2(C.NPADt,10,p_style=>103) AS pos_3, C.StaffAccountability, C.WillfulDefault, C.WillfulDefaultReasonAlt_Key, C.WillfulRemark, DU.UserLocation, C.AuthorisationStatus, UTILS.CONVERT_TO_VARCHAR2(C.WillfulDefaultDate,10,p_style=>103) AS pos_10, C.NPA_Reason
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN ( SELECT C.Cust_AssetClassAlt_Key ,
                           C.CustomerEntityId ,
                           C.NPADt ,
                           C.FCRA_YN ,--as FCRAlt_key

                           C.StaffAccountability ,
                           C.WillfulDefault ,
                           C.WillfulDefaultDate ,
                           C.WillfulDefaultReasonAlt_Key ,
                           C.WillfulRemark ,
                           C.AuthorisationStatus ,
                           C.CreatedBy ,
                           C.ModifiedBy ,
                           A.NPA_Reason --C.DefaultReason1Alt_Key,C.DefaultReason2Alt_Key 

                    FROM AdvCustNPAdetail_Mod C
                           JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                                  FROM AdvCustNPAdetail_Mod C
                                   WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                            AND C.EffectiveToTimeKey >= v_TimeKey )
                                            AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND C.CustomerEntityId = v_CustomerEntityID
                                    GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
                           AND ( C.EffectiveFromTimeKey <= v_TimeKey
                           AND C.EffectiveToTimeKey >= v_TimeKey )
                           AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND C.CustomerEntityId = v_CustomerEntityID ) C   ON T.CustomerEntityId = C.CustomerEntityId
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustNPACrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET
      --T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
       T.FCRA_YN = src.FCRA_YN,
       T.NPA_Date
       --T.DbtDt=convert(varchar(10),C.DbtDt,103),
        = pos_3,
       T.StaffAccountability = src.StaffAccountability,
       T.WillfulDefault = src.WillfulDefault,
       T.WillfulDefaultReasonAlt_Key = src.WillfulDefaultReasonAlt_Key,
       T.WillfulRemark = src.WillfulRemark,
       T.Userlocation = src.UserLocation,
       T.AuthorisationStatus = src.AuthorisationStatus,
       T.WillfulDefaultDate
       --,T.DefaultReason1Alt_Key=C.DefaultReason1Alt_Key
        --,T.DefaultReason2Alt_Key=C.DefaultReason2Alt_Key
        = pos_10,
       T.NPA_Reason = src.NPA_Reason;

   END;
   END IF;
   /*	CUST OTHER DETAIL */
   DBMS_OUTPUT.PUT_LINE(5);
   IF v_CustOth = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(4444444444);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.IsPetitioner, C.SplCatg1Alt_Key --SPL_CatgAlt_Key1	
      , C.SplCatg2Alt_Key --SPL_CatgAlt_Key2	
      , C.SplCatg3Alt_Key --SPL_CatgAlt_Key3	
      , C.SplCatg4Alt_Key --SPL_CatgAlt_Key4	
      , C.UnderLitigation, C.IsEmployee, C.PermiNatureID, C.BorrUnitFunct, UTILS.CONVERT_TO_VARCHAR2(C.DtofClosure,10,p_style=>103) AS pos_11, C.NonCoopBorrower, C.ArbiAgreement, C.TransThroughUs, C.CutBackArrangement, C.BankingArrangement, C.MemberBanksNo, C.TotalConsortiumAmt, UTILS.CONVERT_TO_VARCHAR2(C.ROC_CFCReportDate,10,p_style=>103) AS pos_19, C.ROC_ChargeFV, UTILS.CONVERT_TO_VARCHAR2(C.ROC_ChargeFVDt,10,p_style=>103) AS pos_21, C.ROC_ChargeRemark, C.ROC_Securities, C.ROC_Cover, UTILS.CONVERT_TO_VARCHAR2(C.ROC_CoveredDt,10,p_style=>103) AS pos_25, C.ChargeFiledWith, UTILS.CONVERT_TO_VARCHAR2(C.FiledDt,20,p_style=>103) AS pos_27, C.EmployeeID, C.EmployeeType, DG.DesignationName, C.Placeofposting, UTILS.CONVERT_TO_VARCHAR2(C.LPersonalConDate,10,p_style=>103) AS pos_32, C.LPersonalConDtls, UTILS.CONVERT_TO_VARCHAR2(C.RecallNoticeDate,10,p_style=>103) AS pos_34, C.RecallNoticeModeID, UTILS.CONVERT_TO_VARCHAR2(C.LegalAuditDate,10,p_style=>103) AS pos_36, C.IrregularityPending, UTILS.CONVERT_TO_VARCHAR2(C.IrregularityRectiDate,10,p_style=>103) AS pos_38, C.FraudAccoStatus, DU.UserLocation, C.AuthorisationStatus, C.GradeScaleAlt_Key, DP.ParameterName, C.FMRNO, UTILS.CONVERT_TO_VARCHAR2(C.FMRDate,10,p_style=>103) AS pos_45, C.FraudNatureRemark, C.GroupAlt_key
      --,T.LEI = C.LEI

      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey )
             AND T.CustomerEntityId = C.CustomerEntityId
             AND C.CustomerEntityId = v_CustomerEntityID
             AND NVL(C.AuthorisationStatus, 'A') = 'A'
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustOthCrMod
             LEFT JOIN DimParameter DP   ON DP.ParameterAlt_Key = C.GradeScaleAlt_Key
             AND DP.DimParameterName = 'DimGrade'
             LEFT JOIN DimDesignation DG   ON ( DG.EffectiveFromTimeKey <= v_TimeKey
             AND DG.EffectiveToTimeKey >= v_TimeKey )
             AND DG.DesignationName = C.Designation ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IsPetitioner = src.IsPetitioner,
                                   T.splCatg1Alt_Key = src.SplCatg1Alt_Key,
                                   T.splCatg2Alt_Key = src.SplCatg2Alt_Key,
                                   T.splCatg3Alt_Key = src.SplCatg3Alt_Key,
                                   T.splCatg4Alt_Key = src.SplCatg4Alt_Key,
                                   T.UnderLitigation = src.UnderLitigation,
                                   T.IsEmployee = src.IsEmployee,
                                   T.LegalActionProposed = src.PermiNatureID,
                                   T.BorrUnitFunct = src.BorrUnitFunct,
                                   T.DtofClosure = pos_11,
                                   T.NonCoopBorrower = src.NonCoopBorrower,
                                   T.ArbiAgreement = src.ArbiAgreement,
                                   T.TransThroughUs = src.TransThroughUs,
                                   T.CutBackArrangement = src.CutBackArrangement,
                                   T.BankingArrangement = src.BankingArrangement,
                                   T.MemberBanksNo = src.MemberBanksNo,
                                   T.TotalConsortiumAmt = src.TotalConsortiumAmt,
                                   T.ROC_CFCReportDate = pos_19,
                                   T.ROC_ChargeFV = src.ROC_ChargeFV,
                                   T.ROC_ChargeFVDt = pos_21,
                                   T.ROC_ChargeRemark = src.ROC_ChargeRemark,
                                   T.ChargeFiledwithROCRemark2 = src.ROC_Securities,
                                   T.ROC_Cover = src.ROC_Cover,
                                   T.ROCCoveredCertificateDate = pos_25,
                                   T.ChargeFiledWith = src.ChargeFiledWith,
                                   T.FiledDt = pos_27,
                                   T.EmployeeID = src.EmployeeID,
                                   T.EmployeeType = src.EmployeeType,
                                   T.Designation = src.DesignationName,
                                   T.Placeofposting = src.Placeofposting,
                                   T.LPersonalConDate = pos_32,
                                   T.LPersonalConDtls = src.LPersonalConDtls,
                                   T.RecallNoticeDate = pos_34,
                                   T.RecallNoticeModeID = src.RecallNoticeModeID,
                                   T.LegalAuditDate = pos_36,
                                   T.IrregularityPending = src.IrregularityPending,
                                   T.IrregularityRectiDate = pos_38,
                                   T.FraudAccoStatus = src.FraudAccoStatus,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.GradeScaleAlt_Key = src.GradeScaleAlt_Key,
                                   T.Grade = src.ParameterName,
                                   T.FMRNO = src.FMRNO,
                                   T.FMRDate = pos_45,
                                   T.FraudNatureRemark = src.FraudNatureRemark,
                                   T.BorrowerGroupAlt_key = src.GroupAlt_key;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE('abc');
   IF v_CustOth = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(4);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.IsPetitioner, C.SplCatg1Alt_Key, C.SplCatg2Alt_Key, C.SplCatg3Alt_Key, C.SplCatg4Alt_Key, C.UnderLitigation, C.IsEmployee, C.PermiNatureID, C.BorrUnitFunct, UTILS.CONVERT_TO_VARCHAR2(C.DtofClosure,10,p_style=>103) AS pos_11, C.NonCoopBorrower, C.ArbiAgreement, C.TransThroughUs, C.CutBackArrangement, C.BankingArrangement, C.MemberBanksNo, C.TotalConsortiumAmt, UTILS.CONVERT_TO_VARCHAR2(C.ROC_CFCReportDate,10,p_style=>103) AS pos_19, C.ROC_ChargeFV, UTILS.CONVERT_TO_VARCHAR2(C.ROC_ChargeFVDt,10,p_style=>103) AS pos_21, C.ROC_ChargeRemark, C.ROC_Securities, C.ROC_Cover, UTILS.CONVERT_TO_VARCHAR2(C.ROC_CoveredDt,10,p_style=>103) AS pos_25, C.ChargeFiledWith, UTILS.CONVERT_TO_VARCHAR2(C.FiledDt,20,p_style=>103) AS pos_27, C.EmployeeID, C.EmployeeType, DG.DesignationName, C.Placeofposting, UTILS.CONVERT_TO_VARCHAR2(C.LPersonalConDate,10,p_style=>103) AS pos_32, C.LPersonalConDtls, UTILS.CONVERT_TO_VARCHAR2(C.RecallNoticeDate,10,p_style=>103) AS pos_34, C.RecallNoticeModeID, UTILS.CONVERT_TO_VARCHAR2(C.LegalAuditDate,10,p_style=>103) AS pos_36, C.IrregularityPending, UTILS.CONVERT_TO_VARCHAR2(C.IrregularityRectiDate,10,p_style=>103) AS pos_38, C.FraudAccoStatus, DU.UserLocation, C.AuthorisationStatus, C.GradeScaleAlt_Key, DP.ParameterName, C.FMRNO, UTILS.CONVERT_TO_VARCHAR2(C.FMRDate,10,p_style=>103) AS pos_45, C.FraudNatureRemark, C.BorrowerGroupAlt_key
      --,T.LEI = C.LEI

      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN ( SELECT C.CustomerEntityId ,
                           C.IsPetitioner ,
                           C.SplCatg1Alt_Key ,
                           C.SplCatg2Alt_Key ,
                           C.SplCatg3Alt_Key ,
                           C.SplCatg4Alt_Key ,
                           C.UnderLitigation ,
                           C.IsEmployee ,
                           C.PermiNatureID ,
                           C.BorrUnitFunct ,
                           C.DtofClosure ,
                           C.NonCoopBorrower ,
                           C.ArbiAgreement ,
                           C.TransThroughUs ,
                           C.CutBackArrangement ,
                           C.BankingArrangement ,
                           C.MemberBanksNo ,
                           C.TotalConsortiumAmt ,
                           C.ROC_CFCReportDate ,
                           C.ROC_ChargeFV ,
                           C.ROC_ChargeFVDt ,
                           C.ROC_ChargeRemark ,
                           C.ROC_Securities ,
                           C.ROC_Cover ,
                           C.ROC_CoveredDt ,
                           C.ChargeFiledWith ,
                           C.FiledDt ,
                           C.EmployeeID ,
                           C.EmployeeType ,
                           C.Designation ,
                           C.Placeofposting ,
                           C.LPersonalConDate ,
                           C.LPersonalConDtls ,
                           C.RecallNoticeDate ,
                           C.RecallNoticeModeID ,
                           C.LegalAuditDate ,
                           C.IrregularityPending ,
                           C.IrregularityRectiDate ,
                           C.FraudAccoStatus ,
                           C.AuthorisationStatus ,
                           C.CreatedBy ,
                           C.ModifiedBy ,
                           C.GradeScaleAlt_Key ,
                           C.FMRNO ,
                           C.FMRDate ,
                           C.FraudNatureRemark ,
                           C.GroupAlt_Key BorrowerGroupAlt_Key  
                    FROM AdvCustOtherDetail_Mod C
                           JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                                  FROM AdvCustOtherDetail_Mod C
                                   WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                            AND C.EffectiveToTimeKey >= v_TimeKey )
                                            AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND C.CustomerEntityId = v_CustomerEntityID
                                    GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
                           AND ( C.EffectiveFromTimeKey <= v_TimeKey
                           AND C.EffectiveToTimeKey >= v_TimeKey )
                           AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND C.CustomerEntityId = v_CustomerEntityID ) C   ON T.CustomerEntityId = C.CustomerEntityId
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustOthCrMod
             LEFT JOIN DimParameter DP   ON DP.ParameterAlt_Key = C.GradeScaleAlt_Key
             AND DP.DimParameterName = 'DimGrade'
             LEFT JOIN DimDesignation DG   ON ( DG.EffectiveFromTimeKey <= v_TimeKey
             AND DG.EffectiveToTimeKey >= v_TimeKey )
             AND DG.DesignationName = C.Designation ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IsPetitioner = src.IsPetitioner,
                                   T.splCatg1Alt_Key = src.SplCatg1Alt_Key,
                                   T.splCatg2Alt_Key = src.SplCatg2Alt_Key,
                                   T.splCatg3Alt_Key = src.SplCatg3Alt_Key,
                                   T.splCatg4Alt_Key = src.SplCatg4Alt_Key,
                                   T.UnderLitigation = src.UnderLitigation,
                                   T.IsEmployee = src.IsEmployee,
                                   T.LegalActionProposed = src.PermiNatureID,
                                   T.BorrUnitFunct = src.BorrUnitFunct,
                                   T.DtofClosure = pos_11,
                                   T.NonCoopBorrower = src.NonCoopBorrower,
                                   T.ArbiAgreement = src.ArbiAgreement,
                                   T.TransThroughUs = src.TransThroughUs,
                                   T.CutBackArrangement = src.CutBackArrangement,
                                   T.BankingArrangement = src.BankingArrangement,
                                   T.MemberBanksNo = src.MemberBanksNo,
                                   T.TotalConsortiumAmt = src.TotalConsortiumAmt,
                                   T.ROC_CFCReportDate = pos_19,
                                   T.ROC_ChargeFV = src.ROC_ChargeFV,
                                   T.ROC_ChargeFVDt = pos_21,
                                   T.ROC_ChargeRemark = src.ROC_ChargeRemark,
                                   T.ChargeFiledwithROCRemark2 = src.ROC_Securities,
                                   T.ROC_Cover = src.ROC_Cover,
                                   T.ROCCoveredCertificateDate = pos_25,
                                   T.ChargeFiledWith = src.ChargeFiledWith,
                                   T.FiledDt = pos_27,
                                   T.EmployeeID = src.EmployeeID,
                                   T.EmployeeType = src.EmployeeType,
                                   T.Designation = src.DesignationName,
                                   T.Placeofposting = src.Placeofposting,
                                   T.LPersonalConDate = pos_32,
                                   T.LPersonalConDtls = src.LPersonalConDtls,
                                   T.RecallNoticeDate = pos_34,
                                   T.RecallNoticeModeID = src.RecallNoticeModeID,
                                   T.LegalAuditDate = pos_36,
                                   T.IrregularityPending = src.IrregularityPending,
                                   T.IrregularityRectiDate = pos_38,
                                   T.FraudAccoStatus = src.FraudAccoStatus,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.GradeScaleAlt_Key = src.GradeScaleAlt_Key,
                                   T.Grade = src.ParameterName,
                                   T.FMRNO = src.FMRNO,
                                   T.FMRDate = pos_45,
                                   T.FraudNatureRemark = src.FraudNatureRemark,
                                   T.BorrowerGroupAlt_key = src.BorrowerGroupAlt_key;
      DBMS_OUTPUT.PUT_LINE('PQR');

   END;
   END IF;
   /*	CUST RELATIONSHIP DETAIL */
   DBMS_OUTPUT.PUT_LINE(6);
   IF v_CustRel = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(5565);
      --select * FROM tt_CustomerDetailSelect_8
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.PAN, C.VoterID, C.AadhaarId, C.NPR_Id, C.PassportNo, UTILS.CONVERT_TO_VARCHAR2(C.PassportIssueDt,10,p_style=>103) AS pos_7, UTILS.CONVERT_TO_VARCHAR2(C.PassportExpiryDt,10,p_style=>103) AS pos_8, C.PassportIssueLocation, C.DL_No, UTILS.CONVERT_TO_VARCHAR2(C.DL_IssueDate,10,p_style=>103) AS pos_11, UTILS.CONVERT_TO_VARCHAR2(C.DL_ExpiryDate,10,p_style=>103) AS pos_12, C.DL_IssueLocation, C.RationCardNo, C.OtherIdType, C.OtherID, C.TAN, C.TIN, C.DIN, C.CIN, C.RegistrationNo, C.MobileNo, C.Email, DU.UserLocation, C.AuthorisationStatus, C.RelationEntityId, C.LEI
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN CurDat_RBL_MISDB_PROD.AdvCustRelationship C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey )
             AND T.CustomerEntityId = C.CustomerEntityId
             AND NVL(C.AuthorisationStatus, 'A') = 'A'
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustRelCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.PAN = src.PAN,
                                   T.VoterID = src.VoterID,
                                   T.AadharNo = src.AadhaarId,
                                   T.NPR_Id = src.NPR_Id,
                                   T.PassportNo = src.PassportNo,
                                   T.PassportIssueDate = pos_7,
                                   T.PassportExpDate = pos_8,
                                   T.PassportIssueLocation = src.PassportIssueLocation,
                                   T.DL_No = src.DL_No,
                                   T.DL_IssueDate = pos_11,
                                   T.DL_ExpDate = pos_12,
                                   T.DL_IssueLocation = src.DL_IssueLocation,
                                   T.RationCardNo = src.RationCardNo,
                                   T.OtherIdType = src.OtherIdType,
                                   T.OtherIdNo = src.OtherID,
                                   T.TAN = src.TAN,
                                   T.TIN = src.TIN,
                                   T.DIN = src.DIN,
                                   T.CIN = src.CIN,
                                   T.RegistrationNo = src.RegistrationNo,
                                   T.MobileNo = src.MobileNo,
                                   T.EmailID = src.Email,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.RelationEntityId = src.RelationEntityId,
                                   T.LEI = src.LEI;

   END;
   END IF;
   IF v_CustRel = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(5);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.PAN, C.VoterID, C.AadhaarId, C.NPR_Id, C.PassportNo, UTILS.CONVERT_TO_VARCHAR2(C.PassportIssueDt,10,p_style=>103) AS pos_7, UTILS.CONVERT_TO_VARCHAR2(C.PassportExpiryDt,10,p_style=>103) AS pos_8, C.PassportIssueLocation, C.DL_No, UTILS.CONVERT_TO_VARCHAR2(C.DL_IssueDate,10,p_style=>103) AS pos_11, UTILS.CONVERT_TO_VARCHAR2(C.DL_ExpiryDate,10,p_style=>103) AS pos_12, C.DL_IssueLocation, C.RationCardNo, C.OtherIdType, C.OtherID, C.TAN, C.TIN, C.DIN, C.CIN, C.RegistrationNo, C.MobileNo, C.Email, DU.UserLocation, C.AuthorisationStatus, C.RelationEntityId, C.LEI
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN ( SELECT C.CustomerEntityId ,
                           C.PAN ,
                           C.VoterID ,
                           C.AadhaarId ,
                           C.NPR_Id ,
                           C.PassportNo ,
                           C.PassportIssueDt ,
                           C.PassportIssueLocation ,
                           C.DL_No ,
                           C.DL_IssueDate ,
                           C.DL_ExpiryDate ,
                           C.DL_IssueLocation ,
                           C.RationCardNo ,
                           C.OtherIdType ,
                           C.OtherID ,
                           C.PassportExpiryDt ,
                           C.TAN ,
                           C.TIN ,
                           C.DIN ,
                           C.CIN ,
                           C.RegistrationNo ,
                           C.MobileNo ,
                           C.Email ,
                           C.AuthorisationStatus ,
                           C.CreatedBy ,
                           C.ModifiedBy ,
                           C.RelationEntityId ,
                           C.LEI 
                    FROM AdvCustRelationship_Mod C
                           JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                                  FROM AdvCustRelationship_Mod C
                                   WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                            AND C.EffectiveToTimeKey >= v_TimeKey )
                                            AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND C.CustomerEntityId = v_CustomerEntityID
                                    GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
                           AND ( C.EffectiveFromTimeKey <= v_TimeKey
                           AND C.EffectiveToTimeKey >= v_TimeKey )
                           AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND C.CustomerEntityId = v_CustomerEntityID ) C   ON T.CustomerEntityId = C.CustomerEntityId
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustRelCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.PAN = src.PAN,
                                   T.VoterID = src.VoterID,
                                   T.AadharNo = src.AadhaarId,
                                   T.NPR_Id = src.NPR_Id,
                                   T.PassportNo = src.PassportNo,
                                   T.PassportIssueDate = pos_7,
                                   T.PassportExpDate = pos_8,
                                   T.PassportIssueLocation = src.PassportIssueLocation,
                                   T.DL_No = src.DL_No,
                                   T.DL_IssueDate = pos_11,
                                   T.DL_ExpDate = pos_12,
                                   T.DL_IssueLocation = src.DL_IssueLocation,
                                   T.RationCardNo = src.RationCardNo,
                                   T.OtherIdType = src.OtherIdType,
                                   T.OtherIdNo = src.OtherID,
                                   T.TAN = src.TAN,
                                   T.TIN = src.TIN,
                                   T.DIN = src.DIN,
                                   T.CIN = src.CIN,
                                   T.RegistrationNo = src.RegistrationNo,
                                   T.MobileNo = src.MobileNo,
                                   T.EmailID = src.Email,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.RelationEntityId = src.RelationEntityId,
                                   T.LEI = src.LEI;

   END;
   END IF;
   /*	CUST Coomunication DETAIL */
   DBMS_OUTPUT.PUT_LINE(7);
   IF v_CustComm = 'N'
     OR v_OperationFlag <> 16 THEN

    -- FROM MAIN TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(6);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.PinCode, C.STD_Code_Res, C.PhoneNo_Res, C.STD_Code_Off, C.PhoneNo_Off, C.FaxNo, C.CityAlt_Key, DC.CityName, C.DistrictAlt_Key, DD.DistrictName, C.CountryAlt_Key, DT.CountryName, C.Add1, C.Add2, C.Add3, C.AddressTypeAlt_Key, DA.AddressCategoryAlt_Key, DU.UserLocation, C.AuthorisationStatus, C.RelationADDEntityId
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN CurDat_RBL_MISDB_PROD.AdvCustCommunicationDetail C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey )
             AND T.CustomerEntityId = C.CustomerEntityId
             AND NVL(C.AuthorisationStatus, 'A') = 'A'
           --LEFT JOIN DimCity DC
            --ON DC.CityAlt_Key=C.CityAlt_Key
            --LEFT JOIN Dimgeography DD
            --ON DD.DistrictAlt_Key=C.DistrictAlt_Key
            --LEFT JOIN DimCountry DT
            --ON DT.CountryAlt_Key=C.CountryAlt_Key
            --LEFT JOIN DimAddressCategory DA ON DA.AddressCategoryAlt_Key=C.AddressCategoryAlt_Key  Condition of EffectiveFromTimeKey and EffectiveToTimeKey Added Triloki 21/02/2017

             LEFT JOIN DimCity DC   ON ( DC.EffectiveFromTimeKey <= v_TimeKey
             AND DC.EffectiveToTimeKey >= v_TimeKey )
             AND DC.CityAlt_Key = C.CityAlt_Key
             LEFT JOIN DimGeography DD   ON ( DD.EffectiveFromTimeKey <= v_TimeKey
             AND DD.EffectiveToTimeKey >= v_TimeKey )
             AND DD.DistrictAlt_Key = C.DistrictAlt_Key
             LEFT JOIN DimCountry DT   ON ( DT.EffectiveFromTimeKey <= v_TimeKey
             AND DT.EffectiveToTimeKey >= v_TimeKey )
             AND DT.CountryAlt_Key = C.CountryAlt_Key
             LEFT JOIN DimAddressCategory DA   ON ( DA.EffectiveFromTimeKey <= v_TimeKey
             AND DA.EffectiveToTimeKey >= v_TimeKey )
             AND DA.AddressCategoryAlt_Key = C.AddressCategoryAlt_Key
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustCommCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.PinCode = src.PinCode,
                                   T.STD_Code_Res = src.STD_Code_Res,
                                   T.PhoneNo_Res = src.PhoneNo_Res,
                                   T.STD_Code_Off = src.STD_Code_Off,
                                   T.PhoneNo_Off = src.PhoneNo_Off,
                                   T.FaxNo = src.FaxNo,
                                   T.CityAlt_Key = src.CityAlt_Key,
                                   T.CityName = src.CityName,
                                   T.DistrictAlt_Key = src.DistrictAlt_Key,
                                   T.DistrictName = src.DistrictName,
                                   T.CountryAlt_Key = src.CountryAlt_Key,
                                   T.CountryName = src.CountryName,
                                   T.Add1 = src.Add1,
                                   T.Add2 = src.Add2,
                                   T.Add3 = src.Add3,
                                   T.AddressTypeAlt_Key = src.AddressTypeAlt_Key,
                                   T.AddressCategoryAlt_Key = src.AddressCategoryAlt_Key,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.RelationADDEntityId = src.RelationADDEntityId;

   END;
   END IF;
   IF v_CustComm = 'Y'
     OR v_OperationFlag = 16 THEN

    -- FROM MOD TABLE
   BEGIN
      DBMS_OUTPUT.PUT_LINE(6);
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, C.PinCode, C.STD_Code_Res, C.PhoneNo_Res, C.STD_Code_Off, C.PhoneNo_Off, C.FaxNo, C.CityAlt_Key, DC.CityName, C.DistrictAlt_Key, DD.DistrictName, C.CountryAlt_Key, DT.CountryName, C.Add1, C.Add2, C.Add3, C.AddressTypeAlt_Key, DA.AddressCategoryAlt_Key, DU.UserLocation, C.AuthorisationStatus, C.RelationAddEntityId
      FROM T ,tt_CustomerDetailSelect_8 T
             JOIN ( SELECT C.CustomerEntityId ,
                           C.PinCode ,
                           C.STD_Code_Res ,
                           C.PhoneNo_Res ,
                           C.STD_Code_Off ,
                           C.PhoneNo_Off ,
                           C.FaxNo ,
                           C.CityAlt_Key ,
                           C.DistrictAlt_Key ,
                           C.CountryAlt_Key ,
                           C.Add1 ,
                           C.Add2 ,
                           C.Add3 ,
                           C.AddressTypeAlt_Key ,
                           C.AddressCategoryAlt_Key ,
                           C.AuthorisationStatus ,
                           C.CreatedBy ,
                           C.ModifiedBy ,
                           C.RelationAddEntityId 
                    FROM AdvCustCommunicationDetail_Mod C
                           JOIN ( SELECT MAX(C.EntityKey)  EntityKey  
                                  FROM AdvCustCommunicationDetail_Mod C
                                   WHERE  ( C.EffectiveFromTimeKey <= v_TimeKey
                                            AND C.EffectiveToTimeKey >= v_TimeKey )
                                            AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                            AND C.CustomerEntityId = v_CustomerEntityID
                                    GROUP BY C.CustomerEntityId ) A   ON A.EntityKey = C.EntityKey
                           AND ( C.EffectiveFromTimeKey <= v_TimeKey
                           AND C.EffectiveToTimeKey >= v_TimeKey )
                           AND C.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           AND C.CustomerEntityId = v_CustomerEntityID ) C   ON T.CustomerEntityId = C.CustomerEntityId
             LEFT JOIN DimCity DC   ON ( DC.EffectiveFromTimeKey <= v_TimeKey
             AND DC.EffectiveToTimeKey >= v_TimeKey )
             AND DC.CityAlt_Key = C.CityAlt_Key
             LEFT JOIN DimGeography DD   ON ( DD.EffectiveFromTimeKey <= v_TimeKey
             AND DD.EffectiveToTimeKey >= v_TimeKey )
             AND DD.DistrictAlt_Key = C.DistrictAlt_Key
             LEFT JOIN DimCountry DT   ON ( DT.EffectiveFromTimeKey <= v_TimeKey
             AND DT.EffectiveToTimeKey >= v_TimeKey )
             AND DT.CountryAlt_Key = C.CountryAlt_Key
             LEFT JOIN DimAddressCategory DA   ON ( DA.EffectiveFromTimeKey <= v_TimeKey
             AND DA.EffectiveToTimeKey >= v_TimeKey )
             AND DA.AddressCategoryAlt_Key = C.AddressCategoryAlt_Key
             LEFT JOIN DimUserInfo DU   ON DU.UserLoginID = v_CustCommCrMod ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.PinCode = src.PinCode,
                                   T.STD_Code_Res = src.STD_Code_Res,
                                   T.PhoneNo_Res = src.PhoneNo_Res,
                                   T.STD_Code_Off = src.STD_Code_Off,
                                   T.PhoneNo_Off = src.PhoneNo_Off,
                                   T.FaxNo = src.FaxNo,
                                   T.CityAlt_Key = src.CityAlt_Key,
                                   T.CityName = src.CityName,
                                   T.DistrictAlt_Key = src.DistrictAlt_Key,
                                   T.DistrictName = src.DistrictName,
                                   T.CountryAlt_Key = src.CountryAlt_Key,
                                   T.CountryName = src.CountryName,
                                   T.Add1 = src.Add1,
                                   T.Add2 = src.Add2,
                                   T.Add3 = src.Add3,
                                   T.AddressTypeAlt_Key = src.AddressTypeAlt_Key,
                                   T.AddressCategoryAlt_Key = src.AddressCategoryAlt_Key,
                                   T.Userlocation = src.UserLocation,
                                   T.AuthorisationStatus = src.AuthorisationStatus,
                                   T.RelationADDEntityId = src.RelationAddEntityId;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(8);
   IF 'Y' IN ( v_CustBasic,v_CustFin,v_CustNonFin,v_CustOth,v_CustNPA,v_CustRel,v_CustComm )
    THEN
    DECLARE
      v_CreateModifyBy VARCHAR2(20);

   BEGIN
      SELECT CrModBy 

        INTO v_CreateModifyBy
        FROM ( SELECT v_CustBasicCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustFinCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustNonFinCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustOthCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustNPACrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustRelCrMod CrModBy  
                 FROM DUAL 
               UNION 
               SELECT v_CustCommCrMod CrModBy  
                 FROM DUAL  ) A
       WHERE  NVL(CrModBy, ' ') <> ' ';
      UPDATE tt_CustomerDetailSelect_8
         SET IsMainTable = 'N',
             CreateModifyBy = v_CreateModifyBy;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(212);
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_CustomerDetailSelect_8  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   SELECT MAX(TimeKey)  

     INTO v_FromTimekey
     FROM ( SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM CustomerBasicDetail 
             WHERE  CustomerEntityId = v_CustomerEntityId
            UNION 
            SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM AdvCustOtherDetail 
             WHERE  CustomerEntityId = v_CustomerEntityId
            UNION 
            SELECT MAX(EffectiveFromTimeKey)  TimeKey  
            FROM AdvCustCommunicationDetail 
             WHERE  CustomerEntityId = v_CustomerEntityId ) K;
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
   --if exists(select EffectiveFromTimekey from tt_CustomerDetailSelect_8 )

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
                      FROM tt_CustomerDetailSelect_8  );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      --Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select EffectiveFromTimekey from tt_CustomerDetailSelect_8)
      --Select TimeKey
      --,Convert(varchar(10),[Date],103) as [AvailableDate]
      --,@FromDate as MinDate
      --,@ToDate as MaxDate
      --from SysDayMatrix SD
      --inner join tt_CustomerDetailSelect_8 c
      --  on C.EffectiveFromTimeKey= SD.TimeKey
      -- select @FromDate
      SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 

        INTO v_FromDate
        FROM SysDayMatrix 
       WHERE  TimeKey = ( SELECT MAX(EffectiveFromTimekey)  
                          FROM tt_CustomerDetailSelect_8  );
      -- select @FromDate
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
      --	exec CustomerDetailSelect @CustomerEntityId=1001884,@CustType=N'BORROWER',@TimeKey=24583,@BranchCode=N'0',@OperationFlag=2

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSELECT_28052024" TO "ADF_CDR_RBL_STGDB";
