--------------------------------------------------------
--  DDL for Procedure CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" 
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
 ---- exec CustomerLevelNPAMOCSearchList @UCICID=N'84',@OperationFlag=2
 ----go
 --sp_helptext CustomerLevelNPAMOCSearchList
 -------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --exec CustomerLevelNPAMOCSearchList @UCICID=N'82000002',@OperationFlag=2
 --go
 --SELECT Top 100 * FROM [PRO].[CustomerCal_Hist]	where RefCustomerID ='95'
 --And EffectiveFromTimeKey=25992 AND EffectiveToTimeKey=25992
 --Exec [CustomerLevelNPAMOCfH.MOCSourceAltKeySearchList] @OperationFlag =, @UCICID='161760505'		--Main screen select
 --MOCSource
 --MOCSourceAltKey
 --exec CalypsoCustomerLevelNPAMOCSearchList @UCICID=N'82000010',@OperationFlag=2

(
  --Declare
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_UCICID IN VARCHAR2 DEFAULT '82000004' ,
  iv_TimeKey IN NUMBER DEFAULT 25841 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
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
        FROM CalypsoCustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','NP','1A','A' )

                AND UCIFID = v_UCICID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;

   END;
   END IF;
   --AND  Entity_key in (select max(Entity_key) FROM CalypsoCustomerLevelMOC_Mod 
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
        FROM CalypsoCustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','NP' )

                AND UCIFID = v_UCICID
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
        FROM CalypsoCustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND UCIFID = v_UCICID
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
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CUST_PREMOC_2  --SQLDEV: NOT RECOGNIZED
         DBMS_OUTPUT.PUT_LINE('Prashant');
         DELETE FROM tt_CUST_PREMOC_2;
         UTILS.IDENTITY_RESET('tt_CUST_PREMOC_2');

         INSERT INTO tt_CUST_PREMOC_2 ( 
         	SELECT * 
         	  FROM ( SELECT DISTINCT B.InvEntityId ,
                                   B.RefIssuerID CustomerID  ,
                                   I.IssuerName CustomerName  ,
                                   b.InvID AccountID  ,
                                   c.StatusDate FraudDate  ,
                                   E.StatusDate TwoDate  ,
                                   Interest_DividendDueAmount InterestReceivable  ,
                                   CASE 
                                        WHEN A.FinalAssetClassAlt_Key IS NULL THEN 1
                                   ELSE A.FinalAssetClassAlt_Key
                                      END AssetClassAlt_Key  ,
                                   A.NPIDt NPADate  ,
                                   V.security_value SecurityValue  ,
                                   B.RefIssuerID UCICID  ,
                                   0 AdditionalProvision  ,
                                   I.SourceAlt_key 
                   FROM InvestmentBasicDetail B
                          JOIN InvestmentIssuerDetail I   ON B.RefIssuerID = I.IssuerID
                          AND I.EffectiveFromTimeKey <= v_timekey
                          AND I.EffectiveToTimeKey >= v_Timekey
                          JOIN InvestmentFinancialDetail A   ON A.RefInvID = B.InvID
                          AND A.EffectiveFromTimeKey <= v_timekey
                          AND A.EffectiveToTimeKey >= v_Timekey
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Fraud Committed'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) c   ON b.InvID = c.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'TWO'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) E   ON b.InvID = E.ACID
                          LEFT JOIN ( SELECT B.UcifId UcifId  ,
                                             SUM(a.SecurityValue)  security_value  
                                      FROM InvestmentBasicDetail a
                                             JOIN InvestmentIssuerDetail B   ON a.RefIssuerID = B.IssuerID
                                       WHERE  a.EffectiveFromTimeKey <= v_timekey
                                                AND a.EffectiveToTimeKey >= v_timekey
                                                AND B.UcifId = v_UCICID
                                        GROUP BY B.UcifId ) V   ON B.InvID = V.UcifId
                    WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             AND I.UcifId = v_UCICID
                   UNION 
                   SELECT B.DerivativeEntityID ,
                          B.CustomerID ,
                          B.CustomerName ,
                          b.DerivativeRefNo AccountID  ,
                          c.StatusDate FraudDate  ,
                          E.StatusDate TwoDate  ,
                          DueAmtReceivable InterestReceivable  ,
                          CASE 
                               WHEN B.FinalAssetClassAlt_Key IS NULL THEN 1
                          ELSE B.FinalAssetClassAlt_Key
                             END AssetClassAlt_Key  ,
                          B.NPIDt ,
                          V.security_value SecurityValue  ,
                          B.UCIC_ID UCICID  ,
                          0 AdditionalProvision  ,
                          DB.SourceAlt_Key 
                   FROM CurDat_RBL_MISDB_PROD.DerivativeDetail B
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Fraud Committed'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) c   ON b.CustomerACID = c.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'TWO'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) E   ON b.CustomerACID = E.ACID
                          LEFT JOIN ( SELECT A.UCIC_ID ,
                                             0 security_value  
                                      FROM CurDat_RBL_MISDB_PROD.DerivativeDetail a
                                       WHERE  a.EffectiveFromTimeKey <= v_timekey
                                                AND a.EffectiveToTimeKey >= v_timekey
                                                AND a.UCIC_ID = v_UCICID
                                        GROUP BY a.UCIC_ID ) V   ON B.CustomerId = V.UCIC_ID
                          LEFT JOIN DIMSOURCEDB DB   ON b.SourceSystem = DB.SourceName
                    WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             AND B.UCIC_ID = v_UCICID ) X );
         ----POST 
         --Select 'tt_CUST_PREMOC_2',* from tt_CUST_PREMOC_2
         DBMS_OUTPUT.PUT_LINE('jaydev');
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CUST_POSTMOC_2  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_CUST_POSTMOC_2;
         UTILS.IDENTITY_RESET('tt_CUST_POSTMOC_2');

         INSERT INTO tt_CUST_POSTMOC_2 ( 
         	SELECT * 
         	  FROM ( SELECT A.CustomerEntityID ,
                          B.RefIssuerID CustomerID  ,
                          C.IssuerName CustomerName  ,
                          FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                          A.NPADate ,
                          A.SecurityValue SecurityValue  ,
                          A.BookValue ,
                          UTILS.CONVERT_TO_VARCHAR2(A.SMADate,20,p_style=>103) SMADate  ,
                          A.SMASubAssetClassValue ,
                          C.UcifId UCICID  ,
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
                          C.SourceAlt_key SourceSystemAlt_Key1  ,
                          UTILS.CONVERT_TO_VARCHAR2('Calypso',50) SourceName  ,
                          0 MOCReason  
                   FROM CalypsoCustomerLevelMOC_Mod A
                          JOIN InvestmentIssuerDetail C   ON a.UcifID = C.UcifId
                          AND C.EffectiveFromTimeKey <= v_TimeKey
                          AND C.EffectiveToTimeKey >= v_TimeKey
                          JOIN InvestmentBasicDetail B   ON c.IssuerEntityId = B.IssuerEntityId
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          JOIN InvestmentFinancialDetail D   ON B.InvEntityId = D.InvEntityId
                          AND D.EffectiveFromTimeKey <= v_TimeKey
                          AND D.EffectiveToTimeKey >= v_TimeKey
                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND A.UcifID = v_UCICID
                             AND A.AuthorisationStatus IN ( 'NP','MP','1A','A' )

                   UNION 
                   SELECT A.CustomerEntityID ,
                          B.CustomerId ,
                          B.CustomerName ,
                          AssetClassAlt_Key ,
                          A.NPADate ,
                          A.SecurityValue SecurityValue  ,
                          A.BookValue ,
                          UTILS.CONVERT_TO_VARCHAR2(A.SMADate,20,p_style=>103) SMADate  ,
                          A.SMASubAssetClassValue ,
                          B.UCIC_ID UCICID  ,
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
                          C.SourceAlt_Key SourceSystemAlt_Key1  ,
                          UTILS.CONVERT_TO_VARCHAR2('Calypso',50) SourceName  ,
                          0 MOCReason  
                   FROM CalypsoCustomerLevelMOC_Mod A
                          JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.UcifID = B.UCIC_ID
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          JOIN DIMSOURCEDB C   ON B.SourceSystem = C.SourceName
                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND B.UCIC_ID = v_UCICID
                             AND A.AuthorisationStatus IN ( 'NP','MP','1A','A' )
                  ) P );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_CUST_POSTMOC_2 
                                 WHERE  UCICID = v_UCICID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('swapna');
            INSERT INTO tt_CUST_POSTMOC_2
              ( SELECT DISTINCT B.IssuerEntityId ,
                                C.IssuerID ,
                                C.IssuerName ,
                                --d.RefInvID as AccountID,FraudDate,TwoDate,unserviedint as InterestReceivable,
                                A.AssetClassAlt_Key ,
                                A.NPA_Date ,
                                A.CurntQtrRv SecurityValue  ,
                                A.BookValue ,
                                UTILS.CONVERT_TO_VARCHAR2(A.SMADate,20,p_style=>103) SMADate  ,
                                A.SMASubAssetClassValue ,
                                C.UcifId UCICID  ,
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
                                C.SourceAlt_key SourceSystemAlt_Key1  ,
                                UTILS.CONVERT_TO_VARCHAR2('Calypso',50) SourceName  ,
                                0 MOCReason  
                FROM CalypsoInvMOC_ChangeDetails A
                       JOIN InvestmentIssuerDetail C   ON a.UCICID = C.UcifId
                       AND C.EffectiveFromTimeKey <= v_TimeKey
                       AND C.EffectiveToTimeKey >= v_TimeKey
                       JOIN InvestmentBasicDetail B   ON c.IssuerEntityId = B.IssuerEntityId
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                       JOIN InvestmentFinancialDetail D   ON B.InvEntityId = D.InvEntityId
                       AND D.EffectiveFromTimeKey <= v_TimeKey
                       AND D.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND A.UCICID = v_UCICID
                          AND MOCType_Flag = 'CUST'
                UNION 
                SELECT B.DerivativeEntityID ,
                       B.CustomerId ,
                       B.CustomerName ,
                       --b.DerivativeRefNo as AccountID,FraudDate,TwoDate,unserviedint as InterestReceivable,
                       A.AssetClassAlt_Key ,
                       A.NPA_Date ,
                       A.CurntQtrRv SecurityValue  ,
                       A.BookValue ,
                       UTILS.CONVERT_TO_VARCHAR2(A.SMADate,20,p_style=>103) SMADate  ,
                       A.SMASubAssetClassValue ,
                       B.UCIC_ID UCICID  ,
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
                       C.SourceAlt_Key SourceSystemAlt_Key1  ,
                       UTILS.CONVERT_TO_VARCHAR2('Calypso',50) SourceName  ,
                       0 MOCReason  
                FROM CalypsoDervMOC_ChangeDetails A
                       JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.UCICID = B.UCIC_ID
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                       JOIN DIMSOURCEDB C   ON B.SourceSystem = C.SourceName
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND A.UCICID = v_UCICID
                          AND MOCType_Flag = 'CUST' );

         END;
         END IF;
         DBMS_OUTPUT.PUT_LINE('Sudesh');
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SourceName
         FROM A ,tt_CUST_POSTMOC_2 A
                JOIN DIMSOURCEDB B   ON A.SourceSystemAlt_Key1 = B.SourceAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SourceName = src.SourceName;
         --Select 'tt_CUST_POSTMOC_2',MOCReason_1, * from tt_CUST_POSTMOC_2
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.ParameterAlt_Key, ' ') AS MOCReason
         FROM A ,tt_CUST_POSTMOC_2 A
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
                   A.AccountID ,
                   A.FraudDate ,
                   A.TwoDate ,
                   A.InterestReceivable ,
                   C.AssetClassName AssetClass  ,
                   A.NPADate NPADate  ,
                   A.SecurityValue ,
                   B.BookValue ,
                   UTILS.CONVERT_TO_VARCHAR2(B.SMADate,20,p_style=>103) SMADate  ,
                   B.SMASubAssetClassValue ,
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
                   (CASE 
                         WHEN DB.SourceName IS NOT NULL THEN DB.SourceName
                   ELSE DB1.SourceName
                      END) SourceName  
              FROM tt_CUST_PREMOC_2 A
                     LEFT JOIN tt_CUST_POSTMOC_2 B   ON A.CustomerID = b.CustomerID
                     LEFT JOIN DimAssetClass c   ON C.AssetClassAlt_Key = a.AssetClassAlt_Key
                     AND c.EffectiveFromTimeKey <= v_TimeKey
                     AND c.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = b.AssetClassAlt_Key
                     AND D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN DIMSOURCEDB dB   ON dB.SourceAlt_Key = a.SourceAlt_key
                     AND db.EffectiveFromTimeKey <= v_TimeKey
                     AND db.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN DIMSOURCEDB dB1   ON dB1.SourceAlt_Key = b.SourceSystemAlt_Key1
                     AND db1.EffectiveFromTimeKey <= v_TimeKey
                     AND db1.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         DBMS_OUTPUT.PUT_LINE('Priyali');
         IF utils.object_id('tempdb..tt_MOCAuthorisation_9') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOCAuthorisation_9 ';

         END;
         END IF;
         DELETE FROM tt_MOCAuthorisation_9;
         UTILS.IDENTITY_RESET('tt_MOCAuthorisation_9');

         INSERT INTO tt_MOCAuthorisation_9 ( 
         	SELECT * ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
         	  FROM CalypsoCustomerLevelMOC_Mod A
         	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
                    AND A.EffectiveToTimeKey >= v_Timekey
                    AND UCIFID = v_UCICID
                    AND UCIFID IS NOT NULL
                    AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                          FROM CalypsoCustomerLevelMOC_Mod 
                                           WHERE  EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey
                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                            GROUP BY UCIFID )
          );
         --Select ' tt_MOCAuthorisation_9',* from  tt_MOCAuthorisation_9
         --where abc=1
         UPDATE tt_MOCAuthorisation_9 V
            SET ErrorMessage = CASE 
                                    WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through UCIC MOC – Authorization’ menu'
                ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'
                   END,
                ErrorinColumn = CASE 
                                     WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCICID'
                ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCICID'
                   END
          WHERE  V.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND UCIFID = v_UCICID
           AND v_operationflag NOT IN ( 16,17,20 )
         ;
         MERGE INTO tt_MOCAuthorisation_9 Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCICID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCICID'
            END AS pos_3
         FROM CalypsoCustomerLevelMOC_Mod V
                JOIN InvestmentIssuerDetail X   ON V.UcifID = X.UcifId
                JOIN tt_MOCAuthorisation_9 Z   ON X.UcifId = Z.UCIFID 
          WHERE X.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND v_operationflag NOT IN ( 16,17,20 )

           AND Z.UCIFID = v_UCICID) src
         ON ( Z.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         MERGE INTO tt_MOCAuthorisation_9 Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCICID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCICID'
            END AS pos_3
         FROM CalypsoCustomerLevelMOC_Mod V
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail X   ON V.UcifID = X.UCIC_ID
                JOIN tt_MOCAuthorisation_9 Z   ON X.UCIC_ID = Z.UCIFID 
          WHERE X.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND v_operationflag NOT IN ( 16,17,20 )

           AND Z.UCIFID = v_UCICID) src
         ON ( Z.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_MOCAuthorisation_9 
                             WHERE  UCIFID = v_UCICID );
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
                    FROM tt_MOCAuthorisation_9  ;
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

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELNPAMOCSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
