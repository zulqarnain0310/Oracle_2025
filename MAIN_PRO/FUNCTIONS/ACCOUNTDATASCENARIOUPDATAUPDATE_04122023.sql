--------------------------------------------------------
--  DDL for Function ACCOUNTDATASCENARIOUPDATAUPDATE_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" 
(
  v_CustomerAcid IN VARCHAR2 DEFAULT ' ' ,
  v_FirstDtOfDisb IN VARCHAR2 DEFAULT NULL ,
  v_ProductAlt_Key IN NUMBER DEFAULT 0 ,
  v_Balance IN NUMBER DEFAULT 0 ,
  v_DrawingPower IN NUMBER DEFAULT 0 ,
  v_CurrentLimit IN NUMBER DEFAULT 0 ,
  v_ContiExcessDt IN VARCHAR2 DEFAULT NULL ,
  v_StockStDt IN VARCHAR2 DEFAULT NULL ,
  v_DebitSinceDt IN VARCHAR2 DEFAULT NULL ,
  v_LastCrDate IN VARCHAR2 DEFAULT NULL ,
  v_CurQtrCredit IN NUMBER DEFAULT 0 ,
  v_CurQtrInt IN NUMBER DEFAULT 0 ,
  --,@InttServiced Varchar(20) = NULL--,@IntNotServicedDt Varchar(20) = NULL
  v_OverDueSinceDt IN VARCHAR2 DEFAULT NULL ,
  v_ReviewDueDt IN VARCHAR2 DEFAULT NULL ,
  --,@SecurityValue Decimal(18,2) = 0
  v_DFVAmt IN NUMBER DEFAULT 0 ,
  v_GovtGtyAmt IN NUMBER DEFAULT 0 ,
  v_WriteOffAmount IN NUMBER DEFAULT 0 ,
  v_UnAdjSubSidy IN NUMBER DEFAULT 0 ,
  v_Asset_Norm IN VARCHAR2 DEFAULT NULL ,
  v_AddlProvision IN NUMBER DEFAULT 0 ,
  v_PrincOverdueSinceDt IN VARCHAR2 DEFAULT NULL ,
  v_IntOverdueSinceDt IN VARCHAR2 DEFAULT NULL ,
  v_OtherOverdueSinceDt IN VARCHAR2 DEFAULT NULL ,
  v_RepossessionDate IN VARCHAR2 DEFAULT NULL ,
  v_UnserviedInt IN NUMBER DEFAULT 0 ,
  v_AdvanceRecovery IN NUMBER DEFAULT 0 ,
  v_RePossession IN VARCHAR2 DEFAULT NULL ,
  v_RCPending IN VARCHAR2 DEFAULT NULL ,
  v_PaymentPending IN VARCHAR2 DEFAULT NULL ,
  v_WheelCase IN VARCHAR2 DEFAULT NULL ,
  v_RFA IN VARCHAR2 DEFAULT NULL ,
  v_IsNonCooperative IN VARCHAR2 DEFAULT NULL ,
  v_Sarfaesi IN VARCHAR2 DEFAULT NULL ,
  v_WeakAccount IN VARCHAR2 DEFAULT NULL ,
  v_PrvQtrRV IN NUMBER DEFAULT NULL ,
  v_CurntQtrRv IN NUMBER DEFAULT NULL ,
  v_FraudDt IN VARCHAR2 DEFAULT NULL ,
  v_FraudFlag IN VARCHAR2 DEFAULT NULL ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   IF ( v_OperationFlag = 2 ) THEN

   BEGIN
      MERGE INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL 
      USING (SELECT PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID row_id, v_FirstDtOfDisb, v_ProductAlt_Key, v_Balance, v_DrawingPower, v_CurrentLimit, UTILS.CONVERT_TO_VARCHAR2(v_ContiExcessDt,20,p_style=>103) AS pos_7, UTILS.CONVERT_TO_VARCHAR2(v_StockStDt,20,p_style=>103) AS pos_8, UTILS.CONVERT_TO_VARCHAR2(v_DebitSinceDt,20,p_style=>103) AS pos_9, UTILS.CONVERT_TO_VARCHAR2(v_LastCrDate,20,p_style=>103) AS pos_10, v_CurQtrCredit, v_CurQtrInt
      --,InttServiced = @InttServiced
       --,IntNotServicedDt = Convert(Varchar(20),@IntNotServicedDt,103)
      , UTILS.CONVERT_TO_VARCHAR2(v_OverDueSinceDt,20,p_style=>103) AS pos_13, UTILS.CONVERT_TO_VARCHAR2(v_ReviewDueDt,20,p_style=>103) AS pos_14, v_DFVAmt, v_GovtGtyAmt, v_WriteOffAmount, v_UnAdjSubSidy, v_Asset_Norm, v_AddlProvision, UTILS.CONVERT_TO_VARCHAR2(v_PrincOverdueSinceDt,20,p_style=>103) AS pos_21, UTILS.CONVERT_TO_VARCHAR2(v_IntOverdueSinceDt,20,p_style=>103) AS pos_22, UTILS.CONVERT_TO_VARCHAR2(v_OtherOverdueSinceDt,20,p_style=>103) AS pos_23, UTILS.CONVERT_TO_VARCHAR2(v_RepossessionDate,20,p_style=>103) AS pos_24, v_UnserviedInt, v_AdvanceRecovery, v_RePossession, v_RCPending, v_PaymentPending, v_WheelCase, v_RFA, v_IsNonCooperative, v_Sarfaesi, v_WeakAccount
      FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL  
       WHERE CustomerAcID = v_CustomerAcid) src
      ON ( PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET FirstDtOfDisb = v_FirstDtOfDisb,
                                   ProductAlt_Key = v_ProductAlt_Key,
                                   Balance = v_Balance,
                                   DrawingPower = v_DrawingPower,
                                   CurrentLimit = v_CurrentLimit,
                                   ContiExcessDt = pos_7,
                                   StockStDt = pos_8,
                                   DebitSinceDt = pos_9,
                                   LastCrDate = pos_10,
                                   CurQtrCredit = v_CurQtrCredit,
                                   CurQtrInt = v_CurQtrInt,
                                   OverDueSinceDt = pos_13,
                                   ReviewDueDt
                                   --,SecurityValue = @SecurityValue
                                    = pos_14,
                                   DFVAmt = v_DFVAmt,
                                   GovtGtyAmt = v_GovtGtyAmt,
                                   WriteOffAmount = v_WriteOffAmount,
                                   UnAdjSubSidy = v_UnAdjSubSidy,
                                   Asset_Norm = v_Asset_Norm,
                                   AddlProvision = v_AddlProvision,
                                   PrincOverdueSinceDt = pos_21,
                                   IntOverdueSinceDt = pos_22,
                                   OtherOverdueSinceDt = pos_23,
                                   RepossessionDate = pos_24,
                                   UnserviedInt = v_UnserviedInt,
                                   AdvanceRecovery = v_AdvanceRecovery,
                                   RePossession = v_RePossession,
                                   RCPending = v_RCPending,
                                   PaymentPending = v_PaymentPending,
                                   WheelCase = v_WheelCase,
                                   RFA = v_RFA,
                                   IsNonCooperative = v_IsNonCooperative,
                                   Sarfaesi = v_Sarfaesi,
                                   WeakAccount = v_WeakAccount;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, v_PrvQtrRV, v_CurntQtrRv, UTILS.CONVERT_TO_VARCHAR2(v_FraudDt,20,p_style=>103) AS pos_4, (CASE 
      WHEN v_FraudFlag = 'Y' THEN 870   END) AS pos_5
      FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID 
       WHERE B.CustomerAcID = v_CustomerAcid) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.PrvQtrRV = v_PrvQtrRV,
                                   A.CurntQtrRv = v_CurntQtrRv,
                                   A.FraudDt = pos_4,
                                   A.SplCatg1Alt_Key
                                   --Select * 
                                    = pos_5;
      MERGE INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL 
      USING (SELECT PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID row_id, CASE 
      WHEN FirstDtOfDisb = '1900-01-01' THEN NULL
      ELSE FirstDtOfDisb
         END AS pos_2, CASE 
      WHEN ContiExcessDt = '1900-01-01' THEN NULL
      ELSE ContiExcessDt
         END AS pos_3, CASE 
      WHEN StockStDt = '1900-01-01' THEN NULL
      ELSE StockStDt
         END AS pos_4, CASE 
      WHEN DebitSinceDt = '1900-01-01' THEN NULL
      ELSE DebitSinceDt
         END AS pos_5, CASE 
      WHEN LastCrDate = '1900-01-01' THEN NULL
      ELSE LastCrDate
         END AS pos_6, CASE 
      WHEN OverDueSinceDt = '1900-01-01' THEN NULL
      ELSE OverDueSinceDt
         END AS pos_7, CASE 
      WHEN ReviewDueDt = '1900-01-01' THEN NULL
      ELSE ReviewDueDt
         END AS pos_8, CASE 
      WHEN PrincOverdueSinceDt = '1900-01-01' THEN NULL
      ELSE PrincOverdueSinceDt
         END AS pos_9, CASE 
      WHEN IntOverdueSinceDt = '1900-01-01' THEN NULL
      ELSE IntOverdueSinceDt
         END AS pos_10, CASE 
      WHEN OtherOverdueSinceDt = '1900-01-01' THEN NULL
      ELSE OtherOverdueSinceDt
         END AS pos_11, CASE 
      WHEN RepossessionDate = '1900-01-01' THEN NULL
      ELSE RepossessionDate
         END AS pos_12
      FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL  ) src
      ON ( PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET FirstDtOfDisb = pos_2,
                                   ContiExcessDt = pos_3,
                                   StockStDt = pos_4,
                                   DebitSinceDt = pos_5,
                                   LastCrDate = pos_6,
                                   OverDueSinceDt = pos_7,
                                   ReviewDueDt = pos_8,
                                   PrincOverdueSinceDt = pos_9,
                                   IntOverdueSinceDt = pos_10,
                                   OtherOverdueSinceDt = pos_11,
                                   RepossessionDate = pos_12;
      --Where CustomerAcID=@CustomerAcid
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN A.FraudDt = '1900-01-01' THEN NULL
      ELSE A.FraudDt
         END AS FraudDt
      FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.FraudDt = src.FraudDt;
      --Where B.CustomerAcID=@CustomerAcid
      v_Result := 1 ;
      RETURN v_Result;--Select @Result

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCOUNTDATASCENARIOUPDATAUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
