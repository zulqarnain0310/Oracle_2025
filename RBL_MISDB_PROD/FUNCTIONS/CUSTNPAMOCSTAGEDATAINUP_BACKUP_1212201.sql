--------------------------------------------------------
--  DDL for Function CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" /*
declare @p11 int
set @p11=-1
exec [dbo].[CustNPAMOCStageDataInUp] @Authlevel=N'2',@TimeKey=25999,@UserLoginID=N'test_two',@OperationFlag=N'1',@MenuId=N'128',@AuthMode=N'Y',@filepath=N'CustlevelNPAMOCUpload.xlsx',@EffectiveFromTimeKey=25999,@EffectiveToTimeKey=49999,@UniqueUploadID=NU


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
   v_FilePathUpload VARCHAR2(100);
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=25999,
--	@UserLoginID VARCHAR(100)='test_two',
--	@OperationFlag INT=1,
--	@MenuId INT=128,
--	@AuthMode	CHAR(1)='Y',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41

BEGIN

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
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := v_TimeKey ;
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN
         IF ( v_MenuId = 128 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT * 
                                        FROM CustlevelNPAMOCDetails_stg 
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
                                  FROM CustlevelNPAMOCDetails_stg 
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
                             'Customer MOC Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Customer MOC Upload' );
                  DBMS_OUTPUT.PUT_LINE('Sachin111');
                  DBMS_OUTPUT.PUT_LINE('@ExcelUploadId');
                  DBMS_OUTPUT.PUT_LINE(v_ExcelUploadId);
                  /*TODO:SQLDEV*/ SET dateformat DMY /*END:SQLDEV*/
                  --Alter Table CustomerLevelMOC_MOD
                  --add ChangeField Varchar(100)
                  INSERT INTO CustomerLevelMOC_Mod
                    ( SrNo, UploadID
                  --,SummaryID
                   --,SlNo
                  , CustomerID, AssetClass, AssetClassAlt_Key, NPADate, SecurityValue, AdditionalProvision, MOCSource, MOCSourceAltkey, MOCType, MOCTypeAlt_Key, MOCReason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ScreenFlag, ChangeField )
                    ( SELECT SlNo ,
                             v_ExcelUploadId ,
                             --,SummaryID
                             --,SlNo
                             CustomerID ,
                             AssetClass ,
                             B.AssetClassAlt_Key ,
                             CASE 
                                  WHEN NPADate <> ' '
                                    AND utils.isdate(NPADate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(NPADate,200)
                             ELSE NULL
                                END NPADate  ,
                             NVL(CASE 
                                      WHEN NVL(SecurityValue, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(SecurityValue,10,0), 0),30,2)   END, 0) SecurityValue  ,
                             NVL(CASE 
                                      WHEN NVL(AdditionalProvision, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(AdditionalProvision,10,0), 0),30,2)   END, 0) AdditionalProvision  ,
                             MOCSource ,
                             E.MOCTypeAlt_Key ,
                             MOCType ,
                             C.ParameterAlt_Key ,
                             MOCReason ,
                             'NP' ,
                             v_Timekey ,
                             v_TimeKey ,
                             v_UserLoginID ,
                             SYSDATE ,
                             'U' ,
                             NULL 

                      --select * from pro.AccountCal_Hist

                      --select * from MetaScreenFieldDetail   where menuid=128

                      --select * from MetaScreenFieldDetail   where menuid=126
                      FROM CustlevelNPAMOCDetails_stg A
                             LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'MOCType' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'MOCType'
                                                   AND EffectiveFromTimeKey <= v_Timekey
                                                   AND EffectiveToTimeKey >= v_Timekey ) C   ON TRIM(A.MOCType) = TRIM(C.ParameterName)
                             LEFT JOIN ( SELECT MOCTypeAlt_Key ,
                                                MOCTypeName ,
                                                'MOCSource' TableName  
                                         FROM DimMOCType 
                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                   AND EffectiveToTimeKey >= v_Timekey ) E   ON A.MOCSource = E.MOCTypeName
                       WHERE  filname = v_FilePathUpload );
                  DBMS_OUTPUT.PUT_LINE('Sachin123');
                  IF utils.object_id('TempDB..tt_CustMocUpload_12') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustMocUpload_12 ';
                  END IF;
                  DELETE FROM tt_CustMocUpload_12;
                  INSERT INTO tt_CustMocUpload_12
                    ( CustomerID, FieldName )
                    ( SELECT CustomerID ,
                             'AssetClass' FieldName  
                      FROM CustlevelNPAMOCDetails_stg 
                       WHERE  NVL(AssetClass, ' ') <> ' '
                      UNION 
                      SELECT CustomerID ,
                             'NPADate' FieldName  
                      FROM CustlevelNPAMOCDetails_stg 
                       WHERE  NVL(NPADate, ' ') <> ' '
                      UNION ALL 
                      SELECT CustomerID ,
                             'SecurityValue' FieldName  
                      FROM CustlevelNPAMOCDetails_stg 
                       WHERE  NVL(SecurityValue, ' ') <> ' ' --SecurityValue Is not NULL

                      UNION ALL 
                      SELECT CustomerID ,
                             'AdditionalProvision' FieldName  
                      FROM CustlevelNPAMOCDetails_stg 
                       WHERE  NVL(AdditionalProvision, ' ') <> ' ' );--AdditionalProvision Is not NULL
                  --select * 
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                  FROM B ,MetaScreenFieldDetail A
                         JOIN tt_CustMocUpload_12 B   ON A.CtrlName = B.FieldName 
                   WHERE A.MenuId = 128
                    AND A.IsVisible = 'Y') src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                  ----	-------------------
                  ----	select * from tt_CustMocUpload_12
                  ----	select CtrlName,* from MetaScreenFieldDetail A Where A.MenuId=128 And A.IsVisible='Y'
                  ----	update MetaScreenFieldDetail 
                  ----	set CtrlName='AdditionalProvision'
                  ----	 Where MenuId=128 And IsVisible='Y' and entityKey=1406
                  ----	 Asset Class
                  ----NPA Date
                  ----Security Value
                  ----Additional Provision %
                  ------select * into MetaScreenFieldDetail_21062021  from MetaScreenFieldDetail
                  ----select * from MetaScreenFieldDetail_21062021 where menuid=128
                  ----select * from MetaScreenFieldDetail where menuid=128
                  ---------------------
                  IF utils.object_id('TEMPDB..tt_NEWTRANCHE_59') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_59 ';
                  END IF;
                  DELETE FROM tt_NEWTRANCHE_59;
                  UTILS.IDENTITY_RESET('tt_NEWTRANCHE_59');

                  INSERT INTO tt_NEWTRANCHE_59 SELECT * 
                       FROM ( SELECT ss.CustomerID ,
                                     utils.stuff(( SELECT ',' || US.SrNo 
                                                   FROM tt_CustMocUpload_12 US
                                                    WHERE  US.CustomerID = ss.CustomerID ), 1, 1, ' ') REPORTIDSLIST  
                              FROM CustlevelNPAMOCDetails_stg SS
                                GROUP BY ss.CustomerID ) B
                       ORDER BY 1;
                  --Select * from tt_NEWTRANCHE_59
                  --SELECT * 
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                  FROM A ,RBL_MISDB_PROD.CustomerLevelMOC_Mod A
                         JOIN tt_NEWTRANCHE_59 B   ON A.CustomerID = B.CustomerID 
                   WHERE A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND A.UploadID = v_ExcelUploadId) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.ChangeField = src.REPORTIDSLIST;
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  ---DELETE FROM STAGING DATA
                  DELETE CustlevelNPAMOCDetails_stg

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

             ----AUTHORIZE
            BEGIN
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID
                WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Customer MOC Upload';

            END;
            END IF;
            --------------------------------------------
            IF ( v_OperationFlag = 20 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               -----maintain history
               --Update  A
               --Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
               --from dbo.CustomerLevelMOC A
               --inner join CustomerLevelMOC_Mod B
               --ON A.CustomerId=B.CustomerId
               --AND B.EffectiveFromTimeKey <=@Timekey
               --AND B.EffectiveToTimeKey >=@Timekey
               --Where B.UploadId=@UniqueUploadID
               --AND A.EffectiveToTimeKey >=49999
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_CUSTOMER_CAL_2  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_CUSTOMER_CAL_2;
               UTILS.IDENTITY_RESET('tt_CUSTOMER_CAL_2');

               INSERT INTO tt_CUSTOMER_CAL_2 ( 
               	SELECT A.* 
               	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                         JOIN CustomerLevelMOC_Mod B   ON A.RefCustomerID = B.CustomerID
               	 WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey ) );
               --Select 'tt_CUSTOMER_CAL_2',* from tt_CUSTOMER_CAL_2
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
               FROM A ,PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                      JOIN CustomerLevelMOC_Mod B   ON A.RefCustomerID = B.CustomerID 
                WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
                 AND A.EffectiveFromTimeKey < v_TImeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               --declare @MocTypeDesc varchar(20)
               ----select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
               ---- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
               --                   select @MocTypeDesc =ParameterName from dimparameter 
               --                  where Dimparametername= 'MocType' 
               --                                    and ParameterAlt_Key=@MocTypeAlt_Key
               --    AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN C.AssetClassAlt_Key IS NULL THEN NULL
               ELSE c.AssetClassAlt_Key
                  END AS pos_2, CASE 
               WHEN B.NPADate IS NULL THEN NULL
               ELSE B.NPADate
                  END AS pos_3, CASE 
               WHEN B.SecurityValue IS NULL THEN NULL
               ELSE B.SecurityValue
                  END AS pos_4, CASE 
               WHEN AdditionalProvision IS NULL THEN AddlProvisionPer
               ELSE AdditionalProvision
                  END AS pos_5, 'Y', B.MOCReason, B.MOCType, SYSDATE, 'U', B.ChangeField
               FROM A ,PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                      JOIN CustomerLevelMOC_Mod B   ON A.RefCustomerID = B.CustomerID
                      LEFT JOIN DimAssetClass C   ON B.AssetClass = C.AssetClassName 
                WHERE A.EffectiveFromTimeKey = v_TimeKey
                 AND A.EffectiveToTimeKey = v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = pos_2,
                                            a.SysNPA_Dt = pos_3,
                                            a.CurntQtrRv = pos_4,
                                            a.AddlProvisionPer = pos_5,
                                            A.FlgMoc = 'Y',
                                            a.MOCReason = src.MOCReason,
                                            a.MOCTYPE = src.MOCType,
                                            a.MOC_Dt = SYSDATE,
                                            A.ScreenFlag = 'U',
                                            A.ChangeFld = src.ChangeField;
               INSERT INTO PRO_RBL_MISDB_PROD.CustomerCal_Hist
                 ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ScreenFlag, ChangeFld )
                 ( SELECT BranchCode ,
                          UCIF_ID ,
                          UcifEntityID ,
                          A.CustomerEntityID ,
                          ParentCustomerID ,
                          RefCustomerID ,
                          SourceSystemCustomerID ,
                          A.CustomerName ,
                          CustSegmentCode ,
                          ConstitutionAlt_Key ,
                          PANNO ,
                          AadharCardNO ,
                          SrcAssetClassAlt_Key ,
                          CASE 
                               WHEN C.AssetClassAlt_Key IS NULL THEN NULL
                          ELSE C.AssetClassAlt_Key
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
                               WHEN B.SecurityValue IS NULL THEN NULL
                          ELSE B.SecurityValue
                             END col  ,
                          --,@SecurityValue CurntQtrRv
                          TotProvision ,
                          BankTotProvision ,
                          RBITotProvision ,
                          SrcNPA_Dt ,
                          CASE 
                               WHEN B.NPADate IS NULL THEN NULL
                          ELSE B.NPADate
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
                          B.MOCReason ,
                          CASE 
                               WHEN B.AdditionalProvision IS NULL THEN AddlProvisionPer
                          ELSE B.AdditionalProvision
                             END col  ,
                          --	,@AdditionalProvision AddlProvisionPer
                          FraudDt ,
                          FraudAmount ,
                          DegReason ,
                          CustMoveDescription ,
                          TotOsCust ,
                          B.MOCType ,
                          'U' ,
                          B.ChangeField 
                   FROM tt_CUSTOMER_CAL_2 A
                          JOIN CustomerLevelMOC_Mod B   ON A.RefCustomerID = B.CustomerID
                          LEFT JOIN DimAssetClass C   ON B.AssetClass = C.AssetClassName
                    WHERE  ( A.EffectiveToTimeKey > v_TimeKey )
                             OR ( A.EffectiveFromTimeKey < v_TimeKey
                             AND A.EffectiveToTimeKey = v_TimeKey ) );
               INSERT INTO PRO_RBL_MISDB_PROD.CustomerCal_Hist
                 ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ScreenFlag, ChangeFld )
                 ( SELECT BranchCode ,
                          UCIF_ID ,
                          UcifEntityID ,
                          A.CustomerEntityID ,
                          ParentCustomerID ,
                          RefCustomerID ,
                          SourceSystemCustomerID ,
                          A.CustomerName ,
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
                          A.EffectiveToTimeKey ,
                          CommonMocTypeAlt_Key ,
                          InMonthMark ,
                          MocStatusMark ,
                          SourceAlt_Key ,
                          BankAssetClass ,
                          Cust_Expo ,
                          A.MOCReason ,
                          AddlProvisionPer ,
                          FraudDt ,
                          FraudAmount ,
                          DegReason ,
                          CustMoveDescription ,
                          TotOsCust ,
                          A.MOCTYPE ,
                          'U' ,
                          B.ChangeField 
                   FROM tt_CUSTOMER_CAL_2 A
                          JOIN CustomerLevelMOC_Mod B   ON A.RefCustomerID = B.CustomerID
                    WHERE  A.EffectiveToTimeKey > v_TimeKey );
               ---pre moc
               INSERT INTO PreMoc_RBL_MISDB_PROD.CUSTOMERCAL
                 ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ScreenFlag, SourceSystemAlt_key )
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
                          A.MOCTYPE ,
                          'U' ,
                          B.SourceSystemAlt_key 
                   FROM tt_CUSTOMER_CAL_2 A
                          JOIN CustomerLevelMOC_Mod C   ON A.RefCustomerID = C.CustomerID
                          LEFT JOIN PreMoc_RBL_MISDB_PROD.CUSTOMERCAL B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                          AND B.EffectiveFromTimeKey = v_TimeKey
                          AND B.EffectiveToTimeKey = v_TimeKey )
                          AND A.RefCustomerID = B.RefCustomerID
                    WHERE  b.RefCustomerID IS NULL );
               /*--------------------Adding Flag To AdvAcOtherDetail------------Sudesh 03-06-2021--------*/
               --IF OBJECT_ID('TempDB..#IBPCNew') Is Not NUll
               --Drop Table #IBPCNew
               --Select A.RefCustomerId,A.SplFlag 
               --into #IBPCNew                             --DBO.AdvAcOtherDetail
               --FROM dbo.advcustotherdetail A               
               --     INNER JOIN CustomerLevelMOC_MOD B 
               --	 ON A.RefCustomerId=B.CustomerID
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
               -- INNER JOIN IBPCPoolDetail_MOD B ON A.RefCustomerId=B.CustomerID
               --		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
               --		AND A.EffectiveToTimeKey=49999
               --		AND Not Exists (Select 1 from #IBPCNew N Where N.RefCustomerId=A.RefCustomerId)
               -------------------------------------------
               --UPDATE A
               --SET 
               --A.POSinRs=ROUND(B.POSinRs,2)
               --,a.ModifyBy=@UserLoginID
               --,a.DateModified=GETDATE()
               --FROM CustomerLevelMOC A
               --INNER JOIN CustomerLevelMOC_MOD  B 
               --ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
               --AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
               --AND A.CustomerId=B.CustomerId
               --	WHERE B.AuthorisationStatus='A'
               --	AND B.UploadId=@UniqueUploadID
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Customer MOC Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT
            BEGIN
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Customer MOC Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT
            BEGIN
               UPDATE CustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Customer MOC Upload';

            END;
            END IF;

         END;
         END IF;
         --COMMIT TRAN
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 128 THEN v_ExcelUploadId
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTNPAMOCSTAGEDATAINUP_BACKUP_1212201" TO "ADF_CDR_RBL_STGDB";
