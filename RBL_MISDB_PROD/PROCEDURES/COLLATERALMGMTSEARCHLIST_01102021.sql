--------------------------------------------------------
--  DDL for Procedure COLLATERALMGMTSEARCHLIST_01102021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --CollateralMgmtSearchList 1

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   --Declare @OperationFlag  INT
   --Set @OperationFlag=1
   v_TimeKey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   v_LatestColletralSum NUMBER(18,2);
   v_LatestColletral1 NUMBER(18,2);
   v_Count NUMBER(10,0);
   v_I NUMBER(10,0);
   v_RowNumber NUMBER(10,0);
   v_CollateralID VARCHAR2(30);
   v_LatestColletralCount NUMBER(10,0);
   v_CustomerID VARCHAR2(30);
   v_CustomerIDPre VARCHAR2(30);
   v_cursor SYS_REFCURSOR;
--	,@CustomerID Varchar(30)

BEGIN

   v_PageFrom := (v_pageSize * v_newPage) - (v_pageSize) + 1 ;
   v_PageTo := v_pageSize * v_newPage ;
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   ------------------Added on 03-04-2021 -----------------------------
   IF utils.object_id('TempDB..tt_Tag1_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Tag1_2 ';
   END IF;
   IF utils.object_id('TempDB..tt_temp_36101') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp101_2 ';
   END IF;
   DELETE FROM tt_Tag1_2;
   UTILS.IDENTITY_RESET('tt_Tag1_2');

   INSERT INTO tt_Tag1_2 ( 
   	SELECT 1 TaggingAlt_Key  ,
           A.RefCustomerId CustomerID  ,
           A.CollateralID ,
           D.TotalCollateralValue 
   	  FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A
             JOIN ( SELECT ParameterAlt_Key ,
                           ParameterName ,
                           'TaggingLevel' Tablename  
                    FROM DimParameter 
                     WHERE  DimParameterName = 'DimRatingType'
                              AND ParameterName NOT IN ( 'Guarantor' )

                              AND EffectiveFromTimeKey <= v_TimeKey
                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
             AND A.TaggingAlt_Key = 1
             JOIN ( SELECT A.RefCustomerId CustomerID  ,
                           SUM(C.CurrentValue)  TotalCollateralValue  
                    FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A
                           JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail C   ON C.CollateralID = A.CollateralID
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                     WHERE  A.EffectiveFromTimeKey <= v_Timekey
                              AND A.EffectiveToTimeKey >= v_Timekey
                      GROUP BY A.RefCustomerId ) D   ON D.CustomerID = A.RefCustomerId
   	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey );
   IF utils.object_id('TempDB..tt_Tag2_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Tag2_2 ';
   END IF;
   DELETE FROM tt_Tag2_2;
   UTILS.IDENTITY_RESET('tt_Tag2_2');

   INSERT INTO tt_Tag2_2 ( 
   	SELECT 2 TaggingAlt_Key  ,
           A.RefSystemAcId AccountID  ,
           A.CollateralID ,
           D.TotalCollateralValue 
   	  FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A
             JOIN ( SELECT ParameterAlt_Key ,
                           ParameterName ,
                           'TaggingLevel' Tablename  
                    FROM DimParameter 
                     WHERE  DimParameterName = 'DimRatingType'
                              AND ParameterName NOT IN ( 'Guarantor' )

                              AND EffectiveFromTimeKey <= v_TimeKey
                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
             AND A.TaggingAlt_Key = 2
             JOIN ( SELECT A.RefSystemAcId AccountID  ,
                           SUM(C.CurrentValue)  TotalCollateralValue  
                    FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A
                           JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail C   ON C.CollateralID = A.CollateralID
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                     WHERE  A.EffectiveFromTimeKey <= v_Timekey
                              AND A.EffectiveToTimeKey >= v_Timekey
                      GROUP BY A.RefSystemAcId ) D   ON D.AccountID = A.RefSystemAcId
   	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey );
   BEGIN

      BEGIN
         -------------------------------------------------
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_36') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_36 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_36101') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp101_2 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_36103') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp103_2 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_36104') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp104_2 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_36105') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp105_2 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_361061') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1061_2 ';
            END IF;
            DELETE FROM tt_temp_36;
            UTILS.IDENTITY_RESET('tt_temp_36');

            INSERT INTO tt_temp_36 ( 
            	SELECT A.AccountID ,
                    A.UCICID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.TaggingAlt_Key ,
                    A.TaggingLevel ,
                    A.DistributionAlt_Key ,
                    A.DistributionModel ,
                    A.CollateralID ,
                    A.CollateralCode ,
                    A.CollateralTypeAlt_Key ,
                    A.CollateralTypeDescription ,
                    A.CollateralSubTypeAlt_Key ,
                    A.CollateralSubTypeDescription ,
                    A.CollateralOwnerTypeAlt_Key ,
                    A.CollOwnerDescription ,
                    A.CollateralOwnerShipTypeAlt_Key ,
                    A.CollateralOwnershipType ,
                    A.ChargeTypeAlt_Key ,
                    A.CollChargeDescription ,
                    A.ChargeNatureAlt_Key ,
                    A.SecurityChargeTypeName ,
                    A.ShareAvailabletoBankAlt_Key ,
                    A.ShareAvailabletoBank ,
                    A.CollateralShareamount ,
                    A.TotalCollateralvalueatcustomerlevel ,
                    A.OldCollateralID ,
                    --,A.TotCollateralsUCICCustAcc
                    A.IfPercentagevalue_or_Absolutevalue ,
                    A.AuthorisationStatus ,
                    A.CollateralValueatSanctioninRs ,
                    A.CollateralValueasonNPAdateinRs ,
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
                    A.ModAppDateFirst 
            	  FROM ( SELECT A.RefSystemAcId AccountID  ,
                             A.UCICID ,
                             A.RefCustomerId CustomerID  ,
                             A.CustomerName ,
                             A.TaggingAlt_Key ,
                             B.ParameterName TaggingLevel  ,
                             A.DistributionAlt_Key ,
                             C.ParameterName DistributionModel  ,
                             A.CollateralID ,
                             A.CollateralCode ,
                             A.SecurityAlt_Key CollateralTypeAlt_Key  ,
                             E.CollateralTypeDescription ,
                             A.CollateralSubTypeAlt_Key ,
                             F.CollateralSubTypeDescription ,
                             A.OwnerTypeAlt_Key CollateralOwnerTypeAlt_Key  ,
                             G.CollOwnerDescription ,
                             A.CollateralOwnerShipTypeAlt_Key ,
                             H.ParameterName CollateralOwnershipType  ,
                             A.SecurityChargeTypeAlt_Key ChargeTypeAlt_Key  ,
                             I.CollChargeDescription ,
                             A.ChargeNatureAlt_Key ,
                             J.SecurityChargeTypeName ,
                             A.ShareAvailabletoBankAlt_Key ,
                             D.ParameterName ShareAvailabletoBank  ,
                             A.CollateralShareamount ,
                             --,A.TotalCollateralvalueatcustomerlevel
                             (CASE 
                                   WHEN A.TaggingAlt_Key = 1 THEN T1.TotalCollateralValue
                                   WHEN A.TaggingAlt_Key = 2 THEN T2.TotalCollateralValue   END) TotalCollateralvalueatcustomerlevel  ,
                             A.Security_RefNo OldCollateralID  ,
                             --,A.TotCollateralsUCICCustAcc
                             A.IfPercentagevalue_or_Absolutevalue ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.CollateralValueatSanctioninRs ,
                             A.CollateralValueasonNPAdateinRs ,
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
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  
                      FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'TaggingLevel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimRatingType'
                                              AND ParameterName NOT IN ( 'Guarantor' )

            	  AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DistributionModel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Collateral'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ShareAvailabletoBank' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralBank'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                             JOIN DimCollateralType E   ON A.SecurityAlt_Key = E.CollateralTypeAltKey
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                             AND F.EffectiveFromTimeKey <= v_Timekey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralOwnerType G   ON A.OwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CollateralOwnershipType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralOwnershipType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                             JOIN DimCollateralChargeType I   ON A.SecurityChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                             AND I.EffectiveFromTimeKey <= v_Timekey
                             AND I.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                             AND J.EffectiveFromTimeKey <= v_Timekey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             AND SecurityChargeTypeGroup = 'COLLATERAL'
                             LEFT JOIN tt_Tag1_2 T1   ON T1.CollateralID = A.CollateralID
                             LEFT JOIN tt_Tag2_2 T2   ON T2.CollateralID = A.CollateralID
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.RefSystemAcId AccountID  ,
                             A.UCICID ,
                             A.RefCustomerId CustomerID  ,
                             A.CustomerName ,
                             A.TaggingAlt_Key ,
                             B.ParameterName TaggingLevel  ,
                             A.DistributionAlt_Key ,
                             C.ParameterName DistributionModel  ,
                             A.CollateralID ,
                             A.CollateralCode ,
                             A.SecurityAlt_Key CollateralTypeAlt_Key  ,
                             E.CollateralTypeDescription ,
                             A.CollateralSubTypeAlt_Key ,
                             F.CollateralSubTypeDescription ,
                             A.OwnerTypeAlt_Key CollateralOwnerTypeAlt_Key  ,
                             G.CollOwnerDescription ,
                             A.CollateralOwnerShipTypeAlt_Key ,
                             H.ParameterName CollateralOwnershipType  ,
                             A.SecurityChargeTypeAlt_Key ChargeTypeAlt_Key  ,
                             I.CollChargeDescription ,
                             A.ChargeNatureAlt_Key ,
                             J.SecurityChargeTypeName ,
                             A.ShareAvailabletoBankAlt_Key ,
                             D.ParameterName ShareAvailabletoBank  ,
                             A.CollateralShareamount ,
                             --,A.TotalCollateralvalueatcustomerlevel
                             (CASE 
                                   WHEN A.TaggingAlt_Key = 1 THEN T1.TotalCollateralValue
                                   WHEN A.TaggingAlt_Key = 2 THEN T2.TotalCollateralValue   END) TotalCollateralvalueatcustomerlevel  ,
                             A.Security_RefNo OldCollateralID  ,
                             --,A.TotCollateralsUCICCustAcc
                             A.IfPercentagevalue_or_Absolutevalue ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.CollateralValueatSanctioninRs ,
                             A.CollateralValueasonNPAdateinRs ,
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
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  
                      FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'TaggingLevel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimRatingType'
                                              AND ParameterName NOT IN ( 'Guarantor' )

                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DistributionModel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Collateral'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ShareAvailabletoBank' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralBank'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                             JOIN DimCollateralType E   ON A.SecurityAlt_Key = E.CollateralTypeAltKey
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                             AND F.EffectiveFromTimeKey <= v_Timekey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralOwnerType G   ON A.OwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CollateralOwnershipType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralOwnershipType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                             JOIN DimCollateralChargeType I   ON A.SecurityChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                             AND I.EffectiveFromTimeKey <= v_Timekey
                             AND I.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                             AND J.EffectiveFromTimeKey <= v_Timekey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             AND SecurityChargeTypeGroup = 'COLLATERAL'
                             LEFT JOIN tt_Tag1_2 T1   ON T1.CollateralID = A.CollateralID
                             LEFT JOIN tt_Tag2_2 T2   ON T2.CollateralID = A.CollateralID
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY CollateralID )
                     ) A
            	  GROUP BY A.AccountID,A.UCICID,A.CustomerID,A.CustomerName,A.TaggingAlt_Key,A.TaggingLevel,A.DistributionAlt_Key,A.DistributionModel,A.CollateralID,A.CollateralCode,A.CollateralTypeAlt_Key,A.CollateralTypeDescription,A.CollateralSubTypeAlt_Key,A.CollateralSubTypeDescription,A.CollateralOwnerTypeAlt_Key,A.CollOwnerDescription,A.CollateralOwnerShipTypeAlt_Key,A.CollateralOwnershipType,A.ChargeTypeAlt_Key,A.CollChargeDescription,A.ChargeNatureAlt_Key,A.SecurityChargeTypeName,A.ShareAvailabletoBankAlt_Key,A.ShareAvailabletoBank,A.CollateralShareamount,A.TotalCollateralvalueatcustomerlevel,A.OldCollateralID
                        --,A.TotCollateralsUCICCustAcc
                        ,A.IfPercentagevalue_or_Absolutevalue,A.AuthorisationStatus,A.CollateralValueatSanctioninRs,A.CollateralValueasonNPAdateinRs,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst );
            --     Drop Table 		 tt_temp_36101
            DELETE FROM tt_temp101_2;
            UTILS.IDENTITY_RESET('tt_temp101_2');

            INSERT INTO tt_temp101_2 SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'Collateral' TableName  ,
                               * ,
                               LENGTH(AuthorisationStatus) AuthorisationStatuslen  
                        FROM ( SELECT * 
                               FROM tt_temp_36 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner;
            -- order by DataPointOwner.AuthorisationStatuslen desc 
            ------------------------------------------------------------------------
            UPDATE tt_temp101_2
               SET TotalCollateralvalueatcustomerlevel = NULL,
                   TotalCount = NULL;
            -----------------------------------------------------------------------------------------
            --Start Customer
            DELETE FROM tt_temp103_2;
            UTILS.IDENTITY_RESET('tt_temp103_2');

            INSERT INTO tt_temp103_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                            * 
                 FROM tt_temp101_2 
                WHERE  TaggingAlt_Key = 1
                         AND AuthorisationStatus = 'A';
            --Select 'tt_temp_36101',*from tt_temp_36101
            --   Select 'tt_temp_36103',* from tt_temp_36103
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_temp103_2 ;
            v_I := 1 ;
            v_LatestColletralSum := 0 ;
            v_CustomerIDPre := ' ' ;
            v_CustomerID := ' ' ;
            v_LatestColletralCount := 0 ;
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT CollateralID ,
                         CustomerID 

                    INTO v_CollateralID,
                         v_CustomerID
                    FROM tt_temp103_2 
                   WHERE  RecentRownumber = v_I
                    ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                  IF ( v_I = 1 ) THEN

                  BEGIN
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                  BEGIN
                     UPDATE tt_temp103_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  CustomerID = v_CustomerIDPre
                       AND TaggingAlt_Key = 1;
                     UPDATE tt_temp101_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  CustomerID = v_CustomerIDPre
                       AND TaggingAlt_Key = 1;
                     v_LatestColletral1 := 0 ;
                     v_LatestColletralSum := 0 ;
                     v_LatestColletralCount := 0 ;
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre = v_CustomerID ) THEN

                  BEGIN
                     SELECT NVL(CurrentValue, 0) 

                       INTO v_LatestColletral1
                       FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                              JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND A.CollateralID = v_CollateralID
                               AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                     FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND CollateralID = v_CollateralID )
                               AND B.RefCustomerId = v_CustomerID;
                     v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                     v_LatestColletralCount := v_LatestColletralCount + 1 ;
                     --Print '@LatestColletral1'
                     --Print @LatestColletral1
                     -- Print '@@LatestColletralSum'
                     --Print @LatestColletralSum
                     v_I := v_I + 1 ;
                     v_LatestColletral1 := 0 ;

                  END;
                  END IF;

               END;
            END LOOP;
            UPDATE tt_temp103_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  CustomerID = v_CustomerIDPre
              AND TaggingAlt_Key = 1;
            UPDATE tt_temp101_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  CustomerID = v_CustomerIDPre
              AND TaggingAlt_Key = 1;
            ---END
            --Start  ACccount
            DELETE FROM tt_temp104_2;
            UTILS.IDENTITY_RESET('tt_temp104_2');

            INSERT INTO tt_temp104_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                            * 
                 FROM tt_temp101_2 
                WHERE  TaggingAlt_Key = 2
                         AND AuthorisationStatus = 'A';
            --Select 'tt_temp_36101',* from tt_temp_36101
            --		Select 'tt_temp_36104',* from tt_temp_36104
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_temp104_2 ;
            v_I := 1 ;
            v_LatestColletralSum := 0 ;
            v_CustomerIDPre := ' ' ;
            v_CustomerID := ' ' ;
            v_LatestColletralCount := 0 ;
            v_LatestColletral1 := 0 ;
            --PRINT @Cou1nt
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT CollateralID ,
                         AccountID 

                    INTO v_CollateralID,
                         v_CustomerID
                    FROM tt_temp104_2 
                   WHERE  RecentRownumber = v_I
                    ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                  IF ( v_I = 1 ) THEN

                  BEGIN
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                  BEGIN
                     UPDATE tt_temp104_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  AccountID = v_CustomerIDPre
                       AND TaggingAlt_Key = 2;
                     UPDATE tt_temp101_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  AccountID = v_CustomerIDPre
                       AND TaggingAlt_Key = 2;
                     v_LatestColletral1 := 0 ;
                     v_LatestColletralSum := 0 ;
                     v_LatestColletralCount := 0 ;
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre = v_CustomerID ) THEN

                  BEGIN
                     SELECT NVL(CurrentValue, 0) 

                       INTO v_LatestColletral1
                       FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                              JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND A.CollateralID = v_CollateralID
                               AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                     FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND CollateralID = v_CollateralID )
                               AND B.RefSystemAcId = v_CustomerID;
                     v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                     v_LatestColletralCount := v_LatestColletralCount + 1 ;
                     DBMS_OUTPUT.PUT_LINE('Account');
                     DBMS_OUTPUT.PUT_LINE('@CollateralID');
                     DBMS_OUTPUT.PUT_LINE(v_CollateralID);
                     DBMS_OUTPUT.PUT_LINE('@LatestColletral1');
                     DBMS_OUTPUT.PUT_LINE(v_LatestColletral1);
                     DBMS_OUTPUT.PUT_LINE('@@LatestColletralSum');
                     DBMS_OUTPUT.PUT_LINE(v_LatestColletralSum);
                     v_I := v_I + 1 ;
                     v_LatestColletral1 := 0 ;

                  END;
                  END IF;

               END;
            END LOOP;
            UPDATE tt_temp104_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  AccountID = v_CustomerIDPre
              AND TaggingAlt_Key = 2;
            UPDATE tt_temp101_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  AccountID = v_CustomerIDPre
              AND TaggingAlt_Key = 2;
            --   Select 'tt_temp_36101',*from tt_temp_36101
            --Select 'tt_temp_36103',* from tt_temp_36103
            --Select 'tt_temp_36104',* from tt_temp_36104
            --Select 'tt_temp_36104',* from tt_temp_36104
            ---END
            --Start  UCIC
            DELETE FROM tt_temp105_2;
            UTILS.IDENTITY_RESET('tt_temp105_2');

            INSERT INTO tt_temp105_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                            * 
                 FROM tt_temp101_2 
                WHERE  TaggingAlt_Key = 4
                         AND AuthorisationStatus = 'A';
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_temp105_2 ;
            --Select * from tt_temp_36101
            --   Select * from tt_temp_36103
            v_I := 1 ;
            v_LatestColletralSum := 0 ;
            v_CustomerIDPre := ' ' ;
            v_CustomerID := ' ' ;
            v_LatestColletralCount := 0 ;
            v_LatestColletral1 := 0 ;
            DBMS_OUTPUT.PUT_LINE(v_Count);
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT CollateralID ,
                         UCICID 

                    INTO v_CollateralID,
                         v_CustomerID
                    FROM tt_temp105_2 
                   WHERE  RecentRownumber = v_I
                    ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                  IF ( v_I = 1 ) THEN

                  BEGIN
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                  BEGIN
                     UPDATE tt_temp105_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  UCICID = v_CustomerIDPre
                       AND TaggingAlt_Key = 4;
                     UPDATE tt_temp101_2
                        SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                            TotalCount = v_LatestColletralCount
                      WHERE  UCICID = v_CustomerIDPre
                       AND TaggingAlt_Key = 4;
                     v_LatestColletral1 := 0 ;
                     v_LatestColletralSum := 0 ;
                     v_LatestColletralCount := 0 ;
                     v_CustomerIDPre := v_CustomerID ;

                  END;
                  END IF;
                  IF ( v_CustomerIDPre = v_CustomerID ) THEN

                  BEGIN
                     SELECT NVL(CurrentValue, 0) 

                       INTO v_LatestColletral1
                       FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                              JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND A.CollateralID = v_CollateralID
                               AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                     FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND CollateralID = v_CollateralID )
                               AND B.UCICID = v_CustomerID;
                     v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                     v_LatestColletralCount := v_LatestColletralCount + 1 ;
                     --Print '@LatestColletral1'
                     --Print @LatestColletral1
                     -- Print '@@LatestColletralSum'
                     --Print @LatestColletralSum
                     v_I := v_I + 1 ;
                     v_LatestColletral1 := 0 ;

                  END;
                  END IF;

               END;
            END LOOP;
            UPDATE tt_temp105_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  UCICID = v_CustomerIDPre
              AND TaggingAlt_Key = 4;
            UPDATE tt_temp101_2
               SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                   TotalCount = v_LatestColletralCount
             WHERE  UCICID = v_CustomerIDPre
              AND TaggingAlt_Key = 4;
            --     Update #tmp
            --SET #tmp.TotalCollateralvalueatcustomerlevel=tt_temp_36105.TotalCollateralvalueatcustomerlevel,
            -- #tmp.TotalCount=tt_temp_36105.TotalCount 
            -- From #tmp INNER JOIN  #tmp104 ON #tmp.CustomerID=tt_temp_36105.CustomerID where #tmp.TaggingAlt_Key=4
            --Select * from tt_temp_36105
            ---END
            ----Select * from tt_temp_36103
            ----UNION
            ----Select * from tt_temp_36104
            ----UNION
            ---- Select * from tt_temp_36105
            --  ROW_NUMBER() OVER(ORDER BY  convert(varchar(50),RecentRownumber))  RowsNum,
            --  Select ROW_NUMBER() OVER(ORDER BY  convert(varchar(50),RecentRownumber))  RowsNum,X.* INTO tt_temp_361061  From 
            --  (
            --    Select  * from tt_temp_36103
            --  UNION ALL
            --  Select * from tt_temp_36104
            -- UNION ALL
            --   Select * from tt_temp_36105
            --) X
            --Select 'tt_temp_36101',* from tt_temp_36101
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_temp101_2 
                WHERE  Rownumber BETWEEN v_PageFrom AND v_PageTo
                 ORDER BY AuthorisationStatuslen DESC,
                          DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_3616') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_29 ';
               END IF;
               IF utils.object_id('TempDB..tt_temp_36102') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp102_2 ';
               END IF;
               IF utils.object_id('TempDB..tt_temp_36106') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp106_2 ';
               END IF;
               IF utils.object_id('TempDB..tt_temp_36107') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp107_2 ';
               END IF;
               IF utils.object_id('TempDB..tt_temp_36108') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp108_2 ';
               END IF;
               IF utils.object_id('TempDB..tt_temp_361091') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1091_2 ';
               END IF;
               DELETE FROM tt_temp16_29;
               UTILS.IDENTITY_RESET('tt_temp16_29');

               INSERT INTO tt_temp16_29 ( 
               	SELECT A.AccountID ,
                       A.UCICID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.TaggingAlt_Key ,
                       A.TaggingLevel ,
                       A.DistributionAlt_Key ,
                       A.DistributionModel ,
                       A.CollateralID ,
                       A.CollateralCode ,
                       A.CollateralTypeAlt_Key ,
                       A.CollateralTypeDescription ,
                       A.CollateralSubTypeAlt_Key ,
                       A.CollateralSubTypeDescription ,
                       A.CollateralOwnerTypeAlt_Key ,
                       A.CollOwnerDescription ,
                       A.CollateralOwnerShipTypeAlt_Key ,
                       A.CollateralOwnershipType ,
                       A.ChargeTypeAlt_Key ,
                       A.CollChargeDescription ,
                       A.ChargeNatureAlt_Key ,
                       A.SecurityChargeTypeName ,
                       A.ShareAvailabletoBankAlt_Key ,
                       A.ShareAvailabletoBank ,
                       A.CollateralShareamount ,
                       A.TotalCollateralvalueatcustomerlevel ,
                       A.OldCollateralID ,
                       --,A.TotCollateralsUCICCustAcc
                       A.IfPercentagevalue_or_Absolutevalue ,
                       A.AuthorisationStatus ,
                       A.CollateralValueatSanctioninRs ,
                       A.CollateralValueasonNPAdateinRs ,
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
                       A.ModAppDateFirst 
               	  FROM ( SELECT A.RefSystemAcId AccountID  ,
                                A.UCICID ,
                                A.RefCustomerId CustomerID  ,
                                A.CustomerName ,
                                A.TaggingAlt_Key ,
                                B.ParameterName TaggingLevel  ,
                                A.DistributionAlt_Key ,
                                C.ParameterName DistributionModel  ,
                                A.CollateralID ,
                                A.CollateralCode ,
                                A.SecurityAlt_Key CollateralTypeAlt_Key  ,
                                E.CollateralTypeDescription ,
                                A.CollateralSubTypeAlt_Key ,
                                F.CollateralSubTypeDescription ,
                                A.OwnerTypeAlt_Key CollateralOwnerTypeAlt_Key  ,
                                G.CollOwnerDescription ,
                                A.CollateralOwnerShipTypeAlt_Key ,
                                H.ParameterName CollateralOwnershipType  ,
                                A.SecurityChargeTypeAlt_Key ChargeTypeAlt_Key  ,
                                I.CollChargeDescription ,
                                A.ChargeNatureAlt_Key ,
                                J.SecurityChargeTypeName ,
                                A.ShareAvailabletoBankAlt_Key ,
                                D.ParameterName ShareAvailabletoBank  ,
                                A.CollateralShareamount ,
                                --,A.TotalCollateralvalueatcustomerlevel
                                (CASE 
                                      WHEN A.TaggingAlt_Key = 1 THEN T1.TotalCollateralValue
                                      WHEN A.TaggingAlt_Key = 2 THEN T2.TotalCollateralValue   END) TotalCollateralvalueatcustomerlevel  ,
                                A.Security_RefNo OldCollateralID  ,
                                --,A.TotCollateralsUCICCustAcc
                                A.IfPercentagevalue_or_Absolutevalue ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.CollateralValueatSanctioninRs ,
                                A.CollateralValueasonNPAdateinRs ,
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
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  
                         FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'TaggingLevel' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimRatingType'
                                                 AND ParameterName NOT IN ( 'Guarantor' )

                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'DistributionModel' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'Collateral'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'ShareAvailabletoBank' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CollateralBank'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                                JOIN DimCollateralType E   ON A.SecurityAlt_Key = E.CollateralTypeAltKey
                                AND E.EffectiveFromTimeKey <= v_Timekey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                                AND F.EffectiveFromTimeKey <= v_Timekey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimCollateralOwnerType G   ON A.OwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                                AND G.EffectiveFromTimeKey <= v_Timekey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'CollateralOwnershipType' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CollateralOwnershipType'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                                JOIN DimCollateralChargeType I   ON A.SecurityChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                                AND I.EffectiveFromTimeKey <= v_Timekey
                                AND I.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                                AND J.EffectiveFromTimeKey <= v_Timekey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND SecurityChargeTypeGroup = 'COLLATERAL'
                                LEFT JOIN tt_Tag1_2 T1   ON T1.CollateralID = A.CollateralID
                                LEFT JOIN tt_Tag2_2 T2   ON T2.CollateralID = A.CollateralID
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY CollateralID )
                        ) A
               	  GROUP BY A.AccountID,A.UCICID,A.CustomerID,A.CustomerName,A.TaggingAlt_Key,A.TaggingLevel,A.DistributionAlt_Key,A.DistributionModel,A.CollateralID,A.CollateralCode,A.CollateralTypeAlt_Key,A.CollateralTypeDescription,A.CollateralSubTypeAlt_Key,A.CollateralSubTypeDescription,A.CollateralOwnerTypeAlt_Key,A.CollOwnerDescription,A.CollateralOwnerShipTypeAlt_Key,A.CollateralOwnershipType,A.ChargeTypeAlt_Key,A.CollChargeDescription,A.ChargeNatureAlt_Key,A.SecurityChargeTypeName,A.ShareAvailabletoBankAlt_Key,A.ShareAvailabletoBank,A.CollateralShareamount,A.TotalCollateralvalueatcustomerlevel,A.OldCollateralID
                           --,A.TotCollateralsUCICCustAcc
                           ,A.IfPercentagevalue_or_Absolutevalue,A.AuthorisationStatus,A.CollateralValueatSanctioninRs,A.CollateralValueasonNPAdateinRs,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst );
               DELETE FROM tt_temp102_2;
               UTILS.IDENTITY_RESET('tt_temp102_2');

               INSERT INTO tt_temp102_2 SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Collateral' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_29 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner;
               --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
               --      AND RowNumber <= (@PageNo * @PageSize)
               ----------------------------------------------------------------
               --Select 'tt_temp_36102',* from tt_temp_36102
               --Select 'tt_temp_3616',* from tt_temp_3616
               UPDATE tt_temp102_2
                  SET TotalCollateralvalueatcustomerlevel = NULL,
                      TotalCount = NULL;
               --------------------------------------------------
               --Start Customer
               DELETE FROM tt_temp106_2;
               UTILS.IDENTITY_RESET('tt_temp106_2');

               INSERT INTO tt_temp106_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                               * 
                    FROM tt_temp102_2 
                   WHERE  TaggingAlt_Key = 1
                            AND AuthorisationStatus = 'A';
               SELECT COUNT(*)  

                 INTO v_Count
                 FROM tt_temp106_2 ;
               --Select * from tt_temp_36101
               --   Select * from tt_temp_36103
               v_I := 1 ;
               v_LatestColletralSum := 0 ;
               v_CustomerIDPre := ' ' ;
               v_CustomerID := ' ' ;
               v_LatestColletralCount := 0 ;
               WHILE ( v_I <= v_Count ) 
               LOOP 

                  BEGIN
                     SELECT CollateralID ,
                            CustomerID 

                       INTO v_CollateralID,
                            v_CustomerID
                       FROM tt_temp106_2 
                      WHERE  RecentRownumber = v_I
                       ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                     IF ( v_I = 1 ) THEN

                     BEGIN
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                     BEGIN
                        UPDATE tt_temp106_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  CustomerID = v_CustomerIDPre
                          AND TaggingAlt_Key = 1;
                        UPDATE tt_temp102_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  CustomerID = v_CustomerIDPre
                          AND TaggingAlt_Key = 1;
                        v_LatestColletral1 := 0 ;
                        v_LatestColletralSum := 0 ;
                        v_LatestColletralCount := 0 ;
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre = v_CustomerID ) THEN

                     BEGIN
                        SELECT NVL(CurrentValue, 0) 

                          INTO v_LatestColletral1
                          FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                                 JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND A.CollateralID = v_CollateralID
                                  AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                        FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND CollateralID = v_CollateralID )
                                  AND B.RefCustomerId = v_CustomerID;
                        v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                        v_LatestColletralCount := v_LatestColletralCount + 1 ;
                        --Print '@LatestColletral1'
                        --Print @LatestColletral1
                        -- Print '@@LatestColletralSum'
                        --Print @LatestColletralSum
                        v_I := v_I + 1 ;
                        v_LatestColletral1 := 0 ;

                     END;
                     END IF;

                  END;
               END LOOP;
               UPDATE tt_temp106_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  CustomerID = v_CustomerIDPre
                 AND TaggingAlt_Key = 1;
               UPDATE tt_temp102_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  CustomerID = v_CustomerIDPre
                 AND TaggingAlt_Key = 1;
               ---END
               --Start  ACccount
               DELETE FROM tt_temp107_2;
               UTILS.IDENTITY_RESET('tt_temp107_2');

               INSERT INTO tt_temp107_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                               * 
                    FROM tt_temp102_2 
                   WHERE  TaggingAlt_Key = 2
                            AND AuthorisationStatus = 'A';
               --Select 'tt_temp_36102',* from tt_temp_36102
               --		Select 'tt_temp_36107',* from tt_temp_36107
               SELECT COUNT(*)  

                 INTO v_Count
                 FROM tt_temp107_2 ;
               v_I := 1 ;
               v_LatestColletralSum := 0 ;
               v_CustomerIDPre := ' ' ;
               v_CustomerID := ' ' ;
               v_LatestColletralCount := 0 ;
               v_LatestColletral1 := 0 ;
               --PRINT @Cou1nt
               WHILE ( v_I <= v_Count ) 
               LOOP 

                  BEGIN
                     SELECT CollateralID ,
                            AccountID 

                       INTO v_CollateralID,
                            v_CustomerID
                       FROM tt_temp107_2 
                      WHERE  RecentRownumber = v_I
                       ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                     IF ( v_I = 1 ) THEN

                     BEGIN
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                     BEGIN
                        UPDATE tt_temp107_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  AccountID = v_CustomerIDPre
                          AND TaggingAlt_Key = 2;
                        UPDATE tt_temp102_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  AccountID = v_CustomerIDPre
                          AND TaggingAlt_Key = 2;
                        v_LatestColletral1 := 0 ;
                        v_LatestColletralSum := 0 ;
                        v_LatestColletralCount := 0 ;
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre = v_CustomerID ) THEN

                     BEGIN
                        SELECT NVL(CurrentValue, 0) 

                          INTO v_LatestColletral1
                          FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                                 JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND A.CollateralID = v_CollateralID
                                  AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                        FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND CollateralID = v_CollateralID )
                                  AND B.RefSystemAcId = v_CustomerID;
                        v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                        v_LatestColletralCount := v_LatestColletralCount + 1 ;
                        --Print '@LatestColletral1'
                        --Print @LatestColletral1
                        -- Print '@@LatestColletralSum'
                        --Print @LatestColletralSum
                        v_I := v_I + 1 ;
                        v_LatestColletral1 := 0 ;

                     END;
                     END IF;

                  END;
               END LOOP;
               UPDATE tt_temp107_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  AccountID = v_CustomerIDPre
                 AND TaggingAlt_Key = 2;
               UPDATE tt_temp102_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  AccountID = v_CustomerIDPre
                 AND TaggingAlt_Key = 2;
               --Select 'tt_temp_36107',* from tt_temp_36107
               ---END
               --Start  UCIC
               DELETE FROM tt_temp108_2;
               UTILS.IDENTITY_RESET('tt_temp108_2');

               INSERT INTO tt_temp108_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                               * 
                    FROM tt_temp102_2 
                   WHERE  TaggingAlt_Key = 4
                            AND AuthorisationStatus = 'A';
               SELECT COUNT(*)  

                 INTO v_Count
                 FROM tt_temp108_2 ;
               --Select * from tt_temp_36101
               --   Select * from tt_temp_36103
               v_I := 1 ;
               v_LatestColletralSum := 0 ;
               v_CustomerIDPre := ' ' ;
               v_CustomerID := ' ' ;
               v_LatestColletralCount := 0 ;
               v_LatestColletral1 := 0 ;
               DBMS_OUTPUT.PUT_LINE(v_Count);
               WHILE ( v_I <= v_Count ) 
               LOOP 

                  BEGIN
                     SELECT CollateralID ,
                            UCICID 

                       INTO v_CollateralID,
                            v_CustomerID
                       FROM tt_temp108_2 
                      WHERE  RecentRownumber = v_I
                       ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50);
                     IF ( v_I = 1 ) THEN

                     BEGIN
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre <> v_CustomerID ) THEN

                     BEGIN
                        UPDATE tt_temp108_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  UCICID = v_CustomerIDPre
                          AND TaggingAlt_Key = 4;
                        UPDATE tt_temp102_2
                           SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                               TotalCount = v_LatestColletralCount
                         WHERE  UCICID = v_CustomerIDPre
                          AND TaggingAlt_Key = 4;
                        v_LatestColletral1 := 0 ;
                        v_LatestColletralSum := 0 ;
                        v_LatestColletralCount := 0 ;
                        v_CustomerIDPre := v_CustomerID ;

                     END;
                     END IF;
                     IF ( v_CustomerIDPre = v_CustomerID ) THEN

                     BEGIN
                        SELECT NVL(CurrentValue, 0) 

                          INTO v_LatestColletral1
                          FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                                 JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND A.CollateralID = v_CollateralID
                                  AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                                        FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND CollateralID = v_CollateralID )
                                  AND B.UCICID = v_CustomerID;
                        v_LatestColletralSum := v_LatestColletralSum + v_LatestColletral1 ;
                        v_LatestColletralCount := v_LatestColletralCount + 1 ;
                        --Print '@LatestColletral1'
                        --Print @LatestColletral1
                        -- Print '@@LatestColletralSum'
                        --Print @LatestColletralSum
                        v_I := v_I + 1 ;
                        v_LatestColletral1 := 0 ;

                     END;
                     END IF;

                  END;
               END LOOP;
               UPDATE tt_temp108_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  UCICID = v_CustomerIDPre
                 AND TaggingAlt_Key = 4;
               UPDATE tt_temp102_2
                  SET TotalCollateralvalueatcustomerlevel = v_LatestColletralSum,
                      TotalCount = v_LatestColletralCount
                WHERE  UCICID = v_CustomerIDPre
                 AND TaggingAlt_Key = 4;
               --Select * from tt_temp_36105
               ---END
               ----Select * from tt_temp_36103
               ----UNION
               ----Select * from tt_temp_36104
               ----UNION
               ---- Select * from tt_temp_36105
               --  ROW_NUMBER() OVER(ORDER BY  convert(varchar(50),RecentRownumber))  RowsNum,
               --  Select ROW_NUMBER() OVER(ORDER BY  convert(varchar(50),RecentRownumber))  RowsNum,X.* INTO tt_temp_361091  From 
               --  (
               --    Select  * from tt_temp_36106
               --  UNION ALL
               --  Select * from tt_temp_36107
               -- UNION ALL
               --   Select * from tt_temp_36108
               --) X
               --   Select  * from tt_temp_361091
               --            WHERE RowsNum BETWEEN @PageFrom AND @PageTo
               --order by AuthorisationStatuslen desc, DateCreated desc
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM tt_temp102_2 
                   WHERE  Rownumber BETWEEN v_PageFrom AND v_PageTo
                    ORDER BY AuthorisationStatus DESC,
                             DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            ------------------------------------------------------------------------
            ELSE
               IF ( v_OperationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_36120') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp120_2 ';
                  END IF;
                  IF utils.object_id('TempDB..tt_temp_36121') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp121_2 ';
                  END IF;
                  IF utils.object_id('TempDB..tt_temp_36122') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp122_2 ';
                  END IF;
                  DELETE FROM tt_temp120_2;
                  UTILS.IDENTITY_RESET('tt_temp120_2');

                  INSERT INTO tt_temp120_2 ( 
                  	SELECT A.AccountID ,
                          A.UCICID ,
                          A.CustomerID ,
                          A.CustomerName ,
                          A.TaggingAlt_Key ,
                          A.TaggingLevel ,
                          A.DistributionAlt_Key ,
                          A.DistributionModel ,
                          A.CollateralID ,
                          A.CollateralCode ,
                          A.CollateralTypeAlt_Key ,
                          A.CollateralTypeDescription ,
                          A.CollateralSubTypeAlt_Key ,
                          A.CollateralSubTypeDescription ,
                          A.CollateralOwnerTypeAlt_Key ,
                          A.CollOwnerDescription ,
                          A.CollateralOwnerShipTypeAlt_Key ,
                          A.CollateralOwnershipType ,
                          A.ChargeTypeAlt_Key ,
                          A.CollChargeDescription ,
                          A.ChargeNatureAlt_Key ,
                          A.SecurityChargeTypeName ,
                          A.ShareAvailabletoBankAlt_Key ,
                          A.ShareAvailabletoBank ,
                          A.CollateralShareamount ,
                          A.TotalCollateralvalueatcustomerlevel ,
                          A.OldCollateralID ,
                          --,A.TotCollateralsUCICCustAcc
                          A.IfPercentagevalue_or_Absolutevalue ,
                          A.AuthorisationStatus ,
                          A.CollateralValueatSanctioninRs ,
                          A.CollateralValueasonNPAdateinRs ,
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
                          A.ModAppDateFirst 
                  	  FROM ( SELECT A.RefSystemAcId AccountID  ,
                                   A.UCICID ,
                                   A.RefCustomerId CustomerID  ,
                                   A.CustomerName ,
                                   A.TaggingAlt_Key ,
                                   B.ParameterName TaggingLevel  ,
                                   A.DistributionAlt_Key ,
                                   C.ParameterName DistributionModel  ,
                                   A.CollateralID ,
                                   A.CollateralCode ,
                                   A.SecurityAlt_Key CollateralTypeAlt_Key  ,
                                   E.CollateralTypeDescription ,
                                   A.CollateralSubTypeAlt_Key ,
                                   F.CollateralSubTypeDescription ,
                                   A.OwnerTypeAlt_Key CollateralOwnerTypeAlt_Key  ,
                                   G.CollOwnerDescription ,
                                   A.CollateralOwnerShipTypeAlt_Key ,
                                   H.ParameterName CollateralOwnershipType  ,
                                   A.SecurityChargeTypeAlt_Key ChargeTypeAlt_Key  ,
                                   I.CollChargeDescription ,
                                   A.ChargeNatureAlt_Key ,
                                   J.SecurityChargeTypeName ,
                                   A.ShareAvailabletoBankAlt_Key ,
                                   D.ParameterName ShareAvailabletoBank  ,
                                   A.CollateralShareamount ,
                                   --,A.TotalCollateralvalueatcustomerlevel
                                   (CASE 
                                         WHEN A.TaggingAlt_Key = 1 THEN T1.TotalCollateralValue
                                         WHEN A.TaggingAlt_Key = 2 THEN T2.TotalCollateralValue   END) TotalCollateralvalueatcustomerlevel  ,
                                   A.Security_RefNo OldCollateralID  ,
                                   --,A.TotCollateralsUCICCustAcc
                                   A.IfPercentagevalue_or_Absolutevalue ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   A.CollateralValueatSanctioninRs ,
                                   A.CollateralValueasonNPAdateinRs ,
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
                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) ModAppDateFirst  
                            FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'TaggingLevel' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'DimRatingType'
                                                    AND ParameterName NOT IN ( 'Guarantor' )

                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'DistributionModel' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'Collateral'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'ShareAvailabletoBank' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'CollateralBank'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                                   JOIN DimCollateralType E   ON A.SecurityAlt_Key = E.CollateralTypeAltKey
                                   AND E.EffectiveFromTimeKey <= v_Timekey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                                   AND F.EffectiveFromTimeKey <= v_Timekey
                                   AND F.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimCollateralOwnerType G   ON A.OwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                                   AND G.EffectiveFromTimeKey <= v_Timekey
                                   AND G.EffectiveToTimeKey >= v_TimeKey
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'CollateralOwnershipType' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'CollateralOwnershipType'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                                   JOIN DimCollateralChargeType I   ON A.SecurityChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                                   AND I.EffectiveFromTimeKey <= v_Timekey
                                   AND I.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                                   AND J.EffectiveFromTimeKey <= v_Timekey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   AND SecurityChargeTypeGroup = 'COLLATERAL'
                                   LEFT JOIN tt_Tag1_2 T1   ON T1.CollateralID = A.CollateralID
                                   LEFT JOIN tt_Tag2_2 T2   ON T2.CollateralID = A.CollateralID
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                             GROUP BY CollateralID )
                           ) A
                  	  GROUP BY A.AccountID,A.UCICID,A.CustomerID,A.CustomerName,A.TaggingAlt_Key,A.TaggingLevel,A.DistributionAlt_Key,A.DistributionModel,A.CollateralID,A.CollateralCode,A.CollateralTypeAlt_Key,A.CollateralTypeDescription,A.CollateralSubTypeAlt_Key,A.CollateralSubTypeDescription,A.CollateralOwnerTypeAlt_Key,A.CollOwnerDescription,A.CollateralOwnerShipTypeAlt_Key,A.CollateralOwnershipType,A.ChargeTypeAlt_Key,A.CollChargeDescription,A.ChargeNatureAlt_Key,A.SecurityChargeTypeName,A.ShareAvailabletoBankAlt_Key,A.ShareAvailabletoBank,A.CollateralShareamount,A.TotalCollateralvalueatcustomerlevel,A.OldCollateralID
                              --,A.TotCollateralsUCICCustAcc
                              ,A.IfPercentagevalue_or_Absolutevalue,A.AuthorisationStatus,A.CollateralValueatSanctioninRs,A.CollateralValueasonNPAdateinRs,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ModAppByFirst,A.ModAppDateFirst );
                  DELETE FROM tt_tmp121_2;
                  UTILS.IDENTITY_RESET('tt_tmp121_2');

                  INSERT INTO tt_tmp121_2 SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'Collateral' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp120_2 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner;
                  DELETE FROM tt_temp122_2;
                  UTILS.IDENTITY_RESET('tt_temp122_2');

                  INSERT INTO tt_temp122_2 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_VARCHAR2(CustomerID,50)  ) RecentRownumber  ,
                                                  * 
                       FROM tt_tmp121_2 ;
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM tt_temp122_2 
                      WHERE  RecentRownumber BETWEEN v_PageFrom AND v_PageTo ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
            END IF;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
