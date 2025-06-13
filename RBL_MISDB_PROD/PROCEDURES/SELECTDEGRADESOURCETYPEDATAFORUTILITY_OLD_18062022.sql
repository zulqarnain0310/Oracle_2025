--------------------------------------------------------
--  DDL for Procedure SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" 
(
  v_SourceType IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @TimeKey AS INT =26298
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      --Select  'FinacleDegrade' AS TableName, AccountID +'|'+ 
      --Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else
      --  Convert(Varchar(10),NPADate,105) End  as DataUtility from ReverseFeedData A								--- As per Bank Revised mail on 05-01-2022  
      --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID
      --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
      -- where B.SourceName='Finacle'
      -- And A.AssetSubClass<>'STD'
      -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      /* =================================Added by Prashant to change the Finacle logic=========================== */
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'FinacleDegrade' TableName  ,
                         AccountID || '|' || CASE 
                                                  WHEN NVL(NPADate, '1900-01-01') < NVL(AcOpenDt, '1900-01-01') THEN UTILS.CONVERT_TO_VARCHAR2(AcOpenDt,10,p_style=>105) || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>105)
                         ELSE UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>105) || '|'
                            END DataUtility  
                  FROM ReverseFeedData A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON A.AccountID = C.CustomerAcID
                         AND C.EffectiveFromTimekey <= v_TimeKey
                         AND C.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.AssetSubClass <> 'STD'
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                  UNION 
                  SELECT 'FinacleDegrade' TableName  ,
                         customeracid || '|' || UTILS.CONVERT_TO_VARCHAR2(a.FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                         AND E.EffectiveFromTimeKey <= v_TimeKey
                         AND E.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.InitialAssetClassAlt_Key > 1
                            AND A.FinalAssetClassAlt_Key > 1
                            AND A.InitialNpaDt <> A.FinalNpaDt
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY TableName,DataUtility ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   /*================================================ END ======================================================================*/
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      OPEN  v_cursor FOR
         SELECT 'GanasevaDegrade' TableName  ,
                AccountID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------mifin
      OPEN  v_cursor FOR
         SELECT AccountID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MiFin'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A
      --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      -- where B.SourceName='MiFin'
      -- And A.AssetSubClass<>'STD'
      -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      OPEN  v_cursor FOR
         SELECT AccountID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-') Value_Date  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      /*

      			Select 
      			SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
      			,UserSubClassification,ValueDate,CurrentDate from ( Select ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
      			ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
      			, DPD, UserClassification, UserSubClassification, ValueDate, CurrentDate
      			from (
      			Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,E.SrcSysClassCode as SystemSubClassification
      			,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as ValueDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
      			  from ReverseFeedData A
      			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
      			And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
      			 where B.SourceName='ECBF'
      			 And A.AssetSubClass<>'STD'
      			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      			 Group By 
      			 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
      			,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)
      			)A
      			)T

      		*/
      OPEN  v_cursor FOR
         SELECT SrNo ,
                ProductType ,
                ClientName ,
                ClientCustId ,
                SystemClassification ,
                SystemSubClassification ,
                DPD ,
                UserClassification ,
                UserSubClassification ,
                NpaDate ,
                CurrentDate 
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
                         ProductType ,
                         ClientName ,
                         ClientCustId ,
                         SystemClassification ,
                         SystemSubClassification ,
                         DPD ,
                         UserClassification ,
                         UserSubClassification ,
                         NpaDate ,
                         CurrentDate 
                  FROM ( SELECT A.ProductName ProductType  ,
                                A.CustomerName ClientName  ,
                                A.CustomerID ClientCustId  ,
                                E.AssetClassGroup SystemClassification  ,
                                CASE 
                                     WHEN E.SrcSysClassCode = 'SS' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                                     WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                                     WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                                ELSE E.SrcSysClassCode
                                   END SystemSubClassification  ,
                                A.DPD DPD  ,
                                'NPA' UserClassification  ,
                                'SBSTD' UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) NpaDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  
                         FROM ReverseFeedData A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                          WHERE  B.SourceName = 'ECBF'
                                   AND A.AssetSubClass <> 'STD'
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MetaGrid' ) THEN

   BEGIN
      ---------MetaGrid
      OPEN  v_cursor FOR
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(NpaDate,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MetaGrid'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ----------------------
   IF ( v_SourceType = 'Calypso' ) THEN

   BEGIN
      ---------Calypso
      OPEN  v_cursor FOR
         SELECT 'AMEND' Action  ,
                D.CP_EXTERNAL_REF External_Reference  ,
                D.COUNTERPARTY_SHORTNAME ShortName  ,
                D.COUNTERPARTY_FULLNAME LongName  ,
                D.COUNTERPARTY_COUNTRY Country  ,
                D.CP_FINANCIAL Financial  ,
                D.CP_PARENT Parent  ,
                D.CP_HOLIDAY HolidayCode  ,
                D.CP_COMMENT Comment_  ,
                D.COUNTERPARTY_ROLE1 Roles_Role  ,
                D.COUNTERPARTY_ROLE2 Roles__A11  ,
                D.COUNTERPARTY_ROLE3 Roles__A12  ,
                D.COUNTERPARTY_ROLE4 Roles__A13  ,
                D.COUNTERPARTY_ROLE5 Roles__A14  ,
                D.CP_STATUS Status  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'CIF_Id' Attribute_AttributeName  ,
                D.CIF_ID Attribute_AttributeValue  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'UCIC' Attribute_AttributeName  ,
                D.ucic_id Attribute_AttributeV_A23  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'ENPA_D2K_NPA_DATE' Attribute_AttributeName  ,
                CASE 
                     WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                   END Attribute_AttributeV_A27  
           FROM RBL_MISDB_PROD.InvestmentFinancialDetail A
                  JOIN RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
                  AND B.EffectiveFromTimeKey <= v_Timekey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                  AND C.EffectiveFromTimeKey <= v_Timekey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  JOIN ReversefeedCalypso D   ON D.issuerId = C.IssuerID
                  AND D.EffectiveFromTimeKey <= v_Timekey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_Timekey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND A.FinalAssetClassAlt_Key <> 1
                   AND A.InitialAssetAlt_key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'SettlementLitigation' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'SettlementLitigation' TableName  ,
                         'ACCOUNT_NO|Date|Flag' DataUtility  
                    FROM DUAL 
                  UNION 
                  SELECT 'SettlementLitigation' TableName  ,
                         ACID || '|' || UTILS.CONVERT_TO_VARCHAR2(DateOfData,10,p_style=>105) || '|' || AcctFlag DataUtility  
                  FROM ( SELECT A.ACID ,
                                UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                                'L' AcctFlag  
                         FROM ExceptionFinalStatusType a
                                LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                                AND b.EffectiveFromTimeKey <= v_timekey
                                AND b.EffectiveToTimeKey >= v_timekey
                                AND b.AcctFlag = 'L'
                                JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                                AND C.EffectiveFromTimeKey <= v_timekey
                                AND C.EffectiveToTimeKey >= v_timekey
                                JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                                AND D.EffectiveFromTimeKey <= v_timekey
                                AND D.EffectiveToTimeKey >= v_timekey
                          WHERE  a.StatusType = 'Litigation'
                                   AND b.AccountId IS NULL
                                   AND a.EffectiveFromTimeKey <= v_timekey
                                   AND a.EffectiveToTimeKey >= v_timekey
                                   AND D.SourceName = 'Finacle'
                                   AND c.FacilityType IN ( 'CC','OD' )

                         UNION 
                         SELECT A.ACID AccountId  ,
                                UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                                'S' AcctFlag  
                         FROM ExceptionFinalStatusType a -----OTS_Details a

                                LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                                AND b.EffectiveFromTimeKey <= v_timekey
                                AND b.EffectiveToTimeKey >= v_timekey
                                AND b.AcctFlag = 'S'
                                JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                                AND C.EffectiveFromTimeKey <= v_timekey
                                AND C.EffectiveToTimeKey >= v_timekey
                                JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                                AND D.EffectiveFromTimeKey <= v_timekey
                                AND D.EffectiveToTimeKey >= v_timekey
                          WHERE  a.StatusType = 'Settlement'
                                   AND b.AccountId IS NULL
                                   AND a.EffectiveFromTimeKey <= v_timekey
                                   AND a.EffectiveToTimeKey >= v_timekey
                                   AND D.SourceName = 'Finacle'
                                   AND c.FacilityType IN ( 'CC','OD' )
                        ) A ) B
           ORDER BY 2 DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_OLD_18062022" TO "ADF_CDR_RBL_STGDB";
