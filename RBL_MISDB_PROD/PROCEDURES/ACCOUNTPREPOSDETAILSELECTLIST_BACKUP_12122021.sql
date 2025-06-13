--------------------------------------------------------
--  DDL for Procedure ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" 
(
  v_AccountId IN VARCHAR2 DEFAULT NULL 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT A.AccountID ,
             Z.FacilityType ,
             A.POS ,
             A.InterestReceivable ,
             Q.CustomerID ,
             Q.CustomerName ,
             Q.UCIF_Id UCIC  ,
             Z.segmentcode Segment  ,
             V.Balance BalanceOSPOS  ,
             V.InterestReceivable BalanceOSInterestReceivable  ,
             A.RestructureFlag RestructureFlagAlt_Key  ,
             B.ParameterName RestructureFlag  ,
             A.RestructureDate ,
             A.FITLFlag FITLFlagAlt_Key  ,
             C.ParameterName FITLFlag  ,
             A.DFVAmount ,
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
             A.UnclearedEffectsFlag UnclearedEffectsFlagAlt_Key  ,
             H.ParameterName UnclearedEffectsFlag  ,
             CASE 
                  WHEN A.UnclearedEffectsFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(M.Statusdate,20,p_style=>103)
             ELSE NULL
                END UnclearedEffectsDate  ,
             A.AdditionalProvisionCustomerlevel ,
             A.AdditionalProvisionAbsolute ,
             A.MOCReason ,
             A.FraudAccountFlag FraudAccountFlagAlt_Key  ,
             W.ParameterName FraudAccountFlag  ,
             CASE 
                  WHEN A.UnclearedEffectsFlag = 'Y' THEN UTILS.CONVERT_TO_VARCHAR2(X.STATUSDATE,20,p_style=>103)
             ELSE NULL
                END FraudDate  ,
             A.MOCSource ,
             A.ScreenFlag ,
             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
             A.EffectiveFromTimeKey ,
             A.EffectiveToTimeKey ,
             A.CreatedBy ,
             A.DateCreated ,
             A.ApprovedBy ,
             A.DateApproved ,
             A.ModifyBy ,
             A.DateModified ,
             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
             NVL(A.DateModified, A.DateCreated) CrModDate  
        FROM AccountLevelMOC A
               JOIN AdvAcBasicDetail Z   ON A.AccountID = Z.CustomerACID
               AND Z.EffectiveFromTimeKey <= v_TimeKey
               AND Z.EffectiveToTimeKey >= v_TimeKey
               JOIN CustomerBasicDetail Q   ON Q.CustomerEntityId = Z.CustomerEntityID
               AND Q.EffectiveFromTimeKey <= v_TimeKey
               AND Q.EffectiveToTimeKey >= v_TimeKey
               JOIN RBL_MISDB_PROD.AdvAcBalanceDetail V   ON A.AccountEntityID = V.AccountEntityId
               AND V.EffectiveFromTimeKey <= v_Timekey
               AND V.EffectiveToTimeKey >= v_Timekey
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
       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND A.AccountID = v_AccountID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select 
   --EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
   --,case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'
   --,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Balance o/s Intt.Receivable'
   --,'Y' AS 'RestructureFlag'
   --,NULL AS 'RestructureDate'
   --,ACAL.FlgFITL AS 'FITLFlag'
   --,ACAL.DFVAmt AS 'DFVAmt'
   --,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
   --,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
   --,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'Inherent Weakness Flag'
   --,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'Inherent Weakness Date'
   --,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESI Flag'
   --,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESI Date'
   --,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'Unusual Bounce Flag'
   --,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Unusual Bounce Date'
   --,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'Uncleared Effect Flag'
   --,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Uncleared Effect Date'
   --,NULL AS 'AdditionalProvisionCustomerLevel'
   --,NULL AS 'AdditionalProvisionAbsolute'
   --,NULL AS 'MOCReason'
   --From [dbo].AdvAcBasicDetail ACBD
   --INNER join [dbo].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
   --                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
   --									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
   ----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
   ----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
   --left JOIN [dbo].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
   --                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
   --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
   --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
   --INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
   --WHERE ACBD.CustomerACID=@AccountId
   --Union
   --select 
   --EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
   --,case when ACBAL.MocStatus='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
   --,case when ACBAL.MocStatus='N' then ACBAL.IntReverseAmt end  AS 'Balance o/s Intt.Receivable'  --InterestReceivable column not available
   --,'Y' AS 'RestructureFlag'
   --,NULL AS 'RestructureDate'
   --,ACAL.FlgFITL AS 'FITLFlag'
   --,ACAL.DFVAmt AS 'DFVAmt'
   --,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
   --,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
   --,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'Inherent Weakness Flag'
   --,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'Inherent Weakness Date'
   --,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESI Flag'
   --,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESI Date'
   --,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'Unusual Bounce Flag'
   --,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Unusual Bounce Date'
   --,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'Uncleared Effect Flag'
   --,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Uncleared Effect Date'
   --,NULL AS 'AdditionalProvisionCustomerLevel'
   --,NULL AS 'AdditionalProvisionAbsolute'
   --,NULL AS 'MOCReason'
   --From [dbo].AdvAcBasicDetail ACBD
   --INNER join [dbo].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
   --                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
   --									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
   ----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
   ----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
   --left JOIN [dbo].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
   --                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
   --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
   --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
   --INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
   --WHERE ACBD.CustomerACID=@AccountId

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILSELECTLIST_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
