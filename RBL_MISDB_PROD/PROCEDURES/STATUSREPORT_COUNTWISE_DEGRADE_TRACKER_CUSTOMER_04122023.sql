--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );

BEGIN

   -- Declare @TimeKey as INT=26460
   IF utils.object_id('tempdb..tt_temp2_24') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_24 ';
   END IF;
   DELETE FROM tt_temp2_24;
   --------------Finacle  
   --Select  'FinacleDegrade' AS TableName, AccountID +'|'+   
   --Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else  
   --  Convert(Varchar(10),NPADate,105) End  as DataUtility   
   --==============================================================  
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
       FROM ReverseFeedData A --- As per Bank Revised mail on 05-01-2022    

              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON A.CustomerID = C.RefCustomerID
              AND C.EffectiveFromTimekey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Finacle'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --===================================================================================================================  
   --   INSERT INTO tt_temp2_24  
   --   select SourceAlt_Key,SourceSystemName,sum(cnt) cnt from (  
   --Select  a.SourceAlt_Key,a.SourceSystemName,count(*) cnt  
   --from ReverseFeedData A  
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key  
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey  
   --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID  
   --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey  
   --where B.SourceName='Finacle'  
   --And A.AssetSubClass<>'STD'  
   --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey   
   --group by a.SourceAlt_Key,a.SourceSystemName  
   --union  
   ----select * from DIMSOURCEDB  
   --Select a.SourceAlt_Key,b.SourceName,count(*) cnt  
   -- from Pro.AccountCal_hist A wITH (NOLOCK)  
   --   Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key  
   --   And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey  
   --   Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key  
   --   And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey  
   --    where B.SourceName='Finacle'  
   --    And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1   
   --    ANd  A.InitialNpaDt<>A.FinalNpaDt       
   --    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey  
   --    group by a.SourceAlt_Key,b.SourceName  
   --)A Group by SourceAlt_Key,SourceSystemName  
   --====================================================================================================================  
   --------------Ganaseva  
   --Select 'GanasevaDegrade' AS TableName, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility   
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Ganaseva'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   ----------------VisionPlus  
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'VisionPlus'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------mifin  
   --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2)   
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'MiFin'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------Indus  
   --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A  
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key  
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey  
   -- where B.SourceName='MiFin'  
   -- And A.AssetSubClass<>'STD'  
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey  
   --Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date'   
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Indus'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
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
   --Select   
   --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification  
   --,UserSubClassification,NpaDate,CurrentDate  
   -- from (  
   --Select   
   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,  
   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification  
   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate  
   --from (  
   --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,  
   --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02'   
   --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification  
   --,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate  
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
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
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode   
   --,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)  
   --)A  
   --)T  
   ---------MetaGrid  
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE'   
   INSERT INTO tt_temp2_24
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(DISTINCT CustomerID)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'MetaGrid'
                 AND A.AssetSubClass <> 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   ---------Calypso  
   --Select   
   --'AMEND' as [Action]  
   --,D.CP_EXTERNAL_REF as [External Reference]  
   --,D.COUNTERPARTY_SHORTNAME as [ShortName]  
   --,D.COUNTERPARTY_FULLNAME as [LongName]  
   --,D.COUNTERPARTY_COUNTRY as [Country]  
   --,D.CP_FINANCIAL as [Financial]  
   --,D.CP_PARENT  as [Parent]         
   --,D.CP_HOLIDAY as [HolidayCode]  
   --,D.CP_COMMENT as [Comment]  
   --,D.COUNTERPARTY_ROLE1 as [Roles.Role]  
   --,D.COUNTERPARTY_ROLE2 as [Roles.Role]  
   --,D.COUNTERPARTY_ROLE3 as [Roles.Role]  
   --,D.COUNTERPARTY_ROLE4 as [Roles.Role]  
   --,D.COUNTERPARTY_ROLE5 as [Roles.Role]  
   --,D.CP_STATUS  as [Status]  
   --,'ALL' as [Attribute.Role]  
   --,'ALL'  as [Attribute.ProcessingOrg]  
   --,'CIF_Id' as [Attribute.AttributeName]  
   --,D.CIF_ID as [Attribute.AttributeValue]  
   --,'ALL' as [Attribute.Role]  
   --,'ALL' as [Attribute.ProcessingOrg]  
   --,'UCIC' as [Attribute.AttributeName]  
   --,D.ucic_id as [Attribute.AttributeValue]  
   --,'ALL' as [Attribute.Role]  
   --,'ALL' as [Attribute.ProcessingOrg]  
   --,'ENPA_D2K_NPA_DATE' as [Attribute.AttributeName]  
   --,Case When A.NPIDt is null then ISNULL(Cast(A.NPIDt as varchar(20)),'') else Convert(varchar(20),A.NPIDt,105) end  as [Attribute.AttributeValue]  
   INSERT INTO tt_temp2_24
     ( SELECT 7 SourceAlt_Key  ,
              'Calypso' SourceName  ,
              COUNT(*)  
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
                 AND A.InitialAssetAlt_key = 1 );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF_Customer a
          JOIN tt_temp2_24 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Degrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END  
                                 = src.CNT;
   UPDATE StatusReport_RF_Customer
      SET Degrade = 0
    WHERE  Degrade IS NULL;--update StatusReport_RF  
   --set    Degrade_Status= case when isnull(Degrade_ACL,0)=isnull(Degrade_RF,0) then 'True' else 'False' END  

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
