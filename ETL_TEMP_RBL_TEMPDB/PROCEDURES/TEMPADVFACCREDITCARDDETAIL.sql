--------------------------------------------------------
--  DDL for Procedure TEMPADVFACCREDITCARDDETAIL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" 
AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_CreditCardEntityId NUMBER(10,0) := 0;

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvFacCreditCardDetail ';
   INSERT INTO RBL_TEMPDB.TempAdvFacCreditCardDetail
     ( EntityKey, AccountEntityId, CreditCardEntityId, CorporateUCIC_ID, CorporateCustomerID, Liability, MinimumAmountDue, CD, Bucket, DPD, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, ISChanged, AccountStatus, AccountBlkCode2, AccountBlkCode1, ChargeoffY_N )
     ( SELECT DISTINCT NULL EntityKey  ,
                       B.AccountEntityId ,
                       NULL CreditCardEntityId  ,
                       A.CorporateUCICID CorporateUCIC_ID  ,
                       A.CorporateCustomerID CorporateCustomerID  ,
                       A.Liability ,
                       NULL MinimumAmountDue  ,
                       A.CD ,
                       A.Bucket ,
                       A.DPD ,
                       B.SystemACID RefSystemAcId  ,
                       NULL AuthorisationStatus  ,
                       B.EffectiveFromTimeKey EffectiveFromTimeKey  ,
                       B.EffectiveToTimeKey EffectiveToTimeKey  ,
                       B.CreatedBy CreatedBy  ,
                       SYSDATE DateCreated  ,
                       NULL ModifiedBy  ,
                       NULL DateModified  ,
                       NULL ApprovedBy  ,
                       NULL DateApproved  ,
                       NULL D2Ktimestamp  ,
                       NULL MocStatus  ,
                       NULL MocDate  ,
                       'U' ISChanged  ,
                       A.AccountStatus ,
                       A.AccountBlkCode2 ,
                       A.AccountBlkCode1 ,
                       ChargeoffY_N 
       FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM06_STG A
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail B   ON A.CustomerAcID = B.CustomerACID );
   -------AND A.CUSTOMERACID='0005239504502474490'
   --WHERE ISNULL(CHARGEOFFY_n,'N') <> 'Y'  --commented by Mandeep 15/09/2023 (add charge of account)
   /*********************************************************************************************************/
   /*  Existing Customers Account Entity ID Update  */
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.CreditCardEntityId
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
          JOIN RBL_MISDB_PROD.AdvFacCreditCardDetail MAIN   ON TEMP.RefSystemAcId = MAIN.RefSystemAcId 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CreditCardEntityId = src.CreditCardEntityId;
   SELECT MAX(CreditCardEntityId)  

     INTO v_CreditCardEntityId
     FROM RBL_MISDB_PROD.AdvFacCreditCardDetail ;
   IF v_CreditCardEntityId IS NULL THEN

   BEGIN
      v_CreditCardEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.CreditCardEntityId
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
          JOIN ( SELECT "TEMPADVFACCREDITCARDDETAIL".RefSystemAcId ,
                        (v_CreditCardEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                 FROM DUAL  )  )) CreditCardEntityId  
                 FROM RBL_TEMPDB.TempAdvFacCreditCardDetail 
                  WHERE  "TEMPADVFACCREDITCARDDETAIL".CreditCardEntityId = 0
                           OR "TEMPADVFACCREDITCARDDETAIL".CreditCardEntityId IS NULL ) ACCT   ON TEMP.RefSystemAcId = ACCT.RefSystemAcId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CreditCardEntityId = src.CreditCardEntityId;
   /*********************************************************************************************************/
   ----------------------------------------------------Added by Amar Sir Dated 12-10-2022----------------------------------------------------------
   --Update A
   --??????SET A.AccountBlkCode2=CASE WHEN B.AccountBlkCode2='K' THEN 'K'??
   --                                 WHEN B.AccountBlkCode2='E' THEN 'E'?
   --								 WHEN B.AccountBlkCode2='D' THEN 'D'?--Added By Parashant--07062024---
   --								 ELSE 'W'  END
   --from RBL_TEMPDB.DBO.TempAdvFacCreditCardDetail A
   --INNER JOIN [RBL_MISDB_PROD].DBO.AdvFacCreditCardDetail b
   --??????ON B.EffectiveToTimeKey=49999
   --??????AND A.AccountEntityId=B.AccountEntityId
   --WHERE ISNULL(A.AccountBlkCode2,'') NOT IN ('K','E','W','D')
   --??????AND B.AccountBlkCode2 IN ('K','E','W','D')
   ---Added By Prashant----09082024------
   MERGE INTO RBL_TEMPDB.TempAdvFacCreditCardDetail A
   USING (SELECT a.ROWID row_id, CASE 
   WHEN NVL(B.AccountBlkCode2, ' ') IN ( 'K','E','W' )
    THEN b.AccountBlkCode2
   WHEN B.AccountBlkCode2 = 'D'
     AND NVL(a.AccountBlkCode2, ' ') IN ( 'K','E','W' )
    THEN a.AccountBlkCode2
   WHEN B.AccountBlkCode2 = 'D'
     AND NVL(a.AccountBlkCode2, ' ') NOT IN ( 'K','E','W' )
    THEN B.AccountBlkCode2
   ELSE a.AccountBlkCode2
      END AS AccountBlkCode2
   FROM RBL_TEMPDB.TempAdvFacCreditCardDetail A
          JOIN RBL_MISDB_PROD.AdvFacCreditCardDetail b   ON B.EffectiveToTimeKey = 49999
          AND A.AccountEntityId = B.AccountEntityId ) src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.AccountBlkCode2 = src.AccountBlkCode2;--------------------------------------------------------------------------------------------------------------------

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL" TO "ADF_CDR_RBL_STGDB";
