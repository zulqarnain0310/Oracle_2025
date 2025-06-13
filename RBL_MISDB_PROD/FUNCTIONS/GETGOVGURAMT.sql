--------------------------------------------------------
--  DDL for Function GETGOVGURAMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."GETGOVGURAMT" 
-- =============================================
 -- Author:		<Madhur Nagar>
 -- Create date: <03/05/2011>
 -- Description:	<Calculation of Govt. Guar Amount from Ac to Customer Depends on parameter>
 -- =============================================

(
  v_CustomerEntityID IN NUMBER,
  v_timekey IN NUMBER
)
RETURN NUMBER
AS
   --Declare Part
   v_GovGurAmt NUMBER(14,0);
   v_Strclientname VARCHAR2(6);
   v_GovtGuarantee VARCHAR2(8);
   v_cursor SYS_REFCURSOR;

BEGIN
   --Find out Client Name
   SELECT ParameterValue 

     INTO v_Strclientname
     FROM SysSolutionParameter 
    WHERE  ParameterName = 'ClientName'
             AND EffectiveFromTimeKey <= v_timekey
             AND EffectiveToTimeKey >= v_timekey;
   --Find out Security parameter
   SELECT ParameterValue 

     INTO v_GovtGuarantee
     FROM SysSolutionParameter 
    WHERE  ParameterName = 'GovtGuarantee'
             AND EffectiveFromTimeKey <= v_timekey
             AND EffectiveToTimeKey >= v_timekey;
   --Set Default value to Zero
   v_GovGurAmt := 0 ;
   --In CUSTFULL sum of Govt guar amt of all Acc where Govt Guar available
   --In CUSTAPP sum of govt. guar amt to the extebd of OS Bal  where Govt Guar available
   --Govt. Guar. amount at account level Directly updated at Customer level without any logic
   IF v_GovtGuarantee = 'CUSTFULL' THEN

   BEGIN
      SELECT SUM(GovGurAmt)  

        INTO v_GovGurAmt
        FROM AdvAcOtherDetail 
               JOIN AdvAcCal    ON AdvAcCal.AccountEntityID = AdvAcOtherDetail.AccountEntityId
               JOIN DimAcSplCategory DimAcSplCategory1   ON AdvAcOtherDetail.SplCatg1Alt_Key = DimAcSplCategory1.SplCatAlt_Key
               JOIN DimAcSplCategory DimAcSplCategory2   ON AdvAcOtherDetail.SplCatg2Alt_Key = DimAcSplCategory2.SplCatAlt_Key
       WHERE  ( AdvAcOtherDetail.EffectiveFromTimeKey <= v_timekey
                AND AdvAcOtherDetail.EffectiveToTimeKey >= v_timekey )
                AND ( AdvAcCal.EffectiveFromTimeKey <= v_Timekey
                AND AdvAcCal.EffectiveToTimeKey >= v_Timekey )
                AND ( DimAcSplCategory1.SplCatShortNameEnum IN ( 'STGOVT GUA','CENGOV GUA' )

                OR DimAcSplCategory2.SplCatShortNameEnum IN ( 'STGOVT GUA','CENGOV GUA' )
               )
                AND AdvAcCal.CustomerEntityID = v_CustomerEntityID;

   END;

   --Govt. Guar. Amount at Account level compare with bal OS which is less will be updated sum of as customer level
   ELSE
      IF v_GovtGuarantee = 'CUSTAPP' THEN

      BEGIN
         OPEN  v_cursor FOR
            WITH CTE_GovtGuar ( Customer_Key,
                                Ac_Key,
                                GovGurAmt ) AS ( SELECT v_CustomerEntityID ,
                                                        AdvAcCal.AccountEntityID ,
                                                        CASE 
                                                             WHEN NVL(AdvAcOtherDetail.GovGurAmt, 0) > NVL(AdvAcBalanceDetail.Balance, 0) THEN NVL(AdvAcBalanceDetail.Balance, 0)
                                                        ELSE NVL(AdvAcOtherDetail.GovGurAmt, 0)
                                                           END GovGurAmt  
           FROM AdvAcOtherDetail 
                  JOIN AdvAcCal    ON AdvAcCal.AccountEntityID = AdvAcOtherDetail.AccountEntityID
                  JOIN AdvAcBalanceDetail    ON AdvAcCal.AccountEntityID = AdvAcBalanceDetail.AccountEntityID
                  JOIN DimAcSplCategory DimAcSplCategory1   ON AdvAcOtherDetail.SplCatg1ALt_Key = DimAcSplCategory1.SplCatAlt_Key
                  JOIN DimAcSplCategory DimAcSplCategory2   ON AdvAcOtherDetail.SplCatg2Alt_Key = DimAcSplCategory2.SplCatAlt_Key
          WHERE  ( AdvAcBalanceDetail.EffectiveFromTimeKey <= v_timekey
                   AND AdvAcBalanceDetail.EffectiveToTimeKey >= v_timekey )
                   AND ( AdvAcOtherDetail.EffectiveFromTimeKey <= v_timekey
                   AND AdvAcOtherDetail.EffectiveToTimeKey >= v_timekey )
                   AND AdvAcCal.EffectiveFromTimeKey <= v_timekey
                   AND AdvAcCal.EffectiveToTimeKey >= v_timekey
                   AND ( DimAcSplCategory1.SplCatShortNameEnum IN ( 'STGOVT GUA','CENGOV GUA' )

                   OR DimAcSplCategory2.SplCatShortNameEnum IN ( 'STGOVT GUA','CENGOV GUA' )
                  )
                   AND AdvAcCal.CustomerEntityID = v_CustomerEntityID ) 
            SELECT SUM(CTE_GovtGuar.GovGurAmt)  

              INTO v_GovGurAmt
              FROM CTE_GovtGuar 
         ;
         DBMS_SQL.RETURN_RESULT(v_cursor)    ;

      END;
      END IF;
   END IF;
   RETURN v_GovGurAmt;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETGOVGURAMT" TO "ADF_CDR_RBL_STGDB";
