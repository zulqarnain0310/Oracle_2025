--------------------------------------------------------
--  DDL for Procedure METAGRIDCUSTOMERMASTER_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.Tempmetagridcustomermaster A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.Tempmetagridcustomermaster A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.metagridcustomermaster B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND A.Customer_ID = B.Customer_ID )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.metagridcustomermaster O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.metagridcustomermaster O
          JOIN RBL_TEMPDB.Tempmetagridcustomermaster T   ON O.Customer_ID = T.Customer_ID
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.UCIC_ID, 0) <> NVL(T.UCIC_ID, 0)
     OR NVL(O.Customer_ID, 0) <> NVL(T.Customer_ID, 0)
     OR NVL(O.Customer_Name, 0) <> NVL(T.Customer_Name, 0)
     OR NVL(O.Customer_Constitution, 0) <> NVL(T.Customer_Constitution, 0)
     OR NVL(O.Gender, 0) <> NVL(T.Gender, 0)
     OR NVL(O.Customer_Segment_Code, 0) <> NVL(T.Customer_Segment_Code, 0)
     OR NVL(O.PAN_No, 0) <> NVL(T.PAN_No, 0)
     OR NVL(O.Asset_Class, 0) <> NVL(T.Asset_Class, 0)
     OR NVL(O.NPA_Date, '1900-01-01') <> NVL(T.NPA_Date, '1900-01-01')
     OR NVL(O.DBT_LOS_Date, '1900-01-01') <> NVL(T.DBT_LOS_Date, '1900-01-01')
     OR NVL(O.Always_NPA, 0) <> NVL(T.Always_NPA, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.Tempmetagridcustomermaster A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.Tempmetagridcustomermaster A
          JOIN RBL_MISDB_PROD.metagridcustomermaster B   ON A.Customer_ID = B.Customer_ID 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.metagridcustomermaster AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.metagridcustomermaster AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.Tempmetagridcustomermaster BB
                       WHERE  AA.Customer_ID = BB.Customer_ID
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   INSERT INTO RBL_MISDB_PROD.metagridcustomermaster
     ( Date_of_Data, Source_System, UCIC_ID, Customer_ID, Customer_Name, Customer_Constitution, Gender, Customer_Segment_Code, PAN_No, Asset_Class, NPA_Date, DBT_LOS_Date, Always_NPA, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MetagridEntityId )
     ( SELECT Date_of_Data ,
              Source_System ,
              UCIC_ID ,
              Customer_ID ,
              Customer_Name ,
              Customer_Constitution ,
              Gender ,
              Customer_Segment_Code ,
              PAN_No ,
              Asset_Class ,
              NPA_Date ,
              DBT_LOS_Date ,
              Always_NPA ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              MetagridEntityId 
       FROM RBL_TEMPDB.Tempmetagridcustomermaster T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDCUSTOMERMASTER_MAIN" TO "ADF_CDR_RBL_STGDB";
