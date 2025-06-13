--------------------------------------------------------
--  DDL for Procedure SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" 
-- dbo.SelectAssetClassificationSourceTypeDataForUtility 'GANASEVA'

(
  v_SourceType IN VARCHAR2
)
AS
   v_Dateofdata VARCHAR2(200);
   --set @Dateofdata='2022-06-30'
   v_RF_Date VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT DISTINCT date_of_data 

     INTO v_Dateofdata
     FROM dwh_DWH_STG.account_data_finacle ;
   SELECT MAX(DateofData)  

     INTO v_RF_Date
     FROM ReverseFeedData ;
   IF ( v_Dateofdata = v_RF_Date ) THEN
    DECLARE
      v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' );
      v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' );

   BEGIN
      --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )
      --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )
      IF ( v_SourceType = 'Finacle' ) THEN

      BEGIN
         --------------Finacle
         DBMS_OUTPUT.PUT_LINE('Finacle ');
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT 'FinacleAssetClassification' TableName  ,
                            A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Finacle'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT 'FinacleAssetClassification' TableName  ,
                            A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || v_Date || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
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
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              GROUP BY TableName,DataUtility ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'Ganaseva' ) THEN

      BEGIN
         --------------Ganaseva
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT 'GanasevaAssetClassification' TableName  ,
                            A.UCIF_ID || '|' || SUBSTR(A.CustomerID, 2, 8) || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>103), ' ') DataUtility  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Ganaseva'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT 'GanasevaAssetClassification' TableName  ,
                            A.UCIF_ID || '|' || SUBSTR(A.RefCustomerID, 2, 8) || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || v_Date || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>103), ' ') DataUtility  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Ganaseva'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              GROUP BY TableName,DataUtility ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'ECBF' ) THEN

      BEGIN
         --------------ECBF
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT A.CustomerID CustomerID  ,
                            A.UCIF_ID UCIC  ,
                            E.SrcSysClassCode Asset_Code  ,
                            E.SrcSysClassName DESCRIPTION  ,
                            UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) Asset_Code_Date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') D2KNpaDate  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'ECBF'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT A.RefCustomerID CustomerID  ,
                            A.UCIF_ID UCIC  ,
                            E.SrcSysClassCode Asset_Code  ,
                            E.SrcSysClassName DESCRIPTION  ,
                            v_Date Asset_Code_Date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') D2KNpaDate  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'ECBF'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              GROUP BY CustomerID,UCIC,Asset_Code,DESCRIPTION,Asset_Code_Date,D2KNpaDate ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'Indus' ) THEN

      BEGIN
         --------------Indus
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT E.AssetClassShortNameEnum asset_code  ,
                            E.SrcSysClassName DESCRIPTION  ,
                            UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) asset_code_date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') D2K_NPA_date  ,
                            A.CustomerID Customer_ID  ,
                            A.UCIF_ID UCIC  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Indus'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT E.AssetClassShortNameEnum asset_code  ,
                            E.SrcSysClassName DESCRIPTION  ,
                            v_Date asset_code_date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') D2K_NPA_date  ,
                            A.RefCustomerID Customer_ID  ,
                            A.UCIF_ID UCIC  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Indus'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              GROUP BY Asset_Code,DESCRIPTION,Asset_Code_Date,D2K_NPA_date,Customer_ID,UCIC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'MiFin' ) THEN

      BEGIN
         --------------MiFin
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT A.CustomerID ,
                            A.UCIF_ID ,
                            E.AssetClassShortNameEnum ,
                            E.AssetClassName ,
                            REPLACE(UTILS.CONVERT_TO_VARCHAR2(DateofData,20,p_style=>106), ' ', '-') Asset_Code_Date  ,
                            NVL(REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>106), ' ', '-'), ' ') D2kNpaDate  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT A.RefCustomerID CustomerID  ,
                            A.UCIF_ID ,
                            E.AssetClassShortNameEnum ,
                            E.AssetClassName ,
                            REPLACE(v_Date, ' ', '-') Asset_Code_Date  ,
                            NVL(REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>106), ' ', '-'), ' ') D2kNpaDate  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              GROUP BY CustomerID,UCIF_ID,AssetClassShortNameEnum,AssetClassName,Asset_Code_Date,D2kNpaDate ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'VisionPlus' ) THEN

      BEGIN
         --------------VisionPlus
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT 'VisionPlusAssetClassification' TableName  ,
                            ('UCIC' || '|' || 'CIF ID' || '|' || 'asset_code' || '|' || 'description' || '|' || 'asset_code_date' || '|' || 'D2K NPA date') DataUtility  
                       FROM DUAL 
                     UNION 
                     SELECT 'VisionPlusAssetClassification' TableName  ,
                            (A.UCIF_ID || '|' || A.CustomerID || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105)) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT 'VisionPlusAssetClassification' TableName  ,
                            (A.UCIF_ID || '|' || A.RefCustomerID || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || v_Date) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
              ORDER BY 2 DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      ------------MetaGrid
      IF ( v_SourceType = 'MetaGrid' ) THEN

      BEGIN
         --------------MetaGrid
         OPEN  v_cursor FOR
            SELECT A.CustomerID CIF_ID  ,
                   A.UCIF_ID UCIC  ,
                   E.SrcSysClassCode ENPA_ASSET_CODE  ,
                   CASE 
                        WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                   ELSE E.SrcSysClassName
                      END ENPA_DESCRIPTION  ,
                   REPLACE(UTILS.CONVERT_TO_VARCHAR2(DateofData,20,p_style=>105), '-', ' ') ENPA_ASSET_CODE_DATE  ,
                   CASE 
                        WHEN A.AssetSubClass <> 'STD' THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>105), '-', ' ')
                   ELSE NULL
                      END ENPA_D2K_NPA_DATE  
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
             WHERE  B.SourceName = 'MetaGrid'

                      --And A.AssetSubClass<>'STD'
                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      ------------Calypso
      IF ( v_SourceType = 'Calypso' ) THEN

      BEGIN
         --------------Calypso
         OPEN  v_cursor FOR
            SELECT 'AMEND' Action  ,
                   CASE 
                        WHEN D.CP_EXTERNAL_REF IS NULL THEN ' '
                   ELSE D.CP_EXTERNAL_REF
                      END External_Reference  ,
                   CASE 
                        WHEN D.COUNTERPARTY_SHORTNAME IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_SHORTNAME
                      END ShortName  ,
                   CASE 
                        WHEN D.COUNTERPARTY_FULLNAME IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_FULLNAME
                      END LongName  ,
                   CASE 
                        WHEN D.COUNTERPARTY_COUNTRY IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_COUNTRY
                      END Country  ,
                   CASE 
                        WHEN D.CP_FINANCIAL IS NULL THEN ' '
                   ELSE D.CP_FINANCIAL
                      END Financial  ,
                   CASE 
                        WHEN D.CP_PARENT IS NULL THEN ' '
                   ELSE D.CP_PARENT
                      END Parent  ,
                   CASE 
                        WHEN D.CP_HOLIDAY IS NULL THEN ' '
                   ELSE D.CP_HOLIDAY
                      END HolidayCode  ,
                   CASE 
                        WHEN D.CP_COMMENT IS NULL THEN ' '
                   ELSE D.CP_COMMENT
                      END Comment_  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE1 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE1
                      END Roles_Role  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE2 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE2
                      END Roles__A11  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE3 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE3
                      END Roles__A12  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE4 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE4
                      END Roles__A13  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE5 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE5
                      END Roles__A14  ,
                   CASE 
                        WHEN D.CP_STATUS IS NULL THEN ' '
                   ELSE D.CP_STATUS
                      END Status  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'CIF_Id' Attribute_AttributeName  ,
                   CASE 
                        WHEN D.CIF_ID IS NULL THEN ' '
                   ELSE D.CIF_ID
                      END Attribute_AttributeValue  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'UCIC' Attribute_AttributeName  ,
                   CASE 
                        WHEN D.ucic_id IS NULL THEN ' '
                   ELSE D.ucic_id
                      END Attribute_AttributeV_A23  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_ASSET_CODE' Attribute_AttributeName  ,
                   CASE 
                        WHEN E.SrcSysClassCode IS NULL THEN ' '
                   ELSE E.SrcSysClassCode
                      END Attribute_AttributeV_A27  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_DESCRIPTION' Attribute_AttributeName  ,
                   CASE 
                        WHEN E.SrcSysClassName IS NULL THEN ' '
                   ELSE E.SrcSysClassName
                      END Attribute_AttributeV_A31  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_ASSET_CODE_DATE' Attribute_AttributeName  ,
                   CASE 
                        WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                   ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                      END Attribute_AttributeV_A35  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_D2K_NPA_DATE' Attribute_AttributeName  ,
                   CASE 
                        WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                   ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                      END Attribute_AttributeV_A39  
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
                      AND A.FinalAssetClassAlt_Key <> A.InitialAssetAlt_key ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   ELSE

   BEGIN
      utils.raiserror( 0, 'ACL Failed' );

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_01072022" TO "ADF_CDR_RBL_STGDB";
