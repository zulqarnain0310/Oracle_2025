--------------------------------------------------------
--  DDL for Procedure ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" 
-- exec AccountLvlPerviousSearchdetail @AccountID=N'171'

(
  --Declare  
  v_AccountID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_DateOfData DATE;
   v_Facility VARCHAR2(4000);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   SELECT S.LastQtrDate 

     INTO v_DateOfData
     FROM SysDayMatrix S
            LEFT JOIN SysDataMatrix M   ON S.TimeKey = M.TimeKey
    WHERE  CurrentStatus = 'C';
   SELECT FacilityType 

     INTO v_Facility
     FROM MAIN_PRO.AccountCal_Hist 
    WHERE  effectivefromtimekey = v_Timekey
             AND CustomerAcID = v_AccountID;

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.AccountID ,
                v_Facility FacilityType ,--Z.FacilityType  

                A.POS ,
                A.InterestReceivable ,
                --,'' as CustomerID  --Q.CustomerID  
                --,'' as CustomerName --Q.CustomerName  
                --,'' as UCIC--Q.UCIF_ID as UCIC  
                --,'' as Segment --Z.segmentcode as Segment  
                A.POS BalanceOSPOS  ,
                A.InterestReceivable BalanceOSInterestReceivable  ,
                RestructureFlag RestructureFlagAlt_Key  ,
                UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,10,p_style=>103) RestructureDate  ,
                A.FITLFlag FITLFlag  ,
                --,A.flagFITL as FITLFlag  
                A.DFVAmount ,
                A.RePossessionFlag RePossessionFlag  ,
                UTILS.CONVERT_TO_VARCHAR2(A.RePossessionDate,10,p_style=>103) RePossessionDate  ,
                A.InherentWeaknessFlag InherentWeaknessFlag  ,
                UTILS.CONVERT_TO_VARCHAR2(A.InherentWeaknessDate,10,p_style=>103) InherentWeaknessDate  ,
                A.SARFAESIFlag SARFAESIFlagAlt_key  ,
                UTILS.CONVERT_TO_VARCHAR2(A.SARFAESIDate,10,p_style=>103) SARFAESIDate  ,
                A.UnusualBounceFlag UnusualBounceFlag  ,
                UTILS.CONVERT_TO_VARCHAR2(A.UnusualBounceDate,10,p_style=>103) UnusualBounceDate  ,
                A.UnclearedEffectsFlag UnclearedEffectsFlag  ,
                UTILS.CONVERT_TO_VARCHAR2(A.UnclearedEffectsDate,10,p_style=>103) UnclearedEffectsDate  ,
                A.AdditionalProvisionCustomerlevel ,
                A.AdditionalProvisionAbsolute ,
                A.FraudAccountFlag FraudAccountFlag  ,
                UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,10,p_style=>103) FraudDate  ,
                UTILS.CONVERT_TO_VARCHAR2(v_DateOfData,10,p_style=>103) DateOfData  ,
                A.MOCReason ,
                UTILS.CONVERT_TO_VARCHAR2(A.MOCDate,10,p_style=>103) MOCDate  ,
                A.MOCBy ,
                D.MOCTypeName MOCSource  ,
                C.ParameterName MOCType  ,
                ScreenFlag ,
                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                A.EffectiveFromTimeKey ,
                A.EffectiveToTimeKey ,
                A.CreatedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,10,p_style=>103) DateCreated  ,
                ApprovedByFirstLevel Level_1_ApprovedBy  ,
                DateApprovedFirstLevel Level_1_DateApproved  ,
                A.ApprovedBy ApprovedBy  ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,10,p_style=>103) DateApproved  ,
                A.ModifyBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,10,p_style=>103) DateModified  ,
                NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                UTILS.CONVERT_TO_VARCHAR2(NVL(A.DateModified, A.DateCreated),10,p_style=>103) CrModDate  
           FROM AccountLevelMOC_Mod A
                  LEFT JOIN DimMOCType D   ON A.MOCSource = D.MOCTypeAlt_Key
                  LEFT JOIN ( SELECT EffectiveFromTimeKey ,
                                     EffectiveToTimeKey ,
                                     ParameterAlt_Key ,
                                     ParameterName ,
                                     'MOCType' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'MOCType'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) C   ON C.ParameterAlt_Key = A.MOCTypeAlt_Key
          WHERE  AccountID = v_AccountID
                   AND A.AuthorisationStatus IN ( 'A' )

                   AND A.EffectiveFromTimeKey = v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLPERVIOUSSEARCHDETAIL_PROD" TO "ADF_CDR_RBL_STGDB";
