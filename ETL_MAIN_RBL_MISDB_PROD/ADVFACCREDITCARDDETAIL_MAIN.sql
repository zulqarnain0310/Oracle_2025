--------------------------------------------------------
--  DDL for Procedure ADVFACCREDITCARDDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" 
AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   -------------------------------
   /*  New Customers Ac Key ID Update  */
   v_EntityKey NUMBER(19,0) := 0;

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvFacCreditCardDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId
                                 AND A.CreditCardEntityId = B.CreditCardEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   MERGE INTO RBL_MISDB_PROD.AdvFacCreditCardDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacCreditCardDetail O
          JOIN RBL_TEMPDB.TempAdvFacCreditCardDetail T   ON O.AccountEntityID = T.AccountEntityID
          AND O.CreditCardEntityId = T.CreditCardEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.CorporateUCIC_ID, ' ') <> NVL(T.CorporateUCIC_ID, ' ')
     OR NVL(O.CorporateCustomerID, ' ') <> NVL(T.CorporateCustomerID, ' ')
     OR NVL(O.Liability, 0) <> NVL(T.Liability, 0)
     OR NVL(O.MinimumAmountDue, 0) <> NVL(T.MinimumAmountDue, 0)
     OR NVL(O.CD, 0) <> NVL(T.CD, 0)
     OR NVL(O.Bucket, 0) <> NVL(T.Bucket, 0)
     OR NVL(O.DPD, 0) <> NVL(T.DPD, 0)
     OR NVL(O.RefSystemAcId, ' ') <> NVL(T.RefSystemAcId, ' ')
     OR NVL(O.AccountStatus, ' ') <> NVL(T.AccountStatus, ' ')
     OR NVL(O.AccountBlkCode2, ' ') <> NVL(T.AccountBlkCode2, ' ')
     OR NVL(O.AccountBlkCode1, ' ') <> NVL(T.AccountBlkCode1, ' ')
     OR NVL(O.ChargeoffY_N, ' ') <> NVL(T.ChargeoffY_N, ' ') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail A
          JOIN RBL_MISDB_PROD.AdvFacCreditCardDetail B   ON B.AccountEntityId = A.AccountEntityId
          AND A.CreditCardEntityId = B.CreditCardEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvFacCreditCardDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacCreditCardDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvFacCreditCardDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID
                                AND AA.CreditCardEntityId = BB.CreditCardEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvFacCreditCardDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
          JOIN ( SELECT "TEMPADVFACCREDITCARDDETAIL".RefSystemAcId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvFacCreditCardDetail 
                  WHERE  "TEMPADVFACCREDITCARDDETAIL".EntityKey = 0
                           OR "TEMPADVFACCREDITCARDDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.RefSystemAcId = ACCT.RefSystemAcId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   /***************************************************************************************************************/
   INSERT INTO RBL_MISDB_PROD.AdvFacCreditCardDetail
     ( EntityKey, AccountEntityId, CreditCardEntityId, CorporateUCIC_ID, CorporateCustomerID, Liability, MinimumAmountDue, CD, Bucket, DPD, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, AccountStatus, AccountBlkCode2, AccountBlkCode1, ChargeoffY_N )
     ( SELECT EntityKey ,
              AccountEntityId ,
              CreditCardEntityId ,
              CorporateUCIC_ID ,
              CorporateCustomerID ,
              Liability ,
              MinimumAmountDue ,
              CD ,
              Bucket ,
              DPD ,
              RefSystemAcId ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              TO_DATE(DateModified,'YYYY-MM-DD') ,
              ApprovedBy ,
              TO_DATE(DateApproved,'YYYY-MM-DD') ,
              SYSDATE D2Ktimestamp  ,
              MocStatus ,
              TO_DATE(MocDate,'YYYY-MM-DD') ,
              AccountStatus ,
              AccountBlkCode2 ,
              AccountBlkCode1 ,
              ChargeoffY_N 
       FROM RBL_TEMPDB.TempAdvFacCreditCardDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCREDITCARDDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
