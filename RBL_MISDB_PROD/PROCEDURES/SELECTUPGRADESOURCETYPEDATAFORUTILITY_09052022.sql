--------------------------------------------------------
--  DDL for Procedure SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" 
--dbo.SelectUpgradeSourceTypeDataForUtility 'Finacle'

(
  v_SourceType IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --------------Finacle
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @TimeKey AS INT =26298
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'FinacleUpgrade' TableName  ,
                AccountID || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>105) DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Finacle'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      OPEN  v_cursor FOR
         SELECT 'GanasevaUpgrade' TableName  ,
                AccountID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------MiFin
      OPEN  v_cursor FOR
         SELECT AccountID ,
                'STD' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MiFin'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      OPEN  v_cursor FOR
         SELECT AccountID Loan_Account_Number  ,
                'STD' MAIN_STATUS_OF_ACCOUNT  ,
                'STD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-') Value_Date  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.AssetSubClass = 'STD'
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
      		,UserSubClassification,NpaDate,CurrentDate

      		 from (
      		Select 
      		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
      		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
      		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

      		from (
      		Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,
      		'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
      		,A.DPD as DPD, E.AssetClassGroup as UserClassification, 'DPD0' as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
      		  from ReverseFeedData A
      		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
      		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
      		 where B.SourceName='ECBF'
      		 And A.AssetSubClass='STD'
      		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      		 Group By 
      		 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
      		,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
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
                                'NPA' SystemClassification  ,
                                'SBSTD' SystemSubClassification  ,
                                A.DPD DPD  ,
                                E.AssetClassGroup UserClassification  ,
                                (CASE 
                                      WHEN A.DPD = 0 THEN 'DPD0'
                                      WHEN A.DPD BETWEEN 1 AND 30 THEN 'DPD30'
                                      WHEN A.DPD BETWEEN 31 AND 60 THEN 'DPD60'
                                      WHEN A.DPD BETWEEN 61 AND 90 THEN 'DPD90'
                                      WHEN A.DPD BETWEEN 91 AND 180 THEN 'DPD180'
                                      WHEN A.DPD BETWEEN 181 AND 365 THEN 'PD1YR'   END) UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105) NpaDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  
                         FROM ReverseFeedData A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey

                         --Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
                         WHERE  B.SourceName = 'ECBF'
                                  AND A.AssetSubClass = 'STD'
                                  AND A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ------------------New Source-----------
   IF ( v_SourceType = 'MetaGrid' ) THEN

   BEGIN
      --------------MetaGrid
      OPEN  v_cursor FOR
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL ENPA_D2K_NPA_DATE  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MetaGrid'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -----------------------------------------------
   IF ( v_SourceType = 'Calypso' ) THEN

   BEGIN
      --------------Calypso
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
                   AND A.FinalAssetClassAlt_Key = 1
                   AND A.InitialAssetAlt_key <> 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022" TO "ADF_CDR_RBL_STGDB";
