--------------------------------------------------------
--  DDL for Function BUYOUTSTAGEUPLOADDATAINUPNEW_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" 
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
--DECLARE @Timekey INT=24928,  
-- @UserLoginID VARCHAR(100)='FNAOPERATOR',  
-- @OperationFlag INT=1,  
-- @MenuId INT=163,  
-- @AuthMode CHAR(1)='N',  
-- @filepath VARCHAR(MAX)='',  
-- @EffectiveFromTimeKey INT=24928,  
-- @EffectiveToTimeKey INT=49999,  
--    @Result  INT=0 ,  
-- @UniqueUploadID INT=41  

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --DECLARE @Timekey INT  
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle  
   -- WHERE ProcessType='Quarterly')  
   SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

     INTO v_Timekey
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN  
         IF ( v_MenuId = 1466 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM BuyoutUploadDetails_stg 
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
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM BuyoutUploadDetails_stg 
                                   WHERE  filname = v_FilePathUpload );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN
                DECLARE
                  --PRINT @@ROWCOUNT  
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
                             'Buyout Upload' ,
                             v_EffectiveFromTimeKey ,
                             v_EffectiveToTimeKey ,
                             v_UserLoginID ,
                             SYSDATE 
                        FROM DUAL  );
                  SELECT MAX(UniqueUploadID)  

                    INTO v_ExcelUploadId
                    FROM ExcelUploadHistory ;
                  INSERT INTO UploadStatus
                    ( FileNames, UploadedBy, UploadDateTime, UploadType )
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Buyout Upload' );
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  INSERT INTO BuyoutUploadDetails_Mod
                    ( SlNo, UploadID, DateofData, ReportDate, CustomerAcID, SchemeCode, NPA_ClassSeller, NPA_DateSeller, DPD_Seller, PeakDPD, PeakDPD_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT SlNo ,
                             v_ExcelUploadId ,
                             NULL ,
                             --,Case When ISNULL(ReportDate,'')<>'' Then Convert(Date,ReportDate) Else NULL END DateofData  
                             CASE 
                                  WHEN NVL(ReportDate, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(ReportDate,200)
                             ELSE NULL
                                END ReportDate  ,
                             AccountNo ,
                             SchemeCode ,
                             CASE 
                                  WHEN NVL(NPAClassificationwithSeller, ' ') <> ' ' THEN NPAClassificationwithSeller
                             ELSE NULL
                                END NPAClassificationwithSeller  ,
                             CASE 
                                  WHEN NVL(DateofNPAwithSeller, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(DateofNPAwithSeller,200)
                             ELSE NULL
                                END NPA_DateSeller  ,
                             DPDwithSeller ,
                             CASE 
                                  WHEN NVL(PeakDPDwithSeller, ' ') <> ' ' THEN PeakDPDwithSeller
                             ELSE NULL
                                END PeakDPDwithSeller  ,
                             CASE 
                                  WHEN NVL(PeakDPDDate, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(PeakDPDDate,200)
                             ELSE NULL
                                END PeakDPD_Date  ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM BuyoutUploadDetails_stg 
                       WHERE  filname = v_FilePathUpload );
                  --INSERT INTO IBPCPoolSummary_Mod  
                  --(  
                  -- UploadID  
                  -- ,SummaryID  
                  -- ,PoolID  
                  -- ,PoolName  
                  -- ,BalanceOutstanding  
                  -- ,NoOfAccount  
                  -- ,AuthorisationStatus   
                  -- ,EffectiveFromTimeKey   
                  -- ,EffectiveToTimeKey   
                  -- ,CreatedBy   
                  -- ,DateCreated   
                  --)  
                  --SELECT  
                  -- @ExcelUploadId  
                  -- ,@SummaryId+Row_Number() over(Order by PoolID)  
                  -- ,PoolID  
                  -- ,PoolName  
                  -- ,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))  
                  -- ,Count(PoolID)  
                  -- ,'NP'   
                  -- ,@Timekey  
                  -- ,49999   
                  -- ,@UserLoginID   
                  -- ,GETDATE()  
                  --FROM IBPCPoolDetail_stg  
                  --where FilName=@FilePathUpload  
                  --Group by PoolID,PoolName  
                  ---------------------------------------------------------ChangeField Logic---------------------  
                  ----select * from AccountLvlMOCDetails_stg  
                  IF utils.object_id('TempDB..tt_Buyout_Upload_7') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Buyout_Upload_7 ';
                  END IF;
                  DELETE FROM tt_Buyout_Upload_7;
                  INSERT INTO tt_Buyout_Upload_7
                    ( AccountNo, FieldName )
                    ( 
                      -- Select SummaryID, 'AUNo' FieldName from BuyoutUploadDetails_stg Where isnull(AUNo,'')<>''   

                      --UNION ALL  

                      --Select AccountNo, 'DateofData' FieldName from BuyoutUploadDetails_stg Where isnull(DateofData,'')<>''   

                      --UNION ALL  
                      SELECT AccountNo ,
                             'ReportDate' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(ReportDate, ' ') <> ' '
                      UNION 
                      SELECT AccountNo ,
                             'SchemeCode' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(SchemeCode, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNo ,
                             'NPAClassificationwithSeller' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(NPAClassificationwithSeller, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNo ,
                             'DateofNPAwithSeller' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(DateofNPAwithSeller, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNo ,
                             'DPDwithSeller' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(DPDwithSeller, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNo ,
                             'PeakDPDwithSeller' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(PeakDPDwithSeller, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNo ,
                             'PeakDPDDate' FieldName  
                      FROM BuyoutUploadDetails_stg 
                       WHERE  NVL(PeakDPDDate, ' ') <> ' ' );
                  DBMS_OUTPUT.PUT_LINE('nanda3');
                  --select *  
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                  FROM B ,MetaScreenFieldDetail A
                         JOIN tt_Buyout_Upload_7 B   ON A.CtrlName = B.FieldName 
                   WHERE A.MenuId = v_MenuId
                    AND A.IsVisible = 'Y') src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                  DBMS_OUTPUT.PUT_LINE('nanda4');
                  IF utils.object_id('TEMPDB..tt_NEWTRANCHE_37') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_37 ';
                  END IF;
                  DELETE FROM tt_NEWTRANCHE_37;
                  UTILS.IDENTITY_RESET('tt_NEWTRANCHE_37');

                  INSERT INTO tt_NEWTRANCHE_37 SELECT * 
                       FROM ( SELECT ss.AccountNo ,
                                     utils.stuff(( SELECT ',' || US.SrNo 
                                                   FROM tt_Buyout_Upload_7 US
                                                    WHERE  US.AccountNo = ss.AccountNo ), 1, 1, ' ') REPORTIDSLIST  
                              FROM BuyoutUploadDetails_stg SS
                                GROUP BY ss.AccountNo ) B
                       ORDER BY 1;
                  --Select * from tt_NEWTRANCHE_37  
                  --SELECT *   
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                  FROM A ,RBL_MISDB_PROD.BuyoutUploadDetails_Mod A
                         JOIN tt_NEWTRANCHE_37 B   ON A.CustomerAcID = B.AccountNo 
                   WHERE A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND A.UploadID = v_ExcelUploadId) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.ChangeFields = src.REPORTIDSLIST;
                  ---DELETE FROM STAGING DATA  
                  DELETE BuyoutUploadDetails_stg

                   WHERE  filname = v_FilePathUpload;

               END;
               END IF;

            END;
            END IF;
            ----RETURN @ExcelUploadId  
            ----DECLARE @UniqueUploadID INT  
            --SET  @UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)  
            ----------------------Two level Auth. Changes-------------  
            IF ( v_OperationFlag = 16 ) THEN

             ----AUTHORIZE  
            BEGIN
               UPDATE BuyoutUploadDetails_Mod
                  SET AuthorisationStatus = '1A',
                      ApprovedByFirstLevel = v_UserLoginID,
                      DateApprovedFirstLevel = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A',
                      ApprovedByFirstLevel = v_UserLoginID,
                      DateApprovedFirstLevel = SYSDATE
                WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Buyout Upload';

            END;
            END IF;
            --------------------------------------------  
            IF ( v_OperationFlag = 20 ) THEN

             ----AUTHORIZE  
            BEGIN
               UPDATE BuyoutUploadDetails_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               MERGE INTO B 
               USING (SELECT B.ROWID row_id, v_timekey - 1 AS EffectiveToTimeKey
               FROM B ,BuyoutUploadDetails_Mod A
                      JOIN BuyoutUploadDetails B   ON A.CustomerAcID = B.CustomerAcID
                      AND B.EffectiveFromTimeKey <= v_timekey
                      AND B.EffectiveToTimeKey >= v_Timekey 
                WHERE A.UploadID = v_UniqueUploadID) src
               ON ( B.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
               INSERT INTO BuyoutUploadDetails
                 ( SlNo, DateofData, ReportDate, CustomerAcID, SchemeCode, NPA_ClassSeller, NPA_DateSeller, DPD_Seller, PeakDPD, PeakDPD_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ApprovedBy, DateApproved )
                 ( SELECT SlNo ,
                          NULL ,
                          CASE 
                               WHEN NVL(ReportDate, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(ReportDate,200)
                          ELSE NULL
                             END ReportDate  ,
                          CustomerAcID ,
                          SchemeCode ,
                          NPA_ClassSeller ,
                          CASE 
                               WHEN NVL(NPA_DateSeller, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateSeller,200)
                          ELSE NULL
                             END NPA_DateSeller  ,
                          DPD_Seller ,
                          PeakDPD ,
                          CASE 
                               WHEN NVL(PeakDPD_Date, ' ') <> ' ' THEN UTILS.CONVERT_TO_VARCHAR2(PeakDPD_Date,200)
                          ELSE NULL
                             END PeakDPD_Date  ,
                          'A' ,
                          v_Timekey ,
                          49999 ,
                          CreatedBy ,
                          DateCreated ,
                          v_UserLoginID ,
                          SYSDATE 
                   FROM BuyoutUploadDetails_Mod A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND A.EffectiveToTimeKey >= v_Timekey );
               --Case When ISNULL(NPA_ClassSeller,'') IN('','NULL') then NULL When ISNULL(NPA_ClassSeller,'')<>'' Then NPA_ClassSeller Else NULL END  
               ---------------------------------------------  
               /*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Buyout Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT  
            BEGIN
               UPDATE BuyoutUploadDetails_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedByFirstLevel = v_UserLoginID,
                      DateApprovedFirstLevel = SYSDATE,
                      EffectiveToTimeKey = EffectiveFromTimeKey - 1
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               ----SELECT * FROM IBPCPoolDetail  
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedByFirstLevel = v_UserLoginID,
                      DateApprovedFirstLevel = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Buyout Upload';

            END;
            END IF;
            --------------------Two level Auth. Changes---------------  
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT  
            BEGIN
               UPDATE BuyoutUploadDetails_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE,
                      EffectiveToTimeKey = EffectiveFromTimeKey - 1
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               ----SELECT * FROM IBPCPoolDetail  
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Buyout Upload';

            END;
            END IF;

         END;
         END IF;
         ---------------------------------------------------------------------  
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
         --COMMIT TRAN  
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END  
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 1466 THEN v_ExcelUploadId
         ELSE 1
            END ;
         UPDATE UploadStatus
            SET InsertionOfData = 'Y',
                InsertionCompletedOn = SYSDATE
          WHERE  FileNames = v_filepath;
         ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)  
         ----BEGIN  
         ----  DELETE FROM IBPCPoolDetail_stg  
         ----  WHERE filEname=@FilePathUpload  
         ----  PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTSTAGEUPLOADDATAINUPNEW_04122023" TO "ADF_CDR_RBL_STGDB";
