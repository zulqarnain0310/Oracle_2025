--------------------------------------------------------
--  DDL for Procedure ACCOUNTPREPOSDETAILS_SELECTLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_AccountId IN VARCHAR2 DEFAULT NULL ,
  v_OperationFlag IN NUMBER DEFAULT 2 
)
AS
   v_Timekey NUMBER(10,0);
   --Select @Timekey
   --Declare @MOCType Varchar(50)
   --Declare @MocTypeAlt_Key Int
   --Declare @MOCSourceAltkey Int
   v_CreatedBy VARCHAR2(50);
   v_DateCreated VARCHAR2(200);
   v_ModifiedBy VARCHAR2(50);
   v_DateModified VARCHAR2(200);
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved VARCHAR2(200);
   v_AuthorisationStatus VARCHAR2(5);
   --select 
   --EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
   --,case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'
   ------,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
   --,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'BalanceosIntt.Receivable'
   ------,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
   ------,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
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
   --From [CurDat].AdvAcBasicDetail ACBD
   --INNER join [CurDat].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
   --                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
   --									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
   ----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
   ----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
   --left JOIN [CurDat].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
   --                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
   --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
   --left JOIN ExceptionFinalStatusType EFT ON EFT.ACID=ACBD.CustomerACID
   --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
   --left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
   --WHERE EFT.ACID=@AccountId
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
   SELECT CreatedBy ,
          DateCreated ,
          ModifyBy ,
          DateModified ,
          ApprovedBy ,
          DateApproved ,
          AuthorisationStatus 

     INTO v_CreatedBy,
          v_DateCreated,
          v_ModifiedBy,
          v_DateModified,
          v_ApprovedBy,
          v_DateApproved,
          v_AuthorisationStatus
     FROM AccountLevelMOC_Mod 
    WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

             AND AccountID = v_AccountId
             AND EffectiveFromTimeKey = v_TimeKey
             AND EffectiveToTimeKey = v_TimeKey;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
   DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
   BEGIN
      DECLARE
         ---PRE MOC
         v_DateOfData DATE;
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

           INTO v_DateOfData
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_PREMOC_7  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ACCOUNT_PREMOC_7;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_PREMOC_7');

         INSERT INTO tt_ACCOUNT_PREMOC_7 ( 
         	SELECT * 
         	  FROM ( SELECT AccountEntityId ,
                          CustomerACID AccountID  ,
                          Balance ,
                          InttServiced ,
                          FLGFITL ,
                          DFVAmt ,
                          RePossession ,
                          RepossessionDate ,
                          Sarfaesi ,
                          AddlProvision ,
                          FlgMoc ,
                          UCIF_ID UCICID  ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  
                   FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey
                             AND CustomerAcID = v_AccountId
                   UNION ALL 
                   SELECT AccountEntityId ,
                          CustomerACID AccountID  ,
                          Balance ,
                          InttServiced ,
                          FLGFITL ,
                          DFVAmt ,
                          RePossession ,
                          RepossessionDate ,
                          Sarfaesi ,
                          AddlProvision ,
                          FlgMoc ,
                          UCIF_ID UCICID  ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  
                   FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey
                             AND NVL(FlgMoc, 'N') = 'N'
                             AND CustomerAcID = v_AccountId ) X );
         ----POST 
         --Select '#CUST_PREMOC',* from #CUST_PREMOC
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_POSTMOC_7  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ACCOUNT_POSTMOC_7;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_POSTMOC_7');

         INSERT INTO tt_ACCOUNT_POSTMOC_7 ( 
         	SELECT AccountEntityId ,
                 AccountID AccountID  ,
                 POS Balance  ,
                 InterestReceivable ,
                 DFVAmount ,
                 RePossessionFlag ,
                 RepossessionDate ,
                 SarfaesiFlag ,
                 ' ' asFlgMoc  ,
                 ' ' UCICID  ,
                 'a' AuthorisationStatus  ,
                 'a' CreatedBy  ,
                 'a' DateCreated  ,
                 'a' ModifiedBy  ,
                 'a' DateModified  ,
                 'a' ApprovedBy  ,
                 'a' DateApproved  
         	  FROM AccountLevelMOC_Mod 
         	 WHERE  AuthorisationStatus = CASE 
                                             WHEN v_OperationFlag = 20 THEN '1A'
                  ELSE 'MP'
                     END
                    AND EffectiveFromTimeKey = v_TimeKey
                    AND EffectiveToTimeKey = v_TimeKey
                    AND AccountID = v_AccountId );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_ACCOUNT_POSTMOC_7 
                                 WHERE  AccountID = v_AccountId );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_ACCOUNT_POSTMOC_7
              ( SELECT AccountEntityId ,
                       CustomerACID AccountID  ,
                       Balance ,
                       InttServiced ,
                       FLGFITL ,
                       DFVAmt ,
                       RePossession ,
                       RepossessionDate ,
                       Sarfaesi ,
                       AddlProvision ,
                       FlgMoc ,
                       UCIF_ID UCICID  ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_CreatedBy CreatedBy  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  
                FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                 WHERE  EffectiveFromTimeKey = v_TimeKey
                          AND EffectiveToTimeKey = v_TimeKey
                          AND NVL(FlgMoc, 'N') = 'Y'
                          AND CustomerACID = v_AccountId );

         END;
         END IF;
         --Select '#CUST_POSTMOC',* from #CUST_POSTMOC
         OPEN  v_cursor FOR
            SELECT A.CustomerACID AccountID  ,
                   ' ' FacilityType ,--A.FacilityType

                   A.Balance Balance ,--A.POS

                   A.InterestReceivable ,
                   ' ' CustomerID  ,
                   ' ' CustomerName  ,
                   ' ' UCIC  ,
                   ' ' Segment  ,
                   ' ' BalanceOSPOS  ,
                   ' ' BalanceOSInterestReceivable ,--A.

                   1 RestructureFlagAlt_Key ,--A.RestructureFlagAlt_Key

                   ' ' RestructureFlag ,--B.ParameterName as RestructureFlag

                   ' ' RestructureDate ,--A.RestructureDate

                   ' ' FITLFlagAlt_Key ,--A.FITLFlagAlt_Key

                   ' ' FITLFlag ,--C.ParameterName as FITLFlag

                   A.DFVAmount ,
                   B.Balance Balance_POS  ,
                   B.InterestReceivable InterestReceivable_POS  ,
                   B.DFVAmount DFVAmount_POS  ,
                   ' ' RePossessionFlagAlt_Key ,--A.RePossessionFlagAlt_Key

                   ' ' RePossessionFlag  ,
                   ' ' RePossessionDate  ,
                   ' ' InherentWeaknessFlagAlt_Key ,--A.InherentWeaknessFlagAlt_Key

                   ' ' InherentWeaknessFlag  ,
                   ' ' InherentWeaknessDate  ,
                   ' ' SARFAESIFlagAlt_Key ,--A.SARFAESIFlagAlt_Key

                   ' ' SARFAESIFlag  ,
                   ' ' SARFAESIDate  ,
                   ' ' UnusualBounceFlagAlt_Key ,--A.UnusualBounceFlagAlt_Key

                   ' ' UnusualBounceFlag  ,
                   ' ' UnusualBounceDate  ,
                   ' ' UnclearedEffectsFlagAlt_Key ,--A.UnclearedEffectsFlagAlt_Key

                   ' ' UnclearedEffectsFlag  ,
                   ' ' UnclearedEffectsDate  ,
                   ' ' AdditionalProvisionCustomerlevel ,--A.AdditionalProvisionCustomerlevel

                   ' ' AdditionalProvisionAbsolute ,--A.AdditionalProvisionAbsolute

                   ' ' MOCReason ,--A.MOCReason

                   ' ' FraudAccountFlagAlt_Key ,-- A.FraudAccountFlagAlt_Key

                   ' ' FraudAccountFlag  ,
                   ' ' FraudDate  ,
                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                   v_TimeKey EffectiveFromTimeKey ,--A.EffectiveFromTimeKey

                   v_TimeKey EffectiveToTimeKey ,-- A.EffectiveToTimeKey

                   A.CreatedBy ,
                   A.DateCreated ,
                   A.ApprovedBy ,
                   A.DateApproved ,
                   A.ModifiedBy ,
                   A.DateModified ,
                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                   NVL(A.DateModified, A.DateCreated) CrModDate  
              FROM tt_ACCOUNT_PREMOC_7 A
                     LEFT JOIN tt_ACCOUNT_POSTMOC_7 B   ON A.AccountID = B.AccountID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'FITLFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) C   ON C.ParameterAlt_Key = A.FITLFlagAlt_Key
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'RePossessionFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.RePossessionFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'RePossessionDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Reposse%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) I   ON A.CustomerID = I.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'InherentWeaknessFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) E   ON E.ParameterAlt_Key = A.InherentWeaknessFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'InherentWeaknessDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Inherent%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) J   ON A.CustomerID = J.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'SARFAESIFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) F   ON F.ParameterAlt_Key = A.SARFAESIFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'SARFAESIDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%SARFAESI%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) K   ON A.CustomerID = K.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'UnusualBounceFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) G   ON G.ParameterAlt_Key = A.UnusualBounceFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'UnusualBounceDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Unusual%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) L   ON A.CustomerID = L.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'UnclearedEffectsFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UnclearedEffectsFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'UnclearedEffectsDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Uncleared%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) M   ON A.CustomerID = M.CustomerID
                     LEFT JOIN ( SELECT CustomerID ,
                                        STATUSTYPE ,
                                        STATUSDATE 
                                 FROM ExceptionFinalStatusType 
                                  WHERE  STATUSTYPE LIKE '%FRAUD%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) X   ON A.CustomerID = X.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'Fraud' TableName  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) W   ON W.ParameterAlt_Key = A.FraudAccountFlagAlt_Key
             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND A.Accountid = v_AccountID
            UNION 
            SELECT A.AccountID ,
                   A.FacilityType ,
                   A.POS ,
                   A.InterestReceivable ,
                   A.CustomerID ,
                   A.CustomerName ,
                   A.UCIC ,
                   A.Segment ,
                   A.BalanceOSPOS ,
                   A.BalanceOSInterestReceivable ,
                   A.RestructureFlagAlt_Key ,
                   B.ParameterName RestructureFlag  ,
                   A.RestructureDate ,
                   A.FITLFlagAlt_Key ,
                   C.ParameterName FITLFlag  ,
                   A.DFVAmount ,
                   A.RePossessionFlagAlt_Key ,
                   D.ParameterName RePossessionFlag  ,
                   CASE 
                        WHEN A.RePossessionFlagAlt_Key = 1 THEN UTILS.CONVERT_TO_VARCHAR2(I.StatusDate,20,p_style=>103)
                   ELSE NULL
                      END RePossessionDate  ,
                   A.InherentWeaknessFlagAlt_Key ,
                   E.ParameterName InherentWeaknessFlag  ,
                   CASE 
                        WHEN A.InherentWeaknessFlagAlt_Key = 1 THEN UTILS.CONVERT_TO_VARCHAR2(J.StatusDate,20,p_style=>103)
                   ELSE NULL
                      END InherentWeaknessDate  ,
                   A.SARFAESIFlagAlt_Key ,
                   F.ParameterName SARFAESIFlag  ,
                   CASE 
                        WHEN A.SARFAESIFlagAlt_Key = 1 THEN UTILS.CONVERT_TO_VARCHAR2(K.StatusDate,20,p_style=>103)
                   ELSE NULL
                      END SARFAESIDate  ,
                   A.UnusualBounceFlagAlt_Key ,
                   G.ParameterName UnusualBounceFlag  ,
                   CASE 
                        WHEN A.UnusualBounceFlagAlt_Key = 1 THEN UTILS.CONVERT_TO_VARCHAR2(L.StatusDate,20,p_style=>103)
                   ELSE NULL
                      END UnusualBounceDate  ,
                   A.UnclearedEffectsFlagAlt_Key ,
                   H.ParameterName UnclearedEffectsFlag  ,
                   CASE 
                        WHEN A.UnclearedEffectsFlagAlt_Key = 1 THEN UTILS.CONVERT_TO_VARCHAR2(M.Statusdate,20,p_style=>103)
                   ELSE NULL
                      END UnclearedEffectsDate  ,
                   A.AdditionalProvisionCustomerlevel ,
                   A.AdditionalProvisionAbsolute ,
                   A.MOCReason ,
                   A.FraudAccountFlagAlt_Key ,
                   W.ParameterName FraudAccountFlag  ,
                   UTILS.CONVERT_TO_VARCHAR2(X.STATUSDATE,20,p_style=>103) FraudDate  ,
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
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'RestructureFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) B   ON B.ParameterAlt_Key = A.RestructureFlagAlt_Key
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'FITLFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) C   ON C.ParameterAlt_Key = A.FITLFlagAlt_Key
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'RePossessionFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.RePossessionFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'RePossessionDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Reposse%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) I   ON A.CustomerID = I.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'InherentWeaknessFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) E   ON E.ParameterAlt_Key = A.InherentWeaknessFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'InherentWeaknessDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Inherent%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) J   ON A.CustomerID = J.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'SARFAESIFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) F   ON F.ParameterAlt_Key = A.SARFAESIFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'SARFAESIDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%SARFAESI%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) K   ON A.CustomerID = K.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'UnusualBounceFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) G   ON G.ParameterAlt_Key = A.UnusualBounceFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'UnusualBounceDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Unusual%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) L   ON A.CustomerID = L.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'UnclearedEffectsFlag' Tablename  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UnclearedEffectsFlagAlt_Key
                     LEFT JOIN ( SELECT CustomerID ,
                                        StatusType ,
                                        StatusDate ,
                                        'UnclearedEffectsDate' TableName  
                                 FROM ExceptionFinalStatusType 
                                  WHERE  StatusType LIKE '%Uncleared%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) M   ON A.CustomerID = M.CustomerID
                     LEFT JOIN ( SELECT CustomerID ,
                                        STATUSTYPE ,
                                        STATUSDATE 
                                 FROM ExceptionFinalStatusType 
                                  WHERE  STATUSTYPE LIKE '%FRAUD%'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) X   ON A.CustomerID = X.CustomerID
                     JOIN ( SELECT ParameterAlt_Key ,
                                   ParameterName ,
                                   'Fraud' TableName  
                            FROM DimParameter 
                             WHERE  DimParameterName = 'DimYN'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey ) W   ON W.ParameterAlt_Key = A.FraudAccountFlagAlt_Key
             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND A.Accountid = v_AccountID ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --select 
      --EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
      --,case when ACBAL.MocStatus='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
      ----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
      --,case when ACBAL.MocStatus='N' then ACBAL.IntReverseAmt end  AS 'BalanceosIntt.Receivable'  --InterestReceivable column not available
      ----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
      ----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
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
      --From [CurDat].AdvAcBasicDetail ACBD
      --INNER join [CurDat].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
      --                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
      --									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
      ----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
      ----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
      --left JOIN [CurDat].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
      --                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
      --left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
      --                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
      --left JOIN ExceptionFinalStatusType EFT ON EFT.ACID=ACBD.CustomerACID
      --                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
      --left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
      --WHERE EFT.ACID=@AccountId
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTPREPOSDETAILS_SELECTLIST_04122023" TO "ADF_CDR_RBL_STGDB";
