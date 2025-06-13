--------------------------------------------------------
--  DDL for Procedure VALIDATIONCONTROLSCRIPTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" 
AS
   v_TIMEKEY NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C' );
   v_PROCESSINGDATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_Cost FLOAT(53) := 1;
   v_SUB_Days NUMBER(10,0) := ( SELECT RefValue 
     FROM PRO_RBL_MISDB_PROD.RefPeriod 
    WHERE  BusinessRule = 'SUB_Days' );
   v_DB1_Days NUMBER(10,0) := ( SELECT RefValue 
     FROM PRO_RBL_MISDB_PROD.RefPeriod 
    WHERE  BusinessRule = 'DB1_Days' );
   v_DB2_Days NUMBER(10,0) := ( SELECT RefValue 
     FROM PRO_RBL_MISDB_PROD.RefPeriod 
    WHERE  BusinessRule = 'DB2_Days' );
   v_MoveToDB1 NUMBER(5,2) := ( SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) 
     FROM PRO_RBL_MISDB_PROD.RefPeriod 
    WHERE  BusinessRule = 'MoveToDB1'
             AND EffectiveFromTimeKey <= v_TIMEKEY
             AND EffectiveToTimeKey >= v_TIMEKEY );
   v_MoveToLoss NUMBER(5,2) := ( SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) 
     FROM PRO_RBL_MISDB_PROD.RefPeriod 
    WHERE  BusinessRule = 'MoveToLoss'
             AND EffectiveFromTimeKey <= v_TIMEKEY
             AND EffectiveToTimeKey >= v_TIMEKEY );

BEGIN

   --------------------1. Completeness of the data flowing in the ENPA system--------------------
   --------------------2. Exceptional Standard Facilities 90--------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 2
             AND ExceptionDescription = 'Exceptional Standard Facilities 90'
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              2 ExceptionCode  ,
              'Exceptional Standard Facilities 90' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  DPD_Max > 90
                 AND Ah.FinalAssetClassAlt_Key = 1
                 AND Ah.Asset_Norm <> 'ALWYS_STD' );
   --AND (ISNULL(DimProduct.PRODUCTGROUP,'N')='KCC'
   --OR ((LineCode LIKE '%CROP_OD_F%' or LineCode LIKE '%CROP_DLOD%' or LineCode LIKE '%CROP_TL_F%'))
   --OR( (ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%' OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%' OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
   -- OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST HYPOTHEC%' OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%' OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
   -- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
   -- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
   -- OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
   -- OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
   -- OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%'
   -- ))
   --) 
   --------------------2. Exceptional Standard Facilities 90--------------------
   --------------------2. Exceptional Standard Facilities 365--------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 2
             AND ExceptionDescription = 'Exceptional Standard Facilities 365'
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              2 ExceptionCode  ,
              'Exceptional Standard Facilities 365' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  DPD_Max > 365
                 AND Ah.FinalAssetClassAlt_Key = 1
                 AND Ah.Asset_Norm <> 'ALWYS_STD'
                 AND ( NVL(DimProduct.ProductGroup, 'N') = 'KCC'
                 OR ( ( LineCode LIKE '%CROP_OD_F%'
                 OR LineCode LIKE '%CROP_DLOD%'
                 OR LineCode LIKE '%CROP_TL_F%' ) )
                 OR ( ( ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%'
                 OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%'
                 OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
                 OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST HYPOTHEC%'
                 OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%'
                 OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
                 OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
                 OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
                 OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
                 OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
                 OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%' ) ) ) );
   --------------------2. Exceptional Standard Facilities 365--------------------
   ------------------3. Exceptional NPA Facilities------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 3
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              3 ExceptionCode  ,
              'Exceptional NPA Facilities' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  DPD_Max <= 90
                 AND Ah.FinalAssetClassAlt_Key > 1
                 AND Ah.Asset_Norm <> 'ALWYS_NPA'
                 AND AH.DegReason NOT LIKE '%Percolation%' );
   ------------------3. Exceptional NPA Facilities------------------
   ------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 
   DELETE ControlScripts

    WHERE  ExceptionCode = 4
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              4 ExceptionCode  ,
              'Fresh Slippages Not tagged as Sub Standard' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  CH.FlgDeg = 'Y'
                 AND AH.FinalAssetClassAlt_Key IN ( 3,4,5,6 )
      );
   ------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 
   ------------------------5. Exceptional aging of NPA facilities------------------
   ------Delete from ControlScripts
   ------where ExceptionCode=5 
   ------and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')
   ------Insert into ControlScripts
   ------(
   ------UCIF_ID
   ------,PANNO
   ------,CustomerAcID
   ------,RefCustomerID
   ------,SourceSystemCustomerID
   ------,CustomerName
   ------,SourceName
   ------,DPD_Max
   ------,POS
   ------,BalanceInCrncy
   ------,Balance
   ------,SysNPA_Dt
   ------,FinalAssetClassName
   ------,ExceptionCode
   ------,ExceptionDescription
   ------,EffectiveFromTimeKey
   ------,EffectiveToTimeKey
   ------)
   ------SELECT  
   ------CH.UCIF_ID
   ------,CH.PanNO
   ------,AH.CustomerAcID
   ------,AH.RefCustomerID
   ------,AH.SourceSystemCustomerID
   ------,CH.CustomerName
   ------,DB.SourceName
   ------,AH.DPD_Max
   ------,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
   ------,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
   ------,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
   ------,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
   ------,DA.AssetClassShortName                          AS FinalAssetClassName
   ------,5 AS ExceptionCode
   ------,'Exceptional aging of NPA facilities'  AS ExceptionDescription
   ------,AH.EffectiveFromTimeKey
   ------,AH.EffectiveToTimeKey
   ------FROM PRO.CUSTOMERCAL_HIST CH
   ------INNER JOIN PRO.ACCOUNTCAL_HIST      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
   ------														  AH.EffectiveFromTimeKey<=@Timekey AND
   ------														  AH.EffectiveToTimeKey>=@Timekey AND
   ------														  CH.EffectiveFromTimeKey<=@Timekey AND
   ------		                                                  CH.EffectiveToTimeKey>=@Timekey
   ------INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
   ------                                                           DB.EffectiveFromTimeKey<=@Timekey AND
   ------													       DB.EffectiveToTimeKey>=@Timekey
   ------INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
   ------                                                           DA.EffectiveFromTimeKey<=@Timekey AND
   ------													       DA.EffectiveToTimeKey>=@Timekey
   ------INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
   ------                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
   ------													        DimAssetClass.EffectiveToTimeKey>=@Timekey
   ------LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
   ------                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
   ------													       DimProduct.EffectiveToTimeKey>=@Timekey
   ------LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
   ------			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
   ------														   DimCurrency.EffectiveToTimeKey>=@Timekey
   ------where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5)
   ------   --CASE  WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
   ------			--							  WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
   ------			--						      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
   ------			--						       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
   ------			--						   END)
   ------   --       ,A.DBTDT= (CASE 
   ------			--						       WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)
   ------			--						       WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)
   ------			--						       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),A.SysNPA_Dt)
   ------			--							   ELSE DBTDT 
   ------			--						   END)
   ------------------------5. Exceptional aging of NPA facilities------------------
   ------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 6
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   IF utils.object_id('TEMPDB..tt_TempTableNpaCustomers') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableNpaCustomers ';
   END IF;
   DELETE FROM tt_TempTableNpaCustomers;
   UTILS.IDENTITY_RESET('tt_TempTableNpaCustomers');

   INSERT INTO tt_TempTableNpaCustomers ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           SourceSystemCustomerID ,
           PANNO ,
           SysAssetClassAlt_Key ,
           SysNPA_Dt 
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN DIMSOURCEDB B   ON B.SourceAlt_Key = A.SourceAlt_Key
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND B.EffectiveFromTimeKey <= v_TIMEKEY
             AND B.EffectiveToTimeKey >= v_TIMEKEY
   	 WHERE  NVL(SYSASSETCLASSALT_KEY, 1) <> 1
   	  GROUP BY UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt );
   IF utils.object_id('TEMPDB..tt_DuplicateNpaDt') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DuplicateNpaDt ';
   END IF;
   DELETE FROM tt_DuplicateNpaDt;
   UTILS.IDENTITY_RESET('tt_DuplicateNpaDt');

   INSERT INTO tt_DuplicateNpaDt ( 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableNpaCustomers A
             JOIN tt_TempTableNpaCustomers B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
             AND A.SysNPA_Dt <> B.SysNPA_Dt
   	UNION 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableNpaCustomers A
             JOIN tt_TempTableNpaCustomers B   ON A.PANNO = B.PANNO
             AND A.SysNPA_Dt <> B.SysNPA_Dt
   	 WHERE  A.PANNO IS NOT NULL
              AND B.PANNO IS NOT NULL );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              6 ExceptionCode  ,
              'Customers having Multiple NPA date in different facilities across Customer ID & PAN' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              JOIN tt_DuplicateNpaDt    ON tt_DuplicateNpaDt.SourceSystemCustomerID = CH.SourceSystemCustomerID
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  AH.FinalAssetClassAlt_Key IN ( 2,3,4,5,6 )
      );
   ------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------
   ------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 
   DELETE ControlScripts

    WHERE  ExceptionCode = 7
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   IF utils.object_id('TEMPDB..tt_TempTableCustomersAsset') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableCustomersAsset ';
   END IF;
   DELETE FROM tt_TempTableCustomersAsset;
   UTILS.IDENTITY_RESET('tt_TempTableCustomersAsset');

   INSERT INTO tt_TempTableCustomersAsset ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           SourceSystemCustomerID ,
           PANNO ,
           SysAssetClassAlt_Key ,
           SysNPA_Dt 
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN DIMSOURCEDB B   ON B.SourceAlt_Key = A.SourceAlt_Key
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND B.EffectiveFromTimeKey <= v_TIMEKEY
             AND B.EffectiveToTimeKey >= v_TIMEKEY

   	-- WHERE  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
   	GROUP BY UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt );
   IF utils.object_id('TEMPDB..tt_DuplicateAssetClass') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DuplicateAssetClass ';
   END IF;
   DELETE FROM tt_DuplicateAssetClass;
   UTILS.IDENTITY_RESET('tt_DuplicateAssetClass');

   INSERT INTO tt_DuplicateAssetClass ( 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableCustomersAsset A
             JOIN tt_TempTableCustomersAsset B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
             AND A.SysAssetClassAlt_Key <> B.SysAssetClassAlt_Key
   	UNION 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableCustomersAsset A
             JOIN tt_TempTableCustomersAsset B   ON A.PANNO = B.PANNO
             AND A.SysAssetClassAlt_Key <> B.SysAssetClassAlt_Key
   	 WHERE  A.PANNO IS NOT NULL
              AND B.PANNO IS NOT NULL );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              7 ExceptionCode  ,
              'Customers having different asset class in different facilities across Customer ID & PAN' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              JOIN tt_DuplicateAssetClass    ON tt_DuplicateAssetClass.SourceSystemCustomerID = CH.SourceSystemCustomerID
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey );
   --where  AH.FinalAssetClassAlt_Key  IN (2)
   ------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 
   ------------------8. Customers appearing in slippage & upgradation on same date------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 8
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   IF utils.object_id('TEMPDB..tt_TempTableFreshSillapge') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableFreshSillapge ';
   END IF;
   DELETE FROM tt_TempTableFreshSillapge;
   UTILS.IDENTITY_RESET('tt_TempTableFreshSillapge');

   INSERT INTO tt_TempTableFreshSillapge ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           SourceSystemCustomerID ,
           CustomerAcID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL Ah
             JOIN DIMSOURCEDB B   ON B.SourceAlt_Key = Ah.SourceAlt_Key
             AND Ah.EffectiveFromTimeKey <= v_TIMEKEY
             AND Ah.EffectiveToTimeKey >= v_TIMEKEY
             AND B.EffectiveFromTimeKey <= v_TIMEKEY
             AND B.EffectiveToTimeKey >= v_TIMEKEY
   	 WHERE  Ah.FlgDeg = 'Y' );
   IF utils.object_id('TEMPDB..tt_TempTableUpgrade') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableUpgrade ';
   END IF;
   DELETE FROM tt_TempTableUpgrade;
   UTILS.IDENTITY_RESET('tt_TempTableUpgrade');

   INSERT INTO tt_TempTableUpgrade ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           SourceSystemCustomerID ,
           CustomerAcID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL Ah
             JOIN DIMSOURCEDB B   ON B.SourceAlt_Key = Ah.SourceAlt_Key
             AND Ah.EffectiveFromTimeKey <= v_TIMEKEY
             AND Ah.EffectiveToTimeKey >= v_TIMEKEY
             AND B.EffectiveFromTimeKey <= v_TIMEKEY
             AND B.EffectiveToTimeKey >= v_TIMEKEY
   	 WHERE  Ah.FlgUpg = 'U' );
   IF utils.object_id('TEMPDB..tt_TempTableFreshSillapgeUpgrade') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableFreshSillapgeUp ';
   END IF;
   DELETE FROM tt_TempTableFreshSillapgeUp;
   UTILS.IDENTITY_RESET('tt_TempTableFreshSillapgeUp');

   INSERT INTO tt_TempTableFreshSillapgeUp ( 
   	SELECT A.CustomerAcID 
   	  FROM tt_TempTableFreshSillapge A
             JOIN tt_TempTableUpgrade B   ON A.CustomerAcID = B.CustomerAcID );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              8 ExceptionCode  ,
              'Customers appearing in slippage & upgradation on same date' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN tt_TempTableFreshSillapgeUp SU   ON SU.CustomerAcID = AH.CustomerAcID
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey );
   ------------------8. Customers appearing in slippage & upgradation on same date------------------
   ------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 9
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              9 ExceptionCode  ,
              'Customers slipped to NPA without having Debit Freeze Flag.' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  CH.FlgDeg = 'Y'
                 AND AH.FinalAssetClassAlt_Key IN ( 2,3,4,5,6 )

                 AND AH.DebitSinceDt IS NULL );
   ------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------
   ------------------10. Customers having different asset class in source system and CrisMac System------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 10
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              10 ExceptionCode  ,
              'Customers having different asset class in source system and CrisMac System' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  ( AH.InitialAssetClassAlt_Key IN ( 1 )

                 AND AH.FinalAssetClassAlt_Key IN ( 2,3,4,5,6 )

                 OR AH.InitialAssetClassAlt_Key IN ( 2,3,4,5,6 )

                 AND AH.FinalAssetClassAlt_Key IN ( 1 )
                ) );
   ------------------10. Customers having different asset class in source system and CrisMac System------------------
   ----------------------11. Exceptional variation in DPD reported from source system------------------
   ----Delete from ControlScripts
   ----where ExceptionCode=11
   ----and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')
   ----IF OBJECT_ID('TEMPDB..#TempTablePreviousDayDpdData') IS NOT NULL
   ----  DROP TABLE #TempTablePreviousDayDpdData
   ----	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max
   ----	 INTO #TempTablePreviousDayDpdData FROM PRO.AccountCal_Hist Ah
   ----	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
   ----	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY-1 AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY-1
   ----	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
   ----	  --WHERE  Ah.DPD_Max>0
   ----	 IF OBJECT_ID('TEMPDB..#TempTableCurrentDpdData') IS NOT NULL
   ----		DROP TABLE #TempTableCurrentDpdData
   ----	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max
   ----	 INTO #TempTableCurrentDpdData FROM PRO.AccountCal_Hist Ah
   ----	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
   ----	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY
   ----	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
   ----	  --WHERE  Ah.DPD_Max>0
   ----	 IF OBJECT_ID('TEMPDB..#TempTableDpdData') IS NOT NULL
   ----		DROP TABLE #TempTableDpdData
   ----	  SELECT A.CustomerAcID,A.DPD_Max AS DPD_MaxP ,B.DPD_Max  AS DPD_MaxC
   ----	  INTO #TempTableDpdData
   ----	   FROM #TempTablePreviousDayDpdData  A
   ----	  INNER JOIN #TempTableCurrentDpdData B
   ----	  ON A.CustomerAcID=B.CustomerAcID
   ----Insert into ControlScripts
   ----(
   ----UCIF_ID
   ----,PANNO
   ----,CustomerAcID
   ----,RefCustomerID
   ----,SourceSystemCustomerID
   ----,CustomerName
   ----,SourceName
   ----,DPD_Max
   ----,POS
   ----,BalanceInCrncy
   ----,Balance
   ----,SysNPA_Dt
   ----,FinalAssetClassName
   ----,ExceptionCode
   ----,ExceptionDescription
   ----,DPDPreviousDay
   ----,DPDCurrentDay
   ----,EffectiveFromTimeKey
   ----,EffectiveToTimeKey
   ----)
   ----SELECT  
   ----CH.UCIF_ID
   ----,CH.PanNO
   ----,AH.CustomerAcID
   ----,AH.RefCustomerID
   ----,AH.SourceSystemCustomerID
   ----,CH.CustomerName
   ----,DB.SourceName
   ----,AH.DPD_Max
   ----,case    when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
   ----,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
   ----,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
   ----,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
   ----,DA.AssetClassShortName                          AS FinalAssetClassName
   ----,11 AS ExceptionCode
   ----,'Exceptional variation in DPD reported from source system'  AS ExceptionDescription
   ----,SU.DPD_MaxP
   ----,SU.DPD_MaxC
   ----,AH.EffectiveFromTimeKey
   ----,AH.EffectiveToTimeKey
   ----FROM PRO.CUSTOMERCAL_HIST CH
   ----INNER JOIN PRO.ACCOUNTCAL_HIST      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
   ----														  AH.EffectiveFromTimeKey<=@Timekey AND
   ----														  AH.EffectiveToTimeKey>=@Timekey AND
   ----														  CH.EffectiveFromTimeKey<=@Timekey AND
   ----		                                                  CH.EffectiveToTimeKey>=@Timekey
   ----INNER JOIN #TempTableDpdData SU ON SU.CustomerAcID=AH.CustomerAcID
   ----INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
   ----                                                           DB.EffectiveFromTimeKey<=@Timekey AND
   ----													       DB.EffectiveToTimeKey>=@Timekey
   ----INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
   ----                                                           DA.EffectiveFromTimeKey<=@Timekey AND
   ----													       DA.EffectiveToTimeKey>=@Timekey
   ----INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
   ----                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
   ----													        DimAssetClass.EffectiveToTimeKey>=@Timekey
   ----LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
   ----                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
   ----													       DimProduct.EffectiveToTimeKey>=@Timekey
   ----LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
   ----			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
   ----														   DimCurrency.EffectiveToTimeKey>=@Timekey
   ----where (
   ----     (isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)>1)
   ----or (isnull(SU.DPD_MaxC,0)>0 and isnull(SU.DPD_Maxp,0)>0 and isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)=0)
   ----or (isnull(SU.DPD_Maxp,0)=0 and isnull(SU.DPD_MaxC,0)>1) 
   ----)
   ------------------11. Exceptional variation in DPD reported from source system------------------
   ------------------12. No Upward Movement in NPA categories------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 12
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              12 ExceptionCode  ,
              'No Upward Movement in NPA categories' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey
        WHERE  ( AH.InitialAssetClassAlt_Key IN ( 3,4,5,6 )

                 AND AH.FinalAssetClassAlt_Key IN ( 2 )

                 OR AH.InitialAssetClassAlt_Key IN ( 4,5,6 )

                 AND AH.FinalAssetClassAlt_Key IN ( 2,3 )

                 OR AH.InitialAssetClassAlt_Key IN ( 5,6 )

                 AND AH.FinalAssetClassAlt_Key IN ( 2,3,4 )
                ) );
   ------------------12. No Upward Movement in NPA categories------------------
   ------------------14. Same UCICFCR customer id but having different PAN number------------------
   DELETE ControlScripts

    WHERE  ExceptionCode = 14
             AND EffectiveFromTimeKey = ( SELECT timekey 
                                          FROM SysDataMatrix 
                                           WHERE  CurrentStatus = 'C' );
   IF utils.object_id('TEMPDB..tt_TempTableAllCustomers') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempTableAllCustomers ';
   END IF;
   DELETE FROM tt_TempTableAllCustomers;
   UTILS.IDENTITY_RESET('tt_TempTableAllCustomers');

   INSERT INTO tt_TempTableAllCustomers ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           SourceSystemCustomerID ,
           PANNO 
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN DIMSOURCEDB B   ON B.SourceAlt_Key = A.SourceAlt_Key
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND B.EffectiveFromTimeKey <= v_TIMEKEY
             AND B.EffectiveToTimeKey >= v_TIMEKEY
   	 WHERE  a.PANNO <> ' '
   	  GROUP BY UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO );
   IF utils.object_id('TEMPDB..tt_DuplicatePan') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DuplicatePan ';
   END IF;
   DELETE FROM tt_DuplicatePan;
   UTILS.IDENTITY_RESET('tt_DuplicatePan');

   INSERT INTO tt_DuplicatePan ( 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableAllCustomers A
             JOIN tt_TempTableAllCustomers B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
             AND A.PANNO <> B.PANNO
   	UNION 
   	SELECT A.SourceSystemCustomerID 
   	  FROM tt_TempTableAllCustomers A
             JOIN tt_TempTableAllCustomers B   ON A.UCIF_ID = B.UCIF_ID
             AND A.PANNO <> B.PANNO );
   INSERT INTO ControlScripts
     ( UCIF_ID, PANNO, CustomerAcID, RefCustomerID, SourceSystemCustomerID, CustomerName, SourceName, DPD_Max, POS, BalanceInCrncy, Balance, SysNPA_Dt, FinalAssetClassName, ExceptionCode, ExceptionDescription, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT CH.UCIF_ID ,
              CH.PANNO ,
              AH.CustomerAcID ,
              AH.RefCustomerID ,
              AH.SourceSystemCustomerID ,
              CH.CustomerName ,
              DB.SourceName ,
              AH.DPD_Max ,
              CASE 
                   WHEN NVL(AH.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(AH.PrincOutStd, 0)
                 END / v_cost POS  ,
              CASE 
                   WHEN NVL(AH.BalanceInCrncy, 0) < 0 THEN 0
              ELSE NVL(AH.BalanceInCrncy, 0)
                 END / v_cost BalanceInCrncy  ,
              CASE 
                   WHEN NVL(AH.Balance, 0) < 0 THEN 0
              ELSE NVL(AH.Balance, 0)
                 END / v_cost Balance  ,
              UTILS.CONVERT_TO_VARCHAR2(CH.SysNPA_Dt,20,p_style=>103) SysNPA_Dt  ,
              DA.AssetClassShortName FinalAssetClassName  ,
              14 ExceptionCode  ,
              'Same UCIC/FCR customer id but having different PAN number' ExceptionDescription  ,
              AH.EffectiveFromTimeKey ,
              AH.EffectiveToTimeKey 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL CH
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AH   ON CH.SourceSystemCustomerID = AH.SourceSystemCustomerID
              AND AH.EffectiveFromTimeKey <= v_Timekey
              AND AH.EffectiveToTimeKey >= v_Timekey
              AND CH.EffectiveFromTimeKey <= v_Timekey
              AND CH.EffectiveToTimeKey >= v_Timekey
              JOIN DIMSOURCEDB DB   ON DB.SourceAlt_Key = AH.SourceAlt_Key
              AND DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = AH.FinalAssetClassAlt_Key
              AND DA.EffectiveFromTimeKey <= v_Timekey
              AND DA.EffectiveToTimeKey >= v_Timekey
              JOIN tt_DuplicatePan    ON tt_DuplicatePan.SourceSystemCustomerID = CH.SourceSystemCustomerID
              JOIN DimAssetClass    ON DimAssetClass.AssetClassAlt_Key = AH.InitialAssetClassAlt_Key
              AND DimAssetClass.EffectiveFromTimeKey <= v_Timekey
              AND DimAssetClass.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct    ON DimProduct.ProductAlt_Key = AH.ProductAlt_Key
              AND DimProduct.EffectiveFromTimeKey <= v_Timekey
              AND DimProduct.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimCurrency    ON DimCurrency.CurrencyAlt_Key = AH.CurrencyAlt_Key
              AND DimCurrency.EffectiveFromTimeKey <= v_Timekey
              AND DimCurrency.EffectiveToTimeKey >= v_Timekey );--where  AH.FinalAssetClassAlt_Key  IN (2)
   ------------------14. Same UCICFCR customer id but having different PAN number------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATIONCONTROLSCRIPTS" TO "ADF_CDR_RBL_STGDB";
