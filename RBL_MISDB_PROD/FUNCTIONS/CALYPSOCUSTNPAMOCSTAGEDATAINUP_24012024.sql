--------------------------------------------------------
--  DDL for Function CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" /*
declare @p11 int
set @p11=-1
exec [dbo].[CustNPAMOCStageDataInUp] @Authlevel=N'2',@TimeKey=25999,@UserLoginID=N'test_two',@OperationFlag=N'1',@MenuId=N'27766 ',@AuthMode=N'Y',@filepath=N'CustlevelNPAMOCUpload.xlsx',@EffectiveFromTimeKey=25999,@EffectiveToTimeKey=49999,@UniqueUploadID=NU




LL,@Result=@p11 output
select @p11
go

*/
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
  v_UniqueUploadID IN NUMBER,
  v_Authlevel IN VARCHAR2
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=25999,
--	@UserLoginID VARCHAR(100)='test_two',
--	@OperationFlag INT=1,
--	@MenuId INT=27766 ,
--	@AuthMode	CHAR(1)='Y',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM ACLProcessInProgressStatus 
                       WHERE  STATUS = 'RUNNING'
                                AND StatusFlag = 'N'
                                AND TimeKey IN ( SELECT MAX(Timekey)  
                                                 FROM ACLProcessInProgressStatus  )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process is In Progress');

   END;

   --IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )

   --BEGIN

   --	PRINT 'ACL Process Completed'
   ELSE
   DECLARE
      --DECLARE @Timekey INT
      --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
      --	WHERE ProcessType='Quarterly')
      --Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
      --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
      -- where A.CurrentStatus='C')
      --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
      --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
      v_MocDate VARCHAR2(200);
      v_MocStatus VARCHAR2(100) := ' ';
      v_FilePathUpload VARCHAR2(100);

   BEGIN
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';
      SELECT ExtDate 

        INTO v_MocDate
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';
      DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
      v_EffectiveFromTimeKey := v_TimeKey ;
      v_EffectiveToTimeKey := 49999 ;
      SELECT MocStatus 

        INTO v_MocStatus
        FROM CalypsoMOCMonitorStatus 
       WHERE  EntityKey IN ( SELECT MAX(EntityKey)  
                             FROM CalypsoMOCMonitorStatus  )
      ;
      IF ( v_MocStatus = 'InProgress' ) THEN

      BEGIN
         v_Result := 5 ;
         RETURN v_Result;

      END;
      END IF;
      v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
      DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
      DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
      BEGIN

         BEGIN
            --BEGIN TRAN
            IF ( v_MenuId = 27766 ) THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT * 
                                           FROM CalypsoCustlevelNPAMOCDetails_stg 
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
                  DBMS_OUTPUT.PUT_LINE('Sachin');
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM CalypsoCustlevelNPAMOCDetails_stg 
                                      WHERE  filname = v_FilePathUpload );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN
                   DECLARE
                     v_ExcelUploadId NUMBER(10,0);

                  BEGIN
                     INSERT INTO ExcelUploadHistory
                       ( UploadedBy, DateofUpload, AuthorisationStatus
                     --,Action	
                     , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                       ( SELECT v_UserLoginID ,
                                SYSDATE ,
                                'NP' ,
                                --,'NP'
                                'Calypso Customer MOC Upload' ,
                                v_EffectiveFromTimeKey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE 
                           FROM DUAL  );
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     SELECT MAX(UniqueUploadID)  

                       INTO v_ExcelUploadId
                       FROM ExcelUploadHistory ;
                     INSERT INTO UploadStatus
                       ( FileNames, UploadedBy, UploadDateTime, UploadType )
                       VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Calypso Customer MOC Upload' );
                     DBMS_OUTPUT.PUT_LINE('Sachin111');
                     DBMS_OUTPUT.PUT_LINE('@ExcelUploadId');
                     DBMS_OUTPUT.PUT_LINE(v_ExcelUploadId);
                     /*TODO:SQLDEV*/ SET dateformat DMY /*END:SQLDEV*/
                     --  Update  A
                     --Set A.EffectiveToTimeKey=@Timekey-1
                     --from CalypsoCustomerLevelMOC_MOD A
                     --inner join CalypsoCustlevelNPAMOCDetails_stg B
                     --ON A.UCICID=B.UCICID
                     --AND A.EffectiveFromTimeKey <=@Timekey
                     --AND A.EffectiveToTimeKey >=@Timekey
                     --Where A.EffectiveToTimeKey >=@Timekey
                     --and A.AuthorisationStatus = 'A'
                     INSERT INTO CalypsoCustomerLevelMOC_Mod
                       ( SrNo, UploadID
                     --,SummaryID
                      --,SlNo
                     , UCIFID, AssetClass, AssetClassAlt_Key, NPADate
                     --,SecurityValue
                     , AdditionalProvision, MOCSource, MOCSourceAltkey, MOCType, MOCTypeAlt_Key, MOCReason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ScreenFlag, ChangeField, MOCDate, MOCType_Flag, CustomerEntityID, CustomerID, CustomerName )
                       ( SELECT SlNo ,
                                v_ExcelUploadId ,
                                --,SummaryID
                                --,SlNo
                                A.UCICID ,
                                A.AssetClass ,
                                B.AssetClassAlt_Key ,
                                CASE 
                                     WHEN NPIDate <> ' '
                                       AND utils.isdate(NPIDate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(NPIDate,200)
                                ELSE NULL
                                   END NPIDate  ,
                                --,ISNULL(case when isnull(SecurityValue,'0')<>'0' then CAST(ISNULL(CAST(SecurityValue AS INT),0) AS DECIMAL(30,2))   end,0) SecurityValue
                                --,Case When SecurityValue<>'' THEN CAST(ISNULL(CAST(SecurityValue AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END SecurityValue
                                CASE 
                                     WHEN AdditionalProvision <> ' ' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(AdditionalProvision,16,2), 0),16,2)
                                ELSE NULL
                                   END AdditionalProvision  ,
                                --,ISNULL(case when isnull(AdditionalProvision,'0')<>'0' then CAST(ISNULL(CAST(AdditionalProvision AS INT),0) AS DECIMAL(30,2))   end,0) AdditionalProvision 
                                MOCSource ,
                                E.MOCTypeAlt_Key ,
                                --,case when MOCType='Auto' then 1 else 2 END MOCType
                                MOCType ,
                                C.ParameterAlt_Key ,
                                f.ParameterName MOCReason  ,
                                'NP' ,
                                v_Timekey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE ,
                                'U' ,
                                NULL ,
                                v_MocDate ,
                                'CUST' ,
                                H.IssuerEntityId ,
                                H.IssuerID ,
                                H.IssuerName 
                         FROM CalypsoCustlevelNPAMOCDetails_stg A
                                JOIN InvestmentIssuerDetail H   ON A.UCICID = H.UcifId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName 
                                            FROM DimParameter 
                                             WHERE  dimParameterName = 'DimMOCReason'
                                                      AND EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) f   ON f.ParameterName = RTRIM(LTRIM(a.MOCReason))
                                LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'MOCType' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'MOCType'
                                                      AND EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) C   ON A.MOCType = C.ParameterName
                                LEFT JOIN ( SELECT MOCTypeAlt_Key ,
                                                   MOCTypeName ,
                                                   'MOCSource' TableName  
                                            FROM DimMOCType 
                                             WHERE  EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) E   ON A.MOCSource = E.MOCTypeName
                          WHERE  filname = v_FilePathUpload
                         UNION 
                         SELECT SlNo ,
                                v_ExcelUploadId ,
                                --,SummaryID
                                --,SlNo
                                A.UCICID ,
                                A.AssetClass ,
                                B.AssetClassAlt_Key ,
                                CASE 
                                     WHEN NPIDate <> ' '
                                       AND utils.isdate(NPIDate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(NPIDate,200)
                                ELSE NULL
                                   END NPIDate  ,
                                --,ISNULL(case when isnull(SecurityValue,'0')<>'0' then CAST(ISNULL(CAST(SecurityValue AS INT),0) AS DECIMAL(30,2))   end,0) SecurityValue
                                --,Case When SecurityValue<>'' THEN CAST(ISNULL(CAST(SecurityValue AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END SecurityValue
                                CASE 
                                     WHEN AdditionalProvision <> ' ' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(AdditionalProvision,16,2), 0),16,2)
                                ELSE NULL
                                   END AdditionalProvision  ,
                                --,ISNULL(case when isnull(AdditionalProvision,'0')<>'0' then CAST(ISNULL(CAST(AdditionalProvision AS INT),0) AS DECIMAL(30,2))   end,0) AdditionalProvision 
                                MOCSource ,
                                E.MOCTypeAlt_Key ,
                                --,case when MOCType='Auto' then 1 else 2 END MOCType
                                MOCType ,
                                C.ParameterAlt_Key ,
                                f.ParameterName MOCReason  ,
                                'NP' ,
                                v_Timekey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE ,
                                'U' ,
                                NULL ,
                                v_MocDate ,
                                'CUST' ,
                                0 ,
                                CustomerID ,
                                CustomerName 

                         --select * from pro.AccountCal_Hist

                         --select * from MetaScreenFieldDetail   where menuid=27766 

                         --select * from MetaScreenFieldDetail   where menuid=126
                         FROM CalypsoCustlevelNPAMOCDetails_stg A
                                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail X   ON A.UCICID = X.UCIC_ID
                                AND X.EffectiveFromTimeKey <= v_TimeKey
                                AND X.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName 
                                            FROM DimParameter 
                                             WHERE  dimParameterName = 'DimMOCReason'
                                                      AND EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) f   ON f.ParameterName = RTRIM(LTRIM(a.MOCReason))
                                LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'MOCType' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'MOCType'
                                                      AND EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) C   ON A.MOCType = C.ParameterName
                                LEFT JOIN ( SELECT MOCTypeAlt_Key ,
                                                   MOCTypeName ,
                                                   'MOCSource' TableName  
                                            FROM DimMOCType 
                                             WHERE  EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey ) E   ON A.MOCSource = E.MOCTypeName
                          WHERE  filname = v_FilePathUpload );
                     --Update A
                     --Set A.CustomerEntityID=B.CustomerEntityID
                     --from CalypsoCustomerLevelMOC_MOD A
                     --	INNER JOIN CustomerBasicDetail B ON A.UCICID =B.UCICID
                     --	Where UploadID=@ExcelUploadId
                     IF utils.object_id('TempDB..tt_CustMocUpload_4') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustMocUpload_4 ';
                     END IF;
                     DELETE FROM tt_CustMocUpload_4;
                     INSERT INTO tt_CustMocUpload_4
                       ( UCICID, FieldName )
                       ( SELECT UCICID ,
                                'AssetClass' FieldName  
                         FROM CalypsoCustlevelNPAMOCDetails_stg 
                          WHERE  NVL(AssetClass, ' ') <> ' '
                         UNION 
                         SELECT UCICID ,
                                'NPIDate' FieldName  
                         FROM CalypsoCustlevelNPAMOCDetails_stg 
                          WHERE  NVL(NPIDate, ' ') <> ' '
                         UNION ALL 
                         SELECT UCICID ,
                                'AdditionalProvision' FieldName  
                         FROM CalypsoCustlevelNPAMOCDetails_stg 
                          WHERE  NVL(AdditionalProvision, ' ') <> ' ' );--AdditionalProvision Is not NULL
                     --select * 
                     MERGE INTO B 
                     USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                     FROM B ,MetaScreenFieldDetail A
                            JOIN tt_CustMocUpload_4 B   ON A.CtrlName = B.FieldName 
                      WHERE A.MenuId = 27766
                       AND A.IsVisible = 'Y') src
                     ON ( B.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                     ----	-------------------
                     ----	select * from tt_CustMocUpload_4
                     ----	select CtrlName,* from MetaScreenFieldDetail A Where A.MenuId=27766  And A.IsVisible='Y'
                     ----	update MetaScreenFieldDetail 
                     ----	set CtrlName='AdditionalProvision'
                     ----	 Where MenuId=27766  And IsVisible='Y' and entityKey=1406
                     ----	 Asset Class
                     ----NPA Date
                     ----Security Value
                     ----Additional Provision %
                     ------select * into MetaScreenFieldDetail_21062021  from MetaScreenFieldDetail
                     ----select * from MetaScreenFieldDetail_21062021 where menuid=27766 
                     ----select * from MetaScreenFieldDetail where menuid=27766 
                     ---------------------
                     IF utils.object_id('TEMPDB..tt_NEWTRANCHE_51') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_51 ';
                     END IF;
                     DELETE FROM tt_NEWTRANCHE_51;
                     UTILS.IDENTITY_RESET('tt_NEWTRANCHE_51');

                     INSERT INTO tt_NEWTRANCHE_51 SELECT * 
                          FROM ( SELECT ss.UCICID ,
                                        utils.stuff(( SELECT ',' || US.SrNo 
                                                      FROM tt_CustMocUpload_4 US
                                                       WHERE  US.UCICID = ss.UCICID ), 1, 1, ' ') REPORTIDSLIST  
                                 FROM CalypsoCustlevelNPAMOCDetails_stg SS
                                   GROUP BY ss.UCICID ) B
                          ORDER BY 1;
                     --Select * from tt_NEWTRANCHE_51
                     --SELECT * 
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                     FROM A ,RBL_MISDB_PROD.CalypsoCustomerLevelMOC_Mod A
                            JOIN tt_NEWTRANCHE_51 B   ON A.UcifID = B.UCICID 
                      WHERE A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND A.UploadID = v_ExcelUploadId) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.ChangeField = src.REPORTIDSLIST;
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     -----DELETE FROM STAGING DATA
                     DELETE CalypsoCustlevelNPAMOCDetails_stg

                      WHERE  filname = v_FilePathUpload;

                  END;
                  END IF;

               END;
               END IF;
               ----RETURN @ExcelUploadId
               ----DECLARE @UniqueUploadID INT
               --SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
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
                                                FROM CalypsoCustomerLevelMOC_Mod 
                                                 WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey >= 49999

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')  
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     ROLLBACK;
                     utils.resetTrancount;
                     RETURN v_Result;

                  END;
                  END IF;
                  UPDATE CalypsoCustomerLevelMOC_Mod
                     SET AuthorisationStatus = '1A',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Calypso Customer MOC Upload';

               END;
               END IF;
               --------------------------------------------
               IF ( v_OperationFlag = 20 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

                ----AUTHORIZE
               BEGIN
                  --------------07-07-2021---------------IMPLEMENTED BY PRASHANT WITH DISCUSSION WITH AKSHAY FOR MAKER CHECKER BY PASS POINT ---------------
                  -- IF @UserLoginID= (select UserLoginID from DimUserInfo where  IsChecker2='N' and UserLoginID=@UserLoginID )
                  --   BEGIN
                  --					SET @Result=-1
                  --					ROLLBACK TRAN
                  --					RETURN @Result
                  --	END
                  --ELSE BEGIN
                  --	IF (@UserLoginID =(Select CreatedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
                  --	and EffectiveToTimeKey >= 49999 and CreatedBy = @UserLoginID
                  --	                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                  --					   Group By CreatedBy))
                  --	BEGIN
                  --					SET @Result=-1
                  --					ROLLBACK TRAN
                  --					RETURN @Result
                  --					--select * from AccountFlaggingDetails_Mod
                  --	END
                  --	ELSE
                  --	BEGIN
                  --		IF (@UserLoginID =(Select ApprovedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
                  --		and EffectiveToTimeKey >= 49999 and ApprovedBy = @UserLoginID
                  --	                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                  --					   Group By ApprovedBy))
                  --	BEGIN
                  --					SET @Result=-1
                  --					ROLLBACK TRAN
                  --					RETURN @Result
                  --					--select * from AccountFlaggingDetails_Mod
                  --	END
                  --	ELSE
                  --	BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM CalypsoCustomerLevelMOC_Mod 
                                                 WHERE  AuthorisationStatus IN ( 'NP','MP','1A' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey >= 49999

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')  
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     ROLLBACK;
                     utils.resetTrancount;
                     RETURN v_Result;

                  END;
                  END IF;
                  UPDATE CalypsoCustomerLevelMOC_Mod
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM CalypsoInvMOC_ChangeDetails A
                                            JOIN InvestmentBasicDetail B   ON A.CustomerEntityID = B.IssuerEntityID
                                            AND A.EffectiveFromTimeKey <= v_Timekey
                                            AND A.EffectiveToTimeKey >= v_Timekey
                                            AND B.EffectiveFromTimeKey <= v_Timekey
                                            AND B.EffectiveToTimeKey >= v_Timekey
                                            JOIN CalypsoCustomerLevelMOC_Mod C   ON B.IssuerEntityid = C.CustomerEntityid
                                            AND C.EffectiveFromTimeKey <= v_Timekey
                                            AND C.EffectiveToTimeKey >= v_Timekey
                                            AND NVL(C.AuthorisationStatus, 'A') = 'A'
                                            AND UploadId = v_UniqueUploadID
                                      WHERE  A.EffectiveToTimeKey >= v_Timekey
                                               AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                               AND A.MOCType_Flag = 'CUST'
                                               AND UploadId = v_UniqueUploadID );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                     FROM A ,CalypsoInvMOC_ChangeDetails A
                            JOIN InvestmentBasicDetail B   ON A.CustomerEntityID = B.IssuerEntityID
                            AND A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                            JOIN CalypsoCustomerLevelMOC_Mod C   ON B.IssuerEntityid = C.CustomerEntityID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                            AND NVL(C.AuthorisationStatus, 'A') = 'A'
                            AND UploadId = v_UniqueUploadID 
                      WHERE A.EffectiveToTimeKey >= v_Timekey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.MOCType_Flag = 'CUST'
                       AND UploadId = v_UniqueUploadID) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;

                  END;
                  ELSE

                  BEGIN
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                     FROM A ,CalypsoDervMOC_ChangeDetails A
                            JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.UCICID = B.UCIC_ID
                            AND A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                            JOIN CalypsoCustomerLevelMOC_Mod C   ON B.UCIC_ID = C.UcifID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                            AND NVL(C.AuthorisationStatus, 'A') = 'A'
                            AND UploadId = v_UniqueUploadID 
                      WHERE A.EffectiveToTimeKey >= v_Timekey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.MOCType_Flag = 'CUST'
                       AND UploadId = v_UniqueUploadID) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;

                  END;
                  END IF;
                  --UPDATE  A
                  --SET A.CustomerEntityID=B.IssuerEntityId
                  --from CalypsoCustomerLevelMOC_MOD A
                  --INNER JOIN InvestmenTIssuerDetail B
                  --	ON A.UCIFID=B.UCIfID
                  --		AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
                  --		AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
                  --                        WHERE  A.MOCType_Flag='CUST'
                  --AND UploadId=@UniqueUploadID
                  INSERT INTO CalypsoInvMOC_ChangeDetails
                    ( MOCType_Flag, CustomerEntityID, AssetClassAlt_Key, NPA_Date, CurntQtrRv
                  --,AdditionalProvision
                  , AddlProvPer
                  --,MOC_ExpireDate
                  , MOC_Reason, MOC_Date, MOC_Source, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved, MOCTYPE
                  --,ScreenFlag
                  , MOCProcessed, UCICID )
                    ( SELECT MOCType_Flag ,
                             A.CustomerEntityID ,
                             AssetClassAlt_Key ,
                             NPADate ,
                             SecurityValue ,
                             AdditionalProvision ,
                             --,MOC_ExpireDate
                             MOCReason ,
                             --,A.MOCDate
                             v_MocDate ,
                             MOCSource ,
                             'A' ,
                             v_TimeKey ,
                             49999 ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             ApprovedByFirstLevel ,
                             DateApprovedFirstLevel ,
                             A.ApprovedBy ,
                             SYSDATE ,
                             MOCTYPE ,
                             --,'U'
                             'N' ,
                             A.UcifID 
                      FROM CalypsoCustomerLevelMOC_Mod A
                             JOIN InvestmentIssuerDetail B   ON A.UcifID = B.UCIFID
                             AND a.CustomerID = B.ISSUERID
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_Timekey
                       WHERE  UploadId = v_UniqueUploadID
                                AND A.EffectiveFromTimeKey <= v_Timekey
                                AND A.EffectiveToTimeKey >= v_Timekey
                                AND A.AuthorisationStatus = 'A' );
                  INSERT INTO CalypsoDervMOC_ChangeDetails
                    ( MOCType_Flag, CustomerEntityID, AssetClassAlt_Key, NPA_Date, CurntQtrRv
                  --,AdditionalProvision
                  , AddlProvPer
                  --,MOC_ExpireDate
                  , MOC_Reason, MOC_Date, MOC_Source, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved, MOCTYPE
                  --,ScreenFlag
                  , MOCProcessed, UCICID )
                    ( SELECT MOCType_Flag ,
                             A.CustomerEntityID ,
                             AssetClassAlt_Key ,
                             NPADate ,
                             SecurityValue ,
                             AdditionalProvision ,
                             --,MOC_ExpireDate
                             MOCReason ,
                             --,A.MOCDate
                             v_MocDate ,
                             MOCSource ,
                             'A' ,
                             v_TimeKey ,
                             49999 ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             ApprovedByFirstLevel ,
                             DateApprovedFirstLevel ,
                             A.ApprovedBy ,
                             SYSDATE ,
                             MOCTYPE ,
                             --,'U'
                             'N' ,
                             UCIfID 
                      FROM CalypsoCustomerLevelMOC_Mod A
                             JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.UcifID = B.UCIC_ID
                             AND B.CustomerID = A.CustomerID
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_Timekey
                       WHERE  UploadId = v_UniqueUploadID
                                AND A.EffectiveFromTimeKey <= v_Timekey
                                AND A.EffectiveToTimeKey >= v_Timekey
                                AND A.AuthorisationStatus = 'A' );
                  /*--------------------Adding Flag To AdvAcOtherDetail------------Sudesh 03-06-2021--------*/
                  --IF OBJECT_ID('TempDB..#IBPCNew') Is Not NUll
                  --Drop Table #IBPCNew
                  --Select A.RefUCICID,A.SplFlag 
                  --into #IBPCNew                             --DBO.AdvAcOtherDetail
                  --FROM dbo.advcustotherdetail A               
                  --     INNER JOIN CalypsoCustomerLevelMOC_MOD B 
                  --	 ON A.RefUCICID=B.UCICID
                  --			WHERE  B.UploadId=@UniqueUploadID 
                  --			and B.EffectiveToTimeKey>=@Timekey
                  --			AND A.EffectiveToTimeKey=49999 
                  --			And A.SplFlag Like '%IBPC%'
                  -- UPDATE A
                  --SET  
                  --       A.SplFlag=	CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
                  --				ELSE A.SplFlag+','+'IBPC' END
                  -- FROM	dbo.advcustotherdetail A
                  --  --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
                  -- INNER JOIN IBPCPoolDetail_MOD B ON A.RefUCICID=B.UCICID
                  --		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
                  --		AND A.EffectiveToTimeKey=49999
                  --		AND Not Exists (Select 1 from #IBPCNew N Where N.RefUCICID=A.RefUCICID)
                  -------------------------------------------
                  --UPDATE A
                  --SET 
                  --A.POSinRs=ROUND(B.POSinRs,2)
                  --,a.ModifyBy=@UserLoginID
                  --,a.DateModified=GETDATE()
                  --FROM CustomerLevelMOC A
                  --INNER JOIN CalypsoCustomerLevelMOC_MOD  B 
                  --ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
                  --AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
                  --AND A.UCICID=B.UCICID
                  --	WHERE B.AuthorisationStatus='A'
                  --	AND B.UploadId=@UniqueUploadID
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Calypso Customer MOC Upload';

               END;
               END IF;
               --				END
               --END
               --	END
               IF ( v_OperationFlag = 17 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

                ----REJECT
               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM CalypsoCustomerLevelMOC_Mod 
                                                 WHERE  UploadId = v_UniqueUploadID
                                                  GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     RETURN v_Result;

                  END;
                  ELSE

                  BEGIN
                     UPDATE CalypsoCustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            EffectiveToTimeKey = v_Timekey - 1,
                            ApprovedByFirstLevel = v_UserLoginID,
                            DateApprovedFirstLevel = SYSDATE
                      WHERE  UploadId = v_UniqueUploadID
                       AND AuthorisationStatus = 'NP';
                     UPDATE ExcelUploadHistory
                        SET AuthorisationStatus = 'R',
                            EffectiveToTimeKey = v_Timekey - 1,
                            ApprovedBy = v_UserLoginID,
                            DateApproved = SYSDATE
                      WHERE  EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey
                       AND UniqueUploadID = v_UniqueUploadID
                       AND UploadType = 'Calypso Customer MOC Upload';

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
                     v_Result := -1 ;
                     ROLLBACK;
                     utils.resetTrancount;
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
                                                   FROM CalypsoCustomerLevelMOC_Mod 
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
                        v_Result := -1 ;
                        ROLLBACK;
                        utils.resetTrancount;
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
                                                      FROM CalypsoCustomerLevelMOC_Mod 
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
                           v_Result := -1 ;
                           ROLLBACK;
                           utils.resetTrancount;
                           RETURN v_Result;

                        END;

                        --select * from AccountFlaggingDetails_Mod
                        ELSE

                        BEGIN
                           UPDATE CalypsoCustomerLevelMOC_Mod
                              SET AuthorisationStatus = 'R',
                                  EffectiveToTimeKey = v_Timekey - 1,
                                  ApprovedBy = v_UserLoginID,
                                  DateApproved = SYSDATE
                            WHERE  UploadId = v_UniqueUploadID
                             AND AuthorisationStatus IN ( 'NP','1A' )
                           ;
                           UPDATE ExcelUploadHistory
                              SET AuthorisationStatus = 'R',
                                  EffectiveToTimeKey = v_Timekey - 1,
                                  ApprovedBy = v_UserLoginID,
                                  DateApproved = SYSDATE
                            WHERE  EffectiveFromTimeKey <= v_Timekey
                             AND EffectiveToTimeKey >= v_Timekey
                             AND UniqueUploadID = v_UniqueUploadID
                             AND UploadType = 'Calypso Customer MOC Upload';

                        END;
                        END IF;

                     END;
                     END IF;
                     IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_DateCreated DATE;
                        v_ReferenceID1 VARCHAR2(4000);

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('log table');
                        v_DateCreated := SYSDATE ;
                        v_ReferenceID1 := (CASE 
                                                WHEN v_OperationFlag IN ( 16,20,21 )
                                                 THEN v_UniqueUploadID
                        ELSE v_ExcelUploadId
                           END) ;
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

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;
            --COMMIT TRAN
            ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
            v_Result := CASE 
                             WHEN v_OperationFlag = 1
                               AND v_MenuId = 27766 THEN v_ExcelUploadId
            ELSE 1
               END ;
            UPDATE UploadStatus
               SET InsertionOfData = 'Y',
                   InsertionCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;
            ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
            ----BEGIN
            ----	 DELETE FROM IBPCPoolDetail_stg
            ----	 WHERE filEname=@FilePathUpload
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTNPAMOCSTAGEDATAINUP_24012024" TO "ADF_CDR_RBL_STGDB";
