--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" 
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
  v_OperationFlag IN NUMBER,
  v_AccountID IN VARCHAR2,
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
    v_SQLCODE VARCHAR2(1000);
   v_SQLERRM VARCHAR2(1000);
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
   SELECT AccountEntityId 

     INTO v_AccountEntityID
     FROM AdvAcBasicDetail 
    WHERE  CustomerACID = v_AccountID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
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
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;

   END;
   END IF;
   --AND  Entitykey in (select max(Entitykey) FROM AccountLevelMOC_Mod 
   --where AuthorisationStatus in('MP','1A','A') AND AccountID=@AccountId
   --AND  EffectiveFromTimeKey=@Timekey and EffectiveToTimeKey=@Timekey )
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
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;

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
        FROM AccountLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND AccountEntityID = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;

   END;
   END IF;
   --AND SCREENFLAG <> ('U')
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
         
         DBMS_OUTPUT.PUT_LINE('AKSHAY2');
         DELETE FROM GTT_ACCOUNT_PREMOC;
         UTILS.IDENTITY_RESET('GTT_ACCOUNT_PREMOC');

         INSERT INTO GTT_ACCOUNT_PREMOC ( 
         	SELECT * 
         	  FROM ( SELECT A.AccountEntityId ,
                          A.CustomerACID AccountID  ,
                          A.RefCustomerId CustomerID  ,
                          A.FacilityType ,
                          H.CustomerName ,
                          --,CustomerEntityID as CustomerEntityID
                          --,POS as Balance
                          B.DFVAmt ,
                          InterestReceivable InterestReceivable  ,
                          0 AdditionalProvisionAbsolute  ,
                          --,FlgRestructure as RestructureFlag,RestructureDate
                          ' ' FLGFITL  ,
                          c.StatusType FraudAccountFlag  ,
                          c.StatusDate FraudDate  ,
                          --D.StatusType as RestructureFlag,D.StatusDate as RestructureDate,
                          E.StatusType TwoFlag  ,
                          E.StatusDate TwoDate  ,
                          --,FlgMoc
                          v_MocReason MOCReason_1  ,
                          H.UCIF_ID UCICID  ,
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
                          B.PrincipalBalance POS  ,
                          F.SourceName ,
                          0 MOCReason  
                   FROM AdvAcBasicDetail A
                          JOIN AdvAcBalanceDetail B   ON a.AccountEntityId = b.AccountEntityId
                          AND b.EffectiveFromTimeKey <= v_TimeKey
                          AND b.EffectiveToTimeKey >= v_TimeKey
                          JOIN CustomerBasicDetail H   ON A.RefCustomerId = H.CustomerId
                          AND H.EffectiveFromTimeKey <= v_TimeKey
                          AND H.EffectiveToTimeKey >= v_TimeKey
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
                          LEFT JOIN DIMSOURCEDB F   ON A.SourceAlt_Key = F.SourceAlt_Key

                   --AND  A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey 
                   WHERE  A.AccountEntityId = v_AccountEntityID
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey ) X );
         MERGE INTO GTT_ACCOUNT_PREMOC A
         USING (SELECT A.ROWID row_id, NVL(B.ParameterAlt_Key, 0) AS MOCReason
         FROM GTT_ACCOUNT_PREMOC A
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
         --Select 'GTT_ACCOUNT_PREMOC',* from GTT_ACCOUNT_PREMOC
         
         DBMS_OUTPUT.PUT_LINE('SWAPNA');
         DELETE FROM tt_ACCOUNT_POSTMOC;
         UTILS.IDENTITY_RESET('tt_ACCOUNT_POSTMOC');

         INSERT INTO tt_ACCOUNT_POSTMOC ( 
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
                 UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
                 'a' AuthorisationStatus  ,
                 'a' CreatedBy  ,
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
         	  FROM AccountLevelMOC_Mod 

         	--where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
         	WHERE  AuthorisationStatus IN ( '1A','MP','NP' )

                   AND EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND AccountEntityID = v_AccountEntityID );
         --AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_ACCOUNT_POSTMOC 
                                 WHERE  AccountEntityID = v_AccountEntityID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_ACCOUNT_POSTMOC
              ( SELECT B.AccountEntityID ,
                       b.RefSystemAcId AccountID  ,
                       PrincOutStd POS  ,
                       unserviedint InterestReceivable  ,
                       --RestructureFlag,RestructureDate,
                       FlgFITL FLGFITL  ,
                       A.DFVAmt ,
                       AddlProvAbs ,
                       FlgFraud FraudAccountFlag  ,
                       FraudDate ,
                       --FlgRestructure,RestructureDate,
                       TwoFlag ,
                       TwoDate ,
                       MOC_Reason MOCReason  ,
                       TwoAmount ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',50) UCICID  ,
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
                       'ACCT' MOC_TYPEFLAG  
                FROM MOC_ChangeDetails A
                       JOIN AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND A.AccountEntityID = v_AccountEntityID );

         END;
         END IF;
         --Drop Table  ACCOUNT_POSTMOC_HIST 
         --IF NOT EXISTS(SELECT 1 FROM tt_ACCOUNT_POSTMOC WHERE AccountID=@AccountId)
         --BEGIN
         --	INSERT  INTO  tt_ACCOUNT_POSTMOC
         --	SELECT AccountEntityId,CustomerACID as AccountID,CustomerEntityID as CustomerEntityID,Balance,unserviedint as InterestReceivable,FlgRestructure as RestructureFlag,RestructureDate,FLGFITL,DFVAmt,RePossession as RePossessionFlag,
         --    RepossessionDate,WeakAccount as WeakAccountFlag,WeakAccountDate,Sarfaesi as SarfaesiFlag,SarfaesiDate,FlgUnusualBounce as UnusualBounceflag,UnusualBounceDate,FlgUnClearedEffect as UnClearedEffectFlag,
         --    UnClearedEffectDate,AddlProvision as AdditionalProvisionAbsolute,FlgFraud as FraudAccountFlag,FraudDate,BenamiLoansFlag,MarkBenamiDate,SubLendingFlag,
         --	MarkSubLendingDate,AbscondingFlag,MarkAbscondingDate,
         --	FlgMoc,@MocReason as MOCReason,
         --	UCIF_ID as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
         --	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
         --	,@MocSource  AS MOCSource
         --	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
         --	,TwoFlag,TwoDate,PrincOutStd
         --	FROM   [Pro].[ACCOUNTCAL_HIST]
         --	WHERE EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='Y'
         --	AND CustomerACID=@AccountId 
         --	--and  ISNULL(ScreenFlag,'')<>'U'
         --END
         --Select 'tt_ACCOUNT_POSTMOC' ,* from tt_ACCOUNT_POSTMOC

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.AccountID ,
                      A.FacilityType ,
                      A.CustomerID ,
                      --,A.Balance as POS
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
                      --,(case when A.RestructureFlag  IS NULL 
                      --       then 'No' 
                      --	   when  A.RestructureFlag='Y'
                      --	   THEN 'Yes'
                      --	   When  A.RestructureFlag='N'
                      --	   THEN 'No'
                      --	    end)  RestructureFlag
                      --,Convert(Varchar(10),A.RestructureDate,103) as RestructureDate
                      (CASE 
                            WHEN A.TwoFlag IS NULL THEN 'No'
                            WHEN A.TwoFlag = 'Y' THEN 'Yes'
                            WHEN A.TwoFlag = 'N' THEN 'No'   END) TwoFlag  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.TwoDate,10,p_style=>103) RePossessionDate  ,
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
                      -- ,B.RestructureFlag 	as RestructureFlag_POS
                      -- , Convert(Varchar(10),B.RestructureDate,103) 		as RestructureDate_POS
                      B.AuthorisationStatus ,
                      B.AdditionalProvisionAbsolute AddlProvisionPer_POS  ,
                      v_Timekey EffectiveFromTimeKey  ,
                      49999 EffectiveToTimeKey  ,
                      A.CreatedBy ,
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
                      B.FraudDate FraudDate_A26  ,
                      'Account' TableName  
                 FROM GTT_ACCOUNT_PREMOC A
                        LEFT JOIN tt_ACCOUNT_POSTMOC B   ON A.AccountID = b.AccountID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         --LEFT JOIN  [Pro].[CustomerCal_Hist] C ON A.AccountID =C.
         --AND  c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey 
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
         IF utils.object_id('tempdb..GTT_MOCAuthorisation') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_MOCAuthorisation ';

         END;
         END IF;
         DELETE FROM GTT_MOCAuthorisation;
         UTILS.IDENTITY_RESET('GTT_MOCAuthorisation');

         INSERT INTO GTT_MOCAuthorisation ( 
         	SELECT ENTITYKEY,	ACCOUNTENTITYID,	ACCOUNTID,	POS,	INTERESTRECEIVABLE,	RESTRUCTUREFLAG,	RESTRUCTUREDATE,	FITLFLAG,	DFVAMOUNT,	REPOSSESSIONFLAG,	REPOSSESSIONDATE,	INHERENTWEAKNESSFLAG,	INHERENTWEAKNESSDATE,	SARFAESIFLAG,	SARFAESIDATE,	UNUSUALBOUNCEFLAG,	UNUSUALBOUNCEDATE,	UNCLEAREDEFFECTSFLAG,	UNCLEAREDEFFECTSDATE,	ADDITIONALPROVISIONCUSTOMERLEVEL,	ADDITIONALPROVISIONABSOLUTE,	MOCREASON,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	MOCDATE,	MOCBY,	MOCSOURCE,	FRAUDACCOUNTFLAG,	FRAUDDATE,	SCREENFLAG,	MOCTYPEALT_KEY,	APPROVEDBYFIRSTLEVEL,	DATEAPPROVEDFIRSTLEVEL,	CHANGEFIELD,	UPLOADID,	SRNO,	FLGTWO,	TWODATE,	TWOAMOUNT,	MOC_TYPEFLAG,
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
         --Select ' GTT_MOCAuthorisation',* from  GTT_MOCAuthorisation
         --where abc=1
         UPDATE GTT_MOCAuthorisation V
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
         MERGE INTO GTT_MOCAuthorisation Z
         USING (SELECT Z.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM CustomerLevelMOC_Mod V
                JOIN AdvAcBasicDetail X   ON V.CustomerEntityID = X.CustomerEntityId
                JOIN GTT_MOCAuthorisation Z   ON X.CustomerACID = Z.AccountID 
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
                            FROM GTT_MOCAuthorisation 
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
                    FROM GTT_MOCAuthorisation  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLCODE:=SQLCODE;
   v_SQLERRM:=SQLERRM;
      INSERT INTO RBL_MISDB_PROD.Error_Log(ERRORLINE,	ERRORMESSAGE,	ERRORNUMBER,	ERRORPROCEDURE,	ERRORSEVERITY,	ERRORSTATE,	ERRORDATETIME)
        SELECT utils.error_line ErrorLine  ,
                 v_SQLERRM ErrorMessage  ,
                 v_SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  ;
      OPEN  v_cursor FOR
         SELECT v_SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
