--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );

BEGIN

   --Declare @TimeKey AS INT =26298
   IF utils.object_id('tempdb..tt_temp1_46') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_46 ';
   END IF;
   DELETE FROM tt_temp1_46;
   --------------Finacle
   INSERT INTO tt_temp1_46
     ( 
       --Select  'FinacleUpgrade' AS TableName, AccountID +'|'+Convert(Varchar(10),UpgradeDate,105) as DataUtility  
       SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Finacle'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------Ganaseva
   --Select 'GanasevaUpgrade' AS TableName, AccountID +'|'+'0'+'|'+Convert(Varchar(10),UpgradeDate,103)+'|'+'19718'+'|'+'19718' as DataUtility
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Ganaseva'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   ----------------VisionPlus
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'VisionPlus'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------MiFin
   --Select AccountID ,'STD',SubString(Replace(convert(varchar(20),UpgradeDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),UpgradeDate,106),' ','-')),2) 
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'MiFin'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------Indus
   --Select AccountID as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgradeDate,106),' ','-') as 'Value Date' 
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'Indus'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
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
   --Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   --Select 
   --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   --,UserSubClassification,NpaDate,CurrentDate
   -- from (
   --Select 
   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
   --from (
   --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
   --,A.DPD as DPD,E.AssetClassGroup as UserClassification,
   --(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60' 
   --When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )
   -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
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
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   -- Group By 
   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
   --,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
   --)A
   --)T
   --------------MetaGrid
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL as 'ENPA_D2K_NPA_DATE' 
   INSERT INTO tt_temp1_46
     ( SELECT a.SourceAlt_Key ,
              a.SourceSystemName ,
              COUNT(*)  cnt  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'MetaGrid'
                 AND A.AssetSubClass = 'STD'
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY a.SourceAlt_Key,a.SourceSystemName );
   --------------Calypso
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
   INSERT INTO tt_temp1_46
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
                 AND A.FinalAssetClassAlt_Key = 1
                 AND A.InitialAssetAlt_key <> 1 );
   --select * from tt_temp1_46
   --select * 
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF_Normal a
          JOIN tt_temp1_46 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
                                 = src.CNT;
   UPDATE StatusReport_RF_Normal
      SET Upgrade = 0
    WHERE  Upgrade IS NULL;--update StatusReport
   --set    Upgrade_Status= case when isnull(Upgrade_ACL,0)=isnull(Upgrade_RF,0) then 'True' else 'False' END

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_NORMAL" TO "ADF_CDR_RBL_STGDB";
