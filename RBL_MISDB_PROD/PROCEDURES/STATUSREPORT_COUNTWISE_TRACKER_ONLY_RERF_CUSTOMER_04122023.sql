--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @TimeKey as Int=26460    
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
   --select replace(convert(varchar(11),@Date,113),'','-') 'RF Count Date'            
   --select  replace(convert(varchar(10),@Date,103),'/','-') 'RF Data file dated'   
   --update StatusReport_Only_RERF            
   --set    ACL=0   ,Degrade=0,Upgrade=0        
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_Only_RERF_Customer ';
   INSERT INTO StatusReport_Only_RERF_Customer
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   --------------Finacle            
   IF utils.object_id('tempdb..tt_temp1_51') IS NOT NULL THEN
    --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )            
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )            
   --Declare @TimeKey AS INT =26298            
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_51 ';
   END IF;
   DELETE FROM tt_temp1_51;
   /*  

       INSERT INTO tt_temp1_51            
      SELECT SourceAlt_Key,SourceName,COUNT(*)            
      FROM(            
      Select * from(            
      Select b.SourceAlt_Key,b.SourceName,A.CustomerID            
      from ReverseFeedData A            
      Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
      And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
      Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
      And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
       where B.SourceName='Finacle'            
       --And A.AssetSubClass<>'STD'            
       AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

       UNION            

       Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
       from Pro.AccountCal_hist A wITH (NOLOCK)            
      Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
      And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
      Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
      And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
       where B.SourceName='Finacle'            
       And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
       ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date            
       AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

       )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            

       --------------Ganaseva            
         INSERT INTO tt_temp1_51            
      SELECT SourceAlt_Key,SourceName,COUNT(*)            
      FROM(            
      Select * from(            
      Select b.SourceAlt_Key,b.SourceName,A.CustomerID from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='Ganaseva'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        UNION             

        Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
        --Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ Convert(Varchar(10),'2022-01-16',103) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,103),'')  as DataU





   --tility             
      from Pro.AccountCal_hist A wITH (NOLOCK)            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='Ganaseva'            
        And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
        ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            


              --------------ECBF            
       INSERT INTO tt_temp1_51            
       SELECT SourceAlt_Key,SourceName,COUNT(*)            
       FROM(            
       Select * from(            
       Select b.SourceAlt_Key,b.SourceName,A.CustomerID             
       from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='ECBF'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        UNION            

        --Select A.RefCustomerID as CustomerID,A.UCIF_ID as UCIC,E.SrcSysClassCode as Asset_Code,E.SrcSysClassName as Description, Convert(Varchar(10),@Date,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as D2KNpaDate            
        Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
        from Pro.AccountCal_hist A wITH (NOLOCK)            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='ECBF'            
        And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
        ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            

            --------------Indus            
         INSERT INTO tt_temp1_51            
       SELECT SourceAlt_Key,SourceName,COUNT(*)            
       FROM(            
       Select * from(            
       Select b.SourceAlt_Key,b.SourceName,A.CustomerID             
       from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='Indus'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        UNION             

        --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCI 




   --C          

       Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
       from Pro.AccountCal_hist A wITH (NOLOCK)            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='Indus'            
        And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
        ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)       ------Added INitial and Final NPA Date            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            


             --------------MiFin            
        INSERT INTO tt_temp1_51            
       SELECT SourceAlt_Key,SourceName,COUNT(*)            
       FROM(            
       Select * from(            
       Select b.SourceAlt_Key,b.SourceName,A.CustomerID             
       from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='MiFin'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        UNION             

        --Select A.RefCustomerID as CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.FinalNpaDt,106),' ','-'),'')  as D2kNpaDate           

       Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
       from Pro.AccountCal_hist A wITH (NOLOCK)            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='MiFin'            
        And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
        ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

         )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            


             --------------VisionPlus            
        INSERT INTO tt_temp1_51            
       SELECT SourceAlt_Key,SourceName,COUNT(*)            
       FROM(            
       Select * from(            
       Select b.SourceAlt_Key,b.SourceName,A.CustomerID  from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='VisionPlus'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        UNION            

        --Select'VisionPlusAssetClassification' AS TableName, (A.UCIF_ID+'|'+A.RefCustomerID+'|'+E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+Convert(Varchar(10),@Date,105))+'|'+ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility            
         Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID            
         from Pro.AccountCal_hist A wITH (NOLOCK)            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='VisionPlus'            
        And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1             
        ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

        )A Group By CustomerID,SourceAlt_Key,SourceName            
       )B Group By SourceAlt_Key,SourceName            




            --------------MetaGrid            
    INSERT INTO tt_temp1_51            
       SELECT A.SourceAlt_Key,B.SourceName,COUNT(*)            
       from ReverseFeedData A            
       Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
       And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey            
       Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            
       And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey            
        where B.SourceName='MetaGrid'            
        --And A.AssetSubClass<>'STD'            
        AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
        GROUP BY A.SourceAlt_Key,B.SourceName            

            --------------Calypso            

   INSERT INTO tt_temp1_51            
   select 7 as SourceAlt_Key,'Calypso' as SourceName,count(*)            
    from dbo.InvestmentFinancialDetail A            
   Inner Join dbo.investmentbasicdetail B ON A.InvEntityId=B.InvEntityId            
   AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey            
   Inner Join dbo.InvestmentIssuerDetail C ON C.IssuerEntityId=B.IssuerEntityId            
   AND C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey            
   Inner Join ReverseFeedCalypso D ON D.issuerId=C.IssuerID            
   AND D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey            
   Inner Join DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key            
   AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey            
   Where  A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey            
   AND A.FinalAssetClassAlt_Key<>A.InitialAssetAlt_key            

   */
   --select * from tt_temp1_51            
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_Only_RERF_Customer a
          JOIN tt_temp1_51 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.ACL = src.CNT;
   UPDATE StatusReport_Only_RERF_Customer
      SET ACL = 0
    WHERE  ACL IS NULL;
   --update StatusReport            
   --set    Total_RF_ACL_Status= case when Total_ACL_Count=Total_ACL_RF_Count then 'True'            
   --         else 'False' end            
   RBL_MISDB_PROD.StatusReport_CountWise_Degrade_Tracker_only_RERF_Customer() ;
   RBL_MISDB_PROD.StatusReport_CountWise_Upgrade_Tracker_Only_RERF_Customer() ;
   OPEN  v_cursor FOR
      SELECT SourceName ,
             ACL ,
             Degrade ,
             Upgrade 
        FROM StatusReport_Only_RERF_Customer 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
