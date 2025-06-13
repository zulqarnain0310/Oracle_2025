--------------------------------------------------------
--  DDL for Procedure WRITEOFF_CHARGEOFF_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" 
--USE [RBL_MISDB]

(
  iv_DATE IN VARCHAR2 DEFAULT NULL 
)
AS
   v_DATE VARCHAR2(200) := iv_DATE;
   --======================================================================================================
   -- CREATED BY : MANDEEP SINGH
   -- DATE       : 07-03-2024
   -- PURPOSE    : To track WriteOff_ChargeOff monthly data 
   -- EXEC       : WriteOff_ChargeOff_Report   'date'
   --======================================================================================================
   v_TIMEKEY NUMBER(10,0);
   v_EFFECTIVEFROMDATE VARCHAR2(200) := ( SELECT MonthStartDate 
     FROM Automate_Advances 
    WHERE  timekey = v_TIMEKEY );
   v_EFFECTIVETODATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  timekey = v_TIMEKEY );
   v_FROM NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM Automate_Advances 
    WHERE  DATE_ = v_EFFECTIVEFROMDATE );
   v_TO NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM Automate_Advances 
    WHERE  DATE_ = v_EFFECTIVETODATE );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF v_DATE IS NULL THEN
    SELECT DATE_ 

     INTO v_DATE
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   END IF;
   SELECT TIMEKEY 

     INTO v_TIMEKEY
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  DATE_ = v_DATE;
   --select @EFFECTIVEFROMDATE,@FROM,@EFFECTIVETODATE,@TO
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_WRITEOFF_ACCOUNTS_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_WRITEOFF_ACCOUNTS_2;
   UTILS.IDENTITY_RESET('tt_WRITEOFF_ACCOUNTS_2');

   INSERT INTO tt_WRITEOFF_ACCOUNTS_2 SELECT ACID CUSTOMERACID  ,
                                             A.EffectiveFromTimeKey ,
                                             A.EffectiveToTimeKey ,
                                             A.StatusType ,
                                             A.Amount ,
                                             A.StatusDate ,
                                             ROW_NUMBER() OVER ( PARTITION BY A.ACID ORDER BY A.EffectiveFromTimeKey DESC  ) RN  
        FROM RBL_MISDB_PROD.ExceptionFinalStatusType A
       WHERE  ( A.StatusDate BETWEEN v_EFFECTIVEFROMDATE AND v_EFFECTIVETODATE )
                AND A.StatusType IN ( 'WO','Charge Off' )
   ;
   DELETE tt_WRITEOFF_ACCOUNTS_2

    WHERE  RN > 1;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ADVACBASICDETAIL_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_ADVACBASICDETAIL_2;
   UTILS.IDENTITY_RESET('tt_ADVACBASICDETAIL_2');

   INSERT INTO tt_ADVACBASICDETAIL_2 SELECT A.* ,
                                            ROW_NUMBER() OVER ( PARTITION BY A.CUSTOMERACID ORDER BY A.EffectiveFromTimeKey DESC  ) RN  
        FROM RBL_MISDB_PROD.AdvAcBasicDetail A
               JOIN tt_WRITEOFF_ACCOUNTS_2 B   ON A.CustomerACID = B.CUSTOMERACID
       WHERE  A.EffectiveToTimeKey >= v_FROM
                AND A.EffectiveFromTimeKey <= v_TO;
   DELETE tt_ADVACBASICDETAIL_2

    WHERE  RN > 1;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_AdvAcBalanceDetail_18  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_AdvAcBalanceDetail_18;
   UTILS.IDENTITY_RESET('tt_AdvAcBalanceDetail_18');

   INSERT INTO tt_AdvAcBalanceDetail_18 SELECT A.* ,
                                               ROW_NUMBER() OVER ( PARTITION BY A.REFSYSTEMACID ORDER BY A.EffectiveFromTimeKey DESC  ) RN  
        FROM RBL_MISDB_PROD.AdvAcBalanceDetail A
               JOIN tt_WRITEOFF_ACCOUNTS_2 B   ON A.REFSYSTEMACID = B.CUSTOMERACID
       WHERE  A.EffectiveToTimeKey >= v_FROM
                AND A.EffectiveFromTimeKey <= v_TO;
   DELETE tt_AdvAcBalanceDetail_18

    WHERE  RN > 1;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CustomerBasicDetail_12  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CustomerBasicDetail_12;
   UTILS.IDENTITY_RESET('tt_CustomerBasicDetail_12');

   INSERT INTO tt_CustomerBasicDetail_12 SELECT A.* ,
                                                ROW_NUMBER() OVER ( PARTITION BY b.CustomerACID ORDER BY A.EffectiveFromTimeKey DESC  ) RN  
        FROM RBL_MISDB_PROD.CustomerBasicDetail A
               JOIN tt_ADVACBASICDETAIL_2 B   ON A.CustomerId = B.RefCustomerId
       WHERE  A.EffectiveToTimeKey >= v_FROM
                AND A.EffectiveFromTimeKey <= v_TO;
   DELETE tt_CustomerBasicDetail_12

    WHERE  RN > 1;
   -- at the time of write-off ---------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CALCUALTEInitialBalance_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CALCUALTEInitialBalance_2;
   UTILS.IDENTITY_RESET('tt_CALCUALTEInitialBalance_2');

   INSERT INTO tt_CALCUALTEInitialBalance_2 ( 
   	SELECT A.CUSTOMERACID ,
           A.StatusDate ,
           B.Timekey - 1 TIMEKEY  ,
           B.Timekey AtTheTimeOfWriteOff_Timekey  
   	  FROM tt_WRITEOFF_ACCOUNTS_2 A
             JOIN RBL_MISDB_PROD.Automate_Advances B   ON A.StatusDate = B.Date_ );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_CALCUALTEInitialBalance_2 
      ADD ( [AccountEntityID NUMBER(10,0) , PrincOutStd FLOAT(53) , BALANCE FLOAT(53) , FinalAssetClassAlt_Key NUMBER(10,0) ] ) ';
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.AccountEntityId, B.PrincipalBalance, B.Balance
   FROM A ,tt_CALCUALTEInitialBalance_2 A
          JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.CUSTOMERACID = B.RefSystemAcId
          AND B.EffectiveFromTimeKey <= TIMEKEY
          AND B.EffectiveToTimeKey >= TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AccountEntityID = src.AccountEntityId,
                                A.PrincOutStd = src.PrincipalBalance,
                                A.Balance = src.Balance;
   --select * from tt_CALCUALTEInitialBalance_2 where CUSTOMERACID='0007471200001568238'
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key
   FROM A ,tt_CALCUALTEInitialBalance_2 A
          JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CUSTOMERACID = B.CustomerAcID
          AND B.EffectiveFromTimeKey <= TIMEKEY
          AND B.EffectiveToTimeKey >= TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_temp1_80  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_temp1_80;
   UTILS.IDENTITY_RESET('tt_temp1_80');

   INSERT INTO tt_temp1_80 ( 
   	SELECT A.ACID ,
           A.Amount 
   	  FROM ExceptionFinalStatusType A
             JOIN tt_CALCUALTEInitialBalance_2 B   ON A.ACID = B.CUSTOMERACID
             AND A.EffectiveFromTimeKey <= B.AtTheTimeOfWriteOff_Timekey
             AND A.EffectiveToTimeKey >= B.AtTheTimeOfWriteOff_Timekey
             AND A.StatusType IN ( 'WO','Charge Off' )
    );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.Amount
   FROM A ,tt_WRITEOFF_ACCOUNTS_2 A
          JOIN tt_temp1_80 B   ON a.CUSTOMERACID = B.ACID 
    WHERE NVL(a.Amount, 0) <> NVL(B.Amount, 0)) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AMOUNT = src.Amount;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TEMP_45  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TEMP_45;
   UTILS.IDENTITY_RESET('tt_TEMP_45');

   INSERT INTO tt_TEMP_45 ( 
   	SELECT A.CustomerACID Account_Number  ,
           C.CustomerID Customer_ID  ,
           C.UCIF_ID UCIC  ,
           C.CustomerName Borrower_Name  ,
           CASE 
                WHEN B.EffectiveToTimeKey < v_TIMEKEY THEN UTILS.CONVERT_TO_VARCHAR2(K.Date_,200)
           ELSE NULL
              END Account_closure_date  ,
           D.SchemeType Scheme_Type  ,
           D.ProductCode Scheme_Code  ,
           D.ProductName Scheme_Description  ,
           B.segmentcode Segment_Code  ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'
                WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE E.AcBuSegmentDescription
              END Segment_Code_description  ,
           CASE 
                WHEN F.SourceName = 'FIS' THEN 'FI'
                WHEN F.SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  ,
           --CASE WHEN A.StatusType='WO' THEN A.Amount 
           --     ELSE NULL END                                      [Write-off amount],
           A.Amount Write_off_amount  ,
           --CASE WHEN A.StatusType='WO' THEN A.StatusDate       
           --     ELSE NULL END                                      [Write-off date],
           FORMAT(A.StatusDate, 'yyyy-MM-dd') Write_off_date  ,
           F.SourceName SOURCE_Source_system  ,
           H.PrincOutStd Outstanding_at_the_time_of_write_off  ,
           H.Balance Principal_outstanding_at_the_time_of_write_off  ,
           H.FinalAssetClassAlt_Key Asset_classification_at_the_time_write_off  ,
           --CASE WHEN A.StatusType='Charge Off' THEN  I.Balance  ELSE  J.Balance END 
           I.Balance Current_outstanding  ,
           J.FinalNpaDt NPA_Date  ,
           --CASE WHEN A.StatusType='Charge Off' THEN  I.PrincipalBalance  ELSE  J.NetBalance END   
           I.PrincipalBalance Current_principal_outstanding ,-- PrincOutStd

           'N' TWO_Flag  ,
           G.AccountBlkCode1 AccountBlkCode1  ,
           G.AccountBlkCode2 AccountBlkCode2  ,
           G.Accountstatus Accountstatus  ,
           G.cd CD  ,
           G.bucket bucket  ,
           G.dpd DPD  ,
           CASE 
                WHEN A.StatusType = 'Charge Off' THEN 'Y'
           ELSE 'N'
              END Charge_off_flag  ,
           CASE 
                WHEN A.StatusType = 'Charge Off' THEN A.StatusType
           ELSE NULL
              END Charge_off_Type  ,
           NULL Settlement_Flag  ,
           NULL Settlement_Date  
   	  FROM tt_WRITEOFF_ACCOUNTS_2 A
             LEFT JOIN tt_ADVACBASICDETAIL_2 B   ON A.CUSTOMERACID = B.CustomerACID
             LEFT JOIN tt_AdvAcBalanceDetail_18 I   ON B.AccountEntityId = I.AccountEntityId
             LEFT JOIN tt_CustomerBasicDetail_12 C   ON C.CUSTOMERENTITYID = B.CUSTOMERENTITYID
             LEFT JOIN RBL_MISDB_PROD.DimProduct D   ON B.ProductAlt_Key = D.ProductAlt_Key
             AND D.EffectiveFromTimeKey <= v_TIMEKEY
             AND D.EffectiveToTimeKey >= v_TIMEKEY
             LEFT JOIN RBL_MISDB_PROD.DimAcBuSegment E   ON B.SchemeAlt_key = E.AcBuSegmentAlt_Key
             AND E.EffectiveFromTimeKey <= v_TIMEKEY
             AND E.EffectiveToTimeKey >= v_TIMEKEY
             LEFT JOIN DIMSOURCEDB F   ON F.SourceAlt_Key = B.SourceAlt_Key
             AND F.EffectiveFromTimeKey <= v_TIMEKEY
             AND F.EffectiveToTimeKey >= v_TIMEKEY
             LEFT JOIN AdvFacCreditCardDetail G   ON B.ACCOUNTENTITYID = G.ACCOUNTENTITYID
             AND G.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
             AND G.EFFECTIVETOTIMEKEY >= v_TIMEKEY
             LEFT JOIN tt_CALCUALTEInitialBalance_2 H   ON A.CUSTOMERACID = H.CUSTOMERACID
             LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist J   ON B.AccountEntityId = J.AccountEntityId
             AND J.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
             AND J.EFFECTIVETOTIMEKEY >= v_TIMEKEY
             LEFT JOIN RBL_MISDB_PROD.Automate_Advances K   ON B.EffectiveToTimeKey = K.Timekey );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_TEMP_45  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WRITEOFF_CHARGEOFF_REPORT" TO "ADF_CDR_RBL_STGDB";
