--------------------------------------------------------
--  DDL for Function CUSTOMERLEVELINUP_PROD_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  iv_NPADate IN VARCHAR2 DEFAULT NULL ,
  iv_SecurityValue IN VARCHAR2 DEFAULT ' ' ,
  v_AdditionalProvision IN NUMBER DEFAULT ' ' ,
  --,@FraudAccountFlagAlt_Key	Int=0--,@FraudDate					Date
  v_MocTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_MOCReason IN VARCHAR2 DEFAULT ' ' ,
  v_MOCSourceAltkey IN NUMBER DEFAULT 0 ,
  v_ScreenFlag IN VARCHAR2 DEFAULT ' ' ,
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
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_CustomerNPAMOC_ChangeFields IN VARCHAR2 DEFAULT ' ' 
)
RETURN NUMBER
AS
   v_NPADate VARCHAR2(20) := iv_NPADate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_SecurityValue VARCHAR2(50) := iv_SecurityValue;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_CustomerEntityID NUMBER(10,0);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_NPADate := CASE 
                     WHEN ( v_NPADate = ' '
                       OR v_NPADate = '01/01/1900' ) THEN NULL
   ELSE v_NPADate
      END ;
   v_ScreenName := 'CustomerLevel' ;
   -------------------------------------------------------------
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
   SELECT CustomerEntityID 

     INTO v_CustomerEntityID
     FROM CustomerBasicDetail 
    WHERE  CustomerId = v_CustomerId;
   v_SecurityValue := CASE 
                           WHEN v_SecurityValue = ' ' THEN NULL
   ELSE v_SecurityValue
      END ;
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
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifiedBy = v_Modifiedby,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND CustomerID = v_CustomerID
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
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_ApprovedBy,
                      DateApproved = v_DateApproved,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND CustomerID = v_CustomerID
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
                  UPDATE CustomerLevelMOC_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerID = v_CustomerID
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
                     UPDATE CustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'RM'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                       AND CustomerID = v_CustomerID;

                  END;
                  ELSE
                     IF v_OperationFlag = 16 THEN

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE CustomerLevelMOC_Mod
                           SET AuthorisationStatus = '1A',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved
                         WHERE  CustomerID = v_CustomerID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;

                     END;
                     ELSE
                        IF v_OperationFlag = 20
                          OR v_AuthMode = 'N' THEN

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
                              SELECT MAX(Entity_Key)  

                                INTO v_ExEntityKey
                                FROM CustomerLevelMOC_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND CustomerID = v_CustomerID
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT AuthorisationStatus ,
                                     CreatedBy ,
                                     DATECreated ,
                                     ModifiedBy ,
                                     DateModified 

                                INTO v_DelStatus,
                                     v_CreatedBy,
                                     v_DateCreated,
                                     v_ModifiedBy,
                                     v_DateModified
                                FROM CustomerLevelMOC_Mod 
                               WHERE  Entity_Key = v_ExEntityKey;
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              SELECT MIN(Entity_Key)  

                                INTO v_ExEntityKey
                                FROM CustomerLevelMOC_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND CustomerID = v_CustomerID
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT EffectiveFromTimeKey 

                                INTO v_CurrRecordFromTimeKey
                                FROM CustomerLevelMOC_Mod 
                               WHERE  Entity_Key = v_ExEntityKey;
                              UPDATE CustomerLevelMOC_Mod
                                 SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND CustomerID = v_CustomerID
                                AND AuthorisationStatus = 'A';
                              UPDATE CustomerLevelMOC_Mod
                                 SET AuthorisationStatus = 'A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND CustomerID = v_CustomerID
                                AND AuthorisationStatus = '1A';

                           END;
                           END IF;
                           -------DELETE RECORD AUTHORISE
                           DBMS_OUTPUT.PUT_LINE(222222222222);
                           IF NVL(v_DelStatus, ' ') <> 'DP'
                             OR v_AuthMode = 'N' THEN
                            DECLARE
                              v_MocTypeDesc VARCHAR2(20);
                              ---pre moc
                              v_Parameter VARCHAR2(50);
                              v_FinalParameter VARCHAR2(50);

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE(333333333333333333333333);
                              IF  --SQLDEV: NOT RECOGNIZED
                              IF tt_CUSTOMER_CAL_6  --SQLDEV: NOT RECOGNIZED
                              DELETE FROM tt_CUSTOMER_CAL_6;
                              UTILS.IDENTITY_RESET('tt_CUSTOMER_CAL_6');

                              INSERT INTO tt_CUSTOMER_CAL_6 ( 
                              	SELECT * 
                              	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
                              	 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND RefCustomerID = v_CustomerID );
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
                              FROM A ,PRO_RBL_MISDB_PROD.CustomerCal_Hist A 
                               WHERE ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND EffectiveFromTimeKey < v_TImeKey) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                              --select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
                              -- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
                              SELECT ParameterName 

                                INTO v_MocTypeDesc
                                FROM DimParameter 
                               WHERE  Dimparametername = 'MocType'
                                        AND ParameterAlt_Key = v_MocTypeAlt_Key
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey;
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, CASE 
                              WHEN v_AssetClassAlt_Key IS NULL THEN SysAssetClassAlt_Key
                              ELSE v_AssetClassAlt_Key
                                 END AS pos_2, CASE 
                              WHEN v_NPADate IS NULL THEN SysNPA_Dt
                              ELSE v_NPADate
                                 END AS pos_3, CASE 
                              WHEN v_SecurityValue IS NULL THEN CurntQtrRv
                              ELSE v_SecurityValue
                                 END AS pos_4, CASE 
                              WHEN v_AdditionalProvision IS NULL THEN AddlProvisionPer
                              ELSE v_AdditionalProvision
                                 END AS pos_5, 'Y', v_MOCReason, v_MocTypeDesc, SYSDATE
                              FROM A ,PRO_RBL_MISDB_PROD.CustomerCal_Hist a 
                               WHERE EffectiveFromTimeKey = v_TimeKey
                                AND EffectiveToTimeKey = v_TimeKey
                                AND RefCustomerID = v_CustomerID) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = pos_2,
                                                           a.SysNPA_Dt = pos_3,
                                                           a.CurntQtrRv = pos_4,
                                                           a.AddlProvisionPer = pos_5,
                                                           A.FlgMoc = 'Y',
                                                           a.MOCReason = v_MOCReason,
                                                           a.MOCTYPE = v_MocTypeDesc,
                                                           a.MOC_Dt = SYSDATE;
                              INSERT INTO PRO_RBL_MISDB_PROD.CustomerCal_Hist
                                ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE )
                                ( SELECT BranchCode ,
                                         UCIF_ID ,
                                         UcifEntityID ,
                                         CustomerEntityID ,
                                         ParentCustomerID ,
                                         RefCustomerID ,
                                         SourceSystemCustomerID ,
                                         CustomerName ,
                                         CustSegmentCode ,
                                         ConstitutionAlt_Key ,
                                         PANNO ,
                                         AadharCardNO ,
                                         SrcAssetClassAlt_Key ,
                                         CASE 
                                              WHEN v_AssetClassAlt_Key IS NULL THEN SysAssetClassAlt_Key
                                         ELSE v_AssetClassAlt_Key
                                            END col  ,
                                         --,@AssetClassAlt_Key SysAssetClassAlt_Key
                                         SplCatg1Alt_Key ,
                                         SplCatg2Alt_Key ,
                                         SplCatg3Alt_Key ,
                                         SplCatg4Alt_Key ,
                                         SMA_Class_Key ,
                                         PNPA_Class_Key ,
                                         PrvQtrRV ,
                                         CASE 
                                              WHEN v_SecurityValue IS NULL THEN CurntQtrRv
                                         ELSE v_SecurityValue
                                            END col  ,
                                         --,@SecurityValue CurntQtrRv
                                         TotProvision ,
                                         BankTotProvision ,
                                         RBITotProvision ,
                                         SrcNPA_Dt ,
                                         CASE 
                                              WHEN v_NPADate IS NULL THEN SysNPA_Dt
                                         ELSE v_NPADate
                                            END col  ,
                                         --,@NPADate SysNPA_Dt
                                         DbtDt ,
                                         DbtDt2 ,
                                         DbtDt3 ,
                                         LossDt ,
                                         SYSDATE MOC_Dt  ,
                                         ErosionDt ,
                                         SMA_Dt ,
                                         PNPA_Dt ,
                                         Asset_Norm ,
                                         FlgDeg ,
                                         FlgUpg ,
                                         'Y' FlgMoc  ,
                                         FlgSMA ,
                                         FlgProcessing ,
                                         FlgErosion ,
                                         FlgPNPA ,
                                         FlgPercolation ,
                                         FlgInMonth ,
                                         FlgDirtyRow ,
                                         DegDate ,
                                         v_TimeKey ,
                                         v_TimeKey ,
                                         CommonMocTypeAlt_Key ,
                                         InMonthMark ,
                                         MocStatusMark ,
                                         SourceAlt_Key ,
                                         BankAssetClass ,
                                         Cust_Expo ,
                                         v_MOCReason MOCReason  ,
                                         CASE 
                                              WHEN v_AdditionalProvision IS NULL THEN AddlProvisionPer
                                         ELSE v_AdditionalProvision
                                            END col  ,
                                         --	,@AdditionalProvision AddlProvisionPer
                                         FraudDt ,
                                         FraudAmount ,
                                         DegReason ,
                                         CustMoveDescription ,
                                         TotOsCust ,
                                         v_MocTypeDesc MOCTYPE  
                                  FROM tt_CUSTOMER_CAL_6 
                                   WHERE  ( EffectiveToTimeKey > v_TimeKey )
                                            OR ( EffectiveFromTimeKey < v_TimeKey
                                            AND EffectiveToTimeKey = v_TimeKey ) );
                              INSERT INTO PRO_RBL_MISDB_PROD.CustomerCal_Hist
                                ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE )
                                ( SELECT BranchCode ,
                                         UCIF_ID ,
                                         UcifEntityID ,
                                         CustomerEntityID ,
                                         ParentCustomerID ,
                                         RefCustomerID ,
                                         SourceSystemCustomerID ,
                                         CustomerName ,
                                         CustSegmentCode ,
                                         ConstitutionAlt_Key ,
                                         PANNO ,
                                         AadharCardNO ,
                                         SrcAssetClassAlt_Key ,
                                         SysAssetClassAlt_Key ,
                                         SplCatg1Alt_Key ,
                                         SplCatg2Alt_Key ,
                                         SplCatg3Alt_Key ,
                                         SplCatg4Alt_Key ,
                                         SMA_Class_Key ,
                                         PNPA_Class_Key ,
                                         PrvQtrRV ,
                                         CurntQtrRv ,
                                         TotProvision ,
                                         BankTotProvision ,
                                         RBITotProvision ,
                                         SrcNPA_Dt ,
                                         SysNPA_Dt ,
                                         DbtDt ,
                                         DbtDt2 ,
                                         DbtDt3 ,
                                         LossDt ,
                                         MOC_Dt ,
                                         ErosionDt ,
                                         SMA_Dt ,
                                         PNPA_Dt ,
                                         Asset_Norm ,
                                         FlgDeg ,
                                         FlgUpg ,
                                         FlgMoc ,
                                         FlgSMA ,
                                         FlgProcessing ,
                                         FlgErosion ,
                                         FlgPNPA ,
                                         FlgPercolation ,
                                         FlgInMonth ,
                                         FlgDirtyRow ,
                                         DegDate ,
                                         v_TimeKey + 1 ,
                                         EffectiveToTimeKey ,
                                         CommonMocTypeAlt_Key ,
                                         InMonthMark ,
                                         MocStatusMark ,
                                         SourceAlt_Key ,
                                         BankAssetClass ,
                                         Cust_Expo ,
                                         MOCReason ,
                                         AddlProvisionPer ,
                                         FraudDt ,
                                         FraudAmount ,
                                         DegReason ,
                                         CustMoveDescription ,
                                         TotOsCust ,
                                         MOCTYPE 
                                  FROM tt_CUSTOMER_CAL_6 
                                   WHERE  EffectiveToTimeKey > v_TimeKey );
                              SELECT utils.stuff(( SELECT ',' || ChangeField 
                                                   FROM CustomerLevelMOC_Mod 
                                                    WHERE  CustomerID = v_CustomerID
                                                             AND NVL(AuthorisationStatus, 'A') = 'A' ), 1, 1, ' ') 

                                INTO v_Parameter
                                FROM DUAL ;
                              IF utils.object_id('tt_A_16') IS NOT NULL THEN
                               EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_16 ';
                              END IF;
                              DELETE FROM tt_A_16;
                              UTILS.IDENTITY_RESET('tt_A_16');

                              INSERT INTO tt_A_16 ( 
                              	SELECT DISTINCT VALUE 
                              	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                                               VALUE 
                                        FROM ( SELECT VALUE 
                                               FROM TABLE(STRING_SPLIT(v_Parameter, ','))  ) A ) X );
                              SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                                   FROM tt_A_16  ), 1, 1, ' ') 

                                INTO v_FinalParameter
                                FROM DUAL ;
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, v_FinalParameter
                              FROM A ,PRO_RBL_MISDB_PROD.CustomerCal_Hist A 
                               WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
                                AND EffectiveToTimeKey >= v_tiMEKEY )
                                AND RefCustomerID = v_CustomerID) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET a.ChangeFld = v_FinalParameter;
                              INSERT INTO PreMoc_RBL_MISDB_PROD.CUSTOMERCAL
                                ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE )
                                ( SELECT A.BranchCode ,
                                         A.UCIF_ID ,
                                         A.UcifEntityID ,
                                         A.CustomerEntityID ,
                                         A.ParentCustomerID ,
                                         A.RefCustomerID ,
                                         A.SourceSystemCustomerID ,
                                         A.CustomerName ,
                                         A.CustSegmentCode ,
                                         A.ConstitutionAlt_Key ,
                                         A.PANNO ,
                                         A.AadharCardNO ,
                                         A.SrcAssetClassAlt_Key ,
                                         A.SysAssetClassAlt_Key ,
                                         A.SplCatg1Alt_Key ,
                                         A.SplCatg2Alt_Key ,
                                         A.SplCatg3Alt_Key ,
                                         A.SplCatg4Alt_Key ,
                                         A.SMA_Class_Key ,
                                         A.PNPA_Class_Key ,
                                         A.PrvQtrRV ,
                                         A.CurntQtrRv ,
                                         A.TotProvision ,
                                         A.BankTotProvision ,
                                         A.RBITotProvision ,
                                         A.SrcNPA_Dt ,
                                         A.SysNPA_Dt ,
                                         A.DbtDt ,
                                         A.DbtDt2 ,
                                         A.DbtDt3 ,
                                         A.LossDt ,
                                         A.MOC_Dt ,
                                         A.ErosionDt ,
                                         A.SMA_Dt ,
                                         A.PNPA_Dt ,
                                         A.Asset_Norm ,
                                         A.FlgDeg ,
                                         A.FlgUpg ,
                                         'Y' FlgMoc  ,
                                         A.FlgSMA ,
                                         A.FlgProcessing ,
                                         A.FlgErosion ,
                                         A.FlgPNPA ,
                                         A.FlgPercolation ,
                                         A.FlgInMonth ,
                                         A.FlgDirtyRow ,
                                         A.DegDate ,
                                         v_TimeKey ,
                                         v_TimeKey ,
                                         A.CommonMocTypeAlt_Key ,
                                         A.InMonthMark ,
                                         A.MocStatusMark ,
                                         A.SourceAlt_Key ,
                                         A.BankAssetClass ,
                                         A.Cust_Expo ,
                                         A.MOCReason ,
                                         A.AddlProvisionPer ,
                                         A.FraudDt ,
                                         A.FraudAmount ,
                                         A.DegReason ,
                                         A.CustMoveDescription ,
                                         A.TotOsCust ,
                                         A.MOCTYPE 
                                  FROM tt_CUSTOMER_CAL_6 A
                                         LEFT JOIN PreMoc_RBL_MISDB_PROD.CUSTOMERCAL B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                                         AND B.EffectiveFromTimeKey = v_TimeKey
                                         AND B.EffectiveToTimeKey = v_TimeKey )
                                         AND A.RefCustomerID = B.RefCustomerID
                                   WHERE  b.RefCustomerID IS NULL );

                           END;
                           END IF;
                           ---------------------------------------------
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
            INSERT INTO CustomerLevelMOC_Mod
              ( CustomerID, CustomerEntityID, CustomerName, AssetClassAlt_Key, NPADate, SecurityValue, AdditionalProvision
            --,FraudAccountFlagAlt_Key	
             --,FraudDate			
            , MocTypeAlt_Key, MOCReason, MOCSourceAltkey, MOCDate, MOCBy, ScreenFlag, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, ChangeField )
              VALUES ( v_CustomerID, v_CustomerEntityID, v_CustomerName, v_AssetClassAlt_Key, v_NPADate, v_SecurityValue, v_AdditionalProvision, 
            --,@FraudAccountFlagAlt_Key	

            --,@FraudDate			
            v_MocTypeAlt_Key, v_MOCReason, v_MOCSourceAltkey, SYSDATE, v_CreatedBy, v_ScreenFlag, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ApprovedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy'), v_CustomerNPAMOC_ChangeFields );
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
         OPEN  v_cursor FOR
            SELECT v_Result 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
