--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELSEARCHLIST_BACKUP_12122021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=2
 --[AccountLevelSearchList]
 -- exec AccountLevelSearchList @AccountID=N'00283GLN500166',@OperationFlag=2
 --Main Screen Select 
 -- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=16

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER,
  v_AccountID IN VARCHAR2,
  iv_TimeKey IN NUMBER DEFAULT 25992 ,
  iv_SourceSystem IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_SourceSystem VARCHAR2(20) := iv_SourceSystem;
   --SET @Timekey=25992
   v_CreatedBy VARCHAR2(50);
   v_DateCreated VARCHAR2(200);
   v_ModifiedBy VARCHAR2(50);
   v_DateModified VARCHAR2(200);
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved VARCHAR2(200);
   v_AuthorisationStatus VARCHAR2(5);
   v_MOCReason VARCHAR2(500);
   v_MocSource NUMBER(10,0);
   v_ApprovedByFirstLevel VARCHAR2(100);
   v_DateApprovedFirstLevel VARCHAR2(200);
   v_cursor SYS_REFCURSOR;
--25999 

BEGIN

   --Declare @Timekey INT
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   SELECT SourceName 

     INTO v_SourceSystem
     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
            JOIN DIMSOURCEDB B   ON A.SourceAlt_key = B.SourceAlt_Key
    WHERE  CustomerAcID = v_AccountID;
   DBMS_OUTPUT.PUT_LINE('@Timekey');
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   IF v_OperationFlag NOT IN ( 16,20 )
    THEN

   BEGIN
      SELECT CreatedBy ,
             MocReason ,
             DateCreated ,
             ModifyBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             MOCSource ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_CreatedBy,
             v_MocReason,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_MocSource,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                AND AccountID = v_AccountId
                AND EffectiveFromTimeKey = v_TimeKey
                AND EffectiveToTimeKey = v_TimeKey
                AND Entitykey IN ( SELECT MAX(Entitykey)  
                                   FROM AccountLevelMOC_Mod 
                                    WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                                             AND AccountID = v_AccountId
                                             AND EffectiveFromTimeKey = v_Timekey
                                             AND EffectiveToTimeKey = v_Timekey )
      ;

   END;
   END IF;
   IF v_OperationFlag = '16' THEN

   BEGIN
      SELECT CreatedBy ,
             MocReason ,
             DateCreated ,
             ModifyBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             MOCSource ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_CreatedBy,
             v_MocReason,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_MocSource,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP' )

                AND AccountID = v_AccountId
                AND EffectiveFromTimeKey = v_TimeKey
                AND EffectiveToTimeKey = v_TimeKey
                AND SCREENFLAG <> ('U');

   END;
   END IF;
   IF v_OperationFlag = '20' THEN

   BEGIN
      SELECT CreatedBy ,
             MocReason ,
             DateCreated ,
             ModifyBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             MOCSource ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_CreatedBy,
             v_MocReason,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_MocSource,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND AccountID = v_AccountId
                AND EffectiveFromTimeKey = v_TimeKey
                AND EffectiveToTimeKey = v_TimeKey
                AND SCREENFLAG <> ('U');

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
   DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
   BEGIN
      DECLARE
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         v_DateOfData DATE;
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

           INTO v_DateOfData
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_PREMOC_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ACCOUNT_PREMOC_3;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_PREMOC_3');

         INSERT INTO tt_ACCOUNT_PREMOC_3 ( 
         	SELECT * 
         	  FROM ( SELECT AccountEntityId ,
                          CustomerACID AccountID  ,
                          FacilityType ,
                          CustomerEntityID CustomerEntityID  ,
                          Balance ,
                          unserviedint InterestReceivable  ,
                          FlgRestructure RestructureFlag  ,
                          RestructureDate ,
                          FLGFITL ,
                          DFVAmt ,
                          RePossession RePossessionFlag  ,
                          RepossessionDate ,
                          WeakAccount WeakAccountFlag  ,
                          WeakAccountDate ,
                          Sarfaesi SarfaesiFlag  ,
                          SarfaesiDate ,
                          FlgUnusualBounce UnusualBounceflag  ,
                          UnusualBounceDate ,
                          FlgUnClearedEffect UnClearedEffectFlag  ,
                          UnClearedEffectDate ,
                          AddlProvision ,
                          FlgFraud FraudAccountFlag  ,
                          FraudDate ,
                          FlgMoc ,
                          v_MocReason MOCReason  ,
                          UCIF_ID UCICID  ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  ,
                          v_MocSource MOCSource  ,
                          v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                          v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                          v_SourceSystem SourceSystem  
                   FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey

                             --and  ISNULL(ScreenFlag,'')= CASE WHEN @OperationFlag =2   THEN 'U' 

                             --                               When @AuthorisationStatus  in('MP','1A') THEN 'U' END
                             AND CustomerAcID = v_AccountId
                   UNION ALL 
                   SELECT AccountEntityId ,
                          CustomerACID AccountID  ,
                          FacilityType ,
                          CustomerEntityID CustomerEntityID  ,
                          Balance ,
                          unserviedint InterestReceivable  ,
                          FlgRestructure RestructureFlag  ,
                          RestructureDate ,
                          FLGFITL ,
                          DFVAmt ,
                          RePossession RePossessionFlag  ,
                          RepossessionDate ,
                          WeakAccount WeakAccountFlag  ,
                          WeakAccountDate ,
                          Sarfaesi SarfaesiFlag  ,
                          SarfaesiDate ,
                          FlgUnusualBounce UnusualBounceflag  ,
                          UnusualBounceDate ,
                          FlgUnClearedEffect UnClearedEffectFlag  ,
                          UnClearedEffectDate ,
                          AddlProvision ,
                          FlgFraud FraudAccountFlag  ,
                          FraudDate ,
                          FlgMoc ,
                          v_MocReason MOCReason  ,
                          UCIF_ID UCICID  ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  ,
                          v_MocSource MOCSource  ,
                          v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                          v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                          v_SourceSystem SourceSystem  
                   FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey
                             AND NVL(FlgMoc, 'N') = 'N'
                             AND CustomerAcID = v_AccountId ) 
                 --and  ISNULL(ScreenFlag,'') = CASE WHEN @OperationFlag =2   THEN 'U' 

                 --                               When @AuthorisationStatus  in('MP','1A') THEN 'U' END
                 X );
         ----POST 
         --Select 'tt_ACCOUNT_PREMOC_3',* from tt_ACCOUNT_PREMOC_3
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_POSTMOC_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ACCOUNT_POSTMOC_3;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_POSTMOC_3');

         INSERT INTO tt_ACCOUNT_POSTMOC_3 ( 
         	SELECT AccountEntityId ,
                 AccountID AccountID  ,
                 0 CustomerEntityID  ,
                 POS Balance  ,
                 InterestReceivable ,
                 RestructureFlag ,
                 RestructureDate ,
                 FITLFlag FLGFITL  ,
                 DFVAmount ,
                 RePossessionFlag RePossessionFlag  ,
                 RepossessionDate ,
                 InherentWeaknessFlag WeakAccountFlag  ,
                 InherentWeaknessDate WeakAccountDate  ,
                 SarfaesiFlag SarfaesiFlag  ,
                 SARFAESIDate ,
                 UnusualBounceFlag UnusualBounceFlag  ,
                 UnusualBounceDate ,
                 UnclearedEffectsFlag UnClearedEffectFlag  ,
                 UnclearedEffectsDate ,
                 AdditionalProvisionAbsolute ,
                 FraudAccountFlag FraudAccountFlag  ,
                 FraudDate ,
                 ' ' FlgMoc  ,
                 'a' MOCReason  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
                 'a' AuthorisationStatus  ,
                 'a' CreatedBy  ,
                 'a' DateCreated  ,
                 'a' ModifiedBy  ,
                 'a' DateModified  ,
                 'a' ApprovedBy  ,
                 'a' DateApproved  ,
                 0 MOCSource  ,
                 'a' ApprovedByFirstLevel  ,
                 'a' DateApprovedFirstLevel  ,
                 v_SourceSystem SourceSystem  
         	  FROM AccountLevelMOC_Mod 
         	 WHERE  AuthorisationStatus = CASE 
                                             WHEN v_OperationFlag = 20 THEN '1A'
                  ELSE 'MP'
                     END
                    AND EffectiveFromTimeKey = v_TimeKey
                    AND EffectiveToTimeKey = v_TimeKey
                    AND AccountID = v_AccountId

                    --and  ISNULL(ScreenFlag,'')=CASE WHEN @OperationFlag =2   THEN 'U' 

                    --                              When @AuthorisationStatus  in('MP','1A') THEN 'S' END
                    AND SCREENFLAG NOT IN ( CASE 
                                                 WHEN v_OperationFlag IN ( 16,20 )
                                                  THEN 'U'
                                            ELSE 'N'
                                               END )
          );
         --Drop Table  ACCOUNT_POSTMOC_HIST 
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_ACCOUNT_POSTMOC_3 
                                 WHERE  AccountID = v_AccountId );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_ACCOUNT_POSTMOC_3
              ( SELECT AccountEntityId ,
                       CustomerACID AccountID  ,
                       CustomerEntityID CustomerEntityID  ,
                       Balance ,
                       unserviedint InterestReceivable  ,
                       FlgRestructure RestructureFlag  ,
                       RestructureDate ,
                       FLGFITL ,
                       DFVAmt ,
                       RePossession RePossessionFlag  ,
                       RepossessionDate ,
                       WeakAccount WeakAccountFlag  ,
                       WeakAccountDate ,
                       Sarfaesi SarfaesiFlag  ,
                       SarfaesiDate ,
                       FlgUnusualBounce UnusualBounceflag  ,
                       UnusualBounceDate ,
                       FlgUnClearedEffect UnClearedEffectFlag  ,
                       UnClearedEffectDate ,
                       AddlProvision AdditionalProvisionAbsolute  ,
                       FlgFraud FraudAccountFlag  ,
                       FraudDate ,
                       FlgMoc ,
                       v_MocReason MOCReason  ,
                       UCIF_ID UCICID  ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_CreatedBy CreatedBy  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  ,
                       v_MocSource MOCSource  ,
                       v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                       v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                       v_SourceSystem SourceSystem  
                FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                 WHERE  EffectiveFromTimeKey = v_TimeKey
                          AND EffectiveToTimeKey = v_TimeKey
                          AND NVL(FlgMoc, 'N') = 'Y'
                          AND CustomerACID = v_AccountId );

         END;
         END IF;
         --and  ISNULL(ScreenFlag,'')=CASE WHEN @OperationFlag =2   THEN 'U' 
         --                              When @AuthorisationStatus  in('MP','1A') THEN 'U' END
         --Select 'tt_ACCOUNT_POSTMOC_3' ,* from tt_ACCOUNT_POSTMOC_3

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.AccountID ,
                      A.FacilityType ,
                      A.Balance POS  ,
                      A.InterestReceivable ,
                      C.RefCustomerID CustomerID  ,
                      C.CustomerName ,
                      --,A.UCIC
                      --,A.Segment
                      --,A.BalanceOSPOS
                      --,A.BalanceOSInterestReceivable
                      --, 1 as  RestructureFlagAlt_Key
                      (CASE 
                            WHEN A.RestructureFlag IS NULL THEN 'No'
                            WHEN A.RestructureFlag = 'Y' THEN 'Yes'
                            WHEN A.RestructureFlag = 'N' THEN 'No'   END) RestructureFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,10,p_style=>103) RestructureDate  ,
                      --,A.FLGFITL  as FITLFlag
                      (CASE 
                            WHEN A.FLGFITL IS NULL THEN 'No'
                            WHEN A.FLGFITL = 'Y' THEN 'Yes'
                            WHEN A.FLGFITL = 'N' THEN 'No'   END) FITLFlag  ,
                      A.DFVAmt DFVAmount  ,
                      --, 1 as RePossessionFlagAlt_Key
                      --,A.RePossessionFlag
                      (CASE 
                            WHEN A.RePossessionFlag IS NULL THEN 'No'
                            WHEN A.RePossessionFlag = 'Y' THEN 'Yes'
                            WHEN A.RePossessionFlag = 'N' THEN 'No'   END) RePossessionFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RePossessionDate,10,p_style=>103) RePossessionDate  ,
                      --,1 as InherentWeaknessFlagAlt_Key
                      --,A.WeakAccountFlag as InherentWeaknessFlag
                      (CASE 
                            WHEN A.WeakAccountFlag IS NULL THEN 'No'
                            WHEN A.WeakAccountFlag = 'Y' THEN 'Yes'
                            WHEN A.WeakAccountFlag = 'N' THEN 'No'   END) InherentWeaknessFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.WeakAccountDate,10,p_style=>103) InherentWeaknessDate  ,
                      --,1 as SARFAESIFlagAlt_Key
                      --,A.SARFAESIFlag as SarfaesiFlag
                      (CASE 
                            WHEN A.SARFAESIFlag IS NULL THEN 'No'
                            WHEN A.SARFAESIFlag = 'Y' THEN 'Yes'
                            WHEN A.SARFAESIFlag = 'N' THEN 'No'   END) SarfaesiFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.SARFAESIDate,10,p_style=>103) SarfaesiDate  ,
                      --, 1 as UnusualBounceFlagAlt_Key
                      --,A.UnusualBounceflag as UnusualBounceflag
                      (CASE 
                            WHEN A.UnusualBounceflag IS NULL THEN 'No'
                            WHEN A.UnusualBounceflag = 'Y' THEN 'Yes'
                            WHEN A.UnusualBounceflag = 'N' THEN 'No'   END) UnusualBounceflag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.UnusualBounceDate,10,p_style=>103) UnusualBounceDate  ,
                      --,1 as UnclearedEffectsFlagAlt_Key
                      --,A.UnClearedEffectFlag as UnclearedEffectsFlag
                      (CASE 
                            WHEN A.UnClearedEffectFlag IS NULL THEN 'No'
                            WHEN A.UnClearedEffectFlag = 'Y' THEN 'Yes'
                            WHEN A.UnClearedEffectFlag = 'N' THEN 'No'   END) UnclearedEffectsFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.UnclearedEffectDate,10,p_style=>103) UnclearedEffectsDate  ,
                      A.AddlProvision AdditionalProvisionAbsolute  ,
                      --,1 as FraudAccountFlagAlt_key
                      --,A.FraudAccountFlag as FraudAccountFlag
                      (CASE 
                            WHEN A.FraudAccountFlag IS NULL THEN 'No'
                            WHEN A.FraudAccountFlag = 'Y' THEN 'Yes'
                            WHEN A.FraudAccountFlag = 'N' THEN 'No'   END) FraudAccountFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,10,p_style=>103) FraudDate  ,
                      A.MOCReason ,
                      A.MOCSource ,
                      C.AddlProvisionPer AdditionalProvisionCustomerlevel  ,
                      B.RestructureFlag RestructureFlag_POS  ,
                      NULL RestructureFlag_POS1  ,
                      --, Convert(Varchar(10),B.RestructureDate,103) 		as RestructureDate_POS
                      B.RestructureDate RestructureDate_POS  ,
                      B.FLGFITL FITLFlag_POS  ,
                      NULL FITLFlag_POS1  ,
                      B.DFVAmount DFVAmount_POS  ,
                      B.RePossessionFlag RePossessionFlag_POS  ,
                      NULL RePossessionFlag_POS1  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.RePossessionDate,10,p_style=>103) RePossessionDate_POS  ,
                      B.WeakAccountFlag InherentWeaknessFlag_POS  ,
                      NULL InherentWeaknessFlag_POS1  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.WeakAccountDate,10,p_style=>103) InherentWeaknessDate_POS  ,
                      B.SARFAESIFlag SARFAESIFlag_POS  ,
                      NULL SARFAESIFlag_POS1  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.SARFAESIDate,10,p_style=>103) SARFAESIDate_POS  ,
                      B.UnusualBounceFlag UnusualBounceFlag_POS  ,
                      NULL UnusualBounceFlag_POS1  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.UnusualBounceDate,10,p_style=>103) UnusualBounceDate_POS  ,
                      B.UnClearedEffectFlag UnclearedEffectsFlag_POS  ,
                      NULL UnclearedEffectsFlag_POS1  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.UnclearedEffectsDate,10,p_style=>103) UnclearedEffectsDate_POS  ,
                      C.AddlProvisionPer AdditionalProvisionCustomerlevel_POS  ,
                      B.AdditionalProvisionAbsolute AdditionalProvisionAbsolute_POS  ,
                      B.FraudAccountFlag FraudAccountFlag_POS  ,
                      NULL FraudAccountFlag_POS1  ,
                      --, Convert(Varchar(10),B.FraudDate ,103)                   as FraudDate_POS
                      B.FraudDate FraudDate_POS  ,
                      B.Balance POS_POS ,----new add 

                      B.InterestReceivable InterestReceivable_POS ,--new add

                      B.AuthorisationStatus ,
                      v_Timekey EffectiveFromTimeKey  ,
                      v_Timekey EffectiveToTimeKey  ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      NULL FraudDate_POS  ,
                      'Account' TableName  ,
                      B.ApprovedByFirstLevel ,
                      B.DateApprovedFirstLevel ,
                      A.SourceSystem 
                 FROM tt_ACCOUNT_PREMOC_3 A
                        LEFT JOIN tt_ACCOUNT_POSTMOC_3 B   ON A.AccountID = b.AccountID
                        LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON A.CustomerEntityID = C.CustomerEntityID
                        AND c.EffectiveFromTimeKey <= v_TimeKey
                        AND c.EffectiveToTimeKey >= v_TimeKey ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         --LEFT Join (
         --					Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
         --					from DimParameter where DimParameterName='DimYesNo'
         --					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
         --					ON F.ParameterAlt_Key=A.SARFAESIFlag
         --	LEFT join (select ACID,StatusType,StatusDate, 'SARFAESIDate' as TableName
         --					from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
         --					AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
         --					ON A.AccountID=K.ACID	
         --	LEFT Join (
         --					Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
         --					from DimParameter where DimParameterName='DimYesNo'
         --					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
         --					ON C.ParameterAlt_Key=A.FLGFITL
         --	LEFT Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
         --					from DimParameter where DimParameterName='DimYesNo'
         --					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
         --					ON D.ParameterAlt_Key=A.RePossessionFlag
         --END
         DBMS_OUTPUT.PUT_LINE('Nitin');
         IF utils.object_id('tempdb..tt_MOCAuthorisation_3') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOCAuthorisation_3 ';

         END;
         END IF;
         DELETE FROM tt_MOCAuthorisation_3;
         UTILS.IDENTITY_RESET('tt_MOCAuthorisation_3');

         INSERT INTO tt_MOCAuthorisation_3 ( 
         	SELECT * ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
         	  FROM AccountLevelMOC_Mod A
         	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND AccountID = v_AccountID
                    AND AccountID IS NOT NULL
                    AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                         FROM AccountLevelMOC_Mod 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                           GROUP BY AccountID )
          );
         --Select ' tt_MOCAuthorisation_3',* from  tt_MOCAuthorisation_3
         --where abc=1
         UPDATE tt_MOCAuthorisation_3 V
            SET ErrorMessage = CASE 
                                    WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'
                ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Accout Level NPZ MOC – Authorization’ menu'
                   END,
                ErrorinColumn = CASE 
                                     WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID'
                ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID'
                   END
          WHERE  V.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND AccountID = v_AccountID
           AND v_operationflag NOT IN ( 16,17,20 )
         ;
         MERGE INTO tt_MOCAuthorisation_3 Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM CustomerLevelMOC_Mod V
                JOIN AdvAcBasicDetail X   ON V.CustomerEntityID = X.CustomerEntityId
                JOIN tt_MOCAuthorisation_3 Z   ON X.CustomerACID = Z.AccountID 
          WHERE X.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND v_operationflag NOT IN ( 16,17,20 )

           AND Z.AccountID = v_AccountID) src
         ON ( Z.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_MOCAuthorisation_3 
                             WHERE  AccountID = v_AccountID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

          --AND ISNULL(ERRORDATA,'')<>''
         BEGIN
            DBMS_OUTPUT.PUT_LINE('ERROR');
            IF ( v_operationflag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT DISTINCT ErrorMessage ErrorinColumn  ,
                                  'Validation' TableName  
                    FROM tt_MOCAuthorisation_3  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
