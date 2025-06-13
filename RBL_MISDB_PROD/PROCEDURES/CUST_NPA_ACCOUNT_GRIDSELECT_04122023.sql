--------------------------------------------------------
--  DDL for Procedure CUST_NPA_ACCOUNT_GRIDSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" 
--exec cust_npa_account_gridselect @AccountId=N'247'

(
  v_AccountId IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0);
   v_Customerid --='9987888'
    VARCHAR2(4000);
   v_OperationFlag NUMBER(10,0) := 1;
   --select * from tt_PostMOC_6
   --select * from tt_PreMOC_6
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   IF ( v_OperationFlag IN ( 1,16 )
    ) THEN

   BEGIN
      IF ( utils.object_id('tempdb..tt_LABEL_6') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LABEL_6 ';
      END IF;
      DELETE FROM tt_LABEL_6;
      UTILS.IDENTITY_RESET('tt_LABEL_6');

      INSERT INTO tt_LABEL_6 ( 
      	SELECT * 
      	  FROM ( SELECT 'BalanceOSPOS' LabeL  ,
                       01 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'BalanceOSInttReceivable' LabeL  ,
                       02 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'RestructureFlag' LabeL  ,
                       03 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'RestructureDate' LabeL  ,
                       04 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'FITLFlag' LabeL  ,
                       05 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'DFVAmt' LabeL  ,
                       06 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'RePossessionFlag' LabeL  ,
                       07 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'RePossessionDate' LabeL  ,
                       08 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'InherentWeaknessFlag' LabeL  ,
                       09 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'InherentWeaknessDate' LabeL  ,
                       10 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'SARFAESIFlag' LabeL  ,
                       11 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'SARFAESIDate' LabeL  ,
                       12 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'UnusualBounceFlag' LabeL  ,
                       13 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'UnusualBounceDate' LabeL  ,
                       14 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'UnclearedEffectFlag' LabeL  ,
                       15 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'UnclearedEffectDate' LabeL  ,
                       16 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'AdditionalProvisionCustomerLevel' LabeL  ,
                       17 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'AdditionalProvisionAbsolute' LabeL  ,
                       18 RowID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'MOCReason' LabeL  ,
                       19 RowID_  
                  FROM DUAL 
                UNION ALL 

                --SELECT 'FraudAccountFlagAlt_Key'				AS Label, 20 AS ROWID UNION ALL
                SELECT 'FraudAccountFlag' Label  ,
                       20 ROWID_  
                  FROM DUAL 
                UNION ALL 
                SELECT 'FraudDate' Label  ,
                       21 ROWID_  
                  FROM DUAL  ) A );
      --select * from tt_LABEL_6
      -----==========================================
      IF ( utils.object_id('tempdb..tt_PostMOC_6') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PostMOC_6 ';
      END IF;
      DELETE FROM tt_PostMOC_6;
      UTILS.IDENTITY_RESET('tt_PostMOC_6');

      INSERT INTO tt_PostMOC_6 ( 
      	SELECT A.Balance BalanceOSPOS  ,
              A.unserviedint BalanceOSInttReceivable  ,
              --,A.RestructureFlagAlt_Key
              A.FlgRestructure RestructureFlag  ,
              A.RestructureDate ,
              --,A.FITLFlagAlt_Key
              A.FLGFITL FITLFlag  ,
              A.DFVAmt DFVAmt  ,
              --,A.RePossessionFlagAlt_Key
              A.RePossession RePossessionFlag  ,
              A.RePossessionDate ,
              --,A.InherentWeaknessFlagAlt_Key
              A.WeakAccount InherentWeaknessFlag  ,
              A.WeakAccountDate InherentWeaknessDate  ,
              --,A.SARFAESIFlagAlt_Key
              A.Sarfaesi SARFAESIFlag  ,
              A.SARFAESIDate SARFAESIDate  ,
              --,A.UnusualBounceFlagAlt_Key
              A.FlgUnusualBounce UnusualBounceFlag  ,
              A.UnusualBounceDate UnusualBounceDate  ,
              --,A.UnclearedEffectsFlagAlt_Key
              A.FlgUnClearedEffect UnclearedEffectFlag  ,
              A.UnclearedEffectDate UnclearedEffectDate  ,
              NULL AdditionalProvisionCustomerlevel  ,
              NULL AdditionalProvisionAbsolute  ,
              A.MOCReason ,
              --,A.FraudAccountFlagAlt_Key
              A.FlgFraud FraudAccountFlag  ,
              A.FraudDate FraudDate  
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A

      	--Inner Join (Select ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B

      	--						ON B.ParameterAlt_Key=A.RestructureFlagAlt_Key

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C

      	--						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D

      	--						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Reposse%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I

      	--						ON A.CustomerID=I.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E

      	--						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Inherent%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J

      	--						ON A.CustomerID=J.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F

      	--						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K

      	--						ON A.CustomerID=K.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G

      	--						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Unusual%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L

      	--						ON A.CustomerID=L.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

      	--						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Uncleared%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M

      	--						ON A.CustomerID=M.CustomerID

      	--						left join AdvAcBalanceDetail ACBAL ON ACBAL.RefSystemAcId= A.Accountid

      	--						and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

      	--						left JOIN (	SELECT CustomerID,

      	--												STATUSTYPE, 

      	--												STATUSDATE 

      	--										FROM ExceptionFinalStatusType 

      	--										WHERE STATUSTYPE like'%FRAUD%'

      	--										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

      	--									) X

      	--									ON A.CustomerID=X.CustomerID

      	--									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName

      	--									from DimParameter where DimParameterName = 'DimYN'

      	--									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W

      	--									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key

      	--select 

      	--case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'

      	----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'

      	--,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'BalanceOSInttReceivable'

      	----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'

      	----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'

      	--,'Y' AS 'RestructureFlag'

      	--,NULL AS 'RestructureDate'

      	--,ACAL.FlgFITL AS 'FITLFlag'

      	--,ACAL.DFVAmt AS 'DFVAmt'

      	--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'

      	--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'

      	--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'InherentWeaknessFlag'

      	--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'InherentWeaknessDate'

      	--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESIFlag'

      	--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE NULL END  AS 'SARFAESIDate'

      	--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'

      	--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnusualBounceDate'

      	--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'

      	--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnclearedEffectDate'

      	--,NULL AS 'AdditionalProvisionCustomerLevel'

      	--,NULL AS 'AdditionalProvisionAbsolute'

      	--,NULL AS 'MOCReason'

      	--into tt_PostMOC_6

      	--From AdvAcBasicDetail ACBD

      	--INNER join AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId

      	--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey

      	--									  and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

      	----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId

      	----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey

      	--left JOIN CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId

      	--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey

      	----left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId

      	----                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey

      	--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=CBD.CustomerID

      	--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey

      	--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
      	WHERE  A.CustomerAcID = v_AccountId
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey );
      --select * from #FID1
      IF ( utils.object_id('tempdb..tt_PreMOC_6') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PreMOC_6 ';
      END IF;
      DELETE FROM tt_PreMOC_6;
      UTILS.IDENTITY_RESET('tt_PreMOC_6');

      INSERT INTO tt_PreMOC_6 ( 
      	SELECT A.Balance BalanceOSPOS  ,
              A.UnserviedInt BalanceOSInttReceivable  ,
              --,A.RestructureFlagAlt_Key
              A.FlgRestructure RestructureFlag  ,
              A.RestructureDate ,
              --,A.FITLFlagAlt_Key
              A.FlgFITL FITLFlag  ,
              A.DFVAmt DFVAmt  ,
              --,A.RePossessionFlagAlt_Key
              A.RePossession RePossessionFlag  ,
              A.RepossessionDate ,
              --,A.InherentWeaknessFlagAlt_Key
              A.WeakAccount InherentWeaknessFlag  ,
              A.WeakAccountDate InherentWeaknessDate  ,
              --,A.SARFAESIFlagAlt_Key
              A.Sarfaesi SARFAESIFlag  ,
              A.SarfaesiDate SARFAESIDate  ,
              --,A.UnusualBounceFlagAlt_Key
              A.FlgUnusualBounce UnusualBounceFlag  ,
              A.UnusualBounceDate UnusualBounceDate  ,
              --,A.UnclearedEffectsFlagAlt_Key
              A.FlgUnClearedEffect UnclearedEffectFlag  ,
              A.UnClearedEffectDate UnclearedEffectDate  ,
              NULL AdditionalProvisionCustomerlevel  ,
              NULL AdditionalProvisionAbsolute  ,
              A.MOCReason ,
              --,A.FraudAccountFlagAlt_Key
              A.FlgFraud FraudAccountFlag  ,
              A.FraudDate FraudDate  
      	  FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL A

      	--Inner Join (Select ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B

      	--						ON B.ParameterAlt_Key=A.RestructureFlagAlt_Key

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C

      	--						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D

      	--						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Reposse%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I

      	--						ON A.CustomerID=I.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E

      	--						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Inherent%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J

      	--						ON A.CustomerID=J.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F

      	--						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K

      	--						ON A.CustomerID=K.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G

      	--						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Unusual%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L

      	--						ON A.CustomerID=L.CustomerID

      	--						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 

      	--						from DimParameter where DimParameterName='DimYN'

      	--						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

      	--						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

      	--						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName

      	--						from ExceptionFinalStatusType where StatusType like '%Uncleared%'

      	--						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M

      	--						ON A.CustomerID=M.CustomerID

      	--						left join AdvAcBalanceDetail ACBAL ON ACBAL.RefSystemAcId= A.Accountid

      	--						and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

      	--						left JOIN (	SELECT CustomerID,

      	--												STATUSTYPE, 

      	--												STATUSDATE 

      	--										FROM ExceptionFinalStatusType 

      	--										WHERE STATUSTYPE like'%FRAUD%'

      	--										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

      	--									) X

      	--									ON A.CustomerID=X.CustomerID

      	--									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName

      	--									from DimParameter where DimParameterName = 'DimYN'

      	--									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W

      	--									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key

      	--select 

      	--case when ISNULL(ACBAL.MocStatus,'N')='N' then ACBAL.Balance end  AS 'BalanceOSPOS'

      	----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'

      	--,case when ISNULL(ACBAL.MocStatus,'N')='N' then ACBAL.IntReverseAmt end  AS 'BalanceOSInttReceivable'  --InterestReceivable column not available

      	----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'

      	----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'

      	--,'Y' AS 'RestructureFlag'

      	--,NULL AS 'RestructureDate'

      	--,ACAL.FlgFITL AS 'FITLFlag'

      	--,ACAL.DFVAmt AS 'DFVAmt'

      	--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'

      	--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'

      	--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'InherentWeaknessFlag'

      	--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'InherentWeaknessDate'

      	--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESIFlag'

      	--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE NULL END  AS 'SARFAESIDate'

      	--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'

      	--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnusualBounceDate'

      	--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'

      	--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE NULL END  AS 'UnclearedEffectDate'

      	--,NULL AS 'AdditionalProvisionCustomerLevel'

      	--,NULL AS 'AdditionalProvisionAbsolute'

      	--,NULL AS 'MOCReason'

      	--into tt_PreMOC_6

      	--From AdvAcBasicDetail ACBD

      	--/*

      	--INNER join PreMoc.AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId

      	--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey

      	--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

      	--left JOIN premoc.CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId

      	--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey

      	--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId

      	--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey

      	--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID

      	--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey

      	--INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID

      	----WHERE CBD.CustomerID='9987888' 

      	--*/

      	--INNER join AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId

      	--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey

      	--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey

      	----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId

      	----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey

      	--left JOIN CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId

      	--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey

      	----left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId

      	----                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey

      	--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=CBD.CustomerID

      	--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey

      	--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
      	WHERE  A.CustomerAcID = v_AccountId
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey );
      OPEN  v_cursor FOR
         SELECT
         --RowID,
          Label DESCRIPTION  ,
          CASE 
               WHEN tt_LABEL_6.RowID_ = 01 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.BalanceOSPOS,30)
               WHEN tt_LABEL_6.RowID_ = 02 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.BalanceOSInttReceivable,30)
               WHEN tt_LABEL_6.RowID_ = 03 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.RestructureFlag,30)
               WHEN tt_LABEL_6.RowID_ = 04 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.RestructureDate,30)
               WHEN tt_LABEL_6.RowID_ = 05 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.FITLFlag,30)
               WHEN tt_LABEL_6.RowID_ = 06 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.DFVAmt,30)
               WHEN tt_LABEL_6.RowID_ = 07 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.RePossessionFlag,30)
               WHEN tt_LABEL_6.RowID_ = 08 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.RePossessionDate,30)
               WHEN tt_LABEL_6.RowID_ = 09 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.InherentWeaknessFlag,30)
               WHEN tt_LABEL_6.RowID_ = 10 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.InherentWeaknessDate,30)
               WHEN tt_LABEL_6.RowID_ = 11 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.SARFAESIFlag,30)
               WHEN tt_LABEL_6.RowID_ = 12 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.SARFAESIDate,30)
               WHEN tt_LABEL_6.RowID_ = 13 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.UnusualBounceFlag,30)
               WHEN tt_LABEL_6.RowID_ = 14 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.UnusualBounceDate,30)
               WHEN tt_LABEL_6.RowID_ = 15 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.UnclearedEffectFlag,30)
               WHEN tt_LABEL_6.RowID_ = 16 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.UnclearedEffectDate,30)
               WHEN tt_LABEL_6.RowID_ = 17 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.AdditionalProvisionCustomerLevel,30)
               WHEN tt_LABEL_6.RowID_ = 18 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.AdditionalProvisionAbsolute,30)
               WHEN tt_LABEL_6.RowID_ = 19 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.MOCReason,30)
               WHEN tt_LABEL_6.RowID_ = 20 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.FraudAccountFlag,30)
               WHEN tt_LABEL_6.RowID_ = 21 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.FraudDate,30)   END PostMocStatus  ,
          CASE 
               WHEN tt_LABEL_6.RowID_ = 01 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.BalanceOSPOS,30)
               WHEN tt_LABEL_6.RowID_ = 02 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.BalanceOSInttReceivable,30)
               WHEN tt_LABEL_6.RowID_ = 03 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.RestructureFlag,30)
               WHEN tt_LABEL_6.RowID_ = 04 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.RestructureDate,30)
               WHEN tt_LABEL_6.RowID_ = 05 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.FITLFlag,30)
               WHEN tt_LABEL_6.RowID_ = 06 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.DFVAmt,30)
               WHEN tt_LABEL_6.RowID_ = 07 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.RePossessionFlag,30)
               WHEN tt_LABEL_6.RowID_ = 08 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.RePossessionDate,30)
               WHEN tt_LABEL_6.RowID_ = 09 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.InherentWeaknessFlag,30)
               WHEN tt_LABEL_6.RowID_ = 10 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.InherentWeaknessDate,30)
               WHEN tt_LABEL_6.RowID_ = 11 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.SARFAESIFlag,30)
               WHEN tt_LABEL_6.RowID_ = 12 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.SARFAESIDate,30)
               WHEN tt_LABEL_6.RowID_ = 13 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.UnusualBounceFlag,30)
               WHEN tt_LABEL_6.RowID_ = 14 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.UnusualBounceDate,30)
               WHEN tt_LABEL_6.RowID_ = 15 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.UnclearedEffectFlag,30)
               WHEN tt_LABEL_6.RowID_ = 16 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.UnclearedEffectDate,30)
               WHEN tt_LABEL_6.RowID_ = 17 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.AdditionalProvisionCustomerLevel,30)
               WHEN tt_LABEL_6.RowID_ = 18 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.AdditionalProvisionAbsolute,30)
               WHEN tt_LABEL_6.RowID_ = 19 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PreMOC_6.MOCReason,30)
               WHEN tt_LABEL_6.RowID_ = 20 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.FraudAccountFlag,30)
               WHEN tt_LABEL_6.RowID_ = 21 THEN UTILS.CONVERT_TO_VARCHAR2(tt_PostMOC_6.FraudDate,30)   END PreMocStatus  
           FROM tt_LABEL_6 CROSS
                  JOIN tt_PostMOC_6 CROSS
                  JOIN tt_PreMOC_6  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);-------------------------==========================
      --DROP TABLE tt_LABEL_6,tt_PostMOC_6,tt_PreMOC_6

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUST_NPA_ACCOUNT_GRIDSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
