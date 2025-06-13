--------------------------------------------------------
--  DDL for Procedure FACILITYDETAILSELECTAUX
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

(
  v_CustomerEntityID IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 
)
AS
   v_cursor SYS_REFCURSOR;
--declare @CustomerEntityID INT=123229
--	,@TimeKey	INT=4109
--	,@OperationFlag TINYINT=2

BEGIN

   /*-- CREATE TABP TABLE FOR SELECT THE DATA*/
   IF utils.object_id('Tempdb..tt_FacilityDetailSelectAux') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FacilityDetailSelectAux ';
   END IF;
   DELETE FROM tt_FacilityDetailSelectAux;
   /*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
   --DECLARE @FacilityType varchar(10), @CustomerACID varchar(30), @CustomerID varchar(20)
   --SELECT @CustomerACID=CustomerAcId, @FacilityType=FacilityType, @CustomerID= RefCustomerId FROM AdvAcBasicDetail WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND CustomerEntityID=@CustomerEntityID AND ISNULL(AuthorisationStatus,'A')='A' 
   --	print 12
   INSERT INTO tt_FacilityDetailSelectAux
     ( CustomerEntityId, CustomerID, AccountEntityID, CustomerAcId, FacilityType, BranchCode )
     ( SELECT CustomerEntityId ,
              RefCustomerId ,
              AccountEntityID ,
              CustomerAcId ,
              FacilityType ,
              BranchCode 
       FROM AdvAcBasicDetail 
        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND CustomerEntityID = v_CustomerEntityID
                 AND NVL(AuthorisationStatus, 'A') = 'A'
       UNION 
       SELECT CustomerEntityId ,
              RefCustomerId ,
              AccountEntityID ,
              CustomerAcId ,
              FacilityType ,
              BranchCode 
       FROM AdvAcBasicDetail_mod 
        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND CustomerEntityID = v_CustomerEntityID
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
      );
   --select * from tt_FacilityDetailSelectAux
   IF v_OperationFlag = 16 THEN

   BEGIN
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_FacilityDetailSelectAux A
               LEFT JOIN ( SELECT A.AccountEntityId 
                           FROM AdvAcBasicDetail_mod A
                                  JOIN tt_FacilityDetailSelectAux B   ON ( EffectiveFromTimeKey <= v_TimeKey
                                  AND EffectiveToTimeKey >= v_TimeKey )
                                  AND A.AccountEntityId = B.AccountEntityID
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           UNION 
                           SELECT A.AccountEntityId 
                           FROM AdvAcOtherDetail_Mod A
                                  JOIN tt_FacilityDetailSelectAux B   ON ( EffectiveFromTimeKey <= v_TimeKey
                                  AND EffectiveToTimeKey >= v_TimeKey )
                                  AND A.AccountEntityId = B.AccountEntityID
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           UNION 
                           SELECT A.AccountEntityId 
                           FROM AdvAcFinancialDetail_Mod A
                                  JOIN tt_FacilityDetailSelectAux B   ON ( EffectiveFromTimeKey <= v_TimeKey
                                  AND EffectiveToTimeKey >= v_TimeKey )
                                  AND A.AccountEntityId = B.AccountEntityID
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                           UNION 
                           SELECT A.AccountEntityId 
                           FROM AdvAcBalanceDetail_mod A
                                  JOIN tt_FacilityDetailSelectAux B   ON ( EffectiveFromTimeKey <= v_TimeKey
                                  AND EffectiveToTimeKey >= v_TimeKey )
                                  AND A.AccountEntityId = B.AccountEntityID
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                          ) B   ON A.AccountEntityId = B.AccountEntityID,
             A
       WHERE  B.AccountEntityId IS NULL );

   END;
   END IF;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, DB.BranchName
   FROM A ,tt_FacilityDetailSelectAux A
          JOIN DimBranch DB   ON ( DB.EffectiveFromTimeKey <= v_TimeKey
          AND DB.EffectiveToTimeKey >= v_TimeKey )
          AND DB.BranchCode = A.BranchCode 
    WHERE A.CustomerEntityID = v_CustomerEntityID) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.BranchName = src.BranchName;
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_FacilityDetailSelectAux  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(CustomerSinceDt,10,p_style=>103) 
        FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  CustomerEntityId = v_CustomerEntityID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FACILITYDETAILSELECTAUX" TO "ADF_CDR_RBL_STGDB";
