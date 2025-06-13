--------------------------------------------------------
--  DDL for Procedure FACILITYDETAILSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" 
--exec FacilityDetailSelect @CustomerEntityID=601,@AccountEntityID=101,@FacilityType=N'TL',@TimeKey=25999,@BranchCode=N'101',@OperationFlag=2,@AccountFlag=N'F'
 --go
 --sp_helptext FacilityDetailSelect
 --------------------------------------------------------------------------------------------------------
 --Text
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================

(
  v_CustomerEntityID IN NUMBER DEFAULT 0 ,
  v_AccountEntityID IN NUMBER DEFAULT 0 ,
  v_FacilityType IN VARCHAR2 DEFAULT ' ' ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AccountFlag IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_cursor SYS_REFCURSOR;
-- Declare
--     @CustomerEntityID INT=1001556
--	,@AccountEntityID INT=679
--	,@FacilityType varchar(10)='AB'
--	,@TimeKey	INT=24570
--	,@BranchCode VARCHAR(10)='0110'
--	,@OperationFlag TINYINT=2
--	,@AccountFlag varchar(2)='F'

BEGIN

   IF ( v_OperationFlag = 2 ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.CustomerAcId ,
                UTILS.CONVERT_TO_VARCHAR2(A.AccountOpenDate,20,p_style=>103) AcOpenDt  ,
                I.SchemeType SchemeType  ,
                I.ProductName SchemeProductCode  ,
                A.SegmentCode ACSegmentCode  ,
                A.FacilityType ,
                C.InttRate Rateofinterest  ,
                A.FlgSecured SecuredStatus  ,
                --,A.AssetClass AssetClassNorm
                A.ReferencePeriod AssetClassNorm  ,
                NVL(J.AssetClassName, 'STANDARD') AssetClassCode  ,
                UTILS.CONVERT_TO_VARCHAR2(C.NpaDt,20,p_style=>103) NPADate  ,
                K.SubSectorName Sector  ,
                L.ActivityName PurposeofAdvance  ,
                A.CurrentLimit ,
                UTILS.CONVERT_TO_VARCHAR2(A.CurrentLimitDt,20,p_style=>103) CurrentLimitDate  ,
                UTILS.CONVERT_TO_VARCHAR2(A.DtofFirstDisb,20,p_style=>103) FirstDateofDisbursement  ,
                B.Balance BalanceosINR  ,
                B.PrincipalBalance POS  ,
                B.InterestReceivable InterestReceivable  ,
                B.UnAppliedIntAmount InterestAccrued  ,
                C.DrawingPower ,
                G.AdhocAmt ,
                UTILS.CONVERT_TO_VARCHAR2(G.AdhocDt,20,p_style=>103) AdhocDate  ,
                UTILS.CONVERT_TO_VARCHAR2(G.AdhocExpiryDate,20,p_style=>103) AdhocExpiryDate  ,
                UTILS.CONVERT_TO_VARCHAR2(AC.IntNotServicedDt,20,p_style=>103) IntNotServicedDate  ,
                UTILS.CONVERT_TO_VARCHAR2(AC.DebitSinceDt,20,p_style=>103) DebitSinceDate  ,
                UTILS.CONVERT_TO_VARCHAR2(B.LastCrDt,20,p_style=>103) LastCreditDate  ,
                UTILS.CONVERT_TO_VARCHAR2(G.ContExcsSinceDt,20,p_style=>103) ContiExcessDate  ,
                AC.CurQtrCredit CurQtrCredit  ,
                AC.CurQtrInt CurQtrInt  ,
                UTILS.CONVERT_TO_VARCHAR2(AC.StockStDt,20,p_style=>103) StockStatementDt  ,
                --,NULL StockStatemenFrequency
                UTILS.CONVERT_TO_VARCHAR2(C.Ac_ReviewDt,20,p_style=>103) ReviewRenewalDueDate  ,
                B.OverduePrincipal PrincipalOverdueAmt  ,
                UTILS.CONVERT_TO_VARCHAR2(B.OverduePrincipalDt,20,p_style=>103) PrincipalOverDueSinceDt  ,
                B.Overdueinterest InterestOverdueAmt  ,
                UTILS.CONVERT_TO_VARCHAR2(B.OverdueIntDt,20,p_style=>103) InterestOverDueSinceDt  ,
                F.CorporateUCIC_ID CorporateUCICID  ,
                F.CorporateCustomerID CorporateCustomerID  ,
                F.Liability ,
                F.MinimumAmountDue ,
                F.CD CycleDue  ,
                F.Bucket ,
                F.DPD ,
                --,NULL AccountCategory
                --,NULL STDProvisionCategory
                --,Convert(varchar(20),E.WriteOffDt,103) DateofTWO
                UTILS.CONVERT_TO_VARCHAR2(EFST_T.StatusDate,20,p_style=>103) DateofTWO  ,
                --,E.WriteOffAmt WriteOffAmt_HO
                EFST_T.Amount WriteOffAmt_HO  ,
                --,N.SplFlag FraudCommitted 
                CASE 
                     WHEN EFST.StatusType IS NULL THEN 'No'
                ELSE 'Yes'
                   END FraudCommitted  ,
                --,D.FMRDate FraudDate
                UTILS.CONVERT_TO_VARCHAR2(EFST.StatusDate,20,p_style=>103) FraudDate  ,
                --,O.SplFlag IBPCExposure
                --,P.SplFlag SecurtisedExposure
                --,Q.SplFlag AbInitio
                --,R.SplFlag PUIMarked
                CASE 
                     WHEN pui.AccountEntityId IS NULL THEN 'No'
                ELSE 'Yes'
                   END PUIMarked  ,
                --,NULL RFAMarked
                --,S.SplFlag NonCooperative
                --,T.SplFlag Repossesion
                --,U.SplFlag Sarfaesi
                --,V.SplFlag Inherentweakness
                --,W.SplFlag RCPendingFlag
                --,M.ExitCDRFlg RestructureFlag
                CASE 
                     WHEN M.AccountEntityId IS NULL THEN 'No'
                ELSE 'Yes'
                   END RestructureFlag  ,
                --, Case When AD.StatusType ='TWO' Then AD.StatusDate Else '' END  [TWO Date]
                UTILS.CONVERT_TO_VARCHAR2(EFST_T.StatusDate,20,p_style=>103) TWO_Date  ,
                --, Case When AD.StatusType ='TWO' Then ISNULL(AD.Amount,0)  Else 0.00 END  [TWO Amount]
                EFST_T.Amount TWO_Amount  ,
                -- , AD.StatusDate AS [Fraud Date] --Sachin
                --,EFST.StatusDate AS [Fraud Date] --PRASHANT
                --,IB.ExposureAmount AS [IBPC Exposure Amount] --Sachin
                --,SF.ExposureAmount AS [Securtised Exposure Amount] --Sachin
                --,N.SplFlag AS [Fraud Committed] --Sachin
                --,case when EFST.StatusType is null then 'No' else 'Yes' end [Fraud Committed] --PRASHANT
                --,Q.SplFlag AS [Ab-Initio] --Sachin
                --,R.SplFlag AS [PUI Marked] --Sachin
                --,case when pui.AccountEntityId is null then 'No' else 'Yes' end [PUI Marked]
                --,RF.SplFlag AS [RFA Marked] --Sachin
                DPRest.ParameterName RestructureType  ,
                UTILS.CONVERT_TO_VARCHAR2(M.RestructureDt,10,p_style=>103) RestructureDate  ,
                CASE 
                     WHEN EFST_SETT.StatusType IS NULL THEN 'No'
                ELSE 'Yes'
                   END Settlement  ,
                --,Convert(varchar(10),EFST_SETT.StatusDate,103) SettlementDate
                CASE 
                     WHEN EFST_LITI.StatusType IS NULL THEN 'No'
                ELSE 'Yes'
                   END Litigation  ,
                --,Convert(varchar(10),EFST_LITI.StatusDate,103) LitigationDate
                CASE 
                     WHEN EFST_T.StatusType IS NULL THEN 'No'
                ELSE 'Yes'
                   END TWO  
           FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityId = B.AccountEntityId
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcFinancialDetail C   ON C.AccountEntityId = A.AccountEntityId
                  AND C.EffectiveFromTimeKey <= v_TimeKey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail D   ON D.CustomerEntityId = A.CustomerEntityId
                  AND D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcWODetail E   ON E.AccountEntityId = A.AccountEntityId
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON F.AccountEntityId = A.AccountEntityId
                  AND F.EffectiveFromTimeKey <= v_TimeKey
                  AND F.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.ADVFACCCDETAIL G   ON G.AccountEntityId = A.AccountEntityId
                  AND G.EffectiveFromTimeKey <= v_TimeKey
                  AND G.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.ADVFACDLDETAIL H   ON H.AccountEntityId = A.AccountEntityId
                  AND H.EffectiveFromTimeKey <= v_TimeKey
                  AND H.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN DimProduct I   ON I.ProductAlt_Key = A.ProductAlt_Key
                  AND I.EffectiveFromTimeKey <= v_TimeKey
                  AND I.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN DimAssetClass J   ON J.AssetClassAlt_Key = B.AssetClassAlt_Key
                  AND J.EffectiveFromTimeKey <= v_TimeKey
                  AND j.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN DimSubSector k   ON k.SubSectorAlt_Key = A.SubSectorAlt_Key
                  AND K.EffectiveFromTimeKey <= v_TimeKey
                  AND K.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN DimActivity l   ON l.ActivityAlt_Key = A.ActivityAlt_Key
                  AND l.EffectiveFromTimeKey <= v_TimeKey
                  AND l.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail M   ON M.AccountEntityId = A.AccountEntityId
                  AND M.EffectiveFromTimeKey <= v_TimeKey
                  AND M.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN ExceptionFinalStatusType AD   ON A.CustomerACID = AD.ACID --Sachin

                  AND AD.EffectiveFromTimeKey <= v_TimeKey
                  AND AD.EffectiveToTimeKey >= v_TimeKey
                --LEFT JOIN IBPCFinalPoolDetail IB ON A.CustomerACID=IB.AccountID  --Sachin
                 --AND IB.EffectiveFromTimeKey<=@TimeKey And IB.EffectiveToTimeKey>=@TimeKey
                 --LEFT JOIN SecuritizedFinalACDetail SF ON A.CustomerACID=SF.AccountID  --Sachin
                 --AND SF.EffectiveFromTimeKey<=@TimeKey And SF.EffectiveToTimeKey>=@TimeKey
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'Fraud' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%Fraud%') N ON N.AccountEntityId=A.AccountEntityId
                 --AND N.EffectiveFromTimeKey<=@TimeKey And N.EffectiveToTimeKey>=@TimeKey AND N.SplFlag like '%Fraud%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'IBPC' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%IBPC%') O ON O.AccountEntityId=A.AccountEntityId
                 ----AND O.EffectiveFromTimeKey<=@TimeKey And O.EffectiveToTimeKey>=@TimeKey AND O.SplFlag like '%IBPC%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'Securitised' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%Securitised%') P ON P.AccountEntityId=A.AccountEntityId
                 ----AND P.EffectiveFromTimeKey<=@TimeKey And P.EffectiveToTimeKey>=@TimeKey AND P.SplFlag like '%Securitised%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'Ab-Initio' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%Ab-Initio%') Q ON Q.AccountEntityId=A.AccountEntityId
                 ----AND Q.EffectiveFromTimeKey<=@TimeKey And Q.EffectiveToTimeKey>=@TimeKey AND Q.SplFlag like '%Ab-Initio%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'PUI' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%PUI%') R ON R.AccountEntityId=A.AccountEntityId
                 --AND R.EffectiveFromTimeKey<=@TimeKey And R.EffectiveToTimeKey>=@TimeKey AND R.SplFlag like '%PUI%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'NonCooperative' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%NonCooperative%') S ON S.AccountEntityId=A.AccountEntityId
                 ----AND S.EffectiveFromTimeKey<=@TimeKey And S.EffectiveToTimeKey>=@TimeKey AND S.SplFlag like '%NonCooperative%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'Repossed' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%Repossed%') T ON T.AccountEntityId=A.AccountEntityId
                 ----AND T.EffectiveFromTimeKey<=@TimeKey And T.EffectiveToTimeKey>=@TimeKey AND T.SplFlag like '%Repossed%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'Sarfaesi' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%Sarfaesi%') U ON U.AccountEntityId=A.AccountEntityId
                 ----AND U.EffectiveFromTimeKey<=@TimeKey And U.EffectiveToTimeKey>=@TimeKey AND U.SplFlag like '%Sarfaesi%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'WeakAccount' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%WeakAccount%') V ON V.AccountEntityId=A.AccountEntityId
                 ----AND V.EffectiveFromTimeKey<=@TimeKey And V.EffectiveToTimeKey>=@TimeKey AND V.SplFlag like '%WeakAccount%' 
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'RC-Pending' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%RC-Pending%') W ON W.AccountEntityId=A.AccountEntityId
                 --LEFT JOIN (Select AccountEntityId,RefSystemAcId,'RFA' SplFlag from CurDat.AdvAcOtherDetail 
                 --where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
                 --	And SplFlag like '%RFA%') RF ON RF.AccountEntityId=A.AccountEntityId
                 --AND W.EffectiveFromTimeKey<=@TimeKey And W.EffectiveToTimeKey>=@TimeKey AND W.SplFlag like '%RC-Pending%' 

                  LEFT JOIN AdvAcPUIDetailMain pui   ON pui.AccountEntityId = a.AccountEntityId
                  AND pui.EffectiveFromTimeKey <= v_TimeKey
                  AND pui.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL AC   ON AC.AccountEntityID = A.AccountEntityId
                  AND AC.EffectiveFromTimeKey <= v_TimeKey
                  AND AC.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN ( SELECT CustomerID ,
                                     ACID ,
                                     StatusType ,
                                     StatusDate 
                              FROM ExceptionFinalStatusType 
                               WHERE  StatusType = 'Fraud Committed'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) EFST   ON a.CustomerACID = EFST.ACID
                  LEFT JOIN ( SELECT CustomerID ,
                                     ACID ,
                                     StatusType ,
                                     StatusDate ,
                                     Amount 
                              FROM ExceptionFinalStatusType 
                               WHERE  StatusType = 'TWO'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) EFST_T   ON a.CustomerACID = EFST_T.ACID
                  LEFT JOIN ( SELECT CustomerID ,
                                     ACID ,
                                     StatusType ,
                                     StatusDate ,
                                     Amount 
                              FROM ExceptionFinalStatusType 
                               WHERE  StatusType = 'Settlement'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) EFST_SETT   ON a.CustomerACID = EFST_SETT.ACID
                  LEFT JOIN ( SELECT CustomerID ,
                                     ACID ,
                                     StatusType ,
                                     StatusDate ,
                                     Amount 
                              FROM ExceptionFinalStatusType 
                               WHERE  StatusType = 'Litigation'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) EFST_LITI   ON a.CustomerACID = EFST_LITI.ACID
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     DimParameterName ,
                                     ParameterName ,
                                     ParameterShortName 
                              FROM DimParameter 
                               WHERE  DimParameterName = 'TypeofRestructuring'
                                        AND ( EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) ) DPRest   ON M.RestructureTypeAlt_Key = DPRest.ParameterAlt_Key
          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND A.AccountEntityId = v_AccountEntityId
                   AND A.FacilityType = v_FacilityType
                   AND A.CustomerEntityId = v_CustomerEntityId
                   AND A.BranchCode = v_BranchCode ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
