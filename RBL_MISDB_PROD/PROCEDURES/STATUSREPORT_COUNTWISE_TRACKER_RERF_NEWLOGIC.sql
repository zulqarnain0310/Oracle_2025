--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_RF ';
   INSERT INTO StatusReport_RF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   --------------Finacle
   IF utils.object_id('tempdb..tt_temp1_52') IS NOT NULL THEN
    --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )
   --Declare @TimeKey AS INT =26298
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_52 ';
   END IF;
   DELETE FROM tt_temp1_52;
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Ganaseva
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  

                     --Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ Convert(Varchar(10),'2022-01-16',103) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,103),'')  as DataUtility 
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------ECBF
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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

                     --Select A.RefCustomerID as CustomerID,A.UCIF_ID as UCIC,E.SrcSysClassCode as Asset_Code,E.SrcSysClassName as Description, Convert(Varchar(10),@Date,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as D2KNpaDate
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Indus
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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

                     --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MiFin
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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

                     --Select A.RefCustomerID as CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.FinalNpaDt,106),' ','-'),'')  as D2kNpaDate 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------VisionPlus
   INSERT INTO tt_temp1_52
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
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

                     --Select'VisionPlusAssetClassification' AS TableName, (A.UCIF_ID+'|'+A.RefCustomerID+'|'+E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+Convert(Varchar(10),@Date,105))+'|'+ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MetaGrid
   INSERT INTO tt_temp1_52
     ( SELECT A.SourceAlt_Key ,
              B.SourceName ,
              COUNT(*)  
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
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY A.SourceAlt_Key,B.SourceName );
   --------------Calypso
   INSERT INTO tt_temp1_52
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
                 AND A.FinalAssetClassAlt_Key <> A.InitialAssetAlt_key );
   --select * from tt_temp1_52
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF a
          JOIN tt_temp1_52 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.ACL = src.CNT;
   UPDATE StatusReport_RF
      SET ACL = 0
    WHERE  ACL IS NULL;
   --update StatusReport
   --set    Total_RF_ACL_Status= case when Total_ACL_Count=Total_ACL_RF_Count then 'True'
   --								 else 'False' end
   StatusReport_CountWise_Degrade_Tracker() ;
   StatusReport_CountWise_Upgrade_Tracker() ;
   OPEN  v_cursor FOR
      SELECT REPLACE(v_Date, ' ', '-') RF_Count_Date  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT REPLACE(v_Date, '/', '-') RF_Data_file_dated  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT SourceName ,
             ACL ,
             Degrade ,
             Upgrade 
        FROM StatusReport_RF 
        ORDER BY ACL DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_NEWLOGIC" TO "ADF_CDR_RBL_STGDB";
