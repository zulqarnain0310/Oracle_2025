--------------------------------------------------------
--  DDL for Procedure CRILIC_REPORT_CUSTOMERWISE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" 
AS
   v_timekey NUMBER(10,0);

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   --SET      @Timekey =26510
   --CIF ID	ACCOUNT NUMBER	PAN	CUST_NAME	ASSETS CLASSIFICATION	DATE OF NPA	 TOTAL PROVISIONS HELD (IN LAKHS) 	PRINCIPAL OUTSTANDING
   EXECUTE IMMEDIATE ' TRUNCATE TABLE CriliC_Customer_Report ';
   INSERT INTO CriliC_Customer_Report
     SELECT b.RefCustomerID ,
            b.CustomerName ,
            b.PANNO ,
            c.AssetClassShortName AssetClass  ,
            SysNPA_Dt ,
            SUM(A.TotalProvision)  TotalProvision  ,
            SUM(PrincOutStd)  PrincOutStd  

       --into            CriliC_Customer_Report
       FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
              JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist b   ON a.CustomerEntityID = b.CustomerEntityID
              LEFT JOIN DimAssetClass c   ON b.SysAssetClassAlt_Key = c.AssetClassAlt_Key
              AND c.EffectiveToTimeKey = 49999
      WHERE  SysAssetClassAlt_Key > 1
               AND NVL(WriteOffAmount, 0) = 0
               AND a.EffectiveFromTimeKey <= v_timekey
               AND a.EffectiveToTimeKey >= v_timekey
               AND b.EffectiveFromTimeKey <= v_timekey
               AND b.EffectiveToTimeKey >= v_timekey
       GROUP BY b.RefCustomerID,b.CustomerName,b.PANNO,c.AssetClassShortName,SysNPA_Dt

        HAVING SUM(PrincOutStd)  > 50000000
       ORDER BY 1;--Select * from CriliC_Customer_Report
   ------------------------------------------------------------------------------------------------------------------------------------------------
   /*
   select			distinct b.RefCustomerID
   into #temp
   from            pro.AccountCal_Hist a
   inner join      pro.CustomerCal_Hist b
   on              a.CustomerEntityID=b.CustomerEntityID
   where           SysAssetClassAlt_Key >1
   and             a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   and             b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   group by        b.RefCustomerID
   having          sum(PrincOutStd) > 50000000  

   select			b.RefCustomerID,b.CustomerName,a.CustomerAcID,b.PANNO,a.FinalAssetClassAlt_Key,a.FinalNpaDt,sum(a.TotalProvision) TotalProvision,sum(PrincOutStd)PrincOutStd
   from            pro.AccountCal_Hist a
   inner join      pro.CustomerCal_Hist b
   on              a.CustomerEntityID=b.CustomerEntityID
   inner join      #temp c
   on              a.RefCustomerID=c.RefCustomerID
   where           a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   and             b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   group by        b.RefCustomerID,b.CustomerName,a.CustomerAcID,b.PANNO,a.FinalAssetClassAlt_Key,a.FinalNpaDt
   order by        1
   */
   -------------------------------------------------------------------------------------------------------------------
   /*
   IF OBJECT_ID('TEMPDB..#temp2') IS NOT NULL  
    DROP TABLE  #temp2  

   select			distinct b.CustomerEntityID
   into			#temp2
   from            pro.AccountCal_Hist a With(Nolock)
   inner join      pro.CustomerCal_Hist b With(Nolock)
   on              a.CustomerEntityID=b.CustomerEntityID
   where           SysAssetClassAlt_Key >1
   and             a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   and             b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   group by        b.CustomerEntityID
   having          sum(PrincOutStd) > 50000000  

   select			b.RefCustomerID,b.CustomerName,a.CustomerAcID,b.PANNO,d.AssetClassShortName AssetClass,a.FinalNpaDt,sum(a.TotalProvision) TotalProvision,sum(PrincOutStd)PrincOutStd
   from            pro.AccountCal_Hist a With(Nolock)
   inner join      pro.CustomerCal_Hist b With(Nolock)
   on              a.CustomerEntityID=b.CustomerEntityID
   inner join      #temp2 c
   on              a.CustomerEntityID=c.CustomerEntityID
   left join       DimAssetClass D With(Nolock)
   on              A.FinalAssetClassAlt_Key=D.AssetClassAlt_Key
   and             D.EffectiveToTimeKey=49999
   where           a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   and             b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   group by        b.RefCustomerID,b.CustomerName,a.CustomerAcID,b.PANNO,d.AssetClassShortName,a.FinalNpaDt
   order by        1
   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_CUSTOMERWISE_04122023" TO "ADF_CDR_RBL_STGDB";
