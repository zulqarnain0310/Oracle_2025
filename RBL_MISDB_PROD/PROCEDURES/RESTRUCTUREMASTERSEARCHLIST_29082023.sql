--------------------------------------------------------
--  DDL for Procedure RESTRUCTUREMASTERSEARCHLIST_29082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" 
---------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --1

(
  --Declare
  v_PageNo IN NUMBER DEFAULT 1 ,
  v_PageSize IN NUMBER DEFAULT 10 ,
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         --25999
         IF utils.object_id('TempDB..#Previous') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Previous_6 ';
         END IF;
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         DBMS_OUTPUT.PUT_LINE('NANDA');
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_235') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_235 ';
            END IF;
            DELETE FROM tt_temp_235;
            UTILS.IDENTITY_RESET('tt_temp_235');

            INSERT INTO tt_temp_235 ( 
            	SELECT A.AccountEntityId ,
                    A.SystemACID ,
                    A.SourceName ,
                    A.CustomerId ,
                    A.CustomerName ,
                    A.UCIF_ID ,
                    A.CurrencyAlt_Key ,
                    A.CurrencyName ,
                    A.AccountOpenDate ,
                    A.SchemeType ,
                    A.Productcode ,
                    A.ProductDescription ,
                    A.segmentcode ,
                    A.SegmentDescription ,
                    A.AcBuSegmentDescription ,
                    A.BankingType ,
                    A."BankingRelationship" ,
                    A.SanctionLimit ,
                    A.SanctionLimitDt ,
                    --,A.AssetClassAlt_Key
                    A.RestructureAssetClassAlt_key ,
                    A.AssetClassName ,
                    A.NpaDt ,
                    A.DtofFirstDisb ,
                    A.RestructureTypeAlt_Key ,
                    A.RestructureType ,
                    A.RestructureCatgAlt_Key ,
                    A.RestructureFacility ,
                    A.PreRestrucDefaultDate ,
                    A.PreAssetClassName ,
                    A.PreRestrucNPA_Date ,
                    A.PostAssetClassName ,
                    A.Npa_Qtr ,
                    A.RestructureDt ,
                    A.RestructureProposalDt ,
                    A.RestructureAmt ,
                    A.ApprovingAuthAlt_Key ,
                    A.RestructureApprovalDt ,
                    A.POS_RepayStartDate ,
                    A.RestructurePOS ,
                    A.IntRepayStartDate ,
                    A.RefDate ,
                    A.InvocationDate ,
                    A.IsEquityCoversion ,
                    A.ConversionDate ,
                    A.Is_COVID_Morat ,
                    A.Covid_Morit ,
                    A.parameterAlt_Key ,
                    A.COVID_OTR_Catg ,
                    A.ReportingBank ,
                    A.ICA_SignDate ,
                    A.Is_InvestmentGrade ,
                    A."Status_Current_Quarter" ,
                    A."Status_previous_Quarter" ,
                    A."Status_of_MoniroringPeriod" ,
                    A."Status_of_Specified_Period" ,
                    A.CreditProvision ,
                    A.DFVProvision ,
                    A.MTMProvision ,
                    A.TotalProv ,
                    A.Percentage ,
                    A.TotalProvisionPrevious ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.CRILIC_Fst_DefaultDate ,
                    A.Status_of_MoniroringPeriodAlt_Key ,
                    A.Status_of_Specified_PeriodAlt_Key ,
                    A.RevisedBusSegAlt_Key ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.NPA_Provision_per ,
                    A.EquityConversionYN ,
                    A.CrntQtrAssetClass ,
                    A.PrevQtrAssetClass ,
                    A.MonitoringPeriodStatus ,
                    A.PrevQtrTotalProvision ,
                    A.AcBuSegmentDescription1 
            	  FROM ( SELECT A.AccountEntityId ,
                             B.SystemACID ,
                             C.SourceName ,
                             D.CustomerId ,
                             D.CustomerName ,
                             D.UCIF_ID ,
                             H.CurrencyCode CurrencyAlt_Key  ,
                             H.CurrencyName ,
                             --,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
                             CASE 
                                  WHEN AccountOpenDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountOpenDate,200),10,p_style=>103)
                                END AccountOpenDate  ,
                             B.FacilityType SchemeType  ,
                             G.ProductCode Productcode  ,
                             G.ProductName ProductDescription  ,
                             B.segmentcode ,
                             --,P.SegmentDescription SegmentDescription
                             --	,W.EWS_SegmentName AS SegmentDescription
                             DBS.AcBuSegmentDescription SegmentDescription  ,
                             A.RevisedBusinessSegment AcBuSegmentDescription  ,
                             A.BankingType ,
                             M.ParameterName BankingRelationship  ,
                             B.CurrentLimit SanctionLimit  ,
                             --,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
                             CASE 
                                  WHEN B.CurrentLimitDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200),10,p_style=>103)
                                END SanctionLimitDt  ,
                             --,E.AssetClassAlt_Key -----------chk
                             A.RestructureAssetClassAlt_key ,
                             J.AssetClassName ,
                             CASE 
                                  WHEN A.PreRestrucNPA_Date IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucNPA_Date,10,p_style=>103)
                                END NpaDt  ,
                             --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
                             --,convert(varchar(10),cast(B.DtofFirstDisb as date),103) DtofFirstDisb
                             CASE 
                                  WHEN A.DisbursementDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.DisbursementDate,200),10,p_style=>103)
                                END DtofFirstDisb  ,
                             A.RestructureTypeAlt_Key ,
                             k.ParameterName RestructureType  ,
                             A.RestructureCatgAlt_Key ,
                             L.ParameterName RestructureFacility  ,
                             --,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
                             CASE 
                                  WHEN A.PreRestrucDefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200),10,p_style=>103)
                                END PreRestrucDefaultDate  ,
                             Q.AssetClassName PreAssetClassName  ,
                             --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
                             CASE 
                                  WHEN Y.NPADt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200),10,p_style=>103)
                                END PreRestrucNPA_Date  ,
                             R.AssetClassName PostAssetClassName  ,
                             A.Npa_Qtr ,
                             --,Convert(Date,A.RestructureDt,103)RestructureDt
                             CASE 
                                  WHEN A.RestructureDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,200),10,p_style=>103)
                                END RestructureDt  ,
                             --,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
                             CASE 
                                  WHEN A.RestructureProposalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200),10,p_style=>103)
                                END RestructureProposalDt  ,
                             A.RestructureAmt ,
                             A.ApprovingAuthAlt_Key ,
                             --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
                             CASE 
                                  WHEN A.RestructureApprovalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200),10,p_style=>103)
                                END RestructureApprovalDt  ,
                             --,Convert(Date,A.RepaymentStartDate,103) POS_RepayStartDate
                             CASE 
                                  WHEN A.RepaymentStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200),10,p_style=>103)
                                END POS_RepayStartDate  ,
                             A.RestructurePOS ,
                             --,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate
                             CASE 
                                  WHEN A.IntRepayStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200),10,p_style=>103)
                                END IntRepayStartDate  ,
                             --,Convert(Date,A.RefDate,103)RefDate
                             CASE 
                                  WHEN A.RefDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200),10,p_style=>103)
                                END RefDate  ,
                             --,Convert(Date,A.InvocationDate,103)InvocationDate
                             CASE 
                                  WHEN A.InvocationDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200),10,p_style=>103)
                                END InvocationDate  ,
                             A.IsEquityCoversion ,
                             --,Convert(Date,A.ConversionDate,103)ConversionDate
                             CASE 
                                  WHEN A.ConversionDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200),10,p_style=>103)
                                END ConversionDate  ,
                             S.ParameterAlt_Key Is_COVID_Morat  ,
                             S.ParameterName Covid_Morit  ,
                             N.ParameterAlt_Key ,
                             N.ParameterName COVID_OTR_Catg  ,
                             A.FstDefaultReportingBank ReportingBank  ,
                             --,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
                             CASE 
                                  WHEN A.ICA_SignDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200),10,p_style=>103)
                                END ICA_SignDate  ,
                             Z.ParameterAlt_Key Is_InvestmentGrade  ,
                             --,P.[Status_Current_Quarter]
                             --,P.[Status_previous_Quarter]
                             --,P.[Status_of_MoniroringPeriod]
                             --,P.[Status_of_Specified_Period]
                             --,P.TotalProvisionPrevious
                             O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                             X.AssetClassName Status_Current_Quarter  ,
                             T.AssetClassName Status_previous_Quarter  ,
                             U.ParameterName Status_of_MoniroringPeriod  ,
                             V.ParameterName Status_of_Specified_Period  ,
                             A.CreditProvision ,
                             A.DFVProvision ,
                             A.MTMProvision ,
                             E.TotalProv ,
                             CASE 
                                  WHEN E.Balance <> 0 THEN utils.round_((E.TotalProv / E.Balance) * 100, 2)
                             ELSE 0
                                END Percentage  ,
                             --,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
                             CASE 
                                  WHEN A.CRILIC_Fst_DefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200),10,p_style=>103)
                                END CRILIC_Fst_DefaultDate  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                             A.ApprovedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,200,p_style=>103) DateApproved  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,200,p_style=>103) DateModified  ,
                             --,P.Status_of_MoniroringPeriodAlt_Key
                             --,P.Status_of_Specified_PeriodAlt_Key
                             O.MonitoringPeriodStatus Status_of_MoniroringPeriodAlt_Key  ,
                             O.SpecifiedPeriodStatus Status_of_Specified_PeriodAlt_Key  ,
                             A.RevisedBusSegAlt_Key ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             A.NPA_Provision_per ,
                             A.EquityConversionYN ,
                             o.CrntQtrAssetClass ,
                             o.PrevQtrAssetClass ,
                             o.MonitoringPeriodStatus ,
                             o.PrevQtrTotalProvision ,
                             DBS.AcBuSegmentDescription AcBuSegmentDescription1  
                      FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail A
                             JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                             AND E.EffectiveFromTimeKey <= v_TimeKey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail Y   ON Y.RefCustomerID = A.RefCustomerId
                             AND Y.EffectiveFromTimeKey <= v_TimeKey
                             AND Y.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                             AND F.EffectiveFromTimeKey <= v_TimeKey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                             AND O.EffectiveFromTimeKey <= v_TimeKey
                             AND O.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                             AND G.EffectiveFromTimeKey <= v_TimeKey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                             AND H.EffectiveFromTimeKey <= v_TimeKey
                             AND H.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = A.RestructureAssetClassAlt_key
                             AND J.EffectiveFromTimeKey <= v_TimeKey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass Q   ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key
                             AND Q.EffectiveFromTimeKey <= v_TimeKey
                             AND Q.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass R   ON R.AssetClassAlt_Key = A.PostRestrucAssetClass
                             AND R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter K   ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key
                             AND k.DimParameterName = 'TypeofRestructuring'
                             AND K.EffectiveFromTimeKey <= v_TimeKey
                             AND K.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter L   ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key
                             AND L.DimParameterName = 'RestructureFacility'
                             AND L.EffectiveFromTimeKey <= v_TimeKey
                             AND L.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter M   ON M.ParameterAlt_Key = A.BankingType
                             AND M.DimParameterName = 'BankingRelationship'
                             AND M.EffectiveFromTimeKey <= v_TimeKey
                             AND M.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter N   ON N.ParameterAlt_Key = A.COVID_OTR_Catg
                             AND N.DimParameterName = 'Covid - OTR Category'
                             AND N.EffectiveFromTimeKey <= v_TimeKey
                             AND N.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass X   ON X.AssetClassAlt_Key = O.CrntQtrAssetClass
                             AND X.EffectiveFromTimeKey <= v_TimeKey
                             AND X.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass T   ON T.AssetClassAlt_Key = O.PrevQtrAssetClass
                             AND T.EffectiveFromTimeKey <= v_TimeKey
                             AND T.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter U   ON U.ParameterAlt_Key = O.MonitoringPeriodStatus
                             AND U.DimParameterName = 'StatusofMonitoringPeriod'
                             AND U.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter V   ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus
                             AND V.DimParameterName = 'StatusofSpecificPeriod'
                             AND V.EffectiveFromTimeKey <= v_TimeKey
                             AND V.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimSegment W   ON W.EWS_SegmentAlt_Key = B.segmentcode
                             AND W.EffectiveFromTimeKey <= v_TimeKey
                             AND W.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                             AND DBS.EffectiveFromTimeKey <= v_TimeKey
                             AND DBS.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'CovidMoratorium' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
            	  AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'InvestmentGrade' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND DimParameterName = 'DimYesNoNA' ) Z   ON Z.ParameterName = A.Is_InvestmentGrade

                      --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.AccountEntityId ,
                             B.SystemACID ,
                             C.SourceName ,
                             D.CustomerId ,
                             D.CustomerName ,
                             D.UCIF_ID ,
                             H.CurrencyCode CurrencyAlt_Key  ,
                             H.CurrencyName ,
                             --,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
                             CASE 
                                  WHEN AccountOpenDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountOpenDate,200),10,p_style=>103)
                                END AccountOpenDate  ,
                             B.FacilityType SchemeType  ,
                             G.ProductCode Productcode  ,
                             G.ProductName ProductDescription  ,
                             B.segmentcode ,
                             --,P.SegmentDescription SegmentDescription
                             --,W.EWS_SegmentName AS SegmentDescription
                             DBS.AcBuSegmentDescription SegmentDescription  ,
                             A.RevisedBusinessSegment AcBuSegmentDescription  ,
                             A.BankingType ,
                             M.ParameterName BankingRelationship  ,
                             B.CurrentLimit SanctionLimit  ,
                             --,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
                             CASE 
                                  WHEN B.CurrentLimitDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200),10,p_style=>103)
                                END SanctionLimitDt  ,
                             --,E.AssetClassAlt_Key -----------chk
                             A.RestructureAssetClassAlt_key ,
                             J.AssetClassName ,
                             CASE 
                                  WHEN A.PreRestrucNPA_Date IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucNPA_Date,10,p_style=>103)
                                END NpaDt  ,
                             --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
                             CASE 
                                  WHEN B.DtofFirstDisb IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200),10,p_style=>103)
                                END DtofFirstDisb  ,
                             A.RestructureTypeAlt_Key ,
                             k.ParameterName RestructureType  ,
                             A.RestructureCatgAlt_Key ,
                             L.ParameterName RestructureFacility  ,
                             --,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
                             CASE 
                                  WHEN A.PreRestrucDefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200),10,p_style=>103)
                                END PreRestrucDefaultDate  ,
                             Q.AssetClassName PreAssetClassName  ,
                             --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
                             CASE 
                                  WHEN Y.NPADt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200),10,p_style=>103)
                                END PreRestrucNPA_Date  ,
                             R.AssetClassName PostAssetClassName  ,
                             A.Npa_Qtr ,
                             --,Convert(Date,A.RestructureDt,103)RestructureDt
                             CASE 
                                  WHEN A.RestructureDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureDt,200),10,p_style=>103)
                                END RestructureDt  ,
                             --,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
                             CASE 
                                  WHEN A.RestructureProposalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200),10,p_style=>103)
                                END RestructureProposalDt  ,
                             A.RestructureAmt ,
                             A.ApprovingAuthAlt_Key ,
                             --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
                             CASE 
                                  WHEN A.RestructureApprovalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200),10,p_style=>103)
                                END RestructureApprovalDt  ,
                             --,Convert(Date,A.RepaymentStartDate,103) POS_RepayStartDate
                             CASE 
                                  WHEN A.RepaymentStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200),10,p_style=>103)
                                END POS_RepayStartDate  ,
                             A.RestructurePOS ,
                             --,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate
                             CASE 
                                  WHEN A.IntRepayStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200),10,p_style=>103)
                                END IntRepayStartDate  ,
                             --,Convert(Date,A.RefDate,103)RefDate
                             CASE 
                                  WHEN A.RefDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200),10,p_style=>103)
                                END RefDate  ,
                             --,Convert(Date,A.InvocationDate,103)InvocationDate
                             CASE 
                                  WHEN A.InvocationDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200),10,p_style=>103)
                                END InvocationDate  ,
                             A.IsEquityCoversion ,
                             --,Convert(Date,A.ConversionDate,103)ConversionDate
                             CASE 
                                  WHEN A.ConversionDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200),10,p_style=>103)
                                END ConversionDate  ,
                             S.ParameterAlt_Key Is_COVID_Morat  ,
                             S.ParameterName Covid_Morit  ,
                             N.ParameterAlt_Key ,
                             N.ParameterName COVID_OTR_Catg  ,
                             A.FstDefaultReportingBank ReportingBank  ,
                             --,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
                             CASE 
                                  WHEN A.ICA_SignDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200),10,p_style=>103)
                                END ICA_SignDate  ,
                             Z.ParameterAlt_Key Is_InvestmentGrade  ,
                             --,P.[Status_Current_Quarter]
                             --,P.[Status_previous_Quarter]
                             --,P.[Status_of_MoniroringPeriod]
                             --,P.[Status_of_Specified_Period]
                             --,P.TotalProvisionPrevious
                             O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                             X.AssetClassName Status_Current_Quarter  ,
                             T.AssetClassName Status_previous_Quarter  ,
                             U.ParameterName Status_of_MoniroringPeriod  ,
                             V.ParameterName Status_of_Specified_Period  ,
                             A.CreditProvision ,
                             A.DFVProvision ,
                             A.MTMProvision ,
                             E.TotalProv ,
                             CASE 
                                  WHEN E.Balance <> 0 THEN utils.round_((E.TotalProv / E.Balance) * 100, 2)
                             ELSE 0
                                END Percentage  ,
                             --,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
                             CASE 
                                  WHEN A.CRILIC_Fst_DefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200),10,p_style=>103)
                                END CRILIC_Fst_DefaultDate  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                             A.ApprovedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,200,p_style=>103) DateApproved  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,200,p_style=>103) DateModified  ,
                             --,P.Status_of_MoniroringPeriodAlt_Key
                             --,P.Status_of_Specified_PeriodAlt_Key
                             O.MonitoringPeriodStatus Status_of_MoniroringPeriodAlt_Key  ,
                             O.SpecifiedPeriodStatus Status_of_Specified_PeriodAlt_Key  ,
                             A.RevisedBusSegAlt_Key ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             A.NPA_Provision_per ,
                             A.EquityConversionYN ,
                             o.CrntQtrAssetClass ,
                             o.PrevQtrAssetClass ,
                             o.MonitoringPeriodStatus ,
                             o.PrevQtrTotalProvision ,
                             DBS.AcBuSegmentDescription AcBuSegmentDescription1  
                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod A
                             JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                             AND E.EffectiveFromTimeKey <= v_TimeKey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                             AND F.EffectiveFromTimeKey <= v_TimeKey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                             AND O.EffectiveFromTimeKey <= v_TimeKey
                             AND O.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail Y   ON Y.RefCustomerID = A.RefCustomerId
                             AND Y.EffectiveFromTimeKey <= v_TimeKey
                             AND Y.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                             AND G.EffectiveFromTimeKey <= v_TimeKey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                             AND H.EffectiveFromTimeKey <= v_TimeKey
                             AND H.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = A.RestructureAssetClassAlt_key
                             AND J.EffectiveFromTimeKey <= v_TimeKey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass Q   ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key
                             AND Q.EffectiveFromTimeKey <= v_TimeKey
                             AND Q.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass R   ON R.AssetClassAlt_Key = A.PostRestrucAssetClass
                             AND R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter K   ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key
                             AND k.DimParameterName = 'TypeofRestructuring'
                             AND K.EffectiveFromTimeKey <= v_TimeKey
                             AND K.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter L   ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key
                             AND L.DimParameterName = 'RestructureFacility'
                             AND L.EffectiveFromTimeKey <= v_TimeKey
                             AND L.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter M   ON M.ParameterAlt_Key = A.BankingType
                             AND M.DimParameterName = 'BankingRelationship'
                             AND M.EffectiveFromTimeKey <= v_TimeKey
                             AND M.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter N   ON N.ParameterAlt_Key = A.COVID_OTR_Catg
                             AND N.DimParameterName = 'Covid - OTR Category'
                             AND N.EffectiveFromTimeKey <= v_TimeKey
                             AND N.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass X   ON X.AssetClassAlt_Key = O.CrntQtrAssetClass
                             AND X.EffectiveFromTimeKey <= v_TimeKey
                             AND X.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass T   ON T.AssetClassAlt_Key = O.PrevQtrAssetClass
                             AND T.EffectiveFromTimeKey <= v_TimeKey
                             AND T.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter U   ON U.ParameterAlt_Key = O.MonitoringPeriodStatus
                             AND U.DimParameterName = 'StatusofMonitoringPeriod'
                             AND U.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter V   ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus
                             AND V.DimParameterName = 'StatusofSpecificPeriod'
                             AND V.EffectiveFromTimeKey <= v_TimeKey
                             AND V.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimSegment W   ON W.EWS_SegmentAlt_Key = B.segmentcode
                             AND W.EffectiveFromTimeKey <= v_TimeKey
                             AND W.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                             AND DBS.EffectiveFromTimeKey <= v_TimeKey
                             AND DBS.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'CovidMoratorium' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat
                             LEFT JOIN ( 
                                         --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                                         SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'InvestmentGrade' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND DimParameterName = 'DimYesNoNA' ) Z   ON Z.ParameterName = A.Is_InvestmentGrade
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY AccountEntityId )
                     ) A
            	  GROUP BY A.AccountEntityId,A.SystemACID,A.SourceName,A.CustomerId,A.CustomerName,A.UCIF_ID,A.CurrencyAlt_Key,A.CurrencyName,A.AccountOpenDate,A.SchemeType,A.Productcode,A.ProductDescription,A.segmentcode,A.SegmentDescription,A.AcBuSegmentDescription,A.BankingType,A."BankingRelationship",A.SanctionLimit,A.SanctionLimitDt
                        --,A.AssetClassAlt_Key
                        ,A.RestructureAssetClassAlt_key,A.AssetClassName,A.NpaDt,A.DtofFirstDisb,A.RestructureTypeAlt_Key,A.RestructureType,A.RestructureCatgAlt_Key,A.RestructureFacility,A.PreRestrucDefaultDate,A.PreAssetClassName,A.PreRestrucNPA_Date,A.PostAssetClassName,A.Npa_Qtr,A.RestructureDt,A.RestructureProposalDt,A.RestructureAmt,A.ApprovingAuthAlt_Key,A.RestructureApprovalDt,A.POS_RepayStartDate,A.RestructurePOS,A.IntRepayStartDate,A.RefDate,A.InvocationDate,A.IsEquityCoversion,A.ConversionDate,A.Is_COVID_Morat,A.Covid_Morit,A.parameterAlt_Key,A.COVID_OTR_Catg,A.ReportingBank,A.ICA_SignDate,A.Is_InvestmentGrade,A."Status_Current_Quarter",A."Status_previous_Quarter",A."Status_of_MoniroringPeriod",A."Status_of_Specified_Period",A.CreditProvision,A.DFVProvision,A.MTMProvision,A.TotalProv,A."Percentage",A.TotalProvisionPrevious,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CRILIC_Fst_DefaultDate,A.Status_of_MoniroringPeriodAlt_Key,A.Status_of_Specified_PeriodAlt_Key,A.RevisedBusSegAlt_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.NPA_Provision_per,A.EquityConversionYN,A.CrntQtrAssetClass,A.PrevQtrAssetClass,A.MonitoringPeriodStatus,A.PrevQtrTotalProvision,A.AcBuSegmentDescription1 );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountEntityId  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'RestructureMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_235 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            DBMS_OUTPUT.PUT_LINE('NANDA1');
         END IF;
         /*  IT IS Used For GRID Search which are Pending for Authorization    */
         IF ( v_OperationFlag IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_23516') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_188 ';
            END IF;
            DELETE FROM tt_temp16_188;
            UTILS.IDENTITY_RESET('tt_temp16_188');

            INSERT INTO tt_temp16_188 ( 
            	SELECT A.AccountEntityId ,
                    A.SystemACID ,
                    A.SourceName ,
                    A.CustomerId ,
                    A.CustomerName ,
                    A.UCIF_ID ,
                    A.CurrencyAlt_Key ,
                    A.CurrencyName ,
                    A.AccountOpenDate ,
                    A.SchemeType ,
                    A.Productcode ,
                    A.ProductDescription ,
                    A.segmentcode ,
                    A.SegmentDescription ,
                    A.RevisedBusinessSegment ,
                    A.BankingType ,
                    A."BankingRelationship" ,
                    A.SanctionLimit ,
                    A.SanctionLimitDt ,
                    --,A.AssetClassAlt_Key
                    A.RestructureAssetClassAlt_key ,
                    A.AssetClassName ,
                    A.NpaDt ,
                    A.DtofFirstDisb ,
                    A.RestructureTypeAlt_Key ,
                    A.RestructureType ,
                    A.RestructureCatgAlt_Key ,
                    A.RestructureFacility ,
                    A.PreRestrucDefaultDate ,
                    A.PreAssetClassName ,
                    A.PreRestrucNPA_Date ,
                    A.PostAssetClassName ,
                    A.Npa_Qtr ,
                    A.RestructureDt ,
                    A.RestructureProposalDt ,
                    A.RestructureAmt ,
                    A.ApprovingAuthAlt_Key ,
                    A.RestructureApprovalDt ,
                    A.POS_RepayStartDate ,
                    A.RestructurePOS ,
                    A.IntRepayStartDate ,
                    A.RefDate ,
                    A.InvocationDate ,
                    A.IsEquityCoversion ,
                    A.ConversionDate ,
                    A.Is_COVID_Morat ,
                    A.Covid_Morit ,
                    A.parameterAlt_Key ,
                    A.COVID_OTR_Catg ,
                    A.ReportingBank ,
                    A.ICA_SignDate ,
                    A.Is_InvestmentGrade ,
                    A."Status_Current_Quarter" ,
                    A."Status_previous_Quarter" ,
                    A."Status_of_MoniroringPeriod" ,
                    A."Status_of_Specified_Period" ,
                    A.CreditProvision ,
                    A.DFVProvision ,
                    A.MTMProvision ,
                    A.TotalProv ,
                    A.Percentage ,
                    A.TotalProvisionPrevious ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.CRILIC_Fst_DefaultDate ,
                    A.Status_of_MoniroringPeriodAlt_Key ,
                    A.Status_of_Specified_PeriodAlt_Key ,
                    A.RevisedBusSegAlt_Key ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.NPA_Provision_per ,
                    A.EquityConversionYN ,
                    A.CrntQtrAssetClass ,
                    A.PrevQtrAssetClass ,
                    A.MonitoringPeriodStatus ,
                    A.PrevQtrTotalProvision ,
                    A.AcBuSegmentDescription 
            	  FROM ( SELECT A.AccountEntityId ,
                             B.SystemACID ,
                             C.SourceName ,
                             D.CustomerId ,
                             D.CustomerName ,
                             D.UCIF_ID ,
                             H.CurrencyCode CurrencyAlt_Key  ,
                             H.CurrencyName ,
                             --,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
                             CASE 
                                  WHEN AccountOpenDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountOpenDate,200),10,p_style=>103)
                                END AccountOpenDate  ,
                             B.FacilityType SchemeType  ,
                             G.ProductCode Productcode  ,
                             G.ProductName ProductDescription  ,
                             B.segmentcode ,
                             --,P.SegmentDescription SegmentDescription
                             --,W.EWS_SegmentName AS SegmentDescription
                             DBS.AcBuSegmentDescription SegmentDescription  ,
                             A.RevisedBusinessSegment ,
                             A.BankingType ,
                             M.ParameterName BankingRelationship  ,
                             B.CurrentLimit SanctionLimit  ,
                             --,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
                             CASE 
                                  WHEN B.CurrentLimitDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200),10,p_style=>103)
                                END SanctionLimitDt  ,
                             --,E.AssetClassAlt_Key -----------chk
                             A.RestructureAssetClassAlt_key ,
                             J.AssetClassName ,
                             CASE 
                                  WHEN F.NpaDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(F.NpaDt,10,p_style=>103)
                                END NpaDt  ,
                             --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
                             CASE 
                                  WHEN B.DtofFirstDisb IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200),10,p_style=>103)
                                END DtofFirstDisb  ,
                             A.RestructureTypeAlt_Key ,
                             k.ParameterName RestructureType  ,
                             A.RestructureCatgAlt_Key ,
                             L.ParameterName RestructureFacility  ,
                             --,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
                             CASE 
                                  WHEN A.PreRestrucDefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200),10,p_style=>103)
                                END PreRestrucDefaultDate  ,
                             Q.AssetClassName PreAssetClassName  ,
                             --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
                             CASE 
                                  WHEN Y.NPADt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200),10,p_style=>103)
                                END PreRestrucNPA_Date  ,
                             R.AssetClassName PostAssetClassName  ,
                             A.Npa_Qtr ,
                             --,Convert(Date,A.RestructureDt,103)RestructureDt
                             CASE 
                                  WHEN A.RestructureDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureDt,200),10,p_style=>103)
                                END RestructureDt  ,
                             --,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
                             CASE 
                                  WHEN A.RestructureProposalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200),10,p_style=>103)
                                END RestructureProposalDt  ,
                             A.RestructureAmt ,
                             A.ApprovingAuthAlt_Key ,
                             --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
                             CASE 
                                  WHEN A.RestructureApprovalDt IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200),10,p_style=>103)
                                END RestructureApprovalDt  ,
                             --,Convert(Date,A.RepaymentStartDate,103) POS_RepayStartDate
                             CASE 
                                  WHEN A.RepaymentStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200),10,p_style=>103)
                                END POS_RepayStartDate  ,
                             A.RestructurePOS ,
                             --,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate
                             CASE 
                                  WHEN A.IntRepayStartDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200),10,p_style=>103)
                                END IntRepayStartDate  ,
                             --,Convert(Date,A.RefDate,103)RefDate
                             CASE 
                                  WHEN A.RefDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200),10,p_style=>103)
                                END RefDate  ,
                             --,Convert(Date,A.InvocationDate,103)InvocationDate
                             CASE 
                                  WHEN A.InvocationDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200),10,p_style=>103)
                                END InvocationDate  ,
                             A.IsEquityCoversion ,
                             --,Convert(Date,A.ConversionDate,103)ConversionDate
                             CASE 
                                  WHEN A.ConversionDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200),10,p_style=>103)
                                END ConversionDate  ,
                             S.ParameterAlt_Key Is_COVID_Morat  ,
                             S.ParameterName Covid_Morit  ,
                             N.ParameterAlt_Key ,
                             N.ParameterName COVID_OTR_Catg  ,
                             A.FstDefaultReportingBank ReportingBank  ,
                             --,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
                             CASE 
                                  WHEN A.ICA_SignDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200),10,p_style=>103)
                                END ICA_SignDate  ,
                             Z.ParameterAlt_Key Is_InvestmentGrade  ,
                             --,P.[Status_Current_Quarter]
                             --,P.[Status_previous_Quarter]
                             --,P.[Status_of_MoniroringPeriod]
                             --,P.[Status_of_Specified_Period]
                             --,P.TotalProvisionPrevious
                             O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                             X.AssetClassName Status_Current_Quarter  ,
                             T.AssetClassName Status_previous_Quarter  ,
                             U.ParameterName Status_of_MoniroringPeriod  ,
                             V.ParameterName Status_of_Specified_Period  ,
                             A.CreditProvision ,
                             A.DFVProvision ,
                             A.MTMProvision ,
                             E.TotalProv ,
                             CASE 
                                  WHEN E.Balance <> 0 THEN utils.round_((E.TotalProv / E.Balance) * 100, 2)
                             ELSE 0
                                END Percentage  ,
                             --,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
                             CASE 
                                  WHEN A.CRILIC_Fst_DefaultDate IS NULL THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200),10,p_style=>103)
                                END CRILIC_Fst_DefaultDate  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                             A.ApprovedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,200,p_style=>103) DateApproved  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,200,p_style=>103) DateModified  ,
                             --,P.Status_of_MoniroringPeriodAlt_Key
                             --,P.Status_of_Specified_PeriodAlt_Key
                             O.MonitoringPeriodStatus Status_of_MoniroringPeriodAlt_Key  ,
                             O.SpecifiedPeriodStatus Status_of_Specified_PeriodAlt_Key  ,
                             A.RevisedBusSegAlt_Key ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             A.NPA_Provision_per ,
                             A.EquityConversionYN ,
                             o.CrntQtrAssetClass ,
                             o.PrevQtrAssetClass ,
                             o.MonitoringPeriodStatus ,
                             o.PrevQtrTotalProvision ,
                             DBS.AcBuSegmentDescription 
                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod A
                             JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                             AND E.EffectiveFromTimeKey <= v_TimeKey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                             AND F.EffectiveFromTimeKey <= v_TimeKey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                             AND O.EffectiveFromTimeKey <= v_TimeKey
                             AND O.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail Y   ON Y.RefCustomerID = A.RefCustomerId
                             AND Y.EffectiveFromTimeKey <= v_TimeKey
                             AND Y.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                             AND G.EffectiveFromTimeKey <= v_TimeKey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                             AND H.EffectiveFromTimeKey <= v_TimeKey
                             AND H.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = A.RestructureAssetClassAlt_key
                             AND J.EffectiveFromTimeKey <= v_TimeKey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass Q   ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key
                             AND Q.EffectiveFromTimeKey <= v_TimeKey
                             AND Q.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass R   ON R.AssetClassAlt_Key = A.PostRestrucAssetClass
                             AND R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter K   ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key
                             AND k.DimParameterName = 'TypeofRestructuring'
                             AND K.EffectiveFromTimeKey <= v_TimeKey
                             AND K.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter L   ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key
                             AND L.DimParameterName = 'RestructureFacility'
                             AND L.EffectiveFromTimeKey <= v_TimeKey
                             AND L.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter M   ON M.ParameterAlt_Key = A.BankingType
                             AND M.DimParameterName = 'BankingRelationship'
                             AND M.EffectiveFromTimeKey <= v_TimeKey
                             AND M.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter N   ON N.ParameterAlt_Key = A.COVID_OTR_Catg
                             AND N.DimParameterName = 'Covid - OTR Category'
                             AND N.EffectiveFromTimeKey <= v_TimeKey
                             AND N.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass X   ON X.AssetClassAlt_Key = O.CrntQtrAssetClass
                             AND X.EffectiveFromTimeKey <= v_TimeKey
                             AND X.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimAssetClass T   ON T.AssetClassAlt_Key = O.PrevQtrAssetClass
                             AND T.EffectiveFromTimeKey <= v_TimeKey
                             AND T.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter U   ON U.ParameterAlt_Key = O.MonitoringPeriodStatus
                             AND U.DimParameterName = 'StatusofMonitoringPeriod'
                             AND U.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimParameter V   ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus
                             AND V.DimParameterName = 'StatusofSpecificPeriod'
                             AND V.EffectiveFromTimeKey <= v_TimeKey
                             AND V.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DimSegment W   ON W.EWS_SegmentAlt_Key = B.segmentcode
                             AND W.EffectiveFromTimeKey <= v_TimeKey
                             AND W.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                             AND DBS.EffectiveFromTimeKey <= v_TimeKey
                             AND DBS.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'CovidMoratorium' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat
                             LEFT JOIN ( 
                                         --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                                         SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'InvestmentGrade' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND DimParameterName = 'DimYesNoNA' ) Z   ON Z.ParameterName = A.Is_InvestmentGrade
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY AccountEntityId )
                     ) A
            	  GROUP BY A.AccountEntityId,A.SystemACID,A.SourceName,A.CustomerId,A.CustomerName,A.UCIF_ID,A.CurrencyAlt_Key,A.CurrencyName,A.AccountOpenDate,A.SchemeType,A.Productcode,A.ProductDescription,A.segmentcode,A.SegmentDescription,A.RevisedBusinessSegment,A.BankingType,A."BankingRelationship",A.SanctionLimit,A.SanctionLimitDt
                        --,A.AssetClassAlt_Key
                        ,A.RestructureAssetClassAlt_key,A.AssetClassName,A.NpaDt,A.DtofFirstDisb,A.RestructureTypeAlt_Key,A.RestructureType,A.RestructureCatgAlt_Key,A.RestructureFacility,A.PreRestrucDefaultDate,A.PreAssetClassName,A.PreRestrucNPA_Date,A.PostAssetClassName,A.Npa_Qtr,A.RestructureDt,A.RestructureProposalDt,A.RestructureAmt,A.ApprovingAuthAlt_Key,A.RestructureApprovalDt,A.POS_RepayStartDate,A.RestructurePOS,A.IntRepayStartDate,A.RefDate,A.InvocationDate,A.IsEquityCoversion,A.ConversionDate,A.Is_COVID_Morat,A.Covid_Morit,A.parameterAlt_Key,A.COVID_OTR_Catg,A.ReportingBank,A.ICA_SignDate,A.Is_InvestmentGrade,A."Status_Current_Quarter",A."Status_previous_Quarter",A."Status_of_MoniroringPeriod",A."Status_of_Specified_Period",A.CreditProvision,A.DFVProvision,A.MTMProvision,A.TotalProv,A."Percentage",A.TotalProvisionPrevious,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CRILIC_Fst_DefaultDate,A.Status_of_MoniroringPeriodAlt_Key,A.Status_of_Specified_PeriodAlt_Key,A.RevisedBusSegAlt_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.NPA_Provision_per,A.EquityConversionYN,A.CrntQtrAssetClass,A.PrevQtrAssetClass,A.MonitoringPeriodStatus,A.PrevQtrTotalProvision,A.AcBuSegmentDescription );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountEntityId  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'RestructureMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp16_188 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize)
         ELSE
            IF ( v_OperationFlag IN ( 20 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_23520') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_153 ';
               END IF;
               DELETE FROM tt_temp20_153;
               UTILS.IDENTITY_RESET('tt_temp20_153');

               INSERT INTO tt_temp20_153 ( 
               	SELECT A.AccountEntityId ,
                       A.SystemACID ,
                       A.SourceName ,
                       A.CustomerId ,
                       A.CustomerName ,
                       A.UCIF_ID ,
                       A.CurrencyAlt_Key ,
                       A.CurrencyName ,
                       A.AccountOpenDate ,
                       A.SchemeType ,
                       A.Productcode ,
                       A.ProductDescription ,
                       A.segmentcode ,
                       A.SegmentDescription ,
                       A.RevisedBusinessSegment ,
                       A.BankingType ,
                       A."BankingRelationship" ,
                       A.SanctionLimit ,
                       A.SanctionLimitDt ,
                       --,A.AssetClassAlt_Key
                       A.RestructureAssetClassAlt_key ,
                       A.AssetClassName ,
                       A.NpaDt ,
                       A.DtofFirstDisb ,
                       A.RestructureTypeAlt_Key ,
                       A.RestructureType ,
                       A.RestructureCatgAlt_Key ,
                       A.RestructureFacility ,
                       A.PreRestrucDefaultDate ,
                       A.PreAssetClassName ,
                       A.PreRestrucNPA_Date ,
                       A.PostAssetClassName ,
                       A.Npa_Qtr ,
                       A.RestructureDt ,
                       A.RestructureProposalDt ,
                       A.RestructureAmt ,
                       A.ApprovingAuthAlt_Key ,
                       A.RestructureApprovalDt ,
                       A.POS_RepayStartDate ,
                       A.RestructurePOS ,
                       A.IntRepayStartDate ,
                       A.RefDate ,
                       A.InvocationDate ,
                       A.IsEquityCoversion ,
                       A.ConversionDate ,
                       A.Is_COVID_Morat ,
                       A.Covid_Morit ,
                       A.parameterAlt_Key ,
                       A.COVID_OTR_Catg ,
                       A.ReportingBank ,
                       A.ICA_SignDate ,
                       A.Is_InvestmentGrade ,
                       A."Status_Current_Quarter" ,
                       A."Status_previous_Quarter" ,
                       A."Status_of_MoniroringPeriod" ,
                       A."Status_of_Specified_Period" ,
                       A.CreditProvision ,
                       A.DFVProvision ,
                       A.MTMProvision ,
                       A.TotalProv ,
                       A.Percentage ,
                       A.TotalProvisionPrevious ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.CRILIC_Fst_DefaultDate ,
                       A.Status_of_MoniroringPeriodAlt_Key ,
                       A.Status_of_Specified_PeriodAlt_Key ,
                       A.RevisedBusSegAlt_Key ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.NPA_Provision_per ,
                       A.EquityConversionYN ,
                       A.CrntQtrAssetClass ,
                       A.PrevQtrAssetClass ,
                       A.MonitoringPeriodStatus ,
                       A.PrevQtrTotalProvision ,
                       A.AcBuSegmentDescription 
               	  FROM ( SELECT A.AccountEntityId ,
                                B.SystemACID ,
                                C.SourceName ,
                                D.CustomerId ,
                                D.CustomerName ,
                                D.UCIF_ID ,
                                H.CurrencyCode CurrencyAlt_Key  ,
                                H.CurrencyName ,
                                --,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
                                CASE 
                                     WHEN AccountOpenDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountOpenDate,200),10,p_style=>103)
                                   END AccountOpenDate  ,
                                B.FacilityType SchemeType  ,
                                G.ProductCode Productcode  ,
                                G.ProductName ProductDescription  ,
                                B.segmentcode ,
                                --,P.SegmentDescription SegmentDescription
                                --,W.EWS_SegmentName AS SegmentDescription
                                DBS.AcBuSegmentDescription SegmentDescription  ,
                                A.RevisedBusinessSegment ,
                                A.BankingType ,
                                M.ParameterName BankingRelationship  ,
                                B.CurrentLimit SanctionLimit  ,
                                --,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
                                CASE 
                                     WHEN B.CurrentLimitDt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200),10,p_style=>103)
                                   END SanctionLimitDt  ,
                                --,E.AssetClassAlt_Key -----------chk
                                A.RestructureAssetClassAlt_key ,
                                J.AssetClassName ,
                                CASE 
                                     WHEN F.NpaDt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(F.NpaDt,10,p_style=>103)
                                   END NpaDt  ,
                                --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
                                CASE 
                                     WHEN B.DtofFirstDisb IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200),10,p_style=>103)
                                   END DtofFirstDisb  ,
                                A.RestructureTypeAlt_Key ,
                                k.ParameterName RestructureType  ,
                                A.RestructureCatgAlt_Key ,
                                L.ParameterName RestructureFacility  ,
                                --,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
                                CASE 
                                     WHEN A.PreRestrucDefaultDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200),10,p_style=>103)
                                   END PreRestrucDefaultDate  ,
                                Q.AssetClassName PreAssetClassName  ,
                                --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
                                CASE 
                                     WHEN Y.NPADt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200),10,p_style=>103)
                                   END PreRestrucNPA_Date  ,
                                R.AssetClassName PostAssetClassName  ,
                                A.Npa_Qtr ,
                                --,Convert(Date,A.RestructureDt,103)RestructureDt
                                CASE 
                                     WHEN A.RestructureDt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureDt,200),10,p_style=>103)
                                   END RestructureDt  ,
                                --,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
                                CASE 
                                     WHEN A.RestructureProposalDt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200),10,p_style=>103)
                                   END RestructureProposalDt  ,
                                A.RestructureAmt ,
                                A.ApprovingAuthAlt_Key ,
                                --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
                                CASE 
                                     WHEN A.RestructureApprovalDt IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200),10,p_style=>103)
                                   END RestructureApprovalDt  ,
                                --,Convert(Date,A.RepaymentStartDate,103) POS_RepayStartDate
                                CASE 
                                     WHEN A.RepaymentStartDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200),10,p_style=>103)
                                   END POS_RepayStartDate  ,
                                A.RestructurePOS ,
                                --,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate
                                CASE 
                                     WHEN A.IntRepayStartDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200),10,p_style=>103)
                                   END IntRepayStartDate  ,
                                --,Convert(Date,A.RefDate,103)RefDate
                                CASE 
                                     WHEN A.RefDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200),10,p_style=>103)
                                   END RefDate  ,
                                --,Convert(Date,A.InvocationDate,103)InvocationDate
                                CASE 
                                     WHEN A.InvocationDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200),10,p_style=>103)
                                   END InvocationDate  ,
                                A.IsEquityCoversion ,
                                --,Convert(Date,A.ConversionDate,103)ConversionDate
                                CASE 
                                     WHEN A.ConversionDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200),10,p_style=>103)
                                   END ConversionDate  ,
                                S.ParameterAlt_Key Is_COVID_Morat  ,
                                S.ParameterName Covid_Morit  ,
                                N.ParameterAlt_Key ,
                                N.ParameterName COVID_OTR_Catg  ,
                                A.FstDefaultReportingBank ReportingBank  ,
                                --,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
                                CASE 
                                     WHEN A.ICA_SignDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200),10,p_style=>103)
                                   END ICA_SignDate  ,
                                Z.ParameterAlt_Key Is_InvestmentGrade  ,
                                --,P.[Status_Current_Quarter]
                                --,P.[Status_previous_Quarter]
                                --,P.[Status_of_MoniroringPeriod]
                                --,P.[Status_of_Specified_Period]
                                --,P.TotalProvisionPrevious
                                O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                                X.AssetClassName Status_Current_Quarter  ,
                                T.AssetClassName Status_previous_Quarter  ,
                                U.ParameterName Status_of_MoniroringPeriod  ,
                                V.ParameterName Status_of_Specified_Period  ,
                                A.CreditProvision ,
                                A.DFVProvision ,
                                A.MTMProvision ,
                                E.TotalProv ,
                                CASE 
                                     WHEN E.Balance <> 0 THEN utils.round_((E.TotalProv / E.Balance) * 100, 2)
                                ELSE 0
                                   END Percentage  ,
                                --,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
                                CASE 
                                     WHEN A.CRILIC_Fst_DefaultDate IS NULL THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200),10,p_style=>103)
                                   END CRILIC_Fst_DefaultDate  ,
                                --,isnull(A.AuthorisationStatus, 'A')
                                A.AuthorisationStatus ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                                A.ApprovedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,200,p_style=>103) DateApproved  ,
                                A.ModifiedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,200,p_style=>103) DateModified  ,
                                --,P.Status_of_MoniroringPeriodAlt_Key
                                --,P.Status_of_Specified_PeriodAlt_Key
                                O.MonitoringPeriodStatus Status_of_MoniroringPeriodAlt_Key  ,
                                O.SpecifiedPeriodStatus Status_of_Specified_PeriodAlt_Key  ,
                                A.RevisedBusSegAlt_Key ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                                A.NPA_Provision_per ,
                                A.EquityConversionYN ,
                                o.CrntQtrAssetClass ,
                                o.PrevQtrAssetClass ,
                                o.MonitoringPeriodStatus ,
                                o.PrevQtrTotalProvision ,
                                DBS.AcBuSegmentDescription 
                         FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod A
                                JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                JOIN RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                JOIN RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                                AND O.EffectiveFromTimeKey <= v_TimeKey
                                AND O.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail Y   ON Y.RefCustomerID = A.RefCustomerId
                                AND Y.EffectiveFromTimeKey <= v_TimeKey
                                AND Y.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = A.RestructureAssetClassAlt_key
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimAssetClass Q   ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key
                                AND Q.EffectiveFromTimeKey <= v_TimeKey
                                AND Q.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimAssetClass R   ON R.AssetClassAlt_Key = A.PostRestrucAssetClass
                                AND R.EffectiveFromTimeKey <= v_TimeKey
                                AND R.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter K   ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key
                                AND k.DimParameterName = 'TypeofRestructuring'
                                AND K.EffectiveFromTimeKey <= v_TimeKey
                                AND K.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter L   ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key
                                AND L.DimParameterName = 'RestructureFacility'
                                AND L.EffectiveFromTimeKey <= v_TimeKey
                                AND L.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter M   ON M.ParameterAlt_Key = A.BankingType
                                AND M.DimParameterName = 'BankingRelationship'
                                AND M.EffectiveFromTimeKey <= v_TimeKey
                                AND M.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter N   ON N.ParameterAlt_Key = A.COVID_OTR_Catg
                                AND N.DimParameterName = 'Covid - OTR Category'
                                AND N.EffectiveFromTimeKey <= v_TimeKey
                                AND N.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimAssetClass X   ON X.AssetClassAlt_Key = O.CrntQtrAssetClass
                                AND X.EffectiveFromTimeKey <= v_TimeKey
                                AND X.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimAssetClass T   ON T.AssetClassAlt_Key = O.PrevQtrAssetClass
                                AND T.EffectiveFromTimeKey <= v_TimeKey
                                AND T.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter U   ON U.ParameterAlt_Key = O.MonitoringPeriodStatus
                                AND U.DimParameterName = 'StatusofMonitoringPeriod'
                                AND U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimParameter V   ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus
                                AND V.DimParameterName = 'StatusofSpecificPeriod'
                                AND V.EffectiveFromTimeKey <= v_TimeKey
                                AND V.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DimSegment W   ON W.EWS_SegmentAlt_Key = B.segmentcode
                                AND W.EffectiveFromTimeKey <= v_TimeKey
                                AND W.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                                AND DBS.EffectiveFromTimeKey <= v_TimeKey
                                AND DBS.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'CovidMoratorium' TableName  
                                            FROM DimParameter 
                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                      AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat
                                LEFT JOIN ( 
                                            --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                                            SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'InvestmentGrade' TableName  
                                            FROM DimParameter 
                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                      AND DimParameterName = 'DimYesNoNA' ) Z   ON Z.ParameterName = A.Is_InvestmentGrade
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND AuthorisationStatus IN ( '1A' )

                                                          GROUP BY AccountEntityId )
                        ) A
               	  GROUP BY A.AccountEntityId,A.SystemACID,A.SourceName,A.CustomerId,A.CustomerName,A.UCIF_ID,A.CurrencyAlt_Key,A.CurrencyName,A.AccountOpenDate,A.SchemeType,A.Productcode,A.ProductDescription,A.segmentcode,A.SegmentDescription,A.RevisedBusinessSegment,A.BankingType,A."BankingRelationship",A.SanctionLimit,A.SanctionLimitDt
                           --,A.AssetClassAlt_Key
                           ,A.RestructureAssetClassAlt_key,A.AssetClassName,A.NpaDt,A.DtofFirstDisb,A.RestructureTypeAlt_Key,A.RestructureType,A.RestructureCatgAlt_Key,A.RestructureFacility,A.PreRestrucDefaultDate,A.PreAssetClassName,A.PreRestrucNPA_Date,A.PostAssetClassName,A.Npa_Qtr,A.RestructureDt,A.RestructureProposalDt,A.RestructureAmt,A.ApprovingAuthAlt_Key,A.RestructureApprovalDt,A.POS_RepayStartDate,A.RestructurePOS,A.IntRepayStartDate,A.RefDate,A.InvocationDate,A.IsEquityCoversion,A.ConversionDate,A.Is_COVID_Morat,A.Covid_Morit,A.parameterAlt_Key,A.COVID_OTR_Catg,A.ReportingBank,A.ICA_SignDate,A.Is_InvestmentGrade,A."Status_Current_Quarter",A."Status_previous_Quarter",A."Status_of_MoniroringPeriod",A."Status_of_Specified_Period",A.CreditProvision,A.DFVProvision,A.MTMProvision,A.TotalProv,A."Percentage",A.TotalProvisionPrevious,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CRILIC_Fst_DefaultDate,A.Status_of_MoniroringPeriodAlt_Key,A.Status_of_Specified_PeriodAlt_Key,A.RevisedBusSegAlt_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.NPA_Provision_per,A.EquityConversionYN,A.CrntQtrAssetClass,A.PrevQtrAssetClass,A.MonitoringPeriodStatus,A.PrevQtrTotalProvision,A.AcBuSegmentDescription );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountEntityId  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'RestructureMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp20_153 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERSEARCHLIST_29082023" TO "ADF_CDR_RBL_STGDB";
