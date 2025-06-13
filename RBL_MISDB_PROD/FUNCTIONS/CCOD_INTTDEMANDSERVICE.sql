--------------------------------------------------------
--  DDL for Function CCOD_INTTDEMANDSERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" 
(
  v_date IN VARCHAR2
)
RETURN NUMBER
AS
   --DECLARE @Date As DateTime='2020-04-04'--(Select DATE from NTBL_STGDB.DBO.Automate_Advances where EXT_FLG='Y')
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_DATE );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   /* CHECK ALREADY PROCESSED FOR THE DATE */
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM CurDat_RBL_MISDB_PROD.AdvAcDemandDetail 
                       WHERE  ( DemandDate = v_Date
                                OR RecDate = v_Date )
                                AND ACTYPE = 'CCOD' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'INTEREST SERVICE ALREADY PROCECSSED FOR THE DATE ' || UTILS.CONVERT_TO_NVARCHAR2(v_date,30,p_style=>104) 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN 1;

   END;
   END IF;
   ----
   /* PREPARE TXNDATA*/
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_AcDailyTxnDetail  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_AcDailyTxnDetail;
   UTILS.IDENTITY_RESET('tt_AcDailyTxnDetail');

   INSERT INTO tt_AcDailyTxnDetail ( 
   	SELECT Branchcode ,
           CustomerAcID ,
           AccountEntityId ,
           TxnDate ,
           TxnAmount ,
           TxnType ,
           TxnSubType 
   	  FROM CurDat_RBL_MISDB_PROD.AcDailyTxnDetail 
   	 WHERE  TXNDATE = v_date );
   /*DLETE CHEQUE RETURN ENTRIES  -- NTBL SPECIFIC */
   /*IF REQUIRED 
   	CHEQUE RETURN TXNS REOMVE TO BE IMPLEMENTED HERE
   */
   /* PREPARE DEMAND DATA FOR CURRENT DATE*/
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DEMAND_DATA  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DEMAND_DATA;
   UTILS.IDENTITY_RESET('tt_DEMAND_DATA');

   INSERT INTO tt_DEMAND_DATA ( 
   	SELECT A."BranchCode" ,
           A."AccountEntityID" ,
           A.TxnSubType DemandType  ,
           A."TxnDate" DemandDate  ,
           utils.dateadd('DD', 1, txndate) DemandOverDueDate  ,
           CASE 
                WHEN SUM(A.TxnAmount)  > Balance THEN BALANCE
           ELSE SUM(A.TxnAmount) 
              END DemandAmt  ,
           UTILS.CONVERT_TO_NUMBER(0,16,2) RecAmount  ,
           SUM(A.TxnAmount)  BalanceDemand  ,
           A.CustomerAcID RefSystemACID  ,
           'CCOD' AcType  ,
           ( SELECT TimeKey 
             FROM SysDayMatrix 
            WHERE  DATE_ = v_DATE ) EffectiveFromTimeKey  ,
           49999 EffectiveToTimeKey  ,
           'D2K' CreatedBy  ,
           SYSDATE DateCreated  
   	  FROM tt_AcDailyTxnDetail A
             JOIN AdvAcBasicDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
             AND B.EffectiveToTimeKey >= v_TimeKey )
             AND B.AccountEntityId = A.AccountEntityId
             AND B.ReferencePeriod = 91
             JOIN AdvAcBalanceDetail BAL   ON BAL.EffectiveFromTimeKey <= v_TimeKey
             AND BAL.EffectiveToTimeKey >= v_TimeKey
             AND A.AccountEntityId = B.AccountEntityId
             JOIN ADVFACCCDETAIL C   ON ( c.EffectiveFromTimeKey <= v_TimeKey
             AND c.EffectiveToTimeKey >= v_TimeKey )
             AND C.AccountEntityId = B.AccountEntityId
   	 WHERE  TxnDate = v_Date
              AND TxnSubType IN ( 'INTEREST' )

              AND TxnType = 'DEBIT'
   	  GROUP BY A.BranchCode,A.AccountEntityID,A.TxnSubType,A.TxnDate,txndate,A.CustomerAcID );
   /* INSERT PREVIOUS BALANCE DEMAND DATA */
   INSERT INTO tt_DEMAND_DATA
     ( BranchCode, AccountEntityID, DemandType, DemandDate, DemandOverDueDate, DemandAmt, RecAmount, BalanceDemand, RefSystemACID, AcType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
     ( SELECT BranchCode ,
              AccountEntityID ,
              DemandType ,
              DemandDate ,
              DemandOverDueDate ,
              DemandAmt ,
              UTILS.CONVERT_TO_NUMBER(0,16,2) RecAmount  ,
              BalanceDemand ,
              RefSystemACID ,
              AcType ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              SYSDATE DateCreated  
       FROM CurDat_RBL_MISDB_PROD.AdvAcDemandDetail A
        WHERE  AcType = 'CCOD'
                 AND BalanceDemand > 0
                 AND ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey ) );
   /* PREPARING RECOVERY DATA */

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DEMAND_DATA 
      ADD ( ENTITYKEY NUMBER(10,0)  ) ';
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_RECOVERY_DATA ;  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_RECOVERY_DATA;
   UTILS.IDENTITY_RESET('tt_RECOVERY_DATA');

   INSERT INTO tt_RECOVERY_DATA WITH CTE_DMD AS ( SELECT AccountEntityId 
        FROM tt_DEMAND_DATA 
        GROUP BY AccountEntityId ) 
         SELECT A.AccountEntityId ,
                SUM(TXNAMOUNT)  RecAmount  
           FROM tt_AcDailyTxnDetail A
                  JOIN CTE_DMD B   ON A.AccountEntityId = B.AccountEntityID
          WHERE  TxnDate = v_Date
                   AND TxnType IN ( 'CREDIT' )

           GROUP BY A.AccountEntityId
         ;
   /* ADJUSTING INTEREST DEMAND  WITH RECOOVERY */
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DMD_REC_DATA  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DMD_REC_DATA;
   UTILS.IDENTITY_RESET('tt_DMD_REC_DATA');

   INSERT INTO tt_DMD_REC_DATA SELECT A.* ,--a.AccountEntityId,DemandDate

                                      --,a.BalanceDemand, B.RecAmount--,-- 
                                      SUM(A.BalanceDemand) OVER ( PARTITION BY A.AccountEntityId ORDER BY A.AccountEntityId, DEMANDDATE, ENTITYKEY  ) DmdRunTotal  ,
                                      b.RecAmount GrossRec  ,
                                      UTILS.CONVERT_TO_NUMBER(0,18,2) RecCalc  ,
                                      UTILS.CONVERT_TO_NUMBER(0,18,2) RecAdjusted  ,
                                      v_Date RecDAte  ,
                                      v_Date RecAdjDAte  ,
                                      ROW_NUMBER() OVER ( ORDER BY A.Accountentityid, A.demanddate  ) RID  
        FROM tt_DEMAND_DATA a
               LEFT JOIN tt_RECOVERY_DATA b   ON A.AccountEntityId = b.AccountEntityId
        ORDER BY AccountEntityId,
                 DemandDate;
   /* CALCULATING BALANCE DEMAND AND ADJUSTED RECOVERY */
   --UPDATE tt_DMD_REC_DATA SET RecCalc=GrossRec-DmdRunTotal
   --UPDATE tt_DMD_REC_DATA SET RecAdjusted =BalanceDemand  WHERE RecCalc>0
   UPDATE tt_DMD_REC_DATA
      SET RecCalc = GrossRec
    WHERE  GrossRec = DmdRunTotal;
   UPDATE tt_DMD_REC_DATA
      SET RecCalc = GrossRec - DmdRunTotal
    WHERE  RecCalc = 0;
   UPDATE tt_DMD_REC_DATA
      SET RecAdjusted = BalanceDemand
    WHERE  RecCalc > 0;
   WITH CTE_AC AS ( SELECT AccountEntityId ,
                           MIN(RID)  RID  
     FROM tt_DMD_REC_DATA 
    WHERE  RecCalc < 0
     GROUP BY AccountEntityId ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, BalanceDemand - (RecCalc * -1) AS RecAdjusted
      FROM A ,tt_DMD_REC_DATA A
             JOIN CTE_AC B   ON A.AccountEntityId = B.AccountEntityId
             AND A.RID = B.RID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.RecAdjusted = src.RecAdjusted
      ;
   UPDATE tt_DMD_REC_DATA
      SET BalanceDemand = BalanceDemand - NVL(RecAdjusted, 0),
          RecAmount = NVL(RecAdjusted, 0)
    WHERE  NVL(RecAdjusted, 0) > 0;
   /* UPDATEING REC DATE AND RECADJ DATE  */
   UPDATE tt_DMD_REC_DATA
      SET RECDATE = NULL
    WHERE  NVL(RecAdjusted, 0) = 0;
   UPDATE tt_DMD_REC_DATA
      SET RECADJDATE = NULL
    WHERE  NVL(BalanceDemand, 0) > 0;
   UPDATE tt_DMD_REC_DATA
      SET RECADJDATE = RECDATE
    WHERE  NVL(BalanceDemand, 0) = 0;
   /* CHANGE EFFECTIVEFFROMTIMEKEY FOR PREVIOUS DATE DEMAND SERVICED DATA */
   UPDATE tt_DMD_REC_DATA
      SET EffectiveFromTimeKey = v_TimeKey
    WHERE  EffectiveFromTimeKey < v_TimeKey
     AND NVL(RecAdjusted, 0) > 0;
   /* DELETE PREVISOU DATES UNSERVE DEMAND DATA - NOT REQUIRED ANY CHANGE IN MAIN TABLE*/
   DELETE tt_DMD_REC_DATA

    WHERE  EffectiveFromTimeKey < v_TimeKey
             AND NVL(RecAdjusted, 0) = 0;
   /*MERGE DEMAND INTO MAIN  TABLE */
   MERGE INTO O 
   USING (SELECT O.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
   FROM O ,CurDat_RBL_MISDB_PROD.AdvAcDemandDetail O
          JOIN tt_DMD_REC_DATA T   ON O.AccountEntityID = T.AccountEntityID
          AND O.DemandType = T.DemandType
          AND O.DemandDate = T.DemandDate
          AND NVL(O.DemandAmt, 0) = NVL(T.DemandAmt, 0)
          AND O.EffectiveToTimeKey = 49999
          AND O.BalanceDemand <> T.BalanceDemand ) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = src.EffectiveToTimeKey;
   ---------------------------------------------------------------------------------------------------------------
   /* INSERT DATA INTO MAIN TABLE */
   INSERT INTO CurDat_RBL_MISDB_PROD.AdvAcDemandDetail
     ( BranchCode, AccountEntityID, DemandType, DemandDate, DemandOverDueDate, DemandAmt, RecDate, RecAdjDate, RecAmount, BalanceDemand, RefSystemACID, AcType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
     ( SELECT T.BranchCode ,
              T.AccountEntityID ,
              T.DemandType ,
              T.DemandDate ,
              T.DemandOverDueDate ,
              T.DemandAmt ,
              T.RecDate ,
              T.RecAdjDate ,
              T.RecAmount ,
              T.BalanceDemand ,
              T.RefSystemACID ,
              T.AcType ,
              T.EffectiveFromTimeKey ,
              T.EffectiveToTimeKey ,
              T.CreatedBy ,
              T.DateCreated 
       FROM tt_DMD_REC_DATA T
        WHERE  EffectiveToTimeKey = 49999
                 AND EffectiveFromTimeKey = v_TimeKey );
   /* INSERT RECOVERY DATA */
   INSERT INTO AdvAcRecoveryDetail
     ( CashRecDate, BranchCode, AcType, CreatedBy, AccountEntityID, RecAmt, RecDate, DemandDate, RefSystemACID, DateCreated )
     ( SELECT RECDATE CashRecDate  ,
              BranchCode ,
              AcType ,
              'D2K' CreatedBy  ,
              AccountEntityID ,
              RecAmount RecAmt  ,
              RecDate ,
              DemandDate ,
              RefSystemACID ,
              SYSDATE DateCreated  
       FROM tt_DMD_REC_DATA 
        WHERE  NVL(RecAmount, 0) > 0 );/*

    SELECT SUM(RECAMOUNT) FROM AdvAcDemandDetail 
     SELECT SUM(RecAmt) FROM	AdvAcRecoveryDetail 


     SELECT  AccountEntityId,DEMANDDATE,DemandAmt,RecDate,RecAmount,RecAdjDate,BalanceDemand,DemandOverDueDate,EffectiveFromTimeKey,EffectiveToTimeKey 
     FROM AdvAcDemandDetail 
     ORDER BY  AccountEntityId,DEMANDDATE ,EffectiveFromTimeKey


     */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_INTTDEMANDSERVICE" TO "ADF_CDR_RBL_STGDB";
