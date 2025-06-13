--------------------------------------------------------
--  DDL for Function ACCOUNTLEVELINUP_PROD_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" /*
declare @p32 int
set @p32=1
exec [dbo].[AccountLevelInUp] @AccountID=N'130',@POS=N'5000000',@InterestReceivable=N'2500',@RestructureFlagAlt_Key=N'Y'
,@RestructureDate=N'2021-05-02T18:30:00Z',@FraudAccountFlagAlt_Key=N'Y',@FraudDate=N'2021-05-01T18:30:00Z',@FITLFlagAlt_Key=N'Y'
,@DFVAmount=65,@RePossessionFlagAlt_Key=N'Y',@RePossessionDate=N'2021-05-02T18:30:00Z',@InherentWeaknessFlagAlt_Key=N'Y'
,@InherentWeaknessDate=N'2021-05-03T18:30:00Z',@SARFAESIFlagAlt_Key=N'Y',@SARFAESIDate=N'2021-05-03T18:30:00Z',@UnusualBounceFlagAlt_Key=N'Y'
,@UnusualBounceDate=N'2021-03-24T18:30:00Z',@UnclearedEffectsFlagAlt_Key=N'Y',@UnclearedEffectsDate=N'2021-04-23T18:30:00Z'
,@AdditionalProvisionCustomerlevel=NULL,@AdditionalProvisionAbsolute=NULL,@MOCReason=N'sdfsdf werwer',@MenuID=127,@CrModApBy=N'2ndlvlchecker'
,@Remark=N'',@OperationFlag=20,@AuthMode=N'Y',@TimeKey=25999,@EffectiveFromTimeKey=N'25999',@EffectiveToTimeKey=49999,@ScreenEntityId=NULL,
@Result=@p32 output
select @p32
go
*/
--SELECT * FROM [PreMoc].[ACCOUNTCAL] where customeracid='130'			
 --SELECT * FROM [PRO].[ACCOUNTCal_Hist]	where customeracid='130'and EffectivetoTimeKey=25841		
 --SELECT AuthorisationStatus, * FROM ACCOUNTLevelMOC_Mod where AccountID='130'	
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_AccountID IN VARCHAR2 DEFAULT ' ' ,
  v_POS IN NUMBER,
  v_InterestReceivable IN NUMBER,
  v_RestructureFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_RestructureDate IN VARCHAR2 DEFAULT NULL ,
  v_FITLFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_DFVAmount IN NUMBER,
  v_RePossessionFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_RePossessionDate IN VARCHAR2 DEFAULT NULL ,
  v_InherentWeaknessFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_InherentWeaknessDate IN VARCHAR2 DEFAULT NULL ,
  v_SARFAESIFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_SARFAESIDate IN VARCHAR2 DEFAULT NULL ,
  v_UnusualBounceFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_UnusualBounceDate IN VARCHAR2 DEFAULT NULL ,
  v_UnclearedEffectsFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_UnclearedEffectsDate IN VARCHAR2 DEFAULT NULL ,
  v_AdditionalProvisionCustomerlevel IN NUMBER,
  v_AdditionalProvisionAbsolute IN NUMBER,
  v_MOCReason IN VARCHAR2 DEFAULT ' ' ,
  v_FraudAccountFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_FraudDate IN VARCHAR2 DEFAULT NULL ,
  v_ScreenFlag IN VARCHAR2 DEFAULT ' ' ,
  v_MOCSource IN NUMBER DEFAULT 0 ,
  v_AccountNPAMOC_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_RestructureDate VARCHAR2(20) := iv_RestructureDate;
   v_FraudDate VARCHAR2(20) := iv_FraudDate;
   v_RePossessionDate VARCHAR2(20) := iv_RePossessionDate;
   v_InherentWeaknessDate VARCHAR2(20) := iv_InherentWeaknessDate;
   v_SARFAESIDate VARCHAR2(20) := iv_SARFAESIDate;
   v_UnusualBounceDate VARCHAR2(20) := iv_UnusualBounceDate;
   v_UnclearedEffectsDate VARCHAR2(20) := iv_UnclearedEffectsDate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   --,@AccountEntityID int=0
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_AccountEntityID NUMBER(10,0);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_RestructureDate := CASE 
                             WHEN ( v_RestructureDate = ' '
                               OR v_RestructureDate = '01/01/1900'
                               OR v_RestructureDate = '1900/01/01' ) THEN NULL
   ELSE v_RestructureDate
      END ;
   v_FraudDate := CASE 
                       WHEN ( v_FraudDate = ' '
                         OR v_FraudDate = '01/01/1900'
                         OR v_FraudDate = '1900/01/01' ) THEN NULL
   ELSE v_FraudDate
      END ;
   v_RePossessionDate := CASE 
                              WHEN ( v_RePossessionDate = ' '
                                OR v_RePossessionDate = '01/01/1900'
                                OR v_RePossessionDate = '1900/01/01' ) THEN NULL
   ELSE v_RePossessionDate
      END ;
   v_InherentWeaknessDate := CASE 
                                  WHEN ( v_InherentWeaknessDate = ' '
                                    OR v_InherentWeaknessDate = '01/01/1900'
                                    OR v_InherentWeaknessDate = '1900/01/01' ) THEN NULL
   ELSE v_InherentWeaknessDate
      END ;
   v_SARFAESIDate := CASE 
                          WHEN ( v_SARFAESIDate = ' '
                            OR v_SARFAESIDate = '01/01/1900'
                            OR v_SARFAESIDate = '1900/01/01' ) THEN NULL
   ELSE v_SARFAESIDate
      END ;
   v_UnusualBounceDate := CASE 
                               WHEN ( v_UnusualBounceDate = ' '
                                 OR v_UnusualBounceDate = '01/01/1900'
                                 OR v_UnusualBounceDate = '1900/01/01' ) THEN NULL
   ELSE v_UnusualBounceDate
      END ;
   v_UnclearedEffectsDate := CASE 
                                  WHEN ( v_UnclearedEffectsDate = ' '
                                    OR v_UnclearedEffectsDate = '01/01/1900'
                                    OR v_UnclearedEffectsDate = '1900/01/01' ) THEN NULL
   ELSE v_UnclearedEffectsDate
      END ;
   v_ScreenName := 'AccountLevel' ;
   -------------------------------------------------------------
   ----SET @Timekey =(Select Prev_Month_Key from SysDataMatrix where CurrentStatus='C') 
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := v_Timekey ;
   SELECT AccountEntityID 

     INTO v_AccountEntityID
     FROM AdvAcBasicDetail 
    WHERE  CustomerACID = v_AccountID;
   --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
   DBMS_OUTPUT.PUT_LINE('A');
   SELECT ParameterValue 

     INTO v_AppAvail
     FROM SysSolutionParameter 
    WHERE  Parameter_Key = 6;
   IF ( v_AppAvail = 'N' ) THEN

   BEGIN
      v_Result := -11 ;
      RETURN v_Result;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -----
         DBMS_OUTPUT.PUT_LINE(3);
         --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
         IF ( v_OperationFlag = 2
           OR v_OperationFlag = 3 )
           AND v_AuthMode = 'Y' THEN

          --EDIT AND DELETE
         BEGIN
            DBMS_OUTPUT.PUT_LINE(4);
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_Modifiedby := v_CrModApBy ;
            v_DateModified := SYSDATE ;
            v_AuthorisationStatus := 'MP' ;
            --UPDATE NP,MP  STATUS 
            IF v_OperationFlag = 2 THEN

            BEGIN
               UPDATE AccountLevelMOC_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifyBy = v_Modifiedby,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND AccountID = v_AccountID
                 AND AuthorisationStatus IN ( 'NP','MP','RM' )
               ;

            END;
            END IF;
            GOTO GLCodeMaster_Insert;
            <<GLCodeMaster_Insert_Edit_Delete>>

         END;

         -------------------------------------------------------

         --start 20042021
         ELSE
            IF v_OperationFlag = 21
              AND v_AuthMode = 'Y' THEN

            BEGIN
               v_ApprovedBy := v_CrModApBy ;
               v_DateApproved := SYSDATE ;
               UPDATE AccountLevelMOC_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_ApprovedBy,
                      DateApproved = v_DateApproved,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND AccountID = v_AccountID
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
               ;

            END;

            --till here

            -------------------------------------------------------
            ELSE
               IF v_OperationFlag = 17
                 AND v_AuthMode = 'Y' THEN

               BEGIN
                  v_ApprovedBy := v_CrModApBy ;
                  v_DateApproved := SYSDATE ;
                  UPDATE AccountLevelMOC_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID
                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                  ;

               END;

               ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
               ELSE
                  IF v_OperationFlag = 18 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(18);
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE AccountLevelMOC_Mod
                        SET AuthorisationStatus = 'RM'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                       AND AccountID = v_AccountID;

                  END;
                  ELSE
                     IF v_OperationFlag = 16 THEN

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE AccountLevelMOC_Mod
                           SET AuthorisationStatus = '1A',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved
                         WHERE  AccountID = v_AccountID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;

                     END;
                     ELSE
                        IF v_OperationFlag = 20
                          OR v_AuthMode = 'N' THEN
                         DECLARE
                           ---------------------------------------------
                           v_Parameter VARCHAR2(50);
                           v_FinalParameter VARCHAR2(50);

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE('Authorise');
                           -------set parameter for  maker checker disabled
                           IF v_AuthMode = 'N' THEN

                           BEGIN
                              v_ModifiedBy := v_CrModApBy ;
                              v_DateModified := SYSDATE ;
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;

                           END;
                           END IF;
                           DBMS_OUTPUT.PUT_LINE(111111111);
                           ---set parameters and UPDATE mod table in case maker checker enabled
                           IF v_AuthMode = 'Y' THEN
                            DECLARE
                              v_DelStatus CHAR(2) := ' ';
                              v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                              v_CurEntityKey NUMBER(10,0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('B');
                              DBMS_OUTPUT.PUT_LINE('C');
                              SELECT MAX(EntityKey)  

                                INTO v_ExEntityKey
                                FROM AccountLevelMOC_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND AccountID = v_AccountID
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT AuthorisationStatus ,
                                     CreatedBy ,
                                     DATECreated ,
                                     ModifyBy ,
                                     DateModified 

                                INTO v_DelStatus,
                                     v_CreatedBy,
                                     v_DateCreated,
                                     v_ModifiedBy,
                                     v_DateModified
                                FROM AccountLevelMOC_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              SELECT MIN(EntityKey)  

                                INTO v_ExEntityKey
                                FROM AccountLevelMOC_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND AccountID = v_AccountID
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT EffectiveFromTimeKey 

                                INTO v_CurrRecordFromTimeKey
                                FROM AccountLevelMOC_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              UPDATE AccountLevelMOC_Mod
                                 SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND AccountID = v_AccountID
                                AND AuthorisationStatus = 'A';
                              UPDATE AccountLevelMOC_Mod
                                 SET AuthorisationStatus = 'A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND AccountID = v_AccountID
                                AND AuthorisationStatus = '1A';

                           END;
                           END IF;
                           -------DELETE RECORD AUTHORISE
                           DBMS_OUTPUT.PUT_LINE(222222222222);
                           IF NVL(v_DelStatus, ' ') <> 'DP'
                             OR v_AuthMode = 'N' THEN

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE(333333333333333333333333);
                              IF  --SQLDEV: NOT RECOGNIZED
                              IF tt_ACCOUNT_CAL_7  --SQLDEV: NOT RECOGNIZED
                              DELETE FROM tt_ACCOUNT_CAL_7;
                              UTILS.IDENTITY_RESET('tt_ACCOUNT_CAL_7');

                              INSERT INTO tt_ACCOUNT_CAL_7 ( 
                              	SELECT * 
                              	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                              	 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND CustomerAcID = v_AccountID );
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
                              FROM A ,PRO_RBL_MISDB_PROD.AccountCal_Hist A 
                               WHERE ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND EffectiveFromTimeKey < v_TImeKey) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, CASE 
                              WHEN v_POS IS NULL THEN Balance
                              ELSE v_POS
                                 END AS pos_2, CASE 
                              WHEN v_InterestReceivable IS NULL THEN unserviedint
                              ELSE v_InterestReceivable
                                 END AS pos_3, CASE 
                              WHEN v_RestructureFlagAlt_Key IS NULL THEN FlgRestructure
                              ELSE v_RestructureFlagAlt_Key
                                 END AS pos_4, CASE 
                              WHEN v_RestructureDate IS NULL THEN RestructureDate
                              ELSE v_RestructureDate
                                 END AS pos_5, CASE 
                              WHEN v_FITLFlagAlt_Key IS NULL THEN FLGFITL
                              ELSE v_FITLFlagAlt_Key
                                 END AS pos_6, CASE 
                              WHEN v_DFVAmount IS NULL THEN DFVAmt
                              ELSE v_DFVAmount
                                 END AS pos_7, CASE 
                              WHEN v_RePossessionFlagAlt_Key IS NULL THEN RePossession
                              ELSE v_RePossessionFlagAlt_Key
                                 END AS pos_8, CASE 
                              WHEN v_RePossessionDate IS NULL THEN RepossessionDate
                              ELSE v_RePossessionDate
                                 END AS pos_9, CASE 
                              WHEN v_InherentWeaknessFlagAlt_Key IS NULL THEN WeakAccount
                              ELSE v_InherentWeaknessFlagAlt_Key
                                 END AS pos_10, CASE 
                              WHEN v_InherentWeaknessDate IS NULL THEN WeakAccountDate
                              ELSE v_InherentWeaknessDate
                                 END AS pos_11, CASE 
                              WHEN v_SARFAESIFlagAlt_Key IS NULL THEN Sarfaesi
                              ELSE v_SARFAESIFlagAlt_Key
                                 END AS pos_12, CASE 
                              WHEN v_SARFAESIDate IS NULL THEN SarfaesiDate
                              ELSE v_SARFAESIDate
                                 END AS pos_13, CASE 
                              WHEN v_UnusualBounceFlagAlt_Key IS NULL THEN FlgUnusualBounce
                              ELSE v_UnusualBounceFlagAlt_Key
                                 END AS pos_14, CASE 
                              WHEN v_UnusualBounceDate IS NULL THEN UnusualBounceDate
                              ELSE v_UnusualBounceDate
                                 END AS pos_15, CASE 
                              WHEN v_UnclearedEffectsFlagAlt_Key IS NULL THEN FlgUnClearedEffect
                              ELSE v_UnclearedEffectsFlagAlt_Key
                                 END AS pos_16, CASE 
                              WHEN v_UnclearedEffectsDate IS NULL THEN UnClearedEffectDate
                              ELSE v_UnclearedEffectsDate
                                 END AS pos_17, CASE 
                              WHEN v_AdditionalProvisionAbsolute IS NULL THEN AddlProvision
                              ELSE v_AdditionalProvisionAbsolute
                                 END AS pos_18, v_MOCReason, CASE 
                              WHEN v_FraudAccountFlagAlt_Key IS NULL THEN FlgFraud
                              ELSE v_FraudAccountFlagAlt_Key
                                 END AS pos_20, CASE 
                              WHEN v_FraudDate IS NULL THEN FraudDate
                              ELSE v_FraudDate
                                 END AS pos_21, 'Y'
                              FROM A ,PRO_RBL_MISDB_PROD.AccountCal_Hist a 
                               WHERE EffectiveFromTimeKey = v_TimeKey
                                AND EffectiveToTimeKey = v_TimeKey
                                AND CustomerAcID = v_AccountID) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET A.Balance = pos_2,
                                                           A.unserviedint = pos_3,
                                                           A.FlgRestructure = pos_4,
                                                           A.RestructureDate = pos_5,
                                                           A.FLGFITL = pos_6,
                                                           A.DFVAmt = pos_7,
                                                           A.RePossession = pos_8,
                                                           A.RepossessionDate = pos_9,
                                                           A.WeakAccount = pos_10,
                                                           A.WeakAccountDate = pos_11,
                                                           A.Sarfaesi = pos_12,
                                                           A.SarfaesiDate = pos_13,
                                                           A.FlgUnusualBounce = pos_14,
                                                           A.UnusualBounceDate = pos_15,
                                                           A.FlgUnClearedEffect = pos_16,
                                                           A.UnClearedEffectDate
                                                           --------,A.=@AdditionalProvisionCustomerlevel	
                                                            = pos_17,
                                                           A.AddlProvision = pos_18,
                                                           A.MOCReason = v_MOCReason,
                                                           A.FlgFraud = pos_20,
                                                           A.FraudDate
                                                           --,A.=@ScreenFlag						
                                                            --,A.=@MOCSource							
                                                            = pos_21,
                                                           A.FlgMoc = 'Y';
                              -- FlgRestructure	Char(1)
                              --,RestructureDate	Date
                              --,WeakAccountDate	Date
                              --,SarfaesiDate	Date
                              --,FlgUnusualBounce	Char(1)
                              --,UnusualBounceDate	Date
                              --,FlgUnClearedEffect	Char(1)
                              --,UnClearedEffectDate	Date
                              --,FlgFraud			Char(1)
                              --,FraudDate			Date
                              INSERT INTO PRO_RBL_MISDB_PROD.AccountCal_Hist
                                ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate )
                                ( SELECT AccountEntityID ,
                                         UcifEntityID ,
                                         CustomerEntityID ,
                                         CustomerAcID ,
                                         RefCustomerID ,
                                         SourceSystemCustomerID ,
                                         UCIF_ID ,
                                         BranchCode ,
                                         FacilityType ,
                                         AcOpenDt ,
                                         FirstDtOfDisb ,
                                         ProductAlt_Key ,
                                         SchemeAlt_key ,
                                         SubSectorAlt_Key ,
                                         SplCatg1Alt_Key ,
                                         SplCatg2Alt_Key ,
                                         SplCatg3Alt_Key ,
                                         SplCatg4Alt_Key ,
                                         SourceAlt_Key ,
                                         ActSegmentCode ,
                                         InttRate ,
                                         CASE 
                                              WHEN v_POS IS NULL THEN Balance
                                         ELSE v_POS
                                            END Balance  ,
                                         BalanceInCrncy ,
                                         CurrencyAlt_Key ,
                                         DrawingPower ,
                                         CurrentLimit ,
                                         CurrentLimitDt ,
                                         ContiExcessDt ,
                                         StockStDt ,
                                         DebitSinceDt ,
                                         LastCrDate ,
                                         InttServiced ,
                                         IntNotServicedDt ,
                                         OverdueAmt ,
                                         OverDueSinceDt ,
                                         ReviewDueDt ,
                                         SecurityValue ,
                                         CASE 
                                              WHEN v_DFVAmount IS NULL THEN DFVAmt
                                         ELSE v_DFVAmount
                                            END DFVAmt  ,
                                         GovtGtyAmt ,
                                         CoverGovGur ,
                                         WriteOffAmount ,
                                         UnAdjSubSidy ,
                                         CreditsinceDt ,
                                         DegReason ,
                                         Asset_Norm ,
                                         REFPeriodMax ,
                                         RefPeriodOverdue ,
                                         RefPeriodOverDrawn ,
                                         RefPeriodNoCredit ,
                                         RefPeriodIntService ,
                                         RefPeriodStkStatement ,
                                         RefPeriodReview ,
                                         NetBalance ,
                                         ApprRV ,
                                         SecuredAmt ,
                                         UnSecuredAmt ,
                                         ProvDFV ,
                                         Provsecured ,
                                         ProvUnsecured ,
                                         ProvCoverGovGur ,
                                         CASE 
                                              WHEN v_AdditionalProvisionAbsolute IS NULL THEN AddlProvision
                                         ELSE v_AdditionalProvisionAbsolute
                                            END AddlProvision  ,
                                         TotalProvision ,
                                         BankProvsecured ,
                                         BankProvUnsecured ,
                                         BankTotalProvision ,
                                         RBIProvsecured ,
                                         RBIProvUnsecured ,
                                         RBITotalProvision ,
                                         InitialNpaDt ,
                                         FinalNpaDt ,
                                         SMA_Dt ,
                                         UpgDate ,
                                         InitialAssetClassAlt_Key ,
                                         FinalAssetClassAlt_Key ,
                                         ProvisionAlt_Key ,
                                         PNPA_Reason ,
                                         SMA_Class ,
                                         SMA_Reason ,
                                         FlgMoc ,
                                         MOC_Dt ,
                                         CommonMocTypeAlt_Key ,
                                         FlgDeg ,
                                         FlgDirtyRow ,
                                         FlgInMonth ,
                                         FlgSMA ,
                                         FlgPNPA ,
                                         FlgUpg ,
                                         CASE 
                                              WHEN v_FITLFlagAlt_Key IS NULL THEN FLGFITL
                                         ELSE v_FITLFlagAlt_Key
                                            END FlgFITL  ,
                                         FlgAbinitio ,
                                         NPA_Days ,
                                         RefPeriodOverdueUPG ,
                                         RefPeriodOverDrawnUPG ,
                                         RefPeriodNoCreditUPG ,
                                         RefPeriodIntServiceUPG ,
                                         RefPeriodStkStatementUPG ,
                                         RefPeriodReviewUPG ,
                                         v_TimeKey ,
                                         v_TimeKey ,
                                         AppGovGur ,
                                         UsedRV ,
                                         ComputedClaim ,
                                         UPG_RELAX_MSME ,
                                         DEG_RELAX_MSME ,
                                         PNPA_DATE ,
                                         NPA_Reason ,
                                         PnpaAssetClassAlt_key ,
                                         DisbAmount ,
                                         PrincOutStd ,
                                         PrincOverdue ,
                                         PrincOverdueSinceDt ,
                                         IntOverdue ,
                                         IntOverdueSinceDt ,
                                         OtherOverdue ,
                                         OtherOverdueSinceDt ,
                                         RelationshipNumber ,
                                         AccountFlag ,
                                         CommercialFlag_AltKey ,
                                         Liability ,
                                         CD ,
                                         AccountStatus ,
                                         AccountBlkCode1 ,
                                         AccountBlkCode2 ,
                                         ExposureType ,
                                         Mtm_Value ,
                                         BankAssetClass ,
                                         NpaType ,
                                         SecApp ,
                                         BorrowerTypeID ,
                                         LineCode ,
                                         ProvPerSecured ,
                                         ProvPerUnSecured ,
                                         MOCReason ,
                                         AddlProvisionPer ,
                                         FlgINFRA ,
                                         CASE 
                                              WHEN v_RePossessionDate IS NULL THEN RepossessionDate
                                         ELSE v_RePossessionDate
                                            END RepossessionDate  ,
                                         DerecognisedInterest1 ,
                                         DerecognisedInterest2 ,
                                         ProductCode ,
                                         FlgLCBG ,
                                         CASE 
                                              WHEN v_InterestReceivable IS NULL THEN unserviedint
                                         ELSE v_InterestReceivable
                                            END unserviedint  ,
                                         PreQtrCredit ,
                                         PrvQtrInt ,
                                         CurQtrCredit ,
                                         CurQtrInt ,
                                         OriginalBranchcode ,
                                         AdvanceRecovery ,
                                         NotionalInttAmt ,
                                         PrvAssetClassAlt_Key ,
                                         MOCTYPE ,
                                         FlgSecured ,
                                         CASE 
                                              WHEN v_RePossessionFlagAlt_Key IS NULL THEN RePossession
                                         ELSE v_RePossessionFlagAlt_Key
                                            END RePossession  ,
                                         RCPending ,
                                         PaymentPending ,
                                         WheelCase ,
                                         CustomerLevelMaxPer ,
                                         FinalProvisionPer ,
                                         IsIBPC ,
                                         IsSecuritised ,
                                         RFA ,
                                         IsNonCooperative ,
                                         CASE 
                                              WHEN v_SARFAESIFlagAlt_Key IS NULL THEN Sarfaesi
                                         ELSE v_SARFAESIFlagAlt_Key
                                            END Sarfaesi  ,
                                         CASE 
                                              WHEN v_InherentWeaknessFlagAlt_Key IS NULL THEN WeakAccount
                                         ELSE v_InherentWeaknessFlagAlt_Key
                                            END WeakAccount  ,
                                         PUI ,
                                         CASE 
                                              WHEN v_RestructureFlagAlt_Key IS NULL THEN FlgRestructure
                                         ELSE v_RestructureFlagAlt_Key
                                            END FlgRestructure  ,
                                         CASE 
                                              WHEN v_RestructureDate IS NULL THEN RestructureDate
                                         ELSE v_RestructureDate
                                            END RestructureDate  ,
                                         CASE 
                                              WHEN v_InherentWeaknessDate IS NULL THEN WeakAccountDate
                                         ELSE v_InherentWeaknessDate
                                            END WeakAccountDate  ,
                                         CASE 
                                              WHEN v_SARFAESIDate IS NULL THEN SarfaesiDate
                                         ELSE v_SARFAESIDate
                                            END SarfaesiDate  ,
                                         CASE 
                                              WHEN v_UnusualBounceFlagAlt_Key IS NULL THEN FlgUnusualBounce
                                         ELSE v_UnusualBounceFlagAlt_Key
                                            END FlgUnusualBounce  ,
                                         CASE 
                                              WHEN v_UnusualBounceDate IS NULL THEN UnusualBounceDate
                                         ELSE v_UnusualBounceDate
                                            END UnusualBounceDate  ,
                                         CASE 
                                              WHEN v_UnclearedEffectsFlagAlt_Key IS NULL THEN FlgUnClearedEffect
                                         ELSE v_UnclearedEffectsFlagAlt_Key
                                            END FlgUnClearedEffect  ,
                                         CASE 
                                              WHEN v_UnclearedEffectsDate IS NULL THEN UnClearedEffectDate
                                         ELSE v_UnclearedEffectsDate
                                            END UnClearedEffectDate  ,
                                         CASE 
                                              WHEN v_FraudAccountFlagAlt_Key IS NULL THEN FlgFraud
                                         ELSE v_FraudAccountFlagAlt_Key
                                            END FlgFraud  ,
                                         CASE 
                                              WHEN v_FraudDate IS NULL THEN FraudDate
                                         ELSE v_FraudDate
                                            END FraudDate  
                                  FROM tt_ACCOUNT_CAL_7 
                                   WHERE  ( EffectiveToTimeKey > v_TimeKey )
                                            OR ( EffectiveFromTimeKey < v_TimeKey
                                            AND EffectiveToTimeKey = v_TimeKey ) );
                              INSERT INTO PRO_RBL_MISDB_PROD.AccountCal_Hist
                                ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate )
                                ( SELECT AccountEntityID ,
                                         UcifEntityID ,
                                         CustomerEntityID ,
                                         CustomerAcID ,
                                         RefCustomerID ,
                                         SourceSystemCustomerID ,
                                         UCIF_ID ,
                                         BranchCode ,
                                         FacilityType ,
                                         AcOpenDt ,
                                         FirstDtOfDisb ,
                                         ProductAlt_Key ,
                                         SchemeAlt_key ,
                                         SubSectorAlt_Key ,
                                         SplCatg1Alt_Key ,
                                         SplCatg2Alt_Key ,
                                         SplCatg3Alt_Key ,
                                         SplCatg4Alt_Key ,
                                         SourceAlt_Key ,
                                         ActSegmentCode ,
                                         InttRate ,
                                         Balance ,
                                         BalanceInCrncy ,
                                         CurrencyAlt_Key ,
                                         DrawingPower ,
                                         CurrentLimit ,
                                         CurrentLimitDt ,
                                         ContiExcessDt ,
                                         StockStDt ,
                                         DebitSinceDt ,
                                         LastCrDate ,
                                         InttServiced ,
                                         IntNotServicedDt ,
                                         OverdueAmt ,
                                         OverDueSinceDt ,
                                         ReviewDueDt ,
                                         SecurityValue ,
                                         DFVAmt ,
                                         GovtGtyAmt ,
                                         CoverGovGur ,
                                         WriteOffAmount ,
                                         UnAdjSubSidy ,
                                         CreditsinceDt ,
                                         DegReason ,
                                         Asset_Norm ,
                                         REFPeriodMax ,
                                         RefPeriodOverdue ,
                                         RefPeriodOverDrawn ,
                                         RefPeriodNoCredit ,
                                         RefPeriodIntService ,
                                         RefPeriodStkStatement ,
                                         RefPeriodReview ,
                                         NetBalance ,
                                         ApprRV ,
                                         SecuredAmt ,
                                         UnSecuredAmt ,
                                         ProvDFV ,
                                         Provsecured ,
                                         ProvUnsecured ,
                                         ProvCoverGovGur ,
                                         AddlProvision ,
                                         TotalProvision ,
                                         BankProvsecured ,
                                         BankProvUnsecured ,
                                         BankTotalProvision ,
                                         RBIProvsecured ,
                                         RBIProvUnsecured ,
                                         RBITotalProvision ,
                                         InitialNpaDt ,
                                         FinalNpaDt ,
                                         SMA_Dt ,
                                         UpgDate ,
                                         InitialAssetClassAlt_Key ,
                                         FinalAssetClassAlt_Key ,
                                         ProvisionAlt_Key ,
                                         PNPA_Reason ,
                                         SMA_Class ,
                                         SMA_Reason ,
                                         FlgMoc ,
                                         SYSDATE MOC_Dt  ,
                                         CommonMocTypeAlt_Key ,
                                         FlgDeg ,
                                         FlgDirtyRow ,
                                         FlgInMonth ,
                                         FlgSMA ,
                                         FlgPNPA ,
                                         FlgUpg ,
                                         FlgFITL ,
                                         FlgAbinitio ,
                                         NPA_Days ,
                                         RefPeriodOverdueUPG ,
                                         RefPeriodOverDrawnUPG ,
                                         RefPeriodNoCreditUPG ,
                                         RefPeriodIntServiceUPG ,
                                         RefPeriodStkStatementUPG ,
                                         RefPeriodReviewUPG ,
                                         v_Timekey + 1 ,
                                         EffectiveToTimeKey ,
                                         AppGovGur ,
                                         UsedRV ,
                                         ComputedClaim ,
                                         UPG_RELAX_MSME ,
                                         DEG_RELAX_MSME ,
                                         PNPA_DATE ,
                                         NPA_Reason ,
                                         PnpaAssetClassAlt_key ,
                                         DisbAmount ,
                                         PrincOutStd ,
                                         PrincOverdue ,
                                         PrincOverdueSinceDt ,
                                         IntOverdue ,
                                         IntOverdueSinceDt ,
                                         OtherOverdue ,
                                         OtherOverdueSinceDt ,
                                         RelationshipNumber ,
                                         AccountFlag ,
                                         CommercialFlag_AltKey ,
                                         Liability ,
                                         CD ,
                                         AccountStatus ,
                                         AccountBlkCode1 ,
                                         AccountBlkCode2 ,
                                         ExposureType ,
                                         Mtm_Value ,
                                         BankAssetClass ,
                                         NpaType ,
                                         SecApp ,
                                         BorrowerTypeID ,
                                         LineCode ,
                                         ProvPerSecured ,
                                         ProvPerUnSecured ,
                                         v_MOCReason MOCReason  ,
                                         AddlProvisionPer ,
                                         FlgINFRA ,
                                         RepossessionDate ,
                                         DerecognisedInterest1 ,
                                         DerecognisedInterest2 ,
                                         ProductCode ,
                                         FlgLCBG ,
                                         unserviedint ,
                                         PreQtrCredit ,
                                         PrvQtrInt ,
                                         CurQtrCredit ,
                                         CurQtrInt ,
                                         OriginalBranchcode ,
                                         AdvanceRecovery ,
                                         NotionalInttAmt ,
                                         PrvAssetClassAlt_Key ,
                                         MOCTYPE ,
                                         FlgSecured ,
                                         RePossession ,
                                         RCPending ,
                                         PaymentPending ,
                                         WheelCase ,
                                         CustomerLevelMaxPer ,
                                         FinalProvisionPer ,
                                         IsIBPC ,
                                         IsSecuritised ,
                                         RFA ,
                                         IsNonCooperative ,
                                         Sarfaesi ,
                                         WeakAccount ,
                                         PUI ,
                                         FlgRestructure ,
                                         RestructureDate ,
                                         WeakAccountDate ,
                                         SarfaesiDate ,
                                         FlgUnusualBounce ,
                                         UnusualBounceDate ,
                                         FlgUnClearedEffect ,
                                         UnClearedEffectDate ,
                                         FlgFraud ,
                                         FraudDate 
                                  FROM tt_ACCOUNT_CAL_7 
                                   WHERE  EffectiveToTimeKey > v_TimeKey );
                              ---pre moc
                              INSERT INTO PreMoc_RBL_MISDB_PROD.ACCOUNTCAL
                                ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, UnserviedInt
                              --,ENTITYKEY
                              , OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate )
                                ( SELECT A.AccountEntityID ,
                                         A.UcifEntityID ,
                                         A.CustomerEntityID ,
                                         A.CustomerAcID ,
                                         A.RefCustomerID ,
                                         A.SourceSystemCustomerID ,
                                         A.UCIF_ID ,
                                         A.BranchCode ,
                                         A.FacilityType ,
                                         A.AcOpenDt ,
                                         A.FirstDtOfDisb ,
                                         A.ProductAlt_Key ,
                                         A.SchemeAlt_key ,
                                         A.SubSectorAlt_Key ,
                                         A.SplCatg1Alt_Key ,
                                         A.SplCatg2Alt_Key ,
                                         A.SplCatg3Alt_Key ,
                                         A.SplCatg4Alt_Key ,
                                         A.SourceAlt_Key ,
                                         A.ActSegmentCode ,
                                         A.InttRate ,
                                         A.Balance ,
                                         A.BalanceInCrncy ,
                                         A.CurrencyAlt_Key ,
                                         A.DrawingPower ,
                                         A.CurrentLimit ,
                                         A.CurrentLimitDt ,
                                         A.ContiExcessDt ,
                                         A.StockStDt ,
                                         A.DebitSinceDt ,
                                         A.LastCrDate ,
                                         A.PreQtrCredit ,
                                         A.PrvQtrInt ,
                                         A.CurQtrCredit ,
                                         A.CurQtrInt ,
                                         A.InttServiced ,
                                         A.IntNotServicedDt ,
                                         A.OverdueAmt ,
                                         A.OverDueSinceDt ,
                                         A.ReviewDueDt ,
                                         A.SecurityValue ,
                                         A.DFVAmt ,
                                         A.GovtGtyAmt ,
                                         A.CoverGovGur ,
                                         A.WriteOffAmount ,
                                         A.UnAdjSubSidy ,
                                         A.CreditsinceDt ,
                                         A.DegReason ,
                                         A.Asset_Norm ,
                                         A.REFPeriodMax ,
                                         A.RefPeriodOverdue ,
                                         A.RefPeriodOverDrawn ,
                                         A.RefPeriodNoCredit ,
                                         A.RefPeriodIntService ,
                                         A.RefPeriodStkStatement ,
                                         A.RefPeriodReview ,
                                         A.NetBalance ,
                                         A.ApprRV ,
                                         A.SecuredAmt ,
                                         A.UnSecuredAmt ,
                                         A.ProvDFV ,
                                         A.Provsecured ,
                                         A.ProvUnsecured ,
                                         A.ProvCoverGovGur ,
                                         A.AddlProvision ,
                                         A.TotalProvision ,
                                         A.BankProvsecured ,
                                         A.BankProvUnsecured ,
                                         A.BankTotalProvision ,
                                         A.RBIProvsecured ,
                                         A.RBIProvUnsecured ,
                                         A.RBITotalProvision ,
                                         A.InitialNpaDt ,
                                         A.FinalNpaDt ,
                                         A.SMA_Dt ,
                                         A.UpgDate ,
                                         A.InitialAssetClassAlt_Key ,
                                         A.FinalAssetClassAlt_Key ,
                                         A.ProvisionAlt_Key ,
                                         A.PNPA_Reason ,
                                         A.SMA_Class ,
                                         A.SMA_Reason ,
                                         'Y' FlgMoc  ,
                                         A.MOC_Dt ,
                                         A.CommonMocTypeAlt_Key ,
                                         A.FlgDeg ,
                                         A.FlgDirtyRow ,
                                         A.FlgInMonth ,
                                         A.FlgSMA ,
                                         A.FlgPNPA ,
                                         A.FlgUpg ,
                                         A.FlgFITL ,
                                         A.FlgAbinitio ,
                                         A.NPA_Days ,
                                         A.RefPeriodOverdueUPG ,
                                         A.RefPeriodOverDrawnUPG ,
                                         A.RefPeriodNoCreditUPG ,
                                         A.RefPeriodIntServiceUPG ,
                                         A.RefPeriodStkStatementUPG ,
                                         A.RefPeriodReviewUPG ,
                                         v_TimeKey ,
                                         v_TimeKey ,
                                         A.AppGovGur ,
                                         A.UsedRV ,
                                         A.ComputedClaim ,
                                         A.UPG_RELAX_MSME ,
                                         A.DEG_RELAX_MSME ,
                                         A.PNPA_DATE ,
                                         A.NPA_Reason ,
                                         A.PnpaAssetClassAlt_key ,
                                         A.DisbAmount ,
                                         A.PrincOutStd ,
                                         A.PrincOverdue ,
                                         A.PrincOverdueSinceDt ,
                                         A.IntOverdue ,
                                         A.IntOverdueSinceDt ,
                                         A.OtherOverdue ,
                                         A.OtherOverdueSinceDt ,
                                         A.RelationshipNumber ,
                                         A.AccountFlag ,
                                         A.CommercialFlag_AltKey ,
                                         A.Liability ,
                                         A.CD ,
                                         A.AccountStatus ,
                                         A.AccountBlkCode1 ,
                                         A.AccountBlkCode2 ,
                                         A.ExposureType ,
                                         A.Mtm_Value ,
                                         A.BankAssetClass ,
                                         A.NpaType ,
                                         A.SecApp ,
                                         A.BorrowerTypeID ,
                                         A.LineCode ,
                                         A.ProvPerSecured ,
                                         A.ProvPerUnSecured ,
                                         A.MOCReason ,
                                         A.AddlProvisionPer ,
                                         A.FlgINFRA ,
                                         A.RepossessionDate ,
                                         A.DerecognisedInterest1 ,
                                         A.DerecognisedInterest2 ,
                                         A.ProductCode ,
                                         A.FlgLCBG ,
                                         A.UnserviedInt ,
                                         --,ENTITYKEY
                                         A.OriginalBranchcode ,
                                         A.AdvanceRecovery ,
                                         A.NotionalInttAmt ,
                                         A.PrvAssetClassAlt_Key ,
                                         A.MOCTYPE ,
                                         A.FlgSecured ,
                                         A.RePossession ,
                                         A.RCPending ,
                                         A.PaymentPending ,
                                         A.WheelCase ,
                                         A.CustomerLevelMaxPer ,
                                         A.FinalProvisionPer ,
                                         A.IsIBPC ,
                                         A.IsSecuritised ,
                                         A.RFA ,
                                         A.IsNonCooperative ,
                                         A.Sarfaesi ,
                                         A.WeakAccount ,
                                         A.PUI ,
                                         A.FlgRestructure ,
                                         A.RestructureDate ,
                                         A.WeakAccountDate ,
                                         A.SarfaesiDate ,
                                         A.FlgUnusualBounce ,
                                         A.UnusualBounceDate ,
                                         A.FlgUnClearedEffect ,
                                         A.UnClearedEffectDate ,
                                         A.FlgFraud ,
                                         A.FraudDate 
                                  FROM tt_ACCOUNT_CAL_7 A
                                         LEFT JOIN PreMoc_RBL_MISDB_PROD.ACCOUNTCAL B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                                         AND B.EffectiveToTimeKey = v_TimeKey )
                                         AND A.CustomerACID = B.CustomerAcID
                                   WHERE  B.CustomerAcID IS NULL );

                           END;
                           END IF;
                           SELECT utils.stuff(( SELECT ',' || ChangeField 
                                                FROM AccountLevelMOC_Mod 
                                                 WHERE  AccountID = v_AccountID
                                                          AND NVL(AuthorisationStatus, 'A') = 'A' ), 1, 1, ' ') 

                             INTO v_Parameter
                             FROM DUAL ;
                           IF utils.object_id('tt_A_5') IS NOT NULL THEN
                            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_5 ';
                           END IF;
                           DELETE FROM tt_A_5;
                           UTILS.IDENTITY_RESET('tt_A_5');

                           INSERT INTO tt_A_5 ( 
                           	SELECT DISTINCT VALUE 
                           	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                                            VALUE 
                                     FROM ( SELECT VALUE 
                                            FROM TABLE(STRING_SPLIT(v_Parameter, ','))  ) A ) X );
                           SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                                FROM tt_A_5  ), 1, 1, ' ') 

                             INTO v_FinalParameter
                             FROM DUAL ;
                           MERGE INTO A 
                           USING (SELECT A.ROWID row_id, v_FinalParameter
                           FROM A ,PRO_RBL_MISDB_PROD.AccountCal_Hist A 
                            WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
                             AND EffectiveToTimeKey >= v_tiMEKEY )
                             AND CustomerAcID = v_AccountID) src
                           ON ( A.ROWID = src.row_id )
                           WHEN MATCHED THEN UPDATE SET a.ChangeField = v_FinalParameter;
                           IF v_AUTHMODE = 'N' THEN

                           BEGIN
                              v_AuthorisationStatus := 'A' ;
                              GOTO GLCodeMaster_Insert;
                              <<HistoryRecordInUp>>

                           END;
                           END IF;

                        END;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<GLCodeMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO AccountLevelMOC_Mod
              ( AccountID, AccountEntityID, POS, InterestReceivable, RestructureFlag, RestructureDate, FITLFlag, DFVAmount, RePossessionFlag, RePossessionDate, InherentWeaknessFlag, InherentWeaknessDate, SARFAESIFlag, SARFAESIDate, UnusualBounceFlag, UnusualBounceDate, UnclearedEffectsFlag, UnclearedEffectsDate, AdditionalProvisionCustomerlevel, AdditionalProvisionAbsolute, MOCReason, FraudAccountFlag, FraudDate, ScreenFlag, MOCSource, MOCDate, MOCBy, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, Changefield )
              VALUES ( v_AccountID, v_AccountEntityID, v_POS, v_InterestReceivable, v_RestructureFlagAlt_Key, v_RestructureDate, v_FITLFlagAlt_Key, v_DFVAmount, v_RePossessionFlagAlt_Key, v_RePossessionDate, v_InherentWeaknessFlagAlt_Key, v_InherentWeaknessDate, v_SARFAESIFlagAlt_Key, v_SARFAESIDate, v_UnusualBounceFlagAlt_Key, v_UnusualBounceDate, v_UnclearedEffectsFlagAlt_Key, v_UnclearedEffectsDate, v_AdditionalProvisionCustomerlevel, v_AdditionalProvisionAbsolute, v_MOCReason, v_FraudAccountFlagAlt_Key, v_FraudDate, v_ScreenFlag, v_MOCSource, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,20,p_style=>103), v_CreatedBy, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, v_AccountNPAMOC_ChangeFields );
            --Sachin			
            DBMS_OUTPUT.PUT_LINE('Sachin');
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO GLCodeMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM CustomerLevelMOC WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND GLAlt_Key=@GLAlt_Key
         IF v_OperationFlag = 3 THEN

         BEGIN
            v_Result := 0 ;

         END;
         ELSE

         BEGIN
            v_Result := 1 ;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
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
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;---------

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP_PROD_15122023" TO "ADF_CDR_RBL_STGDB";
