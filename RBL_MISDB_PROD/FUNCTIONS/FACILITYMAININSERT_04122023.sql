--------------------------------------------------------
--  DDL for Function FACILITYMAININSERT_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" 
(
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_IsMOC IN CHAR DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT 'd2k' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT 1 ,
  iv_AccountEntityId IN NUMBER DEFAULT 0 ,
  v_ClaimCoverAmt IN NUMBER DEFAULT 0 ,
  v_ClaimLodgedAmt IN NUMBER DEFAULT 0 ,
  v_ClaimReceivedAmt IN NUMBER DEFAULT 0 ,
  --,@DICGC_ECGC_NHBClaimSettled	varchar(20)=''
  v_AdvAcBasicDetail IN CHAR DEFAULT 'N' ,
  iv_AdvBalanceDetail IN CHAR DEFAULT 'N' ,
  v_AdvAcCaseWiseBalanceDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvAcFinancialInUp IN CHAR DEFAULT 'N' ,
  iv_AdvAcOtherBalanceDetail IN CHAR DEFAULT 'N' ,
  v_AdvAcOtherDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvFacBillDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvFacCCDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvFacDLDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvFacNFDetailInUp IN CHAR DEFAULT 'N' ,
  v_AdvFacPCDetailInUp IN CHAR DEFAULT 'N' ,
  v_BlnSCD2ForAdvAcFinancialDetail IN CHAR DEFAULT 'N' ,
  v_Blnscd2foradvacotherdetail IN CHAR DEFAULT 'N' ,
  v_BlnSCD2ForBalanceDetail IN CHAR DEFAULT 'N' ,
  v_BlnSCD2ForAdvAcBasicDetail IN CHAR DEFAULT 'N' ,
  v_BlnSCD2ForAdvFacBillDetail IN CHAR DEFAULT 'N' ,
  v_ScrCrErrorSeq IN VARCHAR2 DEFAULT ' ' ,
  v_AclattestDevelopment IN VARCHAR2 DEFAULT ' ' ,
  v_DICGC_ECGC_NHBClaimSettled IN VARCHAR2 DEFAULT ' ' ,
  v_LastSanctionAuthAlt_Key IN NUMBER DEFAULT 0 ,---LastSanctionAuth
  v_CustomerEntityId IN NUMBER DEFAULT 0 ,
  v_CustomerACID IN VARCHAR2 DEFAULT ' ' ,
  v_RefCustomerId IN VARCHAR2 DEFAULT ' ' ,
  v_FacilityType IN VARCHAR2 DEFAULT ' ' ,
  v_InttTypeAlt_Key IN NUMBER DEFAULT 0 ,--Interest type
  v_InttRate IN NUMBER DEFAULT 0.0 ,--InttRate
  v_OriginalLimitDt IN VARCHAR2 DEFAULT ' ' ,---Originaldate
  v_OriginalLimit IN NUMBER DEFAULT 0 ,--OriginalFirstSanAmt
  v_OriginalSanctionAuthAlt_Key IN NUMBER DEFAULT 0 ,---Original Sanction Authority
  v_OriginalLimitRefNo IN VARCHAR2 DEFAULT ' ' ,---OriginalLimitRefNo
  v_OriginalSanctionAuthLevelAlt_Key IN NUMBER DEFAULT 0 ,--Sanction Authority Level
  v_CurrentLimit IN NUMBER DEFAULT 0.0 ,---LastSanAmount
  v_CurrentLimitDt IN VARCHAR2 DEFAULT ' ' ,---LastSanctionDate
  v_CurrentLimitRefNo IN VARCHAR2 DEFAULT ' ' ,--LastSanctionLimitRefNo 
  v_Ac_ReviewAuthLevelAlt_Key IN NUMBER DEFAULT 0 ,---LastSanctionAuthorityLevel
  iv_GLAlt_Key IN VARCHAR2 DEFAULT ' ' ,--GL_Code
  v_GLProductAlt_Key IN NUMBER DEFAULT 0 ,----GLProductAlt_Key   
  v_SectorAlt_Key IN NUMBER DEFAULT 0 ,---Sector
  v_ActivityAlt_Key IN NUMBER DEFAULT 0 ,
  v_SchemeAlt_Key IN NUMBER DEFAULT 0 ,--scheme
  v_DtofFirstDisb IN VARCHAR2 DEFAULT ' ' ,----Disbrusmentdate
  v_Ac_DocumentDt IN VARCHAR2 DEFAULT ' ' ,-----Acknowledment debt date
  v_TotalProv IN NUMBER DEFAULT 0.0 ,--ProvAmt
  v_RepayModeAlt_Key IN NUMBER,---RepayMode
  v_LastCrDt IN VARCHAR2 DEFAULT ' ' ,--Last Credit Date
  v_WriteOffAmt_HO IN NUMBER,
  v_WriteOffDt IN VARCHAR2,
  v_LastCrAmt IN NUMBER DEFAULT 0.0 ,--Last Credit Amount
  v_ClaimPrincipal IN NUMBER DEFAULT 0.0 ,----LedgerBalance    
  v_ClaimUnapplInt IN NUMBER DEFAULT 0.0 ,----UnappliedInt
  v_ClaimExpenses IN NUMBER DEFAULT 0.0 ,---LegalExpences
  v_ClaimOther IN NUMBER DEFAULT 0.0 ,---other
  v_ClaimTotal IN NUMBER DEFAULT 0.0 ,--Total
  v_Principal IN NUMBER DEFAULT 0.0 ,--PrincipalLedgerBalance
  v_UnapplInt IN NUMBER DEFAULT 0.0 ,--PrincipalUnappliedInterest
  v_Expenses IN NUMBER DEFAULT 0.0 ,--PrincipalLegalExpenses
  v_Other IN NUMBER DEFAULT 0.0 ,---PrincipalOthers
  v_Total IN NUMBER DEFAULT 0.0 ,----PrincipalTotal
  v_MocTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_MOCReason IN VARCHAR2 DEFAULT ' ' ,
  v_ScrCrError IN VARCHAR2 DEFAULT ' ' ,
  v_LimitDisbursed IN VARCHAR2 DEFAULT ' ' ,
  ---------ADD Changefields Column------
  v_Basic_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_Balance_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_CaseWiseBalance_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_Financial_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_OtherBalance_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_Other_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_FacBill_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_FacCC_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_FacDL_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_FacNF_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_FacPC_ChangeFields IN VARCHAR2 DEFAULT ' ' 
)
RETURN NUMBER
AS
   v_AdvAcOtherBalanceDetail CHAR(1) := iv_AdvAcOtherBalanceDetail;
   v_AdvBalanceDetail CHAR(1) := iv_AdvBalanceDetail;
   --,@LastSanctionAuthAlt_Key				    INT				=0---LastSanctionAuth
   v_GLAlt_Key VARCHAR2(20) := iv_GLAlt_Key;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AccountEntityId NUMBER(10,0) := iv_AccountEntityId;

BEGIN

   BEGIN
      DECLARE
         v_ProductAlt_Key NUMBER(10,0);
         v_ProductCode VARCHAR2(20);
         v_FacilitySubType VARCHAR2(20);
         v_GLAlt_Key1 NUMBER(10,0);
         v_MocDate DATE;
         v_AuthorisationStatus CHAR(2);

      BEGIN
         IF v_AdvBalanceDetail = 'Y' THEN

         BEGIN
            v_AdvAcOtherBalanceDetail := 'Y' ;

         END;
         ELSE
            IF v_AdvAcOtherBalanceDetail = 'Y' THEN

            BEGIN
               v_AdvBalanceDetail := 'Y' ;

            END;
            END IF;
         END IF;
         DBMS_OUTPUT.PUT_LINE('Hi');
         SELECT ProductCode ,
                FacilitySubType 

           INTO v_ProductCode,
                v_FacilitySubType
           FROM DimGLProduct 
          WHERE  GLProductAlt_Key = v_GLProductAlt_Key;
         DBMS_OUTPUT.PUT_LINE(v_FacilitySubType);
         SELECT ProductAlt_Key 

           INTO v_ProductAlt_Key
           FROM DimProduct 
          WHERE  ProductCode = v_ProductCode;
         SELECT GLAlt_Key 

           INTO v_GLAlt_Key
           FROM DimGL 
          WHERE  GLCode = UTILS.CONVERT_TO_VARCHAR2(v_GLAlt_Key,10);
         --********************************************************************************
         --			FOR MOC
         --***********************************************************************************
         IF v_IsMOC = 'Y' THEN

         BEGIN
            --- for MOC Effective from TimeKey and Effective to time Key is Prev_Qtr_key e.g for 2922  2830
            DBMS_OUTPUT.PUT_LINE('ISMOC');
            v_EffectiveFromTimeKey := v_TimeKey ;
            v_EffectiveToTimeKey := v_TimeKey ;
            v_MocDate := SYSDATE ;

         END;
         END IF;
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         --********************************************************************************
         IF v_AdvAcBasicDetail = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(1);
            DBMS_OUTPUT.PUT_LINE('A');
            RBL_MISDB_PROD.AdvAcBasicDetailInUP(v_BranchCode,
                                                v_AccountEntityId,
                                                v_CustomerEntityId,
                                                ' ' ----@SystemACID                       
                                                ,
                                                v_CustomerACID,
                                                v_GLAlt_Key,
                                                v_ProductAlt_Key,
                                                v_GLProductAlt_Key ---For DlProductAltKey              
                                                ,
                                                v_FacilityType,
                                                v_SectorAlt_Key,
                                                v_SectorAlt_Key --0---@SubSectorAlt_Key                 
                                                ,
                                                v_ActivityAlt_Key,
                                                0 ----@IndustryAlt_Key                  
                                                ,
                                                v_SchemeAlt_Key,
                                                0 ---@DistrictAlt_Key                  
                                                ,
                                                0 ---@AreaAlt_Key                      
                                                ,
                                                0 ---@VillageAlt_Key                   
                                                ,
                                                0 ---@StateAlt_Key                     
                                                ,
                                                0 ---@CurrencyAlt_Key                  
                                                ,
                                                v_OriginalSanctionAuthAlt_Key,
                                                v_OriginalLimitRefNo,
                                                v_OriginalLimit,
                                                v_OriginalLimitDt,
                                                v_AclattestDevelopment,
                                                v_DtofFirstDisb,
                                                ' ' ---@EmpCode                          
                                                ,
                                                ' ' ---@FlagReliefWavier                 
                                                ,
                                                0 ---@UnderLineActivityAlt_Key         
                                                ,
                                                0 ---@MicroCredit                      
                                                ,
                                                ' ' ---@segmentcode                      
                                                ,
                                                ' ' ---@ScrCrError                       
                                                ,
                                                ' ' ---@AdjDt                            
                                                ,
                                                0 ---@AdjReasonAlt_Key                 
                                                ,
                                                0 ---@MarginType                       
                                                ,
                                                0 ---@Pref_InttRate                    
                                                ,
                                                v_CurrentLimitRefNo,
                                                ' ' --@ProcessingFeeApplicable          
                                                ,
                                                0.0 --@ProcessingFeeAmt                 
                                                ,
                                                0.0 --@ProcessingFeeRecoveryAmt         
                                                ,
                                                0 --@GuaranteeCoverAlt_Key            
                                                ,
                                                ' ' --@AccountName                      
                                                ,
                                                0 --@ReferencePeriod                  
                                                ,
                                                ' ' --@AssetClass                       
                                                ,
                                                ' ' --@D2K_REF_NO                       
                                                ,
                                                ' ' --@InttAppFreq                      
                                                ,
                                                ' ' --@JointAccount                     
                                                ,
                                                ' ' --@LastDisbDt                       
                                                ,
                                                ' ' --@ScrCrErrorBackup                 
                                                ,
                                                ' ' --@AccountOpenDate                  
                                                ,
                                                ' ' --@Ac_LADDt                         
                                                ,
                                                v_Ac_DocumentDt,
                                                v_CurrentLimit,
                                                v_InttTypeAlt_Key,
                                                0 ---@InttRateLoadFactor               
                                                ,
                                                0 ---@Margin                           
                                                ,
                                                ' ' ---@TwentyPointReference             
                                                ,
                                                ' ' ---@BSR1bCode                        
                                                ,
                                                v_CurrentLimitDt,
                                                ' ' ---@Ac_DueDt                         
                                                ,
                                                0 --@DrawingPowerAlt_Key              
                                                ,
                                                v_RefCustomerId,
                                                ' ' ---@D2KACID                          
                                                ,
                                                0 --@IsLAD                            
                                                ,
                                                0 ---@FacilitiesNo                     
                                                ,
                                                0 --@FincaleBasedIndustryAlt_key      
                                                ,
                                                0 --@AcCategoryAlt_Key                
                                                ,
                                                v_OriginalSanctionAuthLevelAlt_Key,
                                                0 --@AcTypeAlt_Key                    
                                                ,
                                                v_ScrCrErrorSeq,
                                                ' ' ---@D2k_OLDAscromID                  
                                                ,
                                                ' ' --@BSRUNID                          
                                                ,
                                                0 --@AdditionalProv                   
                                                ,
                                                0 --@ProjectCost                      
                                                ,
                                                v_Remark,
                                                v_MenuID,
                                                v_OperationFlag,
                                                v_AuthMode,
                                                v_IsMOC,
                                                v_EffectiveFromTimeKey,
                                                v_EffectiveToTimeKey,
                                                v_TimeKey,
                                                v_CrModApBy,
                                                v_D2Ktimestamp,
                                                v_Result,
                                                v_BlnSCD2ForAdvAcBasicDetail,
                                                v_Basic_ChangeFields) ;

         END;
         END IF;
         DBMS_OUTPUT.PUT_LINE('A11');
         IF v_OperationFlag = 1 THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('111aaaaa');
            v_AccountEntityId := v_Result ;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CustPreCaseDataStage 
                                WHERE  CustomerEntityId = v_CustomerEntityId );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               UPDATE CustPreCaseDataStage
                  SET CurrentStageAlt_Key = 20,
                      NextStageAlt_Key = 30
                WHERE  CustomerEntityId = v_CustomerEntityId;

            END;
            END IF;
            /* WHEN ADDED NEW ACCOUNT THEN TRIGGER FOR RE-GENERATE STATUS NOTE REPORT*/
            StatusNoteTriggerInUp(v_CustomerEntityId) ;
            DBMS_OUTPUT.PUT_LINE('2222BBBBBB');

         END;
         END IF;
         IF v_OperationFlag <> 1 THEN

         BEGIN
            v_Result := v_AccountEntityId ;

         END;
         END IF;
         IF v_OperationFlag = 17 THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Reject');
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CustPreCaseDataStage 
                                WHERE  CustomerEntityId = v_CustomerEntityId );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               UPDATE CustPreCaseDataStage
                  SET CurrentStageAlt_Key = 10,
                      NextStageAlt_Key = 20
                WHERE  CustomerEntityId = v_CustomerEntityId
                 AND CurrentStageAlt_Key = 20;

            END;
            END IF;

         END;
         END IF;
         IF v_AdvBalanceDetail = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('balance table ');
            AdvAcBalanceDetailInUP(v_AccountEntityId,
                                   0 --@AssetClassAlt_Key	         
                                   ,
                                   0 ---@BalanceInCurrency	         
                                   ,
                                   0.0 ---@Balance	                 
                                   ,
                                   0 ---@SignBalance	             
                                   ,
                                   v_LastCrDt,
                                   0 ---@OverDue	                 
                                   ,
                                   v_TotalProv,
                                   0 ---@DirectBalance	             
                                   ,
                                   0 ---@InDirectBalance	         
                                   ,
                                   v_LastCrAmt,
                                   v_RefCustomerId,
                                   NULL ---@RefSystemAcId	             
                                   ,
                                   NULL ---@OverDueSinceDt	         
                                   ,
                                   v_MocTypeAlt_Key,
                                   NULL ---@Old_OverDueSinceDt	     
                                   ,
                                   0 ---@Old_OverDue	             
                                   ,
                                   0 ---@IntReverseAmt	             
                                   ,
                                   0 ---@PS_Balance	             
                                   ,
                                   0 ---@NPS_Balance				 
                                   ,
                                   v_IsMOC,
                                   v_EffectiveFromTimeKey,
                                   v_EffectiveToTimeKey,
                                   v_TimeKey,
                                   v_CrModApBy,
                                   v_D2Ktimestamp,
                                   v_Result,
                                   v_Remark,
                                   v_MenuID,
                                   v_OperationFlag,
                                   v_AuthMode,
                                   v_BlnSCD2ForBalanceDetail) ;

         END;
         END IF;
         --,@Balance_ChangeFields	             
         IF v_AdvAcCaseWiseBalanceDetailInUp = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(3);
            RBL_MISDB_PROD.AdvAcCaseWiseBalanceDetailInUp(v_CustomerEntityID,
                                                          v_AccountEntityID,
                                                          v_ClaimPrincipal,
                                                          0.0 ---@ClaimPartialWO         
                                                          ,
                                                          v_ClaimUnapplInt,
                                                          0 ---@ClaimBookInt           
                                                          ,
                                                          v_ClaimExpenses,
                                                          v_ClaimOther,
                                                          v_ClaimTotal,
                                                          v_EffectiveFromTimeKey,
                                                          v_EffectiveToTimeKey,
                                                          v_CrModApBy,
                                                          v_OperationFlag,
                                                          v_D2Ktimestamp,
                                                          v_Result,
                                                          v_AuthMode,
                                                          v_MenuID,
                                                          v_Remark,
                                                          v_TimeKey) ;

         END;
         END IF;
         --,@CaseWiseBalance_ChangeFields  
         IF v_AdvAcFinancialInUp = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(4);
            AdvAcFinancialInUp(v_AccountEntityId,
                               NULL ---@Ac_LastReviewDueDt                             
                               ,
                               0 --@Ac_ReviewTypeAlt_key                           
                               ,
                               NULL --@Ac_ReviewDt                                    
                               ,
                               v_LastSanctionAuthAlt_Key ----@Ac_ReviewAuthAlt_Key                           
                               ,
                               NULL ---@Ac_NextReviewDueDt                             
                               ,
                               0.0 ---@DrawingPower                                   
                               ,
                               v_InttRate,
                               NULL --@IrregularType                                  
                               ,
                               NULL ---@IrregularityDt                                 
                               ,
                               NULL --@NpaDt                                          
                               ,
                               0.0 --@BookDebts                                      
                               ,
                               0.0 --@UnDrawnAmt                                     
                               ,
                               0.0 ---@TotalDI                                        
                               ,
                               0.0 ---@UnAppliedIntt                                  
                               ,
                               0.0 ---@LegalExp                                       
                               ,
                               0.0 ---@UnAdjSubSidy                                   
                               ,
                               NULL ---@LastInttRealiseDt                              
                               ,
                               v_MOCReason,
                               v_WriteOffAmt_HO,
                               0 --@InterestRateCodeAlt_Key                        
                               ,
                               v_WriteOffDt,
                               NULL ---@OD_Dt                                          
                               ,
                               0.0 --@LimitDisbursed                                 
                               ,
                               0.0 ---@WriteOffAmt_BR                                 
                               ,
                               v_RefCustomerId,
                               NULL ---@RefSystemAcId                                  
                               ,
                               v_MocTypeAlt_Key,
                               0.0 --@CropDuration                                   
                               ,
                               v_Ac_ReviewAuthLevelAlt_Key,
                               v_BlnSCD2ForAdvAcFinancialDetail,
                               v_Remark,
                               v_MenuID,
                               v_OperationFlag,
                               v_AuthMode,
                               v_IsMOC,
                               v_EffectiveFromTimeKey,
                               v_EffectiveToTimeKey,
                               v_TimeKey,
                               v_CrModApBy,
                               v_D2Ktimestamp,
                               v_Result) ;

         END;
         END IF;
         --,@Financial_ChangeFields
         IF v_AdvAcOtherBalanceDetail = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap6');
            RBL_MISDB_PROD.AdvAcOtherBalanceDetailInUp(v_CustomerEntityID,
                                                       v_AccountEntityID,
                                                       v_Principal,
                                                       0 ---@PartialWO	            
                                                       ,
                                                       v_UnapplInt,
                                                       0 ---@BookInt	            
                                                       ,
                                                       v_Expenses,
                                                       v_Other,
                                                       v_Total,
                                                       v_EffectiveFromTimeKey,
                                                       v_EffectiveToTimeKey,
                                                       v_D2Ktimestamp,
                                                       v_TimeKey,
                                                       v_OperationFlag,
                                                       v_AuthMode,
                                                       v_MenuID,
                                                       v_Remark,
                                                       v_BranchCode,
                                                       v_ScreenEntityId,
                                                       v_CrModApBy,
                                                       v_Result) ;

         END;
         END IF;
         --,@OtherBalance_ChangeFields  
         IF v_AdvAcOtherDetailInUp = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap5');
            RBL_MISDB_PROD.AdvAcOtherDetailInUp(v_ACCOUNTENTITYID,
                                                0 ---@GOVGURAMT						 
                                                ,
                                                0 ---@REFINANCEAGENCYALT_KEY		 
                                                ,
                                                0 ---@REFINANCEAMOUNT				 
                                                ,
                                                0 --@BANKALT_KEY					 
                                                ,
                                                0 ---@TRANSFERAMT					 
                                                ,
                                                NULL ---@PROJECTID						 
                                                ,
                                                NULL ---@CONSORTIUMID					 
                                                ,
                                                NULL --@REFSYSTEMACID					 
                                                ,
                                                NULL ---@CONTINOUSEXCESSSECDT			 
                                                ,
                                                NULL ---@GOVGUREXPDT					 
                                                ,
                                                v_ISMOC,
                                                v_EFFECTIVEFROMTIMEKEY,
                                                v_EFFECTIVETOTIMEKEY,
                                                0 ---@SPLCATG1ALT_KEY				 
                                                ,
                                                0 ---@SPLCATG2ALT_KEY				 
                                                ,
                                                0 ---@SPLCATG3ALT_KEY				 
                                                ,
                                                0 ---@SPLCATG4ALT_KEY                	   
                                                ,
                                                v_REMARK,
                                                v_MENUID,
                                                v_OPERATIONFLAG,
                                                v_AUTHMODE,
                                                v_TIMEKEY,
                                                v_CrModApBy,
                                                v_D2KTIMESTAMP,
                                                v_RESULT,
                                                v_Blnscd2foradvacotherdetail,
                                                v_MOCTYPEALT_KEY) ;

         END;
         END IF;
         --,@Other_ChangeFields			 
         IF v_AdvFacCCDetailInUp = 'Y'
           AND v_FacilitySubType IN ( 'OD','CC' )
          THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap4');
            RBL_MISDB_PROD.AdvFacCCDetailInUp(v_AccountEntityId,
                                              NULL --@AdhocDt						
                                              ,
                                              0 --@AdhocAmt						
                                              ,
                                              NULL --@ContExcsSinceDt				
                                              ,
                                              0 ---@MarginAmt						
                                              ,
                                              0 ---@DerecognisedInterest1			
                                              ,
                                              0 ---@DerecognisedInterest2			
                                              ,
                                              0 --@AdjReasonAlt_Key				
                                              ,
                                              NULL ---@EntityClosureDate				
                                              ,
                                              0 ---@EntityClosureReasonAlt_Key	
                                              ,
                                              NULL ---@ClaimType						
                                              ,
                                              v_ClaimCoverAmt,
                                              NULL ---@ClaimLodgedDt					
                                              ,
                                              v_ClaimLodgedAmt,
                                              NULL --@ClaimRecvDt					
                                              ,
                                              v_ClaimReceivedAmt,
                                              0 ---@ClaimRate						
                                              ,
                                              NULL ---@RefSystemAcid					
                                              ,
                                              NULL --@AdhocExpiryDate				
                                              ,
                                              0 ---@AdhocPermittedAlt_key			
                                              ,
                                              NULL --@AdhocAuth_ID					
                                              ,
                                              0 ---@AdhocNormalInterest			
                                              ,
                                              NULL ---@DebitSinceDt					
                                              ,
                                              NULL --@Acc_StkSmtFlag				
                                              ,
                                              NULL --@ChangeFields					
                                              ,
                                              v_Remark,
                                              v_MenuID,
                                              v_OperationFlag,
                                              v_AuthMode,
                                              v_IsMOC,
                                              v_EffectiveFromTimeKey,
                                              v_EffectiveToTimeKey,
                                              v_TimeKey,
                                              v_CrModApBy,
                                              v_D2Ktimestamp,
                                              v_Result,
                                              v_BranchCode,
                                              v_ScreenEntityId) ;

         END;
         END IF;
         -- ,@FacCC_ChangeFields
         IF v_AdvFacBillDetailInUp = 'Y'
           AND v_FacilitySubType = 'BP' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap3');
            AdvFacBillDetailInUp(v_AccountEntityId,
                                 0 ---@D2KFacilityID				
                                 ,
                                 NULL --@BillNo					
                                 ,
                                 NULL ---@BillDt					
                                 ,
                                 0 ---@BillAmt					
                                 ,
                                 NULL ---@BillRefNo					
                                 ,
                                 NULL ---@BillPurDt					
                                 ,
                                 0 ---@AdvAmount					
                                 ,
                                 NULL --@BillDueDt					
                                 ,
                                 NULL ---@BillExtendedDueDt			
                                 ,
                                 NULL ---@CrystalisationDt			
                                 ,
                                 NULL --@CommercialisationDt		
                                 ,
                                 0 --@BillNeNo					
                                 ,
                                 NULL ---@DraweeBankName			
                                 ,
                                 NULL ---@DraatureAlt_Key			
                                 ,
                                 NULL ---@BillAcceptanceDt			
                                 ,
                                 0 ---@UsanceDays				
                                 ,
                                 0 ---@DrawewerName				
                                 ,
                                 NULL --@PayeeName					
                                 ,
                                 NULL ---@CollectingBankName		
                                 ,
                                 NULL ---@CollectingBranchPlace		
                                 ,
                                 0 ---@InterestIncome			
                                 ,
                                 0 --@Commission				
                                 ,
                                 0 ---@DiscountCharges			
                                 ,
                                 0 --@DelayedInt				
                                 ,
                                 0 --@MarginType				
                                 ,
                                 0 ---@MarginAmt					
                                 ,
                                 0 --@CountryAlt_Key			
                                 ,
                                 0 --@BillOsReasonAlt_Key		
                                 ,
                                 0 --@CommodityAlt_Key			
                                 ,
                                 NULL ---@LcNo						
                                 ,
                                 0 ---@LcAmt						
                                 ,
                                 0 ---@LcIssuingBankAlt_Key		
                                 ,
                                 NULL ---@LcIssuingBank				
                                 ,
                                 0 ---@CurrencyAlt_Key			
                                 ,
                                 0.0 ---@Balance					
                                 ,
                                 0 --@BalanceInCurrency			
                                 ,
                                 0 ---@Overdue					
                                 ,
                                 0 ---@DerecognisedInterest1		
                                 ,
                                 0 ---@DerecognisedInterest2		
                                 ,
                                 0.0 ----@UnAppliedIntt				
                                 ,
                                 0 ----@BillFacilityNo			
                                 ,
                                 0.0 ---@CAD						
                                 ,
                                 0.0 ---@CADU						
                                 ,
                                 NULL ----@OverDueSinceDt			
                                 ,
                                 v_TotalProv,
                                 0 ----@AdditionalProv			
                                 ,
                                 0 ---@GenericAddlProv			
                                 ,
                                 0 --@Secured					
                                 ,
                                 0 --@CoverGovGur				
                                 ,
                                 0 --@Unsecured					
                                 ,
                                 0 --@Provsecured				
                                 ,
                                 0 --@ProvUnsecured				
                                 ,
                                 0 --@ProvDicgc					
                                 ,
                                 NULL ---@npadt						
                                 ,
                                 NULL ---@ClaimType					
                                 ,
                                 v_ClaimCoverAmt,
                                 NULL ---@ClaimLodgedDt				
                                 ,
                                 v_ClaimLodgedAmt -------DICGC/ECGC/NHBClaimEligible		
                                 ,
                                 NULL ---@ClaimRecvDt				
                                 ,
                                 v_ClaimReceivedAmt,
                                 0 ---@ClaimRate					
                                 ,
                                 v_ScrCrError,
                                 NULL ---@RefSystemAcid				
                                 ,
                                 NULL --@AdjDt						
                                 ,
                                 0 --@AdjReasonAlt_Key			
                                 ,
                                 NULL --@EntityClosureDate			
                                 ,
                                 0 --@EntityClosureReasonAlt_Key
                                 ,
                                 v_MocTypeAlt_Key,
                                 v_ScrCrErrorSeq,
                                 NULL --@ConsigmentExport			
                                 ,

                                 ---------D2k System Common C
                                 v_Remark,
                                 v_MenuID,
                                 v_OperationFlag,
                                 v_AuthMode,
                                 v_IsMOC,
                                 v_EffectiveFromTimeKey,
                                 v_EffectiveToTimeKey,
                                 v_TimeKey,
                                 v_CrModApBy,
                                 v_D2Ktimestamp,
                                 v_Result,
                                 v_BranchCode,
                                 v_ScreenEntityId) ;

         END;
         END IF;
         --,@FacBill_ChangeFields
         IF v_AdvFacDLDetailInUp = 'Y'
           AND v_FacilitySubType IN ( 'DL','TL' )
          THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap2');
            AdvFacDLDetailInUp(v_AccountEntityId,
                               v_Principal,
                               v_RepayModeAlt_Key,
                               0 ---@NoOfInstall					
                               ,
                               0 --@InstallAmt					
                               ,
                               NULL ---@FstInstallDt					
                               ,
                               NULL ---@LastInstallDt					
                               ,
                               0 ---@Tenure_Months					
                               ,
                               0 ---@MarginAmt						
                               ,
                               0 --@CommodityAlt_Key				
                               ,
                               0 --@RephaseAlt_Key				
                               ,
                               NULL --@RephaseDt						
                               ,
                               NULL --@IntServiced					
                               ,
                               0 ---@SuspendedInterest				
                               ,
                               0 ---@DerecognisedInterest1			
                               ,
                               0 ---@DerecognisedInterest2			
                               ,
                               0 --@AdjReasonAlt_Key				
                               ,
                               NULL ----@LcNo							
                               ,
                               0 ----@LcAmt							
                               ,
                               0 --@LcIssuingBankAlt_Key			
                               ,
                               0 --@ResetFrequency				
                               ,
                               NULL ---@ResetDt						
                               ,
                               0 --@Moratorium					
                               ,
                               NULL ---@FirstInstallDtInt				
                               ,
                               NULL ---@ContExcsSinceDt				
                               ,
                               0 ----@loanPeriod					
                               ,
                               NULL ---@ClaimType						
                               ,
                               v_ClaimCoverAmt,
                               NULL ---@ClaimLodgedDt					
                               ,
                               v_ClaimLodgedAmt,
                               NULL ---@ClaimRecvDt					
                               ,
                               v_ClaimReceivedAmt,
                               0 ---@ClaimRate						
                               ,
                               NULL ---@RefSystemAcid					
                               ,
                               0.0 ----@UnAppliedIntt					
                               ,
                               0 ---@NxtInstDay					
                               ,
                               0 ---@PrplOvduAftrMth				
                               ,
                               0 ---@PrplOvduAftrDay				
                               ,
                               0 ---@InttOvduAftrDay				
                               ,
                               0 --@InttOvduAftrMth				
                               ,
                               NULL ---@PrinOvduEndMth				
                               ,
                               NULL --@InttOvduEndMth				
                               ,
                               v_ScrCrErrorSeq,

                               ---------D2k System Common Colum
                               v_Remark,
                               v_MenuID,
                               v_OperationFlag,
                               v_AuthMode,
                               v_IsMOC,
                               v_EffectiveFromTimeKey,
                               v_EffectiveToTimeKey,
                               v_TimeKey,
                               v_CrModApBy,
                               v_D2Ktimestamp,
                               v_Result,
                               v_BranchCode,
                               v_ScreenEntityId) ;

         END;
         END IF;
         --,@FacDL_ChangeFields		
         IF v_AdvFacPCDetailInUp = 'Y'
           AND v_FacilitySubType = 'PC' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Swap1');
            AdvFacPCDetailInUp(v_AccountEntityId,
                               NULL ---@PCRefNo						
                               ,
                               NULL ---@PCAdvDt						
                               ,
                               0 ---@PCAmt							
                               ,
                               NULL ---@PCDueDt						
                               ,
                               0 --@PCDurationDays				
                               ,
                               NULL --@PCExtendedDueDt				
                               ,
                               NULL ---@ExtensionReason				
                               ,
                               0 --@CurrencyAlt_Key				
                               ,
                               NULL --@LcNo							
                               ,
                               0 --@LcAmt							
                               ,
                               NULL ---@LcIssueDt						
                               ,
                               NULL ---@LcIssuingBank_FirmOrder		
                               ,
                               0.0 --@Balance						
                               ,
                               0 ---@BalanceInCurrency				
                               ,
                               0 ---@BalanceInUSD					
                               ,
                               0 ---@Overdue						
                               ,
                               0 --@CommodityAlt_Key				
                               ,
                               0 --@CommodityValue				
                               ,
                               0 ---@CommodityMarketValue			
                               ,
                               NULL ---@ShipmentDt					
                               ,
                               NULL --@CommercialisationDt			
                               ,
                               NULL ----@EcgcPolicyNo					
                               ,
                               0 ---@CAD							
                               ,
                               0 ---@CADU							
                               ,
                               NULL ----@OverDueSinceDt				
                               ,
                               v_TotalProv,
                               0 --@Secured						
                               ,
                               0 --@Unsecured						
                               ,
                               0 --@Provsecured					
                               ,
                               0 --@ProvUnsecured					
                               ,
                               0 --@ProvDicgc						
                               ,
                               NULL --@npadt							
                               ,
                               0 --@CoverGovGur					
                               ,
                               0 --@DerecognisedInterest1			
                               ,
                               0 --@DerecognisedInterest2			
                               ,
                               NULL ---@ClaimType						
                               ,
                               v_ClaimCoverAmt,
                               NULL ---@ClaimLodgedDt					
                               ,
                               v_ClaimLodgedAmt,
                               NULL ---@ClaimRecvDt					
                               ,
                               v_ClaimReceivedAmt,
                               0 ---@ClaimRate						
                               ,
                               NULL ---@AdjDt							
                               ,
                               NULL ---@EntityClosureDate				
                               ,
                               0 ---@EntityClosureReasonAlt_Key	
                               ,
                               NULL ----@RefSystemAcid					
                               ,
                               0.0 ----@UnAppliedIntt					
                               ,
                               NULL --@RBI_ExtnPermRefNo				
                               ,
                               0 --@LC_OrderAlt_Key				
                               ,
                               0 ---@OrderLC_CurrencyAlt_Key		
                               ,
                               0 ---@CountryAlt_Key				
                               ,
                               0 ---@LcAmtInCurrenc				
                               ,

                               ---------D2k System Common Colum
                               v_Remark,
                               v_MenuID,
                               v_OperationFlag,
                               v_AuthMode,
                               v_IsMOC,
                               v_EffectiveFromTimeKey,
                               v_EffectiveToTimeKey,
                               v_TimeKey,
                               v_CrModApBy,
                               v_D2Ktimestamp,
                               v_Result,
                               v_BranchCode,
                               v_ScreenEntityId) ;

         END;
         END IF;
         --,@FacPC_ChangeFields				
         IF v_AdvFacNFDetailInUp = 'Y'
           AND v_FacilityType IN ( 'LC','BG' )
          THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(11);
            DBMS_OUTPUT.PUT_LINE('Swap');
            RBL_MISDB_PROD.AdvFacNFDetailInUp(v_AccountEntityId,
                                              0 --@D2KFacilityID					
                                              ,
                                              v_GLAlt_key,
                                              NULL --@Operative_Acid				
                                              ,
                                              NULL --@LCBG_TYPE						
                                              ,
                                              NULL --@LCBGNo						
                                              ,
                                              0 --@LcBgAmt						
                                              ,
                                              NULL --@OriginDt						
                                              ,
                                              NULL ---@EffectiveDt					
                                              ,
                                              NULL --@ExpiryDt						
                                              ,
                                              NULL --@ExtensionDt					
                                              ,
                                              0 ---@TypeAlt_Key					
                                              ,
                                              0 ---@NatureAlt_Key					
                                              ,
                                              NULL --@BeneficiaryType				
                                              ,
                                              NULL --@BeneficiaryName				
                                              ,
                                              0.0 ---@Balance						
                                              ,
                                              0 --@BalanceInCurrency				
                                              ,
                                              0 --@CurrencyAlt_Key				
                                              ,
                                              0 ---@CountryAlt_Key				
                                              ,
                                              NULL --@NegotiatingBank				
                                              ,
                                              0 --@MargINType					
                                              ,
                                              0 ---@MarginAmt						
                                              ,
                                              0 ---@PurposeAlt_Key				
                                              ,
                                              NULL ---@ShipmentDt					
                                              ,
                                              NULL --@CoveredByBank					
                                              ,
                                              0 --@CoveredByBankAlt_Key			
                                              ,
                                              NULL --@InvocationDt					
                                              ,
                                              0 --@Commission					
                                              ,
                                              0 --@BillReceived					
                                              ,
                                              0 ---@BillsUnderCollAmt				
                                              ,
                                              NULL ---@FundedConversionDt			
                                              ,
                                              NULL ---@Datepaid						
                                              ,
                                              NULL ----@RecoveryDt					
                                              ,
                                              NULL ---@CounterGuar					
                                              ,
                                              NULL --@CorresBankCode				
                                              ,
                                              NULL --@CorresBrCode					
                                              ,
                                              NULL --@ClaimDt						
                                              ,
                                              0 ---@NFFacilityNo					
                                              ,
                                              NULL ---@Periodicity					
                                              ,
                                              0 ---@CommissionDue					
                                              ,
                                              NULL ---@DueDateOfRecovery				
                                              ,
                                              NULL --@CommOnDuedateYN				
                                              ,
                                              NULL --@DelayReason					
                                              ,
                                              NULL --@PresentPosition				
                                              ,
                                              0 ---@AmmountRecovered				
                                              ,
                                              v_ScrCrError,
                                              NULL ---@AdjDt							
                                              ,
                                              0 ---@AdjReasonAlt_Key				
                                              ,
                                              NULL ---@EntityClosureDate				
                                              ,
                                              0 ---@EntityClosureReasonAlt_Key	
                                              ,
                                              v_RefCustomerId,
                                              NULL ----@RefSystemAcId					
                                              ,
                                              NULL ---@GovtGurantee					
                                              ,
                                              0 ---@GovGurAmt						
                                              ,
                                              v_ScrCrErrorSeq,

                                              -----------D2k System Common Col	
                                              v_Remark,
                                              v_MenuID,
                                              v_OperationFlag,
                                              v_AuthMode,
                                              v_IsMOC,
                                              v_EffectiveFromTimeKey,
                                              v_EffectiveToTimeKey,
                                              v_TimeKey,
                                              v_CrModApBy,
                                              v_D2Ktimestamp,
                                              v_Result,
                                              v_BranchCode,
                                              v_ScreenEntityId) ;

         END;
         END IF;
         --,@FacNF_ChangeFields
         IF v_OperationFlag IN ( 1,2,3,16,17,18 )

           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_CreatedCheckedDt VARCHAR2(200) := SYSDATE;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            IF v_OperationFlag IN ( 16,17,18 )
             THEN
             DECLARE
               v_ApprovedBy VARCHAR2(100) := v_CrModApBy;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SP1');
               DBMS_OUTPUT.PUT_LINE(v_Remark);
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => v_BranchCode ----BranchCode
                ,
                v_MenuID => 6675,
                v_ReferenceID => v_RefCustomerId -- ReferenceID ,
                ,
                v_CreatedBy => NULL,
                v_ApprovedBy => v_CrModApBy,
                iv_CreatedCheckedDt => v_CreatedCheckedDt,
                v_Remark => v_Remark,
                v_ScreenEntityAlt_Key => 
                --@ScreenEntityId=16  ,---ScreenEntityId -- for FXT060 screen
                123,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            ELSE
            DECLARE
               v_CreatedBy VARCHAR2(100) := v_CrModApBy;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SP');
               DBMS_OUTPUT.PUT_LINE(v_Remark);
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => v_BranchCode ----BranchCode
                ,
                v_MenuID => 6675,
                v_ReferenceID => v_RefCustomerId -- ReferenceID ,
                ,
                v_CreatedBy => v_CreatedBy,
                v_ApprovedBy => NULL,
                iv_CreatedCheckedDt => v_CreatedCheckedDt,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 123 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            END IF;

         END;
         END IF;
         IF v_OperationFlag = 1 THEN
          v_AuthorisationStatus := 'NP' ;
         END IF;
         IF v_OperationFlag = 2 THEN
          v_AuthorisationStatus := 'MP' ;
         END IF;
         IF v_OperationFlag = 3 THEN
          v_AuthorisationStatus := 'DP' ;
         END IF;
         IF v_OperationFlag = 16 THEN
          v_AuthorisationStatus := 'A' ;
         END IF;
         DBMS_OUTPUT.PUT_LINE('saurabh1');
         utils.commit_transaction;
         --EXEC [SysDataUpdation_InUp]
         --			@BranchCode				=	@BranchCode		
         --			,@ID					=	@CustomerEntityId
         --			,@Name					=	''
         --			,@Type					=	''
         --			,@CaseNo				=	''
         --			,@CaseType				=	0
         --			,@CustomerACID			=	''	
         --			,@RecordType			=	'PreCase'	
         --			,@AuthorisationStatus	=	@AuthorisationStatus
         --			,@CrModBy				=	@CrModApBy
         --			,@MenuID				=	@MenuId
         --			,@ParentEntityID		=	@CustomerEntityId
         --			,@EntityID				=	@CustomerEntityId
         --			,@Remark				=	@Remark
         --			,@CustomerId			=	@RefCustomerId
         --			--,@IsStatusInsert		=	@IsStatusInsert
         --			 print 'saurabh2'
         v_D2Ktimestamp := 1 ;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      ROLLBACK;
      utils.resetTrancount;
      v_Result := -1 ;
      RETURN v_Result;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYMAININSERT_04122023" TO "ADF_CDR_RBL_STGDB";
