--------------------------------------------------------
--  DDL for Procedure CRILIC_REPORT_ACCOUNTWISE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" 
AS
   v_timekey NUMBER(10,0);

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   ----SET      @Timekey =26510
   ----CIF ID	ACCOUNT NUMBER	PAN	CUST_NAME	ASSETS CLASSIFICATION	DATE OF NPA	 TOTAL PROVISIONS HELD (IN LAKHS) 	PRINCIPAL OUTSTANDING
   --select			b.RefCustomerID,b.CustomerName,b.PANNO,c.AssetClassShortName AssetClass,SysNPA_Dt,sum(a.TotalProvision) TotalProvision,sum(PrincOutStd)PrincOutStd
   --from            pro.AccountCal_Hist a
   --inner join      pro.CustomerCal_Hist b
   --on              a.CustomerEntityID=b.CustomerEntityID
   --left join       DimAssetClass c
   --on              b.SysAssetClassAlt_Key=c.AssetClassAlt_Key
   --and             c.EffectiveToTimeKey=49999
   --where           SysAssetClassAlt_Key >1
   --and             a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   --and             b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   --group by        b.RefCustomerID,b.CustomerName,b.PANNO,c.AssetClassShortName,SysNPA_Dt
   --having          sum(PrincOutStd) > 50000000  
   --order by 1
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
   IF utils.object_id('TEMPDB..tt_temp2_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_4 ';
   END IF;
   DELETE FROM tt_temp2_4;
   UTILS.IDENTITY_RESET('tt_temp2_4');

   INSERT INTO tt_temp2_4 ( 
   	SELECT DISTINCT b.CustomerEntityID 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist b   ON a.CustomerEntityID = b.CustomerEntityID
   	 WHERE  SysAssetClassAlt_Key > 1
              AND NVL(WriteOffAmount, 0) = 0
              AND a.EffectiveFromTimeKey <= v_timekey
              AND a.EffectiveToTimeKey >= v_timekey
              AND b.EffectiveFromTimeKey <= v_timekey
              AND b.EffectiveToTimeKey >= v_timekey
   	  GROUP BY b.CustomerEntityID

   	   HAVING SUM(PrincOutStd)  > 50000000 );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE CriliC_Account_Report ';
   INSERT INTO CriliC_Account_Report
     SELECT b.RefCustomerID ,
            b.CustomerName ,
            A.CustomerAcID ,
            b.PANNO ,
            D.AssetClassShortName AssetClass  ,
            A.FinalNpaDt ,
            SUM(A.TotalProvision)  TotalProvision  ,
            SUM(PrincOutStd)  PrincOutStd  
       FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
              JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist b   ON a.CustomerEntityID = b.CustomerEntityID
              JOIN tt_temp2_4 c   ON a.CustomerEntityID = c.CustomerEntityID
              LEFT JOIN DimAssetClass D   ON A.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
              AND D.EffectiveToTimeKey = 49999
      WHERE  a.EffectiveFromTimeKey <= v_timekey
               AND a.EffectiveToTimeKey >= v_timekey
               AND b.EffectiveFromTimeKey <= v_timekey
               AND b.EffectiveToTimeKey >= v_timekey
       GROUP BY b.RefCustomerID,b.CustomerName,a.CustomerAcID,b.PANNO,D.AssetClassShortName,a.FinalNpaDt
       ORDER BY 1;--select * from CriliC_Account_Report

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CRILIC_REPORT_ACCOUNTWISE_04122023" TO "ADF_CDR_RBL_STGDB";
