--------------------------------------------------------
--  DDL for Procedure RESTRUCTUREMASTERVIEWLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

(
  --declare--@OperationFlag  INT         = 1--,
  v_RefSystemAcId IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF utils.object_id('TempDB..#Previous') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Previous_13 ';
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail A
                       WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey )
                                AND A.RefSystemAcId = v_RefSystemAcId
                                AND NVL(A.AuthorisationStatus, 'A') = 'A' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;


   --Select AccountEntityId,'SUB-STANDARD' as NPA_QTR,

   --		'SUB-STANDARD' as 'Status_Current_Quarter'

   --							,'SUB-STANDARD' as 'Status_previous Quarter'

   --							,'Under Monitoring Period' as 'Status of MoniroringPeriod'

   --							,'Under Specified Period' as 'Status of Specified Period'

   --							,150000 as TotalProvisionPrevious

   --							into #Previous

   -- from dbo.AdvAcBasicDetail where AccountEntityId=202

   --Select *

   --							into #Previous

   -- from (

   --Select AccountEntityId,'Corporate Loan' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'

   --,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'

   --,0 as TotalProvisionPrevious

   -- from dbo.AdvAcBasicDetail where AccountEntityId=202

   -- UNION ALL

   --Select AccountEntityId,'Corporate Loan' as SegmentDescription,'DOUBTFUL I' as 'Status_Current_Quarter','DOUBTFUL I' as 'Status_previous_Quarter'

   --,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'

   --,0 as TotalProvisionPrevious

   -- from dbo.AdvAcBasicDetail where AccountEntityId=101

   -- UNION ALL

   --Select AccountEntityId,'Corporate Loan' as SegmentDescription,'DOUBTFUL II' as 'Status_Current_Quarter','DOUBTFUL II' as 'Status_previous_Quarter'

   --,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'

   --,0 as TotalProvisionPrevious

   -- from dbo.AdvAcBasicDetail where AccountEntityId=102

   -- UNION ALL

   --Select AccountEntityId,'Professional Loan - MSE' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'

   --,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'

   --,0 as TotalProvisionPrevious

   -- from dbo.AdvAcBasicDetail where AccountEntityId=103

   -- UNION ALL

   --Select AccountEntityId,'Professional Loan - MSE' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'

   --,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'

   --,0 as TotalProvisionPrevious

   -- from dbo.AdvAcBasicDetail where AccountEntityId=104

   --)A

   -----------------------------------------------------------JAYADEV-08052021------------------------------------------------------------------------------------------------

   --Declare @TimeKey as Int

   --set @TimeKey = 49999

   --Declare @RefSystemAcId  VARCHAR(30)

   --set @RefSystemAcId = '9987880000000001'
   IF v_temp = 1 THEN

   BEGIN
      IF utils.object_id('TempDB..tt_temp_242') IS NOT NULL THEN

      BEGIN
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_242 ';

      END;
      END IF;
      DELETE FROM tt_temp_242;
      UTILS.IDENTITY_RESET('tt_temp_242');

      INSERT INTO tt_temp_242 ( 
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
              A.BankingRelationship ,
              A.SanctionLimit ,
              A.SanctionLimitDt ,
              A.AssetClassAlt_Key ,
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
              A.Status_Current_Quarter ,
              A.Status_previous_Quarter ,
              A.Status_of_MoniroringPeriod ,
              A.Status_of_Specified_Period ,
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
                       UTILS.CONVERT_TO_VARCHAR2(B.AccountOpenDate,200,p_style=>103) AccountOpenDate  ,
                       B.FacilityType SchemeType  ,
                       G.ProductCode Productcode  ,
                       G.ProductName ProductDescription  ,
                       B.segmentcode ,
                       --,P.SegmentDescription SegmentDescription
                       DBS.AcBuSegmentDescription SegmentDescription  ,
                       A.RevisedBusinessSegment ,
                       A.BankingType ,
                       M.ParameterName BankingRelationship  ,
                       B.CurrentLimit SanctionLimit  ,
                       UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200,p_style=>103) SanctionLimitDt  ,
                       E.AssetClassAlt_Key ,
                       J.AssetClassName ,
                       F.NpaDt ,
                       UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200,p_style=>103) DtofFirstDisb  ,
                       A.RestructureTypeAlt_Key ,
                       k.ParameterName RestructureType  ,
                       A.RestructureCatgAlt_Key ,
                       L.ParameterName RestructureFacility  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200,p_style=>103) PreRestrucDefaultDate  ,
                       Q.AssetClassName PreAssetClassName  ,
                       UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200,p_style=>103) PreRestrucNPA_Date  ,
                       R.AssetClassName PostAssetClassName  ,
                       A.Npa_Qtr ,
                       UTILS.CONVERT_TO_VARCHAR2(A.RestructureDt,200,p_style=>103) RestructureDt  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200,p_style=>103) RestructureProposalDt  ,
                       A.RestructureAmt ,
                       A.ApprovingAuthAlt_Key ,
                       UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200,p_style=>103) RestructureApprovalDt  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200,p_style=>103) POS_RepayStartDate  ,
                       A.RestructurePOS ,
                       UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200,p_style=>103) IntRepayStartDate  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200,p_style=>103) RefDate  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200,p_style=>103) InvocationDate  ,
                       A.IsEquityCoversion ,
                       UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200,p_style=>103) ConversionDate  ,
                       S.ParameterAlt_Key Is_COVID_Morat  ,
                       S.ParameterName Covid_Morit  ,
                       N.ParameterAlt_Key ,
                       N.ParameterName COVID_OTR_Catg  ,
                       A.FstDefaultReportingBank ReportingBank  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200,p_style=>103) ICA_SignDate  ,
                       A.Is_InvestmentGrade ,
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
                       utils.round_((E.TotalProv / E.Balance) * 100, 2) Percentage  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200,p_style=>103) CRILIC_Fst_DefaultDate  ,
                       NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>105) DateCreated  ,
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
                       DBS.AcBuRevisedSegmentCode AcBuSegmentDescription  
                FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail A
                       JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                       AND B.EffectiveFromTimeKey <= v_TimeKey
                       AND B.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                       AND DBS.EffectiveFromTimeKey <= v_TimeKey
                       AND DBS.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                       AND C.EffectiveFromTimeKey <= v_TimeKey
                       AND C.EffectiveToTimeKey >= v_TimeKey
                       JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                       AND D.EffectiveFromTimeKey <= v_TimeKey
                       AND D.EffectiveToTimeKey >= v_TimeKey
                       JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                       AND E.EffectiveFromTimeKey <= v_TimeKey
                       AND E.EffectiveToTimeKey >= v_TimeKey
                       JOIN CurDat_RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                       AND F.EffectiveFromTimeKey <= v_TimeKey
                       AND F.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                       AND O.EffectiveFromTimeKey <= v_TimeKey
                       AND O.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail Y   ON Y.RefCustomerID = A.RefCustomerId
                       AND Y.EffectiveFromTimeKey <= v_TimeKey
                       AND Y.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                       AND G.EffectiveFromTimeKey <= v_TimeKey
                       AND G.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                       AND H.EffectiveFromTimeKey <= v_TimeKey
                       AND H.EffectiveToTimeKey >= v_TimeKey
                       LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = E.AssetClassAlt_Key
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
                       LEFT JOIN ( 
                                   --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

                                   --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey
                                   SELECT ParameterAlt_Key ,
                                          ParameterName ,
                                          'CovidMoratorium' TableName  
                                   FROM DimParameter 
                                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                                             AND EffectiveToTimeKey >= v_TimeKey
                                             AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat

                --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND NVL(A.AuthorisationStatus, 'A') = 'A'

                         --AND A.RefSystemAcId=@RefSystemAcId
                         AND A.RefSystemAcId = v_RefSystemAcId ) A );
      OPEN  v_cursor FOR
         SELECT ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountEntityId  ) RowNumber  
                    FROM DUAL  ) ,
                COUNT(*) OVER ( ) TotalCount  ,
                'RestructureMaster' TableName  ,
                * 
           FROM tt_temp_242  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND RefSystemAcId = v_RefSystemAcId );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         IF utils.object_id('TempDB..tt_temp_2421') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_16 ';

         END;
         END IF;
         DELETE FROM tt_temp1_16;
         UTILS.IDENTITY_RESET('tt_temp1_16');

         INSERT INTO tt_temp1_16 ( 
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
                 A.AssetClassAlt_Key ,
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
                 A.AcBuSegmentDescription AcBuSegmentDescription  
         	  FROM ( SELECT A.AccountEntityId ,
                          B.SystemACID ,
                          C.SourceName ,
                          D.CustomerId ,
                          D.CustomerName ,
                          D.UCIF_ID ,
                          H.CurrencyCode CurrencyAlt_Key  ,
                          H.CurrencyName ,
                          UTILS.CONVERT_TO_VARCHAR2(B.AccountOpenDate,200,p_style=>103) AccountOpenDate  ,
                          B.FacilityType SchemeType  ,
                          G.ProductCode Productcode  ,
                          G.ProductName ProductDescription  ,
                          B.segmentcode ,
                          --,P.SegmentDescription SegmentDescription
                          DBS.AcBuSegmentDescription SegmentDescription  ,
                          A.RevisedBusinessSegment ,
                          A.BankingType ,
                          M.ParameterName BankingRelationship  ,
                          B.CurrentLimit SanctionLimit  ,
                          UTILS.CONVERT_TO_VARCHAR2(B.CurrentLimitDt,200,p_style=>103) SanctionLimitDt  ,
                          E.AssetClassAlt_Key ,
                          J.AssetClassName ,
                          F.NpaDt ,
                          UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200,p_style=>103) DtofFirstDisb  ,
                          A.RestructureTypeAlt_Key ,
                          k.ParameterName RestructureType  ,
                          A.RestructureCatgAlt_Key ,
                          L.ParameterName RestructureFacility  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.PreRestrucDefaultDate,200,p_style=>103) PreRestrucDefaultDate  ,
                          Q.AssetClassName PreAssetClassName  ,
                          UTILS.CONVERT_TO_VARCHAR2(Y.NPADt,200,p_style=>103) PreRestrucNPA_Date  ,
                          R.AssetClassName PostAssetClassName  ,
                          A.Npa_Qtr ,
                          UTILS.CONVERT_TO_VARCHAR2(A.RestructureDt,200,p_style=>103) RestructureDt  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.RestructureProposalDt,200,p_style=>103) RestructureProposalDt  ,
                          A.RestructureAmt ,
                          A.ApprovingAuthAlt_Key ,
                          UTILS.CONVERT_TO_VARCHAR2(A.RestructureApprovalDt,200,p_style=>103) RestructureApprovalDt  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.RepaymentStartDate,200,p_style=>103) POS_RepayStartDate  ,
                          A.RestructurePOS ,
                          UTILS.CONVERT_TO_VARCHAR2(A.IntRepayStartDate,200,p_style=>103) IntRepayStartDate  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.RefDate,200,p_style=>103) RefDate  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.InvocationDate,200,p_style=>103) InvocationDate  ,
                          A.IsEquityCoversion ,
                          UTILS.CONVERT_TO_VARCHAR2(A.ConversionDate,200,p_style=>103) ConversionDate  ,
                          S.ParameterAlt_Key Is_COVID_Morat  ,
                          S.ParameterName Covid_Morit  ,
                          N.ParameterAlt_Key ,
                          N.ParameterName COVID_OTR_Catg  ,
                          A.FstDefaultReportingBank ReportingBank  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.ICA_SignDate,200,p_style=>103) ICA_SignDate  ,
                          A.Is_InvestmentGrade ,
                          --,P.[Status_Current_Quarter]
                          --,P.[Status_previous_Quarter]
                          --,P.[Status_of_MoniroringPeriod]
                          --,P.[Status_of_Specified_Period]
                          O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                          X.AssetClassName Status_Current_Quarter  ,
                          T.AssetClassName Status_previous_Quarter  ,
                          U.ParameterName Status_of_MoniroringPeriod  ,
                          V.ParameterName Status_of_Specified_Period  ,
                          A.CreditProvision ,
                          A.DFVProvision ,
                          A.MTMProvision ,
                          E.TotalProv ,
                          utils.round_((E.TotalProv / E.Balance) * 100, 2) Percentage  ,
                          --,P.TotalProvisionPrevious
                          UTILS.CONVERT_TO_VARCHAR2(A.CRILIC_Fst_DefaultDate,200,p_style=>103) CRILIC_Fst_DefaultDate  ,
                          NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>105) DateCreated  ,
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
                          DBS.AcBuRevisedSegmentCode AcBuSegmentDescription  
                   FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod A
                          JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                          AND DBS.EffectiveFromTimeKey <= v_TimeKey
                          AND DBS.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                          AND C.EffectiveFromTimeKey <= v_TimeKey
                          AND C.EffectiveToTimeKey >= v_TimeKey
                          JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = A.RefCustomerId
                          AND D.EffectiveFromTimeKey <= v_TimeKey
                          AND D.EffectiveToTimeKey >= v_TimeKey
                          JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = A.AccountEntityId
                          AND E.EffectiveFromTimeKey <= v_TimeKey
                          AND E.EffectiveToTimeKey >= v_TimeKey
                          JOIN CurDat_RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = A.AccountEntityId
                          AND F.EffectiveFromTimeKey <= v_TimeKey
                          AND F.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                          AND O.EffectiveFromTimeKey <= v_TimeKey
                          AND O.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail Y   ON Y.RefCustomerID = A.RefCustomerId
                          AND Y.EffectiveFromTimeKey <= v_TimeKey
                          AND Y.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                          AND G.EffectiveFromTimeKey <= v_TimeKey
                          AND G.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                          AND H.EffectiveFromTimeKey <= v_TimeKey
                          AND H.EffectiveToTimeKey >= v_TimeKey
                          LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = E.AssetClassAlt_Key
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
                          LEFT JOIN ( 
                                      --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

                                      --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey
                                      SELECT ParameterAlt_Key ,
                                             ParameterName ,
                                             'CovidMoratorium' TableName  
                                      FROM DimParameter 
                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey
                                                AND DimParameterName = 'DimYesNoNA' ) S   ON S.ParameterAlt_Key = A.Is_COVID_Morat

                   --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
                   WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                            AND A.RefSystemAcId = v_RefSystemAcId

                            --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                            AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                 FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                   GROUP BY AccountEntityId )
                  ) A
         	  GROUP BY A.AccountEntityId,A.SystemACID,A.SourceName,A.CustomerId,A.CustomerName,A.UCIF_ID,A.CurrencyAlt_Key,A.CurrencyName,A.AccountOpenDate,A.SchemeType,A.Productcode,A.ProductDescription,A.segmentcode,A.SegmentDescription,A.RevisedBusinessSegment,A.BankingType,A."BankingRelationship",A.SanctionLimit,A.SanctionLimitDt,A.AssetClassAlt_Key,A.AssetClassName,A.NpaDt,A.DtofFirstDisb,A.RestructureTypeAlt_Key,A.RestructureType,A.RestructureCatgAlt_Key,A.RestructureFacility,A.PreRestrucDefaultDate,A.PreAssetClassName,A.PreRestrucNPA_Date,A.PostAssetClassName,A.Npa_Qtr,A.RestructureDt,A.RestructureProposalDt,A.RestructureAmt,A.ApprovingAuthAlt_Key,A.RestructureApprovalDt,A.POS_RepayStartDate,A.RestructurePOS,A.IntRepayStartDate,A.RefDate,A.InvocationDate,A.IsEquityCoversion,A.ConversionDate,A.Is_COVID_Morat,A.Covid_Morit,A.parameterAlt_Key,A.COVID_OTR_Catg,A.ReportingBank,A.ICA_SignDate,A.Is_InvestmentGrade,A."Status_Current_Quarter",A."Status_previous_Quarter",A."Status_of_MoniroringPeriod",A."Status_of_Specified_Period",A.CreditProvision,A.DFVProvision,A.MTMProvision,A.TotalProv,A."Percentage",A.TotalProvisionPrevious,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CRILIC_Fst_DefaultDate,A.Status_of_MoniroringPeriodAlt_Key,A.Status_of_Specified_PeriodAlt_Key,A.RevisedBusSegAlt_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.NPA_Provision_per,A.EquityConversionYN,A.CrntQtrAssetClass,A.PrevQtrAssetClass,A.MonitoringPeriodStatus,A.PrevQtrTotalProvision,A.AcBuSegmentDescription );
         OPEN  v_cursor FOR
            SELECT 
                   --(SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber), 

                   --       COUNT(*) OVER() AS TotalCount, 
                   'RestructureMasterMod' TableName  ,
                   * 
              FROM tt_temp1_16  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;

      -----------------------------------------------JAYADEV END-----------------------------------------------------------------------------------------------------------------
      ELSE


      --Declare @TimeKey as Int

      --set @TimeKey = 49999

      --Declare @RefSystemAcId  VARCHAR(30)

      --set @RefSystemAcId = '9987880000000001'
      BEGIN
         IF utils.object_id('TempDB..tt_temp_2422') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_9 ';

         END;
         END IF;
         DBMS_OUTPUT.PUT_LINE('Sachin11');
         DELETE FROM tt_temp2_9;
         UTILS.IDENTITY_RESET('tt_temp2_9');

         INSERT INTO tt_temp2_9 ( 
         	SELECT A.AccountEntityId ,
                 A.SystemACID ,
                 A.SourceName ,
                 A.CustomerId ,
                 A.CustomerName ,
                 A.UCIF_ID ,
                 A.CurrencyName ,
                 A.AccountOpenDate ,
                 A.SchemeType ,
                 A.Productcode ,
                 A.ProductDescription ,
                 A.segmentcode ,
                 A.SegmentDescription ,
                 A.SanctionLimit ,
                 A.SanctionLimitDt ,
                 A.AssetClassName ,
                 A.TotalProv ,
                 A.Percentage ,
                 A.TotalProvisionPrevious ,
                 A.Status_Current_Quarter ,
                 A.Status_previous_Quarter ,
                 A.Status_of_MoniroringPeriod ,
                 A.Status_of_Specified_Period ,
                 A.CrntQtrAssetClass ,
                 A.PrevQtrAssetClass ,
                 A.MonitoringPeriodStatus ,
                 A.PrevQtrTotalProvision ,
                 A.AcBuSegmentDescription ,
                 A.DtofFirstDisb 
         	  FROM ( SELECT B.AccountEntityId ,
                          B.SystemACID ,
                          C.SourceName ,---

                          D.CustomerId ,--

                          D.CustomerName ,--

                          D.UCIF_ID ,--

                          H.CurrencyName ,
                          B.AccountOpenDate ,
                          B.FacilityType SchemeType  ,
                          B.ProductAlt_Key Productcode  ,
                          G.ProductName ProductDescription  ,
                          B.segmentcode ,
                          DBS.AcBuSegmentDescription SegmentDescription  ,
                          B.CurrentLimit SanctionLimit  ,
                          B.CurrentLimitDt SanctionLimitDt  ,
                          J.AssetClassName ,
                          E.TotalProv ,
                          utils.round_(E.TotalProv / E.Balance, 2) * 100 Percentage  ,
                          --,P.TotalProvisionPrevious
                          --,P.[Status_Current_Quarter]
                          --,P.[Status_previous_Quarter]
                          --,P.[Status_of_MoniroringPeriod]
                          --,P.[Status_of_Specified_Period]
                          O.PrevQtrTotalProvision TotalProvisionPrevious  ,
                          S.AssetClassName Status_Current_Quarter  ,
                          T.AssetClassName Status_previous_Quarter  ,
                          U.ParameterName Status_of_MoniroringPeriod  ,
                          V.ParameterName Status_of_Specified_Period  ,
                          --,Q.AssetClassName PreAssetClassName
                          --,R.AssetClassName PostAssetClassName
                          --,A.PreRestrucDefaultDate
                          --,A.PreRestrucNPA_Date
                          --      ,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                          --A.EffectiveFromTimeKey, 
                          --A.EffectiveToTimeKey, 
                          --A.CreatedBy, 
                          --A.DateCreated, 
                          --A.ApprovedBy, 
                          --A.DateApproved, 
                          --A.ModifiedBy, 
                          --A.DateModified
                          o.CrntQtrAssetClass ,
                          o.PrevQtrAssetClass ,
                          o.MonitoringPeriodStatus ,
                          o.PrevQtrTotalProvision ,
                          DBS.AcBuRevisedSegmentCode AcBuSegmentDescription  ,
                          UTILS.CONVERT_TO_VARCHAR2(B.DtofFirstDisb,200,p_style=>103) DtofFirstDisb  
                   FROM
                   --[CurDat].[AdvAcRestructureDetail] A
                    --INNER JOIN  
                    RBL_MISDB_PROD.AdvAcBasicDetail B
                    --ON B.AccountEntityId =A.AccountEntityId
                     --AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey

                      LEFT JOIN DimAcBuSegment DBS   ON B.segmentcode = DBS.AcBuSegmentCode
                      AND DBS.EffectiveFromTimeKey <= v_TimeKey
                      AND DBS.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON C.SourceAlt_Key = B.SourceAlt_Key
                      AND C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                      AND D.EffectiveFromTimeKey <= v_TimeKey
                      AND D.EffectiveToTimeKey >= v_TimeKey
                      JOIN RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.AccountEntityId = B.AccountEntityId
                      AND E.EffectiveFromTimeKey <= v_TimeKey
                      AND E.EffectiveToTimeKey >= v_TimeKey
                      JOIN RBL_MISDB_PROD.AdvAcFinancialDetail F   ON F.AccountEntityId = B.AccountEntityId
                      AND F.EffectiveFromTimeKey <= v_TimeKey
                      AND F.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal O   ON O.AccountEntityId = B.AccountEntityId
                      AND O.EffectiveFromTimeKey <= v_TimeKey
                      AND O.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail Y   ON Y.RefCustomerID = D.CustomerId
                      AND Y.EffectiveFromTimeKey <= v_TimeKey
                      AND Y.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.DimProduct G   ON G.ProductAlt_Key = B.ProductAlt_Key
                      AND G.EffectiveFromTimeKey <= v_TimeKey
                      AND G.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.DimCurrency H   ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
                      AND H.EffectiveFromTimeKey <= v_TimeKey
                      AND H.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.DimAssetClass J   ON J.AssetClassAlt_Key = E.AssetClassAlt_Key
                      AND J.EffectiveFromTimeKey <= v_TimeKey
                      AND J.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN RBL_MISDB_PROD.DimAssetClass S   ON S.AssetClassAlt_Key = O.CrntQtrAssetClass
                      AND S.EffectiveFromTimeKey <= v_TimeKey
                      AND S.EffectiveToTimeKey >= v_TimeKey
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
                    --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode
                     --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey

                      LEFT JOIN RBL_MISDB_PROD.DimAssetClass Q   ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key
                      AND Q.EffectiveFromTimeKey <= v_TimeKey
                      AND Q.EffectiveToTimeKey >= v_TimeKey

                   --INNER JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 

                   --AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     

                   --INNER JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'

                   --AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey

                   --INNER JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'

                   --AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey

                   --INNER JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingType AND M.DimParameterName='BankingRelationship'

                   --AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey

                   --INNER JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_Catg AND N.DimParameterName='Covid - OTR Category'

                   --AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey

                   --LEFT JOIN #Previous P ON P.AccountEntityId=B.AccountEntityId
                   WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey

                            --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            AND B.SystemAcId = v_RefSystemAcId ) A
         	  GROUP BY A.AccountEntityId,A.SystemACID,A.SourceName,A.CustomerId,A.CustomerName,A.UCIF_ID,A.CurrencyName,A.AccountOpenDate,A.SchemeType,A.Productcode,A.ProductDescription,A.segmentcode,A.SegmentDescription,A.SanctionLimit,A.SanctionLimitDt,A.AssetClassName,A.TotalProv,A.Percentage,A.TotalProvisionPrevious,A.Status_Current_Quarter,A.Status_previous_Quarter,A.Status_of_MoniroringPeriod,A.Status_of_Specified_Period,A.CrntQtrAssetClass,A.PrevQtrAssetClass,A.MonitoringPeriodStatus,A.PrevQtrTotalProvision,A.AcBuSegmentDescription,A.DtofFirstDisb );
         OPEN  v_cursor FOR
            SELECT ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountEntityId  ) RowNumber  
                       FROM DUAL  ) ,
                   COUNT(*) OVER ( ) TotalCount  ,
                   'CustomerDetail' TableName  ,
                   * 
              FROM tt_temp2_9  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREMASTERVIEWLIST" TO "ADF_CDR_RBL_STGDB";
