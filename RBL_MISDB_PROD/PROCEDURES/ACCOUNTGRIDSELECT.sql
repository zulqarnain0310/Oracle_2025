--------------------------------------------------------
--  DDL for Procedure ACCOUNTGRIDSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" 
(
  v_AccountID IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0);
   v_CustomerID VARCHAR2(4000);
   v_OperationFlag NUMBER(10,0) := 1;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF ( v_OperationFlag IN ( 1,16 )
    ) THEN

   BEGIN
      IF ( utils.object_id('tempdb..tt_LABEL') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LABEL ';
      END IF;
      DELETE FROM tt_LABEL;
      UTILS.IDENTITY_RESET('tt_LABEL');

      INSERT INTO tt_LABEL ( 
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
      --select * from tt_LABEL
      -----==========================================
      IF ( utils.object_id('tempdb..GTT_PostMOC') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PostMOC ';
      END IF;
      DELETE FROM GTT_PostMOC;
      UTILS.IDENTITY_RESET('GTT_PostMOC');

      INSERT INTO GTT_PostMOC ( 
      	SELECT CASE 
                   WHEN NVL(ACBAL.MocStatus, 'Y') = 'Y' THEN ACBAL.Balance   END BalanceOSPOS  ,
              CASE 
                   WHEN NVL(ACBAL.MocStatus, 'Y') = 'Y' THEN ACBAL.IntReverseAmt   END BalanceOSInttReceivable  ,
              A.RestructureFlag RestructureFlagAlt_Key  ,
              B.ParameterName RestructureFlag  ,
              A.RestructureDate ,
              A.FITLFlag FITLFlagAlt_Key  ,
              C.ParameterName FITLFlag  ,
              A.DFVAmount DFVAmt  ,
              A.RePossessionFlag RePossessionFlagAlt_Key  ,
              D.ParameterName RePossessionFlag  ,
              CASE 
                   WHEN A.RePossessionFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(I.StatusDate,20,p_style=>103)
              ELSE NULL
                 END RePossessionDate  ,
              A.InherentWeaknessFlag InherentWeaknessFlagAlt_Key  ,
              E.ParameterName InherentWeaknessFlag  ,
              CASE 
                   WHEN A.InherentWeaknessFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(J.StatusDate,20,p_style=>103)
              ELSE NULL
                 END InherentWeaknessDate  ,
              A.SARFAESIFlag SARFAESIFlagAlt_Key  ,
              F.ParameterName SARFAESIFlag  ,
              CASE 
                   WHEN A.SARFAESIFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(K.StatusDate,20,p_style=>103)
              ELSE NULL
                 END SARFAESIDate  ,
              A.UnusualBounceFlag UnusualBounceFlagAlt_Key  ,
              G.ParameterName UnusualBounceFlag  ,
              CASE 
                   WHEN A.UnusualBounceFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(L.StatusDate,20,p_style=>103)
              ELSE NULL
                 END UnusualBounceDate  ,
              A.UnclearedEffectsFlag UnclearedEffectFlagAlt_Key  ,
              H.ParameterName UnclearedEffectFlag  ,
              CASE 
                   WHEN A.UnclearedEffectsFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(M.Statusdate,20,p_style=>103)
              ELSE NULL
                 END UnclearedEffectDate  ,
              A.AdditionalProvisionCustomerlevel ,
              A.AdditionalProvisionAbsolute ,
              A.MOCReason ,
              A.FraudAccountFlag FraudAccountFlagAlt_Key  ,
              W.ParameterName FraudAccountFlag  ,
              CASE 
                   WHEN A.FraudAccountFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(X.STATUSDATE,20,p_style=>103)
              ELSE NULL
                 END FraudDate  
      	  FROM AccountLevelMOC A
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'RestructureFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON B.ParameterAlt_Key = A.RestructureFlag
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'FITLFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) C   ON C.ParameterAlt_Key = A.FITLFlag
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'RePossessionFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.RePossessionFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'RePossessionDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Reposse%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) I   ON A.AccountID = I.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'InherentWeaknessFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) E   ON E.ParameterAlt_Key = A.InherentWeaknessFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'InherentWeaknessDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Inherent%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) J   ON A.AccountID = J.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'SARFAESIFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) F   ON F.ParameterAlt_Key = A.SARFAESIFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'SARFAESIDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%SARFAESI%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) K   ON A.AccountID = K.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'UnusualBounceFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) G   ON G.ParameterAlt_Key = A.UnusualBounceFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'UnusualBounceDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Unusual%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) L   ON A.AccountID = L.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'UnclearedEffectsFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UnclearedEffectsFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'UnclearedEffectsDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Uncleared%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) M   ON A.AccountID = M.ACID
                LEFT JOIN RBL_MISDB_PROD.AdvAcBalanceDetail ACBAL   ON ACBAL.RefSystemAcId = A.AccountID
                AND ACBAL.EffectiveFromTimeKey <= v_Timekey
                AND ACBAL.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN ( SELECT ACID ,
                                   STATUSTYPE ,
                                   STATUSDATE 
                            FROM ExceptionFinalStatusType 
                             WHERE  STATUSTYPE LIKE '%FRAUD%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) X   ON A.AccountID = X.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'Fraud' TableName  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) W   ON W.ParameterAlt_Key = A.FraudAccountFlag
      	 WHERE  A.AccountID = v_AccountID
                 AND A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_Timekey );
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
      --,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESIDate'
      --,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'
      --,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'UnusualBounceDate'
      --,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'
      --,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'UnclearedEffectDate'
      --,NULL AS 'AdditionalProvisionCustomerLevel'
      --,NULL AS 'AdditionalProvisionAbsolute'
      --,NULL AS 'MOCReason'
      --into GTT_PostMOC
      --From AdvAcBasicDetail ACBD
      --INNER join AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
      --                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
      --									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
      ----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
      ----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
      --left JOIN CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
      --                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
      --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
      --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
      --left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
      --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
      --INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
      --WHERE ACBD.CustomerACID=@AccountID
      --select * from #FID1
      IF ( utils.object_id('tempdb..GTT_PreMOC') IS NOT NULL ) THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PreMOC ';
      END IF;
      DELETE FROM GTT_PreMOC;
      UTILS.IDENTITY_RESET('GTT_PreMOC');

      INSERT INTO GTT_PreMOC ( 
      	SELECT CASE 
                   WHEN NVL(ACBAL.MocStatus, 'N') = 'N' THEN ACBAL.Balance   END BalanceOSPOS  ,
              CASE 
                   WHEN NVL(ACBAL.MocStatus, 'N') = 'N' THEN ACBAL.IntReverseAmt   END BalanceOSInttReceivable  ,
              A.RestructureFlag RestructureFlagAlt_Key  ,
              B.ParameterName RestructureFlag  ,
              A.RestructureDate ,
              A.FITLFlag FITLFlagAlt_Key  ,
              C.ParameterName FITLFlag  ,
              A.DFVAmount DFVAmt  ,
              A.RePossessionFlag RePossessionFlagAlt_Key  ,
              D.ParameterName RePossessionFlag  ,
              CASE 
                   WHEN A.RePossessionFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(I.StatusDate,20,p_style=>103)
              ELSE NULL
                 END RePossessionDate  ,
              A.InherentWeaknessFlag InherentWeaknessFlagAlt_Key  ,
              E.ParameterName InherentWeaknessFlag  ,
              CASE 
                   WHEN A.InherentWeaknessFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(J.StatusDate,20,p_style=>103)
              ELSE NULL
                 END InherentWeaknessDate  ,
              A.SARFAESIFlag SARFAESIFlagAlt_Key  ,
              F.ParameterName SARFAESIFlag  ,
              CASE 
                   WHEN A.SARFAESIFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(K.StatusDate,20,p_style=>103)
              ELSE NULL
                 END SARFAESIDate  ,
              A.UnusualBounceFlag UnusualBounceFlagAlt_Key  ,
              G.ParameterName UnusualBounceFlag  ,
              CASE 
                   WHEN A.UnusualBounceFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(L.StatusDate,20,p_style=>103)
              ELSE NULL
                 END UnusualBounceDate  ,
              A.UnclearedEffectsFlag UnclearedEffectFlagAlt_Key  ,
              H.ParameterName UnclearedEffectFlag  ,
              CASE 
                   WHEN A.UnclearedEffectsFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(M.Statusdate,20,p_style=>103)
              ELSE NULL
                 END UnclearedEffectDate  ,
              A.AdditionalProvisionCustomerlevel ,
              A.AdditionalProvisionAbsolute ,
              A.MOCReason ,
              A.FraudAccountFlag FraudAccountFlagAlt_Key  ,
              W.ParameterName FraudAccountFlag  ,
              CASE 
                   WHEN A.FraudAccountFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(X.STATUSDATE,20,p_style=>103)
              ELSE NULL
                 END FraudDate  
      	  FROM AccountLevelPreMOC A
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'RestructureFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON B.ParameterAlt_Key = A.RestructureFlag
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'FITLFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) C   ON C.ParameterAlt_Key = A.FITLFlag
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'RePossessionFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.RePossessionFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'RePossessionDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Reposse%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) I   ON A.AccountID = I.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'InherentWeaknessFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) E   ON E.ParameterAlt_Key = A.InherentWeaknessFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'InherentWeaknessDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Inherent%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) J   ON A.AccountID = J.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'SARFAESIFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) F   ON F.ParameterAlt_Key = A.SARFAESIFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'SARFAESIDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%SARFAESI%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) K   ON A.AccountID = K.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'UnusualBounceFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) G   ON G.ParameterAlt_Key = A.UnusualBounceFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'UnusualBounceDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Unusual%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) L   ON A.AccountID = L.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'UnclearedEffectsFlag' Tablename  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UnclearedEffectsFlag
                LEFT JOIN ( SELECT ACID ,
                                   StatusType ,
                                   StatusDate ,
                                   'UnclearedEffectsDate' TableName  
                            FROM ExceptionFinalStatusType 
                             WHERE  StatusType LIKE '%Uncleared%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) M   ON A.AccountID = M.ACID
                LEFT JOIN RBL_MISDB_PROD.AdvAcBalanceDetail ACBAL   ON ACBAL.RefSystemAcId = A.AccountID
                AND ACBAL.EffectiveFromTimeKey <= v_Timekey
                AND ACBAL.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN ( SELECT ACID ,
                                   STATUSTYPE ,
                                   STATUSDATE 
                            FROM ExceptionFinalStatusType 
                             WHERE  STATUSTYPE LIKE '%FRAUD%'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) X   ON A.AccountID = X.ACID
                JOIN ( SELECT ParameterShortNameEnum ParameterAlt_Key  ,
                              ParameterName ,
                              'Fraud' TableName  
                       FROM DimParameter 
                        WHERE  DimParameterName = 'DimYesNo'
                                 AND EffectiveFromTimeKey <= v_TimeKey
                                 AND EffectiveToTimeKey >= v_TimeKey ) W   ON W.ParameterAlt_Key = A.FraudAccountFlag
      	 WHERE  A.AccountID = v_AccountID
                 AND A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_Timekey );
      --select 
      --case when ACBAL.MocStatus='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
      ----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
      --,case when ACBAL.MocStatus='N' then ACBAL.IntReverseAmt end  AS 'BalanceOSInttReceivable'  --InterestReceivable column not available
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
      --,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESIDate'
      --,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'UnusualBounceFlag'
      --,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'UnusualBounceDate'
      --,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'UnclearedEffectFlag'
      --,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'UnclearedEffectDate'
      --,NULL AS 'AdditionalProvisionCustomerLevel'
      --,NULL AS 'AdditionalProvisionAbsolute'
      --,NULL AS 'MOCReason'
      --into GTT_PreMOC
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
      --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
      --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
      --left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
      --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
      --INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
      --WHERE ACBD.CustomerACID=@AccountID
      --select * from GTT_PostMOC
      --select * from GTT_PreMOC
      OPEN  v_cursor FOR
         SELECT --RowID,
                Label DESCRIPTION  ,
                CASE 
                     WHEN tt_LABEL.RowID_ = 01 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.BalanceOSPOS,30)
                     WHEN tt_LABEL.RowID_ = 02 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.BalanceOSInttReceivable,30)
                     WHEN tt_LABEL.RowID_ = 03 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.RestructureFlag,30)
                     WHEN tt_LABEL.RowID_ = 04 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.RestructureDate,30)
                     WHEN tt_LABEL.RowID_ = 05 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.FITLFlag,30)
                     WHEN tt_LABEL.RowID_ = 06 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.DFVAmt,30)
                     WHEN tt_LABEL.RowID_ = 07 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.RePossessionFlag,30)
                     WHEN tt_LABEL.RowID_ = 08 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.RePossessionDate,30)
                     WHEN tt_LABEL.RowID_ = 09 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.InherentWeaknessFlag,30)
                     WHEN tt_LABEL.RowID_ = 10 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.InherentWeaknessDate,30)
                     WHEN tt_LABEL.RowID_ = 11 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.SARFAESIFlag,30)
                     WHEN tt_LABEL.RowID_ = 12 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.SARFAESIDate,30)
                     WHEN tt_LABEL.RowID_ = 13 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.UnusualBounceFlag,30)
                     WHEN tt_LABEL.RowID_ = 14 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.UnusualBounceDate,30)
                     WHEN tt_LABEL.RowID_ = 15 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.UnclearedEffectFlag,30)
                     WHEN tt_LABEL.RowID_ = 16 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.UnclearedEffectDate,30)
                     WHEN tt_LABEL.RowID_ = 17 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.AdditionalProvisionCustomerLevel,30)
                     WHEN tt_LABEL.RowID_ = 18 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.AdditionalProvisionAbsolute,30)
                     WHEN tt_LABEL.RowID_ = 19 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.MOCReason,30)
                     WHEN tt_LABEL.RowID_ = 20 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.FraudAccountFlag,30)
                     WHEN tt_LABEL.RowID_ = 21 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.FraudDate,30)   END PostMocStatus  ,
                CASE 
                     WHEN tt_LABEL.RowID_ = 01 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.BalanceOSPOS,30)
                     WHEN tt_LABEL.RowID_ = 02 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.BalanceOSInttReceivable,30)
                     WHEN tt_LABEL.RowID_ = 03 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.RestructureFlag,30)
                     WHEN tt_LABEL.RowID_ = 04 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.RestructureDate,30)
                     WHEN tt_LABEL.RowID_ = 05 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.FITLFlag,30)
                     WHEN tt_LABEL.RowID_ = 06 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.DFVAmt,30)
                     WHEN tt_LABEL.RowID_ = 07 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.RePossessionFlag,30)
                     WHEN tt_LABEL.RowID_ = 08 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.RePossessionDate,30)
                     WHEN tt_LABEL.RowID_ = 09 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.InherentWeaknessFlag,30)
                     WHEN tt_LABEL.RowID_ = 10 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.InherentWeaknessDate,30)
                     WHEN tt_LABEL.RowID_ = 11 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.SARFAESIFlag,30)
                     WHEN tt_LABEL.RowID_ = 12 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.SARFAESIDate,30)
                     WHEN tt_LABEL.RowID_ = 13 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.UnusualBounceFlag,30)
                     WHEN tt_LABEL.RowID_ = 14 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.UnusualBounceDate,30)
                     WHEN tt_LABEL.RowID_ = 15 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.UnclearedEffectFlag,30)
                     WHEN tt_LABEL.RowID_ = 16 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.UnclearedEffectDate,30)
                     WHEN tt_LABEL.RowID_ = 17 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.AdditionalProvisionCustomerLevel,30)
                     WHEN tt_LABEL.RowID_ = 18 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.AdditionalProvisionAbsolute,30)
                     WHEN tt_LABEL.RowID_ = 19 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PreMOC.MOCReason,30)
                     WHEN tt_LABEL.RowID_ = 20 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.FraudAccountFlag,30)
                     WHEN tt_LABEL.RowID_ = 21 THEN UTILS.CONVERT_TO_VARCHAR2(GTT_PostMOC.FraudDate,30)   END PreMocStatus  
           FROM tt_LABEL CROSS
                  JOIN GTT_PostMOC CROSS
                  JOIN GTT_PreMOC  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -------------------------==========================
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LABEL ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PostMOC ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PreMOC ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTGRIDSELECT" TO "ADF_CDR_RBL_STGDB";
