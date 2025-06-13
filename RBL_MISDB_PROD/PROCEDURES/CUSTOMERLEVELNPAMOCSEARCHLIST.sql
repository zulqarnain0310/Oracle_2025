--------------------------------------------------------
--  DDL for Procedure CUSTOMERLEVELNPAMOCSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" 
--USE [USFB_ENPADB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelNPAMOCSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --DROP PROCEDURE [dbo].[CustomerLevelNPAMOCSearchList]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelNPAMOCSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 ---- exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2
 ----go
 --sp_helptext CustomerLevelNPAMOCSearchList
 -------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2
 --go
 --SELECT Top 100 * FROM [PRO].[CustomerCal_Hist]	where RefCustomerID ='95'
 --And EffectiveFromTimeKey=25992 AND EffectiveToTimeKey=25992
 --Exec [CustomerLevelNPAMOCfH.MOCSourceAltKeySearchList] @OperationFlag =, @CustomerID='161760505'		--Main screen select
 --MOCSource
 --MOCSourceAltKey
 --exec CustomerLevelNPAMOCSearchList_Backup_14052021_1 @CustomerID=N'90',@OperationFlag=2

(
  --Declare
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_CustomerID IN VARCHAR2 DEFAULT '84' ,
  iv_TimeKey IN NUMBER DEFAULT 25841 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --Select @Timekey
   v_MOCSourceAltkey NUMBER(10,0);
   v_CreatedBy VARCHAR2(50);
   v_DateCreated VARCHAR2(200);
   v_ModifiedBy VARCHAR2(50);
   v_DateModified VARCHAR2(200);
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved VARCHAR2(200);
   v_AuthorisationStatus VARCHAR2(5);
   v_MocReason VARCHAR2(50);
   v_ApprovedByFirstLevel VARCHAR2(100);
   v_DateApprovedFirstLevel VARCHAR2(200);
   v_MOC_ExpireDate VARCHAR2(200);
   v_MOC_TYPEFLAG VARCHAR2(4);
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   IF v_OperationFlag NOT IN ( 16,20 )
    THEN

   BEGIN
      --,@MOC_ExpireDate=MOC_ExpireDate
      SELECT MocReason ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel ,
             MOCType_Flag 

        INTO v_MocReason,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','NP','1A','A' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;

   END;
   END IF;
   --AND  Entity_key in (select max(Entity_key) FROM CustomerLevelMOC_Mod 
   --where AuthorisationStatus in('MP','1A','A') AND CUSTOMERID=@CustomerID
   --AND  EffectiveFromTimeKey=@Timekey and EffectiveToTimeKey=@Timekey )
   IF v_OperationFlag = '16' THEN

   BEGIN
      --,@MOC_ExpireDate=MOC_ExpireDate
      SELECT MocReason ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel ,
             MOCType_Flag 

        INTO v_MocReason,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','NP' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;

   END;
   END IF;
   --AND SCREENFLAG <> ('U')
   IF v_OperationFlag = '20' THEN


   --,@MOC_ExpireDate=MOC_ExpireDate
   BEGIN
      SELECT MocReason ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel ,
             MOCType_Flag 

        INTO v_MocReason,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;

   END;
   END IF;
   --AND SCREENFLAG <> ('U')
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
   DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
   BEGIN
      DECLARE
         ---PRE MOC
         v_DateOfData DATE;
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

           INTO v_DateOfData
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         
         DELETE FROM tt_CUST_PREMOC_3;
         UTILS.IDENTITY_RESET('tt_CUST_PREMOC_3');

         INSERT INTO tt_CUST_PREMOC_3 ( 
         	SELECT * 
         	  FROM ( SELECT B.CustomerEntityId ,
                          B.CustomerID ,
                          B.CustomerName ,
                          CASE 
                               WHEN A.Cust_AssetClassAlt_Key IS NULL THEN 1
                          ELSE A.Cust_AssetClassAlt_Key
                             END AssetClassAlt_Key  ,
                          A.NPADt ,
                          V.security_value SecurityValue  ,
                          B.UCIF_ID UCICID  ,
                          0 AdditionalProvision  

                   --,@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

                   --@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved

                   --,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
                   FROM CustomerBasicDetail B
                          LEFT JOIN AdvCustNPADetail A   ON A.CustomerEntityID = B.CustomerEntityId
                          AND A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN ( SELECT a.CustomerId ,
                                             SUM(c.CurrentValue)  security_value  
                                      FROM CustomerBasicDetail a
                                             LEFT JOIN AdvSecurityDetail b   ON a.CustomerEntityId = b.CustomerEntityId
                                             AND b.EffectiveFromTimeKey <= v_timekey
                                             AND b.EffectiveFromTimeKey >= v_timekey
                                             LEFT JOIN AdvSecurityValueDetail c   ON b.SecurityEntityID = c.SecurityEntityID
                                             AND c.EffectiveFromTimeKey <= v_timekey
                                             AND c.EffectiveFromTimeKey >= v_timekey
                                       WHERE  a.EffectiveFromTimeKey <= v_timekey
                                                AND a.EffectiveFromTimeKey >= v_timekey
                                                AND a.CustomerId = v_customerid
                                        GROUP BY a.CustomerId ) V   ON B.CustomerId = V.CustomerId
                    WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             AND B.CustomerID = v_CustomerID ) X );
         ----POST 
         --Select 'tt_CUST_PREMOC_3',* from tt_CUST_PREMOC_3
         DBMS_OUTPUT.PUT_LINE('jaydev');
         

         INSERT INTO tt_CUST_POSTMOC_3 ( 
         	SELECT * 
         	  FROM ( 
                   --FROM CustomerLevelMOC_Mod 

                   --where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END

                   --AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey AND CUSTOMERID=@CustomerID 

                   --AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)

                   --SELECT   A.CustomerEntityID,CustomerID ,CustomerName,AssetClassAlt_Key, A.NPA_Date,A.CurntQtrRv SecurityValue,B.UCIF_ID as UCICID,

                   --@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

                   --@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,

                   --@DateApproved as DateApproved,@ApprovedByFirstLevel as ApprovedByFirstLevel,

                   --@DateApprovedFirstLevel as DateApprovedFirstLevel,@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag

                   --   FROM MOC_ChangeDetails A

                   --INNER JOIN  CURDAT.CustomerBasicDetail B

                   --ON          A.CustomerEntityID=B.CustomerEntityId

                   --AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 

                   --WHERE       A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND B.CUSTOMERID=@CustomerID 

                   -- AND        A.AuthorisationStatus='A'

                   --UNION
                   SELECT A.CustomerEntityID ,
                          B.CustomerId ,
                          B.CustomerName ,
                          AssetClassAlt_Key ,
                          A.NPADate ,
                          A.SecurityValue SecurityValue  ,
                          B.UCIF_ID UCICID  ,
                          A.AdditionalProvision ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_MocReason MOCReason_1  ,
                          v_MOCSourceAltkey MOCSourceAltkey  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  ,
                          v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                          v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                          v_MOC_ExpireDate MOC_ExpireDate  ,
                          v_MOC_TYPEFLAG MOCType_Flag  ,
                          MOCType ,
                          B.SourceSystemAlt_Key SourceSystemAlt_Key1  ,
                          UTILS.CONVERT_TO_VARCHAR2(' ',50) SourceSystemAlt_Key  ,
                          0 MOCReason  
                   FROM CustomerLevelMOC_Mod A
                          JOIN CustomerBasicDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND B.CUSTOMERID = v_CustomerID

                             --AND         A.AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'A' END
                             AND A.AuthorisationStatus IN ( 'NP','MP','1A','A' )
                  ) P );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_CUST_POSTMOC_3 
                                 WHERE  CUSTOMERID = v_CustomerID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('swapna');
            INSERT INTO tt_CUST_POSTMOC_3
              ( 
                --SELECT CustomerEntityId,RefCustomerID CustomerID,CustomerName,SysAssetClassAlt_Key AssetClassAlt_Key,SysNPA_Dt NPADate,CurntQtrRv  SecurityValue,

                --UCIF_ID as UCICID,ScreenFlag,@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

                --@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved

                --,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel

                --FROM   [Pro].[CustomerCal_Hist] 

                --

                --WHERE EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='Y'

                --AND RefCustomerID=@CustomerID 
                SELECT B.CustomerEntityId ,
                       B.CustomerId ,
                       B.CustomerName ,
                       A.AssetClassAlt_Key ,
                       A.NPA_Date ,
                       A.CurntQtrRv SecurityValue  ,
                       B.UCIF_ID UCICID  ,
                       AddlProvAbs AdditionalProvision  ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_MocReason MOCReason_1  ,
                       v_MOCSourceAltkey MOCSourceAltkey  ,
                       v_CreatedBy CreatedBy  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  ,
                       v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                       v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                       v_MOC_ExpireDate MOC_ExpireDate  ,
                       v_MOC_TYPEFLAG MOCType_Flag  ,
                       MOCType ,
                       B.SourceSystemAlt_Key SourceSystemAlt_Key1  ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',50) SourceSystemAlt_Key  ,
                       0 MOCReason  
                FROM MOC_ChangeDetails A
                       JOIN CustomerBasicDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND B.CustomerID = v_CustomerID
                          AND MOCType_Flag = 'CUST' );

         END;
         END IF;
         --	and isnull(FlgMoc,'N')='Y'
         DBMS_OUTPUT.PUT_LINE('Sudesh');
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SourceName
         FROM A ,tt_CUST_POSTMOC_3 A
                JOIN DIMSOURCEDB B   ON A.SourceSystemAlt_Key1 = B.SourceAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SourceSystemAlt_Key = src.SourceName;
         --Select 'tt_CUST_POSTMOC_3',MOCReason_1, * from tt_CUST_POSTMOC_3
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.ParameterAlt_Key, ' ') AS MOCReason
         FROM A ,tt_CUST_POSTMOC_3 A
                LEFT JOIN ( SELECT DimParameter.ParameterAlt_Key ,
                                   DimParameter.ParameterName ,
                                   'MOCReason' TableName  
                            FROM DimParameter 
                             WHERE  DimParameter.EffectiveFromTimeKey <= v_Timekey
                                      AND DimParameter.EffectiveToTimeKey >= v_Timekey
                                      AND DimParameter.DimParameterName = 'DimMOCReason' ) B   ON A.MOCReason_1 = B.ParameterName ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.MOCReason = src.MOCReason;
         OPEN  v_cursor FOR
            SELECT A.CustomerID CustomerId  ,
                   A.CustomerName ,
                   C.AssetClassName AssetClass  ,
                   A.NPADt NPADate  ,
                   A.SecurityValue ,
                   A.AdditionalProvision ,
                   D.AssetClassName AssetClass_Pos  ,
                   B.NPADate NPADate_Pos  ,
                   B.SecurityValue SecurityValue_Pos  ,
                   B.AdditionalProvision AdditionalProvision_Pos  ,
                   A.UCICID UCICID  ,
                   D.AssetClassAlt_Key AssetClassAlt_Key_Pos  ,
                   --,NULL as FraudAccountFlag
                   --,F.STATUSTYPE as FraudAccountFlag_Pos
                   --,H.FraudAccountFlagAlt_Key AS FraudAccountFlagAlt_Key
                   --,convert(varchar(20),F.STATUSDATE,103) FraudDate	
                   --,H.FraudDate as FraudDate_Pos
                   --,B.MOCType as MOCType
                   B.MOCReason ,
                   B.MOCReason_1 ,
                   --,B.MOCTypeAlt_Key                  
                   --,Y.MOCTypeName as MOCSource
                   B.MOCSourceAltKey ,
                   CASE 
                        WHEN B.MOCType = 'auto' THEN 1
                   ELSE 2
                      END MOCTypeAlt_Key  ,
                   --,X.TotalOSBalance
                   --,X.TotalInterestReversal
                   --,X.TotalPrincOSBalance
                   --,X.TotalInterestReceivabl
                   --,X.TotalProvision
                   NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                   NVL(B.DateModified, B.DateCreated) CrModDate  ,
                   NVL(B.ApprovedByFirstLevel, B.CreatedBy) CrAppBy  ,
                   NVL(B.DateApprovedFirstLevel, B.DateCreated) CrAppDate  ,
                   NVL(B.ApprovedByFirstLevel, B.ModifiedBy) ModAppBy  ,
                   NVL(B.DateApprovedFirstLevel, B.DateModified) ModAppDate  ,
                   B.ModifiedBy ,
                   B.AuthorisationStatus ,
                   B.ApprovedByFirstLevel ,
                   B.DateApprovedFirstLevel ,
                   UTILS.CONVERT_TO_VARCHAR2(v_DateOfData,20,p_style=>103) DateOfData  ,
                   --,B.MOC_ExpireDate
                   B.MOCType_Flag ,
                   B.SourceSystemAlt_Key 
              FROM tt_CUST_PREMOC_3 A
                     LEFT JOIN tt_CUST_POSTMOC_3 B   ON A.CustomerID = b.CustomerID
                     LEFT JOIN DimAssetClass c   ON C.AssetClassAlt_Key = a.AssetClassAlt_Key
                     AND c.EffectiveFromTimeKey <= v_TimeKey
                     AND c.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = b.AssetClassAlt_Key
                     AND D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         --SELECT * FROM CURDAT.AdvAcBalanceDetail
         --left Join (	SELECT  RefCustomerId,
         --					EffectiveFromTimeKey,
         --											EffectiveToTimeKey ,
         --											SUM(T.Balance) As TotalOSBalance, 
         --											Sum(T.IntReverseAmt)as TotalInterestReversal,
         --											0 as TotalPrincOSBalance ,
         --											0 as TotalInterestReceivabl,
         --											Sum(T.TotalProv) as TotalProvision
         --										 --FROM PRO.AccountCal_Hist as T
         --										 FROM CURDAT.AdvAcBalanceDetail T
         --										 Where RefCustomerId=@CustomerID
         --										 AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
         --										Group by T.RefCustomerId,T.EffectiveFromTimeKey,T.EffectiveToTimeKey 
         --								)	X
         --									On X.RefCustomerId=A.CustomerID
         IF utils.object_id('tempdb..tt_MOCAuthorisation_10') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOCAuthorisation_10 ';

         END;
         END IF;
         DELETE FROM tt_MOCAuthorisation_10;
         UTILS.IDENTITY_RESET('tt_MOCAuthorisation_10');

         INSERT INTO tt_MOCAuthorisation_10 ( 
         	SELECT * ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
         	  FROM CustomerLevelMOC_Mod A
         	 WHERE  A.CustomerID = v_CustomerID
                    AND A.EffectiveFromTimeKey <= v_Timekey
                    AND A.EffectiveToTimeKey >= v_Timekey
                    AND CustomerId IS NOT NULL
                    AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                          FROM CustomerLevelMOC_Mod 
                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                            GROUP BY CustomerID )
          );
         --Select ' tt_MOCAuthorisation_10',* from  tt_MOCAuthorisation_10
         --where abc=1
         UPDATE tt_MOCAuthorisation_10 V
            SET ErrorMessage = CASE 
                                    WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                   END,
                ErrorinColumn = CASE 
                                     WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                   END
          WHERE  V.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND CustomerID = v_CustomerID
           AND v_Operationflag NOT IN ( 16,17,20 )
         ;
         MERGE INTO tt_MOCAuthorisation_10 G
         USING (SELECT G.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for an Account ID ' || A.AccountID || ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Author








         ization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for an Account ID ' || A.AccountID || ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM AccountLevelMOC_Mod A
                JOIN AdvAcBasicDetail F   ON A.AccountID = F.CustomerACID
                JOIN CustomerBasicDetail B   ON F.CustomerEntityId = B.CustomerEntityId
                JOIN tt_MOCAuthorisation_10 G   ON F.RefCustomerId = G.CustomerID 
          WHERE A.AuthorisationStatus IN ( 'NP','MP','DP','1A','FM' )

           AND G.CustomerID = v_CustomerID
           AND v_Operationflag NOT IN ( 16,17,20 )
         ) src
         ON ( G.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_MOCAuthorisation_10 
                             WHERE  Customerid = v_CustomerID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

          --AND ISNULL(ERRORDATA,'')<>''
         BEGIN
            DBMS_OUTPUT.PUT_LINE('ERROR');
            IF ( v_operationflag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT DISTINCT ErrorMessage ErrorinColumn  ,
                                  'Validation' TableName  
                    FROM tt_MOCAuthorisation_10  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
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
      -------------------------------
      --				ADVSECURITYDETAIL
      --			select * from ADVSECURITYDETAIL --ExceptionFinalStatusType
      --select * from AdvSecurityVALUEDetail 
      -----AdvSecurityDetail

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
