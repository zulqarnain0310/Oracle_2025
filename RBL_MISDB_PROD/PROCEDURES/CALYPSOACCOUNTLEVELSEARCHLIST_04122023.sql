--------------------------------------------------------
--  DDL for Procedure CALYPSOACCOUNTLEVELSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" 
--Select * from AccountLevelMOC_Mod
 --Where AccountID='133'
 -- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=2
 --[AccountLevelSearchList]
 -- exec AccountLevelSearchList @AccountID=N'00283GLN500166',@OperationFlag=2
 --Main Screen Select 
 --exec AccountLevelSearchList @AccountID=N'809002647561',@OperationFlag=2
 --go
 -- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=16

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_AccountID IN VARCHAR2 DEFAULT ' ' ,
  iv_TimeKey IN NUMBER DEFAULT 25992 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --SET @Timekey=25992
   v_CreatedBy VARCHAR2(50);
   v_DateCreated VARCHAR2(200);
   v_ModifiedBy VARCHAR2(50);
   v_DateModified VARCHAR2(200);
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved VARCHAR2(200);
   v_AuthorisationStatus VARCHAR2(5);
   v_MOCReason VARCHAR2(500);
   v_MocSource VARCHAR2(50);
   v_ApprovedByFirstLevel VARCHAR2(100);
   v_DateApprovedFirstLevel VARCHAR2(200);
   v_MOC_ExpireDate VARCHAR2(200);
   v_MOC_TYPEFLAG VARCHAR2(4);
   v_AccountEntityID NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--25999 

BEGIN

   --Declare @Timekey INT
   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   DBMS_OUTPUT.PUT_LINE('@Timekey');
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   SELECT InvEntityId 

     INTO v_AccountEntityID
     FROM InvestmentBasicDetail 
    WHERE  InvID = v_AccountID
             AND EffectiveFromTimeKey <= v_Timekey
             AND EffectiveToTimeKey >= v_Timekey
   UNION 
   SELECT DerivativeEntityid 
     FROM CurDat_RBL_MISDB_PROD.DerivativeDetail 
    WHERE  DerivativeRefNo = v_AccountID
             AND EffectiveFromTimeKey <= v_Timekey
             AND EffectiveToTimeKey >= v_Timekey;
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
             DateApprovedFirstLevel ,
             MOC_TYPEFLAG 

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
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CalypsoAccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey
                AND accountid = v_AccountID;

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
             DateApprovedFirstLevel ,
             MOC_TYPEFLAG 

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
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CalypsoAccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey
                AND accountid = v_AccountID;

   END;
   END IF;
   --AND SCREENFLAG <> ('U')
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
             DateApprovedFirstLevel ,
             MOC_TYPEFLAG 

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
             v_DateApprovedFirstLevel,
             v_MOC_TYPEFLAG
        FROM CalypsoAccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey

                --AND SCREENFLAG <> ('U')
                AND accountid = v_AccountID;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
   DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
   BEGIN
      DECLARE
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         v_DateOfData VARCHAR2(200);
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         SELECT ExtDate 

           INTO v_DateOfData
           FROM SysDataMatrix 
          WHERE  TimeKey = v_TimeKey;
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_PREMOC_11  --SQLDEV: NOT RECOGNIZED
         DBMS_OUTPUT.PUT_LINE('AKSHAY2');
         DELETE FROM tt_ACCOUNT_PREMOC_11;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_PREMOC_11');

         INSERT INTO tt_ACCOUNT_PREMOC_11 ( 
         	SELECT * 
         	  FROM ( SELECT A.InvEntityId ,
                          A.InvID AccountID  ,
                          A.RefIssuerID CustomerID  ,
                          ' ' FacilityType  ,
                          H.IssuerName CustomerName  ,
                          0 DFVAmt  ,
                          B.BookValue ,
                          Interest_DividendDueAmount InterestReceivable  ,
                          0 AdditionalProvisionAbsolute  ,
                          ' ' FLGFITL  ,
                          c.StatusType FraudAccountFlag  ,
                          c.StatusDate FraudDate  ,
                          E.StatusType TwoFlag  ,
                          E.StatusDate TwoDate  ,
                          v_MocReason MOCReason_1  ,
                          H.UcifId UCICID  ,
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
                          B.Interest_DividendDueAmount POS  ,
                          F.SourceName ,
                          0 MOCReason  
                   FROM InvestmentBasicDetail A
                          JOIN InvestmentFinancialDetail B   ON a.InvEntityid = b.InvEntityid
                          AND b.EffectiveFromTimeKey <= v_TimeKey
                          AND b.EffectiveToTimeKey >= v_TimeKey
                          JOIN InvestmentIssuerDetail H   ON A.RefIssuerID = H.IssuerID
                          AND H.EffectiveFromTimeKey <= v_TimeKey
                          AND H.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Fraud Committed'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) c   ON a.InvID = c.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Restructure'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) D   ON a.InvID = D.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'TWO'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) E   ON a.InvID = E.ACID
                          LEFT JOIN DIMSOURCEDB F   ON H.SourceAlt_KEy = F.SourceAlt_Key
                    WHERE  A.InvEntityid = v_AccountEntityID
                             AND A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND a.InvId = v_AccountID
                   UNION 
                   SELECT A.DerivativeEntityid ,
                          A.DerivativeRefNo AccountID  ,
                          A.CustomerId CustomerID  ,
                          ' ' FacilityType  ,
                          A.CustomerName ,
                          0 DFVAmt  ,
                          NVL((CASE 
                                    WHEN MTMIncomeAmt < 0 THEN 0
                              ELSE MTMIncomeAmt
                                 END), 0.00) MTMValue  ,
                          DueAmtReceivable InterestReceivable  ,
                          0 AdditionalProvisionAbsolute  ,
                          ' ' FLGFITL  ,
                          c.StatusType FraudAccountFlag  ,
                          c.StatusDate FraudDate  ,
                          E.StatusType TwoFlag  ,
                          E.StatusDate TwoDate  ,
                          v_MocReason MOCReason_1  ,
                          A.UCIC_ID UCICID  ,
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
                          --,TwoFlag,TwoDate
                          A.POS POS  ,
                          A.SourceSystem ,
                          0 MOCReason  
                   FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Fraud Committed'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) c   ON a.CustomerACID = c.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'Restructure'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) D   ON a.CustomerACID = D.ACID
                          LEFT JOIN ( SELECT CustomerID ,
                                             ACID ,
                                             StatusType ,
                                             StatusDate 
                                      FROM ExceptionFinalStatusType 
                                       WHERE  StatusType = 'TWO'
                                                AND EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey ) E   ON a.CustomerACID = E.ACID
                    WHERE  A.DerivativeEntityID = v_AccountEntityID
                             AND A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND A.DerivativeRefNo = v_AccountID ) X );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.ParameterAlt_Key, 0) AS MOCReason
         FROM A ,tt_ACCOUNT_PREMOC_11 A
                LEFT JOIN ( SELECT DimParameter.ParameterAlt_Key ,
                                   DimParameter.ParameterName ,
                                   'MOCReason' TableName  
                            FROM DimParameter 
                             WHERE  DimParameter.EffectiveFromTimeKey <= v_Timekey
                                      AND DimParameter.EffectiveToTimeKey >= v_Timekey
                                      AND DimParameter.DimParameterName = 'DimMOCReason' ) B   ON A.MOCReason_1 = B.ParameterName ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.MOCReason = src.MOCReason;
         ----POST 
         --Select 'tt_ACCOUNT_PREMOC_11',* from tt_ACCOUNT_PREMOC_11
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNT_POSTMOC_11  --SQLDEV: NOT RECOGNIZED
         DBMS_OUTPUT.PUT_LINE('SWAPNA');
         DELETE FROM tt_ACCOUNT_POSTMOC_11;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_POSTMOC_11');

         INSERT INTO tt_ACCOUNT_POSTMOC_11 ( 
         	SELECT AccountEntityID ,
                 AccountID AccountID  ,
                 POS POS  ,
                 InterestReceivable InterestReceivable  ,
                 --RestructureFlag,RestructureDate,
                 FITLFlag FLGFITL  ,
                 DFVAmount ,
                 AdditionalProvisionAbsolute ,
                 FraudAccountFlag FraudAccountFlag  ,
                 FraudDate ,
                 --RestructureFlag,RestructureDate,
                 FlgTwo TwoFlag  ,
                 TwoDate TwoDate  ,
                 MocReason MOCReason  ,
                 TwoAmount ,
                 BookValue ,
                 UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate  ,
                 SMASubAssetClassValue ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
                 'a' AuthorisationStatus  ,
                 'a' CreatedBy  ,
                 BookValue BookValue_POS  ,
                 UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate_POS  ,
                 SMASubAssetClassValue SMASubAssetClassValue_POS  ,
                 'a' DateCreated  ,
                 'a' ModifiedBy  ,
                 'a' DateModified  ,
                 'a' ApprovedBy  ,
                 'a' DateApproved  ,
                 'a' MOCSource  ,
                 'a' ApprovedByFirstLevel  ,
                 'a' DateApprovedFirstLevel  ,
                 --,TwoFlag,TwoDate
                 'ACCT' MOC_TYPEFLAG  
         	  FROM CalypsoAccountLevelMOC_Mod 

         	--where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
         	WHERE  AuthorisationStatus IN ( '1A','MP','NP' )

                   AND EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND AccountEntityID = v_AccountEntityID

                   --AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)
                   AND AccountID = v_accountid );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_ACCOUNT_POSTMOC_11 
                                 WHERE  AccountEntityID = v_AccountEntityID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_ACCOUNT_POSTMOC_11
              ( SELECT B.InvEntityId ,
                       b.RefInvID AccountID  ,
                       PrincOutStd POS  ,
                       unserviedint InterestReceivable  ,
                       FlgFITL FLGFITL  ,
                       A.DFVAmt ,
                       AddlProvAbs ,
                       FlgFraud FraudAccountFlag  ,
                       FraudDate ,
                       TwoFlag ,
                       TwoDate ,
                       a.BookValue ,
                       UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate  ,
                       SMASubAssetClassValue ,
                       A.MOC_Reason MOCReason  ,
                       TwoAmount ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_CreatedBy CreatedBy  ,
                       A.BookValue BookValue_POS  ,
                       UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate_POS  ,
                       SMASubAssetClassValue SMASubAssetClassValue_POS  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  ,
                       v_MocSource MOCSource  ,
                       v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                       v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                       'ACCT' MOC_TYPEFLAG  
                FROM CalypsoInvMOC_ChangeDetails A
                       JOIN InvestmentFinancialDetail B   ON A.AccountEntityID = B.InvEntityId
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND A.AccountEntityID = v_AccountEntityID
                          AND b.RefInvID = v_AccountID
                UNION 
                SELECT B.DerivativeEntityID ,
                       b.DerivativeRefNo AccountID  ,
                       POS POS  ,
                       unserviedint InterestReceivable  ,
                       FlgFITL FLGFITL  ,
                       A.DFVAmt ,
                       AddlProvAbs ,
                       FlgFraud FraudAccountFlag  ,
                       FraudDate ,
                       TwoFlag ,
                       TwoDate ,
                       BookValue ,
                       UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate  ,
                       SMASubAssetClassValue ,
                       A.MOC_Reason MOCReason  ,
                       TwoAmount ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_CreatedBy CreatedBy  ,
                       BookValue BookValue_POS  ,
                       UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate_POS  ,
                       SMASubAssetClassValue SMASubAssetClassValue_POS  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  ,
                       v_MocSource MOCSource  ,
                       v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                       v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                       'ACCT' MOC_TYPEFLAG  
                FROM CalypsoDervMOC_ChangeDetails A
                       JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountEntityID = B.DerivativeEntityID
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND A.AccountEntityID = v_AccountEntityID
                          AND b.DerivativeRefNo = v_accountid );

         END;
         END IF;

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.AccountID ,
                      A.FacilityType ,
                      A.CustomerID ,
                      A.CustomerName ,
                      A.UCICID ,
                      A.InterestReceivable ,
                      (CASE 
                            WHEN A.FLGFITL IS NULL THEN 'No'
                            WHEN A.FLGFITL = 'Y' THEN 'Yes'
                            WHEN A.FLGFITL = 'N' THEN 'No'   END) FITLFlag  ,
                      A.DFVAmt DFVAmount  ,
                      (CASE 
                            WHEN A.FraudAccountFlag IS NULL THEN 'No'
                            WHEN A.FraudAccountFlag = 'Y' THEN 'Yes'
                            WHEN A.FraudAccountFlag = 'N' THEN 'No'   END) FraudAccountFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,10,p_style=>103) FraudDate  ,
                      (CASE 
                            WHEN A.TwoFlag IS NULL THEN 'No'
                            WHEN A.TwoFlag = 'Y' THEN 'Yes'
                            WHEN A.TwoFlag = 'N' THEN 'No'   END) TwoFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.TwoDate,10,p_style=>103) RePossessionDate  ,
                      A.BookValue ,
                      A.MOCReason ,
                      A.MOCReason_1 ,
                      A.MOCSource ,
                      A.AdditionalProvisionAbsolute ,
                      A.SourceName ,
                      B.FLGFITL FITLFlag_POS  ,
                      --,NULL				as FITLFlag_POS1
                      B.DFVAmount DFVAmount_POS  ,
                      B.FraudAccountFlag FraudAccountFlag_POS  ,
                      --,NULL                           as FraudAccountFlag_POS1
                      UTILS.CONVERT_TO_VARCHAR2(B.FraudDate,10,p_style=>103) FraudDate_POS  ,
                      B.POS POS_POS ,----new add 

                      B.InterestReceivable InterestReceivable_POS ,--new add

                      B.TwoFlag TwoFlag_POS  ,
                      UTILS.CONVERT_TO_VARCHAR2(B.TwoDate,10,p_style=>103) TwoDate_POS  ,
                      B.TwoAmount TwoAmount_POS  ,
                      b.BookValue_POS ,
                      UTILS.CONVERT_TO_VARCHAR2(b.SMADate,20,p_style=>103) SMADate  ,
                      b.SMASubAssetClassValue ,
                      -- ,B.RestructureFlag 	as RestructureFlag_POS
                      -- , Convert(Varchar(10),B.RestructureDate,103) 		as RestructureDate_POS
                      B.AuthorisationStatus ,
                      B.AdditionalProvisionAbsolute AddlProvisionPer_POS  ,
                      v_Timekey EffectiveFromTimeKey  ,
                      49999 EffectiveToTimeKey  ,
                      A.CreatedBy ,
                      B.BookValue BookValue_POS  ,
                      UTILS.CONVERT_TO_VARCHAR2(SMADate,20,p_style=>103) SMADate_POS  ,
                      SMASubAssetClassValue SMASubAssetClassValue_POS  ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                      B.AuthorisationStatus ,
                      B.ApprovedByFirstLevel ,
                      --,Convert(Varchar(10),MOC_ExpireDate,103)MOC_ExpireDate
                      'ACCT' MOC_TYPEFLAG  ,
                      B.FraudDate FraudDate_A30  ,
                      'Account' TableName  
                 FROM tt_ACCOUNT_PREMOC_11 A
                        LEFT JOIN tt_ACCOUNT_POSTMOC_11 B   ON A.AccountID = b.AccountID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         --END
         DBMS_OUTPUT.PUT_LINE('Nitin');
         IF utils.object_id('tempdb..tt_MOCAuthorisation_7') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOCAuthorisation_7 ';

         END;
         END IF;
         DELETE FROM tt_MOCAuthorisation_7;
         UTILS.IDENTITY_RESET('tt_MOCAuthorisation_7');

         INSERT INTO tt_MOCAuthorisation_7 ( 
         	SELECT * ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
         	  FROM CalypsoAccountLevelMOC_Mod A
         	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND AccountID = v_AccountID
                    AND AccountID IS NOT NULL
                    AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                         FROM CalypsoAccountLevelMOC_Mod 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                           GROUP BY AccountID )
          );
         --Select ' tt_MOCAuthorisation_7',* from  tt_MOCAuthorisation_7
         --where abc=1
         UPDATE tt_MOCAuthorisation_7 V
            SET ErrorMessage = CASE 
                                    WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through Individual investment/derivative MOC – Authorization’ menu'
                ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Individual investment/derivative MOC – Authorization’ menu'
                   END,
                ErrorinColumn = CASE 
                                     WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID'
                ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID'
                   END
          WHERE  V.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND AccountID = v_AccountID
           AND v_operationflag NOT IN ( 16,17,20 )
         ;
         MERGE INTO tt_MOCAuthorisation_7 Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM CalypsoAccountLevelMOC_Mod V
                JOIN InvestmentBasicDetail X   ON V.AccountEntityID = X.InvEntityId
                JOIN tt_MOCAuthorisation_7 Z   ON X.INVID = Z.AccountID 
          WHERE X.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND v_operationflag NOT IN ( 16,17,20 )

           AND Z.AccountID = v_AccountID) src
         ON ( Z.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         MERGE INTO tt_MOCAuthorisation_7 Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM CalypsoAccountLevelMOC_Mod V
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail X   ON V.AccountEntityID = X.DerivativeEntityID
                JOIN tt_MOCAuthorisation_7 Z   ON X.DerivativeRefNo = Z.AccountID 
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
                            FROM tt_MOCAuthorisation_7 
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
                    FROM tt_MOCAuthorisation_7  ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
