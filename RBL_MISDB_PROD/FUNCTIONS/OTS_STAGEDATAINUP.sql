--------------------------------------------------------
--  DDL for Function OTS_STAGEDATAINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" 
(
  iv_Timekey IN NUMBER,
  v_UserLoginID IN VARCHAR2,
  v_OperationFlag IN NUMBER,
  v_MenuId IN NUMBER,
  v_AuthMode IN CHAR,
  v_filepath IN VARCHAR2,
  iv_EffectiveFromTimeKey IN NUMBER,
  iv_EffectiveToTimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_UniqueUploadID IN NUMBER
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_FilePathUpload VARCHAR2(100);
   v_cursor SYS_REFCURSOR;
--@Authlevel varchar(5)
--DECLARE @Timekey INT=24928,
--	@UserLoginID VARCHAR(100)='FNAOPERATOR',
--	@OperationFlag INT=1,
--	@MenuId INT=163,
--	@AuthMode	CHAR(1)='N',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41

BEGIN

   /*TODO:SQLDEV*/ SET XACT_ABORT ON /*END:SQLDEV*/
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --DECLARE @Timekey INT
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
   --	WHERE ProcessType='Quarterly')
   --Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
   --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
   -- where A.CurrentStatus='C')
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   --SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
   --DECLARE @MOC_Date Date
   --SET @MOC_Date=(select cast(ExtDate as date) from SysDataMatrix where TimeKey=@Timekey )
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN
         IF ( v_MenuId = 24741 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM OTSUpload_stg 
                                         WHERE  filname = v_FilePathUpload ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  --Rollback tran
                  v_Result := -8 ;
                  RETURN v_Result;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT * 
                                  FROM OTSUpload_stg 
                                   WHERE  filname = v_FilePathUpload );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN
                DECLARE
                  v_ExcelUploadId NUMBER(10,0);

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Prashant1');
                  INSERT INTO ExcelUploadHistory
                    ( UploadedBy, DateofUpload, AuthorisationStatus
                  --,Action	
                  , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT v_UserLoginID ,
                             SYSDATE ,
                             'NP' ,
                             --,'NP'
                             'OTS Upload' ,
                             v_EffectiveFromTimeKey ,
                             v_EffectiveToTimeKey ,
                             v_UserLoginID ,
                             SYSDATE 
                        FROM DUAL  );
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  SELECT MAX(UniqueUploadID)  

                    INTO v_ExcelUploadId
                    FROM ExcelUploadHistory ;
                  INSERT INTO UploadStatus
                    ( FileNames, UploadedBy, UploadDateTime, UploadType )
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'OTS Upload' );
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM A ,OTS_Details_Mod A
                         JOIN OTSUpload_stg B   ON A.RefCustomerAcid = B.AccountNumber
                         AND A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.EffectiveToTimeKey >= v_Timekey
                    AND A.AuthorisationStatus = 'A') src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  DBMS_OUTPUT.PUT_LINE('nanda1');
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  INSERT INTO OTS_Details_Mod
                    ( SrNo, UploadID, RefCustomerAcid, Date_Approval_Settlement, Approving_Authority, Principal_OS, Interest_Due_time_Settlement, Fees_Charges_Settlement, Total_Dues_Settlement, Settlement_Amount, AmtSacrificePOS, AmtWaiverIOS, AmtWaiverChgOS, TotalAmtSacrifice, SettlementFailed
                  --,Actual_Write_Off_Amount
                   --,Actual_Write_Off_Date
                  , Account_Closure_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, screenFlag, AccountEntityId, CustomerEntityId, RefCustomerId, ACTION, NPA_Date, ACL_Sttlement )
                    ( SELECT SrNo ,
                             v_ExcelUploadId ,
                             AccountNumber ,
                             Dateofapprovalofsettlement ,
                             ApprovingAuthority ,
                             PrincipalOutstandingatthetimeofsettlement ,
                             InterestDueatthetimeofsettlement ,
                             FeesChargesDueatthetimeofsettlement ,
                             NULL TotalDuesSettlement  ,
                             SettlementAmount ,
                             PrincipalSacrifice ,
                             InterestWaiver ,
                             FeeWaiver ,
                             NULL TotalAmtSacrifice  ,
                             SettlementFailure ,
                             --,Actual_Write_Off_Amount
                             --,Actual_Write_Off_Date
                             CASE 
                                  WHEN Accountclosuredateinsystem IN ( ' ','1900-01-01' )
                                   THEN NULL
                             ELSE Accountclosuredateinsystem
                                END col  ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE ,
                             'U' ,
                             c.AccountEntityId ,
                             C.CustomerEntityId ,
                             C.RefCustomerId ,
                             ACTION ,
                             B.NPADt ,
                             B.Cust_AssetClassAlt_Key 
                      FROM OTSUpload_stg A
                             JOIN AdvAcBasicDetail C   ON A.AccountNumber = C.CustomerACID
                             AND C.EffectiveFromTimeKey <= v_Timekey
                             AND C.EffectiveToTimeKey >= v_Timekey
                             LEFT JOIN AdvCustNPADetail B   ON C.CustomerEntityId = B.CustomerEntityId
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_Timekey
                       WHERE  filname = v_FilePathUpload );
                  DBMS_OUTPUT.PUT_LINE('nanda2');
                  ---------------------------------------------------------ChangeField Logic---------------------
                  ----select * from AccountLvlMOCDetails_stg
                  IF utils.object_id('TempDB..tt_OTS_AWOUpload') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_OTS_AWOUpload ';
                  END IF;
                  DELETE FROM tt_OTS_AWOUpload;
                  INSERT INTO tt_OTS_AWOUpload
                    ( AccountNumber, FieldName )
                    ( SELECT AccountNumber ,
                             'Dateofapprovalofsettlement' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(Dateofapprovalofsettlement, ' ') <> ' '
                      UNION 
                      SELECT AccountNumber ,
                             'ApprovingAuthority' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(ApprovingAuthority, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'PrincipalOutstandingatthetimeofsettlement' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(PrincipalOutstandingatthetimeofsettlement, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'InterestDueatthetimeofsettlement' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(InterestDueatthetimeofsettlement, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'FeesChargesDueatthetimeofsettlement' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(FeesChargesDueatthetimeofsettlement, ' ') <> ' '
                      UNION ALL 

                      --Select AccountNumber, 'TotalDuesSettlement' FieldName from OTSUpload_stg Where isnull(TotalDuesSettlement,'')<>'' 

                      --UNION ALL

                      --Select AccountNumber, 'SettlementAmount' FieldName from OTSUpload_stg Where isnull(SettlementAmount,'')<>'' 

                      --UNION ALL
                      SELECT AccountNumber ,
                             'PrincipalSacrifice' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(PrincipalSacrifice, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'InterestWaiver' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(InterestWaiver, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'FeesWaiver' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(FeeWaiver, ' ') <> ' '
                      UNION ALL 

                      --Select AccountNumber, 'TotalAmtSacrifice' FieldName from OTSUpload_stg Where isnull(TotalAmtSacrifice,'')<>''

                      --UNION ALL
                      SELECT AccountNumber ,
                             'SettlementFailure' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(SettlementFailure, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'Action' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(ACTION, ' ') <> ' '
                      UNION 
                      --UNION ALL

                      --Select Account_ID, 'Actual_Write_Off_Date' FieldName from OTSUpload_stg Where isnull(Actual_Write_Off_Date,'')<>'' 
                      ALL 
                      SELECT AccountNumber ,
                             'Accountclosuredateinsystem' FieldName  
                      FROM OTSUpload_stg 
                       WHERE  NVL(Accountclosuredateinsystem, ' ') <> ' ' );
                  DBMS_OUTPUT.PUT_LINE('nanda3');
                  --select *
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                  FROM B ,MetaScreenFieldDetail A
                         JOIN tt_OTS_AWOUpload B   ON A.CtrlName = B.FieldName 
                   WHERE A.MenuId = v_MenuId
                    AND A.IsVisible = 'Y') src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                  DBMS_OUTPUT.PUT_LINE('nanda4');
                  IF utils.object_id('TEMPDB..tt_NEWTRANCHE_78') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_78 ';
                  END IF;
                  DELETE FROM tt_NEWTRANCHE_78;
                  UTILS.IDENTITY_RESET('tt_NEWTRANCHE_78');

                  INSERT INTO tt_NEWTRANCHE_78 SELECT * 
                       FROM ( SELECT ss.AccountNumber ,
                                     utils.stuff(( SELECT ',' || US.SrNo 
                                                   FROM tt_OTS_AWOUpload US
                                                    WHERE  US.AccountNumber = ss.AccountNumber ), 1, 1, ' ') REPORTIDSLIST  
                              FROM OTSUpload_stg SS
                                GROUP BY ss.AccountNumber ) B
                       ORDER BY 1;
                  --Select * from tt_NEWTRANCHE_78
                  --SELECT * 
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                  FROM A ,RBL_MISDB_PROD.OTS_Details_Mod A
                         JOIN tt_NEWTRANCHE_78 B   ON A.RefCustomerAcid = B.AccountNumber 
                   WHERE A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND A.UploadID = v_ExcelUploadId) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.ChangeFields = src.REPORTIDSLIST;
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  ---DELETE FROM STAGING DATA
                  DELETE OTSUpload_stg

                   WHERE  filname = v_FilePathUpload;

               END;
               END IF;

            END;
            END IF;
            ----RETURN @ExcelUploadId
            ----DECLARE @UniqueUploadID INT
            --SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
            DBMS_OUTPUT.PUT_LINE('nanda4');
            ----------------------01042021-------------
            IF ( v_OperationFlag = 16 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----AUTHORIZE
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                             FROM OTS_Details_Mod 
                                              WHERE  CreatedBy = v_UserLoginID
                                                       AND UploadId = v_UniqueUploadID
                                                       AND AuthorisationStatus IN ( 'NP','MP' )

                                                       AND EffectiveToTimeKey = 49999
                                               GROUP BY CreatedBy ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  ROLLBACK;
                  utils.resetTrancount;
                  v_Result := -1 ;
                  RETURN v_Result;

               END;
               ELSE

               BEGIN
                  UPDATE OTS_Details_Mod
                     SET AuthorisationStatus = '1A',
                         FirstLevelApprovedBy = v_UserLoginID,
                         FirstLevelDateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND EffectiveToTimeKey = 49999
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'OTS Upload';

               END;
               END IF;

            END;
            END IF;
            --------------------------------------------
            DBMS_OUTPUT.PUT_LINE('nanda6');
            IF ( v_OperationFlag = 20 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----AUTHORIZE
            BEGIN
               DBMS_OUTPUT.PUT_LINE('vivek');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE v_UserLoginID = ( SELECT UserLoginID 
                                           FROM DimUserInfo 
                                            WHERE  IsChecker2 = 'N'
                                                     AND UserLoginID = v_UserLoginID
                                                     AND EffectiveToTimeKey = 49999 );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  -- ROLLBACK TRAN
                  v_Result := -1 ;
                  RETURN v_Result;

               END;
               ELSE
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('vivek1');
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM OTS_Details_Mod 
                                                 WHERE  AuthorisationStatus IN ( '1A' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey = 49999
                                                          AND CreatedBy = v_UserLoginID

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     --ROLLBACK TRAN
                     v_Result := -1 ;
                     RETURN v_Result;

                  END;

                  --select * from AccountFlaggingDetails_Mod
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('vivek2');
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE ( v_UserLoginID = ( SELECT ApprovedBy 
                                                   FROM OTS_Details_Mod 
                                                    WHERE  AuthorisationStatus IN ( '1A' )

                                                             AND UploadId = v_UniqueUploadID
                                                             AND EffectiveToTimeKey = 49999
                                                             AND ApprovedBy = v_UserLoginID

                                                   --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                   GROUP BY ApprovedBy ) );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        ROLLBACK;
                        utils.resetTrancount;
                        v_Result := -1 ;
                        RETURN v_Result;

                     END;

                     --select * from AccountFlaggingDetails_Mod
                     ELSE

                     BEGIN
                        UPDATE OTS_Details_Mod
                           SET AuthorisationStatus = 'A',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE
                         WHERE  UploadId = v_UniqueUploadID;
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                        FROM A ,OTS_Details A
                               JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityId = B.AccountEntityId
                               AND A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND B.EffectiveFromTimeKey <= v_Timekey
                               AND B.EffectiveToTimeKey >= v_Timekey
                               JOIN OTS_Details_Mod C   ON B.AccountEntityId = C.AccountEntityId
                               AND C.EffectiveFromTimeKey <= v_Timekey
                               AND C.EffectiveToTimeKey >= v_Timekey
                               AND C.AuthorisationStatus = 'A'
                               AND UploadId = v_UniqueUploadID 
                         WHERE A.EffectiveToTimeKey >= v_Timekey
                          AND A.AuthorisationStatus = 'A'
                          AND UploadId = v_UniqueUploadID) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                        INSERT INTO OTS_Details
                          ( RefCustomerAcid, Date_Approval_Settlement, Approving_Authority, Principal_OS, Interest_Due_time_Settlement, Fees_Charges_Settlement, Total_Dues_Settlement, Settlement_Amount, AmtSacrificePOS, AmtWaiverIOS, AmtWaiverChgOS, TotalAmtSacrifice, SettlementFailed
                        --,Actual_Write_Off_Amount
                         --,Actual_Write_Off_Date
                        , Account_Closure_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
                        --,FirstLevelApprovedBy
                         --,FirstLevelDateApproved
                         --,ChangeFields
                        , screenFlag, AccountEntityId, CustomerEntityId, RefCustomerId, ACTION, NPA_Date, ACL_Sttlement )
                          ( SELECT RefCustomerAcid ,
                                   Date_Approval_Settlement ,
                                   Approving_Authority ,
                                   Principal_OS ,
                                   Interest_Due_time_Settlement ,
                                   Fees_Charges_Settlement ,
                                   Total_Dues_Settlement ,
                                   Settlement_Amount ,
                                   AmtSacrificePOS ,
                                   AmtWaiverIOS ,
                                   AmtWaiverChgOS ,
                                   TotalAmtSacrifice ,
                                   SettlementFailed ,
                                   --,Actual_Write_Off_Amount
                                   --,Actual_Write_Off_Date
                                   --,Account_Closure_Date
                                   CASE 
                                        WHEN Account_Closure_Date IN ( ' ','1900-01-01' )
                                         THEN NULL
                                   ELSE Account_Closure_Date
                                      END col  ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   --,FirstLevelApprovedBy
                                   --,FirstLevelDateApproved
                                   --,ChangeFields
                                   'U' ,
                                   A.AccountEntityId ,
                                   A.CustomerEntityId ,
                                   A.RefCustomerId ,
                                   ACTION ,
                                   A.NPA_Date ,
                                   A.ACL_Sttlement 
                            FROM OTS_Details_Mod A
                                   JOIN AdvAcBasicDetail B   ON A.AccountEntityId = B.AccountEntityId
                                   AND B.EffectiveFromTimeKey <= v_Timekey
                                   AND B.EffectiveToTimeKey >= v_Timekey
                             WHERE  A.UploadID = v_UniqueUploadID
                                      AND A.EffectiveFromTimeKey <= v_Timekey
                                      AND A.EffectiveToTimeKey >= v_Timekey
                                      AND A.AuthorisationStatus = 'A'
                                      AND a.action = 'A' );
                        DBMS_OUTPUT.PUT_LINE('BBBB');
                        --UPDATE OTS_Details SET
                        --		-- RefCustomerAcid			    = (case when B.RefCustomerAcid              is null then a.RefCustomerAcid             else B.RefCustomerAcid              end)
                        --		 Date_Approval_Settlement		= (case when B.Date_Approval_Settlement	   is null then a.Date_Approval_Settlement	  else B.Date_Approval_Settlement	  end)
                        --		,Approving_Authority			= (case when B.Approving_Authority		   is null then a.Approving_Authority		  else B.Approving_Authority		  end)
                        --		,Principal_OS					= (case when B.Principal_OS				   is null then a.Principal_OS				  else B.Principal_OS				  end)
                        --		,Interest_Due_time_Settlement	= (case when B.Interest_Due_time_Settlement is null then a.Interest_Due_time_Settlement else B.Interest_Due_time_Settlement end)
                        --		,Fees_Charges_Settlement		= (case when B.Fees_Charges_Settlement	   is null then a.Fees_Charges_Settlement	  else B.Fees_Charges_Settlement	  end)
                        --		,Total_Dues_Settlement			= (case when B.Total_Dues_Settlement		   is null then a.Total_Dues_Settlement		  else B.Total_Dues_Settlement		  end)
                        --		,Settlement_Amount				= (case when B.Settlement_Amount			   is null then a.Settlement_Amount			  else B.Settlement_Amount			  end)
                        --		,AmtSacrificePOS		    	= (case when B.AmtSacrificePOS			   is null then a.AmtSacrificePOS			  else B.AmtSacrificePOS			  end)
                        --		,AmtWaiverIOS			    	= (case when B.AmtWaiverIOS				   is null then a.AmtWaiverIOS				  else B.AmtWaiverIOS				  end)
                        --		,AmtWaiverChgOS					= (case when B.AmtWaiverChgOS			   is null then a.AmtWaiverChgOS			  else B.AmtWaiverChgOS			  	  end)
                        --		,TotalAmtSacrifice	            = (case when B.TotalAmtSacrifice			   is null then a.TotalAmtSacrifice			  else B.TotalAmtSacrifice			  end)
                        --		,SettlementFailed				= (case when B.SettlementFailed			   is null then a.SettlementFailed			  else B.SettlementFailed			  end)
                        --		,Account_Closure_Date			= (case when B.Account_Closure_Date		   is null then a.Account_Closure_Date		  else B.Account_Closure_Date		  end)
                        --		,AuthorisationStatus			= (case when B.AuthorisationStatus		   is null then a.AuthorisationStatus		  else B.AuthorisationStatus		  end)
                        --		,ModifiedBy						= (case when B.ModifiedBy				   is null then a.ModifiedBy				  else B.ModifiedBy				  	  end)
                        --		,DateModified					= (case when B.DateModified				   is null then a.DateModified				  else B.DateModified				  end)
                        --		,ApprovedBy						= (case when B.ApprovedBy 				   is null then a.ApprovedBy				  else B.ApprovedBy 				  end)
                        --		,DateApproved					= (case when B.DateApproved 				   is null then a.DateApproved				  else B.DateApproved 				  end)
                        --		,screenFlag						= 'U'
                        --		,AccountEntityId                = (case when B.AccountEntityId 				   is null then a.AccountEntityId				  else B.AccountEntityId 	  end)
                        --	    ,CustomerEntityId               = (case when B.CustomerEntityId			   is null then a.CustomerEntityId				  else B.CustomerEntityId 	      end)
                        --		,RefCustomerId                  = (case when B.RefCustomerId 				   is null then a.RefCustomerId				  else B.RefCustomerId 			end)
                        --                                      ,action                         =  b.action
                        --		,NPA_Date						= (case when B.NPA_Date 				   is null then a.NPA_Date				  else B.NPA_Date 			end)
                        --		,ACL_Sttlement					= (case when B.ACL_Sttlement 				   is null then a.ACL_Sttlement				  else B.ACL_Sttlement 			end)
                        --	From OTS_Details a
                        --	 inner join OTS_Details_Mod b 
                        --	 on         a.RefCustomerAcid=b.RefCustomerAcid
                        --	 And        a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey 
                        --	 WHERE      b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey 
                        --	 --AND        b.RefCustomerAcid=b.RefCustomerAcid
                        --	 and        b.action='U'
                        MERGE INTO OTS_Details a
                        USING (SELECT a.ROWID row_id, (CASE 
                        WHEN B.Account_Closure_Date IS NULL THEN a.Account_Closure_Date
                        ELSE B.Account_Closure_Date
                           END) AS Account_Closure_Date
                        FROM OTS_Details a
                               JOIN OTS_Details_Mod b   ON a.RefCustomerAcid = b.RefCustomerAcid
                               AND a.EffectiveFromTimeKey <= v_TimeKey
                               AND a.EffectiveToTimeKey >= v_TimeKey 
                         WHERE b.EffectiveFromTimeKey <= v_TimeKey
                          AND b.EffectiveToTimeKey >= v_TimeKey

                          --AND        b.RefCustomerAcid=b.RefCustomerAcid
                          AND b.action = 'U'
                          AND b.screenFlag = 'U') src
                        ON ( a.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET a.Account_Closure_Date = src.Account_Closure_Date;
                        UPDATE ExcelUploadHistory
                           SET AuthorisationStatus = 'A',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE
                         WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey
                          AND UniqueUploadID = v_UniqueUploadID
                          AND UploadType = 'OTS Upload';

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----REJECT
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                             FROM OTS_Details_Mod 
                                              WHERE  CreatedBy = v_UserLoginID
                                                       AND UploadId = v_UniqueUploadID
                                                       AND AuthorisationStatus IN ( 'NP','MP' )

                                                       AND EffectiveToTimeKey = 49999
                                               GROUP BY CreatedBy ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  ROLLBACK;
                  utils.resetTrancount;
                  v_Result := -1 ;
                  RETURN v_Result;

               END;
               ELSE

               BEGIN
                  UPDATE OTS_Details_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_Timekey - 1
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_Timekey - 1
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'OTS Upload';

               END;
               END IF;

            END;
            END IF;
            IF ( v_OperationFlag = 21 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----REJECT
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE v_UserLoginID = ( SELECT UserLoginID 
                                           FROM DimUserInfo 
                                            WHERE  IsChecker2 = 'N'
                                                     AND UserLoginID = v_UserLoginID
                                                     AND EffectiveToTimeKey = 49999 );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  ROLLBACK;
                  utils.resetTrancount;
                  v_Result := -1 ;
                  RETURN v_Result;

               END;
               ELSE
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM OTS_Details_Mod 
                                                 WHERE  AuthorisationStatus IN ( '1A' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey = 49999
                                                          AND CreatedBy = v_UserLoginID

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     ROLLBACK;
                     utils.resetTrancount;
                     v_Result := -1 ;
                     RETURN v_Result;

                  END;

                  --select * from AccountFlaggingDetails_Mod
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE ( v_UserLoginID = ( SELECT ApprovedBy 
                                                   FROM OTS_Details_Mod 
                                                    WHERE  AuthorisationStatus IN ( '1A' )

                                                             AND UploadId = v_UniqueUploadID
                                                             AND EffectiveToTimeKey = 49999
                                                             AND ApprovedBy = v_UserLoginID

                                                   --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                   GROUP BY ApprovedBy ) );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        ROLLBACK;
                        utils.resetTrancount;
                        v_Result := -1 ;
                        RETURN v_Result;

                     END;

                     --select * from AccountFlaggingDetails_Mod
                     ELSE

                     BEGIN
                        UPDATE OTS_Details_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE,
                               EffectiveToTimeKey = v_Timekey - 1
                         WHERE  UploadId = v_UniqueUploadID
                          AND AuthorisationStatus IN ( 'NP','1A' )
                        ;
                        UPDATE ExcelUploadHistory
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE,
                               EffectiveToTimeKey = v_Timekey - 1
                         WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey
                          AND UniqueUploadID = v_UniqueUploadID
                          AND UploadType = 'OTS Upload';

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;

         END;
         END IF;
         IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_DateCreated DATE;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            v_DateCreated := SYSDATE ;
            --declare @ReferenceID1 varchar(max)
            --set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)
            IF v_OperationFlag IN ( 16,17,18,20,21 )
             THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Authorised');
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_UniqueUploadID -- ReferenceID ,
                ,
                v_CreatedBy => NULL,
                v_ApprovedBy => v_UserLoginID,
                iv_CreatedCheckedDt => v_DateCreated,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('UNAuthorised');
               -- Declare
               -- set @CreatedBy  =@UserLoginID
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_ExcelUploadId -- ReferenceID ,
                ,
                v_CreatedBy => v_UserLoginID,
                v_ApprovedBy => NULL,
                iv_CreatedCheckedDt => v_DateCreated,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            END IF;

         END;
         END IF;
         --COMMIT TRAN
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 24741 THEN v_ExcelUploadId
         ELSE 1
            END ;
         UPDATE UploadStatus
            SET InsertionOfData = 'Y',
                InsertionCompletedOn = SYSDATE
          WHERE  FileNames = v_filepath;
         ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
         ----BEGIN
         DELETE OTSUpload_stg

          WHERE  filname = v_FilePathUpload;
         ----	 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
         ----END
         RETURN v_Result;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------RETURN @UniqueUploadID
      --ROLLBACK TRAN
      OPEN  v_cursor FOR
         SELECT SQLERRM ,
                utils.error_line 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_Result := -1 ;
      UPDATE UploadStatus
         SET InsertionOfData = 'Y',
             InsertionCompletedOn = SYSDATE
       WHERE  FileNames = v_filepath;
      RETURN -1;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_STAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
