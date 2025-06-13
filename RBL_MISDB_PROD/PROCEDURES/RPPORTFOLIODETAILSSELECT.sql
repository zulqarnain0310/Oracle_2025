--------------------------------------------------------
--  DDL for Procedure RPPORTFOLIODETAILSSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" 
(
  --declare						
  v_PAN_No IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Date VARCHAR2(200);
   v_cursor SYS_REFCURSOR;
--@PAN_No VARCHAR(12)='1234567765'

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

     INTO v_Date
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';

   BEGIN
      OPEN  v_cursor FOR
         SELECT v_Date ProcessDate  ,
                A.PAN_No ,
                A.UCIC_ID ,
                A.CustomerID ,
                A.CustomerName ,
                A.BankingArrangementAlt_Key ,
                C.ArrangementDescription ,
                UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,20,p_style=>103) BorrowerDefaultDate  ,
                A.LeadBankAlt_Key ,
                B.BankName LeadBankName  ,
                A.ExposureBucketAlt_Key ,
                D.BucketName ,
                A.DefaultStatusAlt_Key ,
                H.ParameterName DefaultStatus  ,
                UTILS.CONVERT_TO_VARCHAR2(A.ReferenceDate,20,p_style=>103) ReferenceDate  ,
                UTILS.CONVERT_TO_VARCHAR2(A.ReviewExpiryDate,20,p_style=>103) ReviewExpiryDate  ,
                UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,20,p_style=>103) RP_ApprovalDate  ,
                A.RPNatureAlt_Key ,
                E.RPDescription RP_Nature  ,
                A.If_Other ,
                UTILS.CONVERT_TO_VARCHAR2(A.RP_ExpiryDate,20,p_style=>103) RP_ExpiryDate  ,
                UTILS.CONVERT_TO_VARCHAR2(A.RP_ImplDate,20,p_style=>103) RP_ImplDate  ,
                A.RP_ImplStatusAlt_Key ,
                I.ParameterName RP_ImplStatus  ,
                A.RP_failed ,
                UTILS.CONVERT_TO_VARCHAR2(A.Revised_RP_Expiry_Date,20,p_style=>103) Revised_RP_Expiry_Date  ,
                UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,20,p_style=>103) Actual_Impl_Date  ,
                UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,20,p_style=>103) RP_OutOfDateAllBanksDeadline  ,
                A.IsBankExposure ,
                G.AssetClassName ,
                UTILS.CONVERT_TO_VARCHAR2(A.RiskReviewExpiryDate,20,p_style=>103) RiskReviewExpiryDate  ,
                'AutomationRPScreenData' TableName  
           FROM RP_Portfolio_Details A
                  LEFT JOIN DimBankRP B   ON A.LeadBankAlt_Key = B.BankRPAlt_Key
                  AND B.EffectiveFromTimeKey <= v_Timekey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimBankingArrangement C   ON A.BankingArrangementAlt_Key = C.BankingArrangementAlt_Key
                  AND C.EffectiveFromTimeKey <= v_Timekey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimExposureBucket D   ON A.ExposureBucketAlt_Key = D.ExposureBucketAlt_Key
                  AND D.EffectiveFromTimeKey <= v_Timekey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimResolutionPlanNature E   ON A.RPNatureAlt_Key = E.RPNatureAlt_Key
                  AND E.EffectiveFromTimeKey <= v_Timekey
                  AND E.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN DimAssetClass G   ON A.AssetClassAlt_Key = G.AssetClassAlt_Key
                  AND G.EffectiveFromTimeKey <= v_Timekey
                  AND G.EffectiveToTimeKey >= v_TimeKey
                  JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName ,
                                'BorrowerDefaultStatus' Tablename  
                         FROM DimParameter 
                          WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
                  JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName ,
                                'ImplementationStatus' Tablename  
                         FROM DimParameter 
                          WHERE  DimParameterName = 'ImplementationStatus'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
          WHERE  A.PAN_No = v_PAN_No
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                   AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
                  ) ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   DECLARE
      v_Cust_Id VARCHAR2(20) := ( SELECT CustomerID 
        FROM RP_Portfolio_Details A
               JOIN ( SELECT ParameterAlt_Key ,
                             ParameterName ,
                             'BorrowerDefaultStatus' Tablename  
                      FROM DimParameter 
                       WHERE  DimParameterName = 'BorrowerDefaultStatus'
                                AND EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.DefaultStatusAlt_Key
               JOIN ( SELECT ParameterAlt_Key ,
                             ParameterName ,
                             'ImplementationStatus' Tablename  
                      FROM DimParameter 
                       WHERE  DimParameterName = 'ImplementationStatus'
                                AND EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.RP_ImplStatusAlt_Key
       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND A.PAN_No = v_PAN_No
                AND ( ( A.DefaultStatusAlt_Key NOT IN ( 2 )

                AND A.RP_ImplStatusAlt_Key NOT IN ( 1,4 )
               ) ) );
   --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
   --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))

   BEGIN
      --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
      --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
      RPLenderDetailsSelect(v_CustomerID => v_Cust_Id) ;--exec RPPortfolioDetailsSelect @PAN_NO=1234567765

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIODETAILSSELECT" TO "ADF_CDR_RBL_STGDB";
