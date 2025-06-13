--------------------------------------------------------
--  DDL for Procedure CUSTACCOUNTMERGE_MOC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" 
(
  v_TIMEKEY IN NUMBER
)
AS
   ------DECLARE @TIMEKEY INT=26267
   ---------- DECLARE @TimeKey  Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
   v_vEffectivefrom -- SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')          
    NUMBER(10,0) := v_TimeKey;
   v_vEffectiveto NUMBER(10,0) := v_TimeKey - 1;--- Set @vEffectiveto= (select Timekey-1 from [dbo].Automate_Advances where EXT_FLG='Y')
   v_cursor SYS_REFCURSOR;

BEGIN
DECLARE v_SQLERRM VARCHAR2(1000);
   BEGIN
      DECLARE
         /*  New Customers EntityKey ID Update  */
         
         v_EntityKey NUMBER(19,0) := 0;

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         /* ADVCUSTNPA DETAIL */
         IF utils.object_id('TEMPDB..#AdvCustNPAdetail') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_AdvCustNPAdetail ';
         END IF;
         DELETE FROM tt_AdvCustNPAdetail_10;
         INSERT INTO GTT_AdvCustNPAdetail
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key, NPA_Reason )
           ( SELECT CustomerEntityId ,
                    A.SysAssetClassAlt_Key Cust_AssetClassAlt_Key  ,
                    SysNPA_Dt NPADt  ,
                    NULL LastInttChargedDt  ,
                    DbtDt DbtDt  ,
                    LossDt LosDt  ,
                    NULL DefaultReason1Alt_Key  ,
                    NULL DefaultReason2Alt_Key  ,
                    NULL StaffAccountability  ,
                    NULL LastIntBooked  ,
                    RefCustomerID RefCustomerID  ,
                    NULL AuthorisationStatus  ,
                    A.EffectiveFromTimeKey EffectiveFromTimeKey  ,
                    49999 EffectiveToTimeKey  ,
                    NULL CreatedBy  ,
                    SYSDATE DateCreated  ,
                    NULL ModifiedBy  ,
                    NULL DateModified  ,
                    NULL ApprovedBy  ,
                    NULL DateApproved  ,
                    NULL MocStatus  ,
                    NULL MocDate  ,
                    NULL MocTypeAlt_Key  ,
                    A.DegReason NPA_Reason  
             FROM GTT_CUSTOMERCAL A
                    JOIN RBL_MISDB_PROD.DimAssetClass B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey )
                    AND A.SysAssetClassAlt_Key = B.AssetClassAlt_Key
                    AND NVL(B.AssetClassShortNameEnum, 'STD') <> 'STD' );

         DELETE FROM GTT_NPA_DATA;
         UTILS.IDENTITY_RESET('GTT_NPA_DATA');

         INSERT INTO GTT_NPA_DATA ( 
         	SELECT A.* ,
                 UTILS.CONVERT_TO_NUMBER(0,10,0) NewEntityKey  ,
                 'N' IsChanged  
         	  FROM RBL_MISDB_PROD.AdvCustNPADetail A
                   JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityId = B.CustomerEntityId
         	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey );
         ----------For New Records
         MERGE INTO GTT_AdvCustNPAdetail A
         USING (SELECT A.ROWID row_id, 'N'
         FROM GTT_AdvCustNPAdetail A 
          WHERE NOT EXISTS ( SELECT 1 
                             FROM GTT_NPA_DATA B
                              WHERE  b.EffectiveFromTimeKey = v_TimeKey
                                       AND B.EffectiveToTimeKey = v_TimeKey
                                       AND B.CustomerEntityId = A.CustomerEntityId )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsChanged
                                      ----Select * 
                                       = 'N';
         /* EXPIRE RECORDS FOR PREV TI,EKEY */
         MERGE INTO RBL_MISDB_PROD.AdvCustNPADetail O
         USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSERACL-MOC' AS pos_4
         FROM RBL_MISDB_PROD.AdvCustNPADetail O
                JOIN GTT_AdvCustNPAdetail T   ON O.CustomerEntityId = T.CustomerEntityId
                AND ( O.EFFECTIVETOTimekey <= v_TimeKey
                AND O.EFFECTIVETOTimekey >= v_TimeKey )
                AND O.EffectiveFromTimeKey < v_TimeKey 
          WHERE ( NVL(O.Cust_AssetClassAlt_Key, 0) <> NVL(T.Cust_AssetClassAlt_Key, 0)
           OR NVL(O.NPADt, '1900-01-01') <> NVL(t.NPADt, '1900-01-01')
           OR NVL(O.LosDt, '1900-01-01') <> NVL(t.LosDt, '1900-01-01')
           OR NVL(O.DbtDt, '1900-01-01') <> NVL(t.DbtDt, '1900-01-01') )) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                      O.DateModified = pos_3,
                                      O.ModifiedBy = pos_4;
         ----- OR  isnull(O.[RefCustomerID],'')		 <> IsnuLL(T.[RefCustomerID],'')
         /* UPDATE RECORDS FOR CURRENT TIMEKEY */
         MERGE INTO RBL_MISDB_PROD.AdvCustNPADetail O
         USING (SELECT O.ROWID row_id, T.Cust_AssetClassAlt_Key, T.NPADt, T.LosDt, T.DbtDt, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_6, 'SSISUSERACL-MOC' AS pos_7, v_TimeKey
         FROM RBL_MISDB_PROD.AdvCustNPADetail O
                JOIN GTT_AdvCustNPAdetail T   ON O.CustomerEntityId = T.CustomerEntityId
                AND O.EffectiveFromTimeKey = v_TimeKey
                AND O.EffectiveToTimeKey >= v_TimeKey ) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.Cust_AssetClassAlt_Key = src.Cust_AssetClassAlt_Key,
                                      O.NPADt = src.NPADt,
                                      O.LosDt = src.LosDt,
                                      O.DbtDt = src.DbtDt,
                                      O.DateModified = pos_6,
                                      O.ModifiedBy = pos_7,
                                      O.EffectiveToTimeKey = v_TimeKey;
         /* EXPIRE PREVIOUS NPA AND STD IN CURRENT */
         MERGE INTO RBL_MISDB_PROD.AdvCustNPADetail AA 
         USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSERACL-MOC' AS pos_4
         FROM RBL_MISDB_PROD.AdvCustNPADetail AA 
          WHERE AA.EffectiveToTimeKey <= v_TimeKey
           AND aa.EffectiveToTimeKey >= v_TimeKey
           AND NOT EXISTS ( SELECT 1 
                            FROM GTT_AdvCustNPAdetail BB
                             WHERE  AA.CustomerEntityId = BB.CustomerEntityId )) src
         ON ( AA.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                      DateModified = pos_3,
                                      ModifiedBy = pos_4;
         ----------For Changes Records
         MERGE INTO GTT_AdvCustNPAdetail A
         USING (SELECT A.ROWID row_id, 'C'
         FROM GTT_AdvCustNPAdetail A
                JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON B.CustomerEntityId = A.CustomerEntityId 
          WHERE B.EffectiveToTimeKey = v_vEffectiveto
           AND b.EffectiveFromTimeKey < v_TimeKey
           AND B.ModifiedBy = 'SSISUSERACL-MOC') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsChanged
                                      ----Select * 
                                       = 'C';
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvCustNPADetail ;
         IF v_EntityKey IS NULL THEN

         BEGIN
            v_EntityKey := 0 ;

         END;
         END IF;
         MERGE INTO GTT_AdvCustNPAdetail TEMP
         USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
         FROM GTT_AdvCustNPAdetail TEMP
                JOIN ( SELECT GTT_AdvCustNPAdetail.CustomerEntityId ,
                              (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  )) EntityKey  
                       FROM GTT_AdvCustNPAdetail 
                        WHERE  GTT_AdvCustNPAdetail.IsChanged IN ( 'N','C' )

                                 AND GTT_AdvCustNPAdetail.EntityKey = 0
                                 OR GTT_AdvCustNPAdetail.EntityKey IS NULL ) ACCT   ON TEMP.CustomerEntityId = ACCT.CustomerEntityId 
          WHERE Temp.IsChanged IN ( 'N','C' )
         ) src
         ON ( TEMP.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
         MERGE INTO GTT_AdvCustNPAdetail A
         USING (SELECT A.ROWID row_id, NULL
         FROM GTT_AdvCustNPAdetail A
                JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
                AND B.EffectiveFromTimeKey = v_TIMEKEY
                AND B.EffectiveToTimeKey = v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsChanged = NULL;
         INSERT INTO RBL_MISDB_PROD.AdvCustNPADetail
           ( ENTITYKEY, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, NPA_Reason )
           ( SELECT ENTITYKEY ,
                    CustomerEntityId ,
                    Cust_AssetClassAlt_Key ,
                    NPADt ,
                    LastInttChargedDt ,
                    DbtDt ,
                    LosDt ,
                    DefaultReason1Alt_Key ,
                    DefaultReason2Alt_Key ,
                    StaffAccountability ,
                    LastIntBooked ,
                    RefCustomerID ,
                    AuthorisationStatus ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    CreatedBy ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    SYSDATE D2Ktimestamp  ,
                    MocStatus ,
                    MocDate ,
                    MocTypeAlt_Key ,
                    NPA_Reason 
             FROM GTT_AdvCustNPAdetail T
              WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
            );
         /*  New Customers EntityKey ID Update  */
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvCustNPADetail ;
         IF v_EntityKey IS NULL THEN

         BEGIN
            v_EntityKey := 0 ;

         END;
         END IF;
         MERGE INTO GTT_NPA_DATA TEMP
         USING (SELECT TEMP.ROWID row_id, ACCT.NewEntityKey
         FROM GTT_NPA_DATA TEMP
                JOIN ( SELECT GTT_NPA_DATA.CustomerEntityId ,
                              (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  )) NewEntityKey  
                       FROM GTT_NPA_DATA 
                        WHERE  GTT_NPA_DATA.EntityKey = 0
                                 OR GTT_NPA_DATA.EntityKey IS NULL
                                 AND GTT_NPA_DATA.EffectiveToTimeKey > v_TimeKey ) ACCT   ON TEMP.CustomerEntityId = ACCT.CustomerEntityId 
          WHERE EffectiveToTimeKey > v_TimeKey) src
         ON ( TEMP.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TEMP.NewEntityKey = src.NewEntityKey;
         MERGE INTO GTT_NPA_DATA T 
         USING (SELECT t.ROWID row_id, 'Y'
         FROM GTT_NPA_DATA T 
          WHERE T.EffectiveToTimeKey > v_TimeKey
           AND CustomerEntityId IN ( SELECT CustomerEntityId 
                                     FROM GTT_AdvCustNPAdetail TT
                                      WHERE  TT.IsChanged = 'C' )
         ) src
         ON ( t.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET t.IsChanged = 'Y';
         /* INSERT DATA FOR NEXT TIME KE IF EXISTING RECORDS ARE AVAILABLE FOR NEXT TIMEKEY */
         INSERT INTO RBL_MISDB_PROD.AdvCustNPADetail
           ( ENTITYKEY, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, NPA_Reason )
           ( SELECT T.NewEntityKey ENTITYKEY  ,
                    T.CustomerEntityId ,
                    T.Cust_AssetClassAlt_Key ,
                    T.NPADt ,
                    T.LastInttChargedDt ,
                    T.DbtDt ,
                    T.LosDt ,
                    T.DefaultReason1Alt_Key ,
                    T.DefaultReason2Alt_Key ,
                    T.StaffAccountability ,
                    T.LastIntBooked ,
                    T.RefCustomerID ,
                    T.AuthorisationStatus ,
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    T.EffectiveToTimeKey ,
                    T.CreatedBy ,
                    T.DateCreated ,
                    T.ModifiedBy ,
                    T.DateModified ,
                    T.ApprovedBy ,
                    T.DateApproved ,
                    SYSDATE D2Ktimestamp  ,
                    T.MocStatus ,
                    T.MocDate ,
                    T.MocTypeAlt_Key ,
                    T.NPA_Reason 
             FROM GTT_NPA_DATA T
              WHERE  T.EffectiveToTimeKey > v_TimeKey
                       AND IsChanged = 'Y' );
         --and CustomerEntityId in (
         --							SELECT CustomerEntityId FROM  #AdvCustNPAdetail TT
         --							WHERE TT.IsChanged='C'
         --						)
         /* PRE MOC DATA INSERT */
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, NPA_Reason )
           ( SELECT T.CustomerEntityId ,
                    T.Cust_AssetClassAlt_Key ,
                    T.NPADt ,
                    T.LastInttChargedDt ,
                    T.DbtDt ,
                    T.LosDt ,
                    T.DefaultReason1Alt_Key ,
                    T.DefaultReason2Alt_Key ,
                    T.StaffAccountability ,
                    T.LastIntBooked ,
                    T.RefCustomerID ,
                    T.AuthorisationStatus ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    T.CreatedBy ,
                    T.DateCreated ,
                    T.ModifiedBy ,
                    T.DateModified ,
                    T.ApprovedBy ,
                    T.DateApproved ,
                    SYSDATE D2Ktimestamp  ,
                    T.MocStatus ,
                    T.MocDate ,
                    T.MocTypeAlt_Key ,
                    T.NPA_Reason 
             FROM GTT_NPA_DATA T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL B   ON B.EffectiveFromTimeKey = v_TimeKey
                    AND B.EffectiveToTimeKey = v_TimeKey
                    AND T.CustomerEntityId = B.CustomerEntityId
              WHERE  B.CustomerEntityId IS NULL );
         ------------------End
         /*        AdvAcFinancialDetail  Start         */
         IF utils.object_id('TEMPDB..GTT_AdvAcFinancialDetail') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_AdvAcFinancialDetail ';
         END IF;
         DELETE FROM GTT_AdvAcFinancialDetail;
         INSERT INTO GTT_AdvAcFinancialDetail
           ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate, NpaDt, BookDebts, UnDrawnAmt, UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason, LimitDisbursed, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key, AccountBlkCode2, NpaDt_Org )
           ( SELECT NULL ENTITYKEY  ,
                    B.AccountEntityId ,
                    B.Ac_LastReviewDueDt ,
                    B.Ac_ReviewTypeAlt_key ,
                    B.Ac_ReviewDt ,
                    B.Ac_ReviewAuthAlt_Key ,
                    B.Ac_NextReviewDueDt ,
                    B.DrawingPower ,
                    B.InttRate ,
                    A.FinalNpaDt NpaDt  ,
                    B.BookDebts ,
                    B.UnDrawnAmt ,
                    B.UnAdjSubSidy ,
                    B.LastInttRealiseDt ,
                    B.MocStatus ,
                    B.MOCReason ,
                    B.LimitDisbursed ,
                    B.RefCustomerId ,
                    B.RefSystemAcId ,
                    B.AuthorisationStatus ,
                    b.EffectiveFromTimeKey ,
                    b.EffectiveToTimeKey ,
                    B.CreatedBy ,
                    B.DateCreated ,
                    B.ModifiedBy ,
                    B.DateModified ,
                    B.ApprovedBy ,
                    B.DateApproved ,
                    NULL D2Ktimestamp  ,
                    B.MocDate ,
                    B.MocTypeAlt_Key ,
                    B.CropDuration ,
                    B.Ac_ReviewAuthLevelAlt_Key ,
                    B.AccountBlkCode2 ,
                    B.NpaDt NpaDt_Org  
             FROM GTT_AccountCal A
                    JOIN RBL_MISDB_PROD.AdvAcFinancialDetail B   ON A.AccountEntityId = B.AccountEntityID
                    AND b.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
                    AND NVL(B.NpaDt, '1900-01-01') <> NVL(A.FinalNpaDt, '1900-01-01') );
         -----------------------------------------------
         MERGE INTO RBL_MISDB_PROD.AdvAcFinancialDetail O
         USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSERACL-MOC' AS pos_4
         FROM RBL_MISDB_PROD.AdvAcFinancialDetail O
                JOIN GTT_AdvAcFinancialDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND O.EffectiveFromTimeKey <= v_TimeKey
                AND O.EffectiveToTimeKey >= v_TimeKey
                AND O.EffectiveFromTimeKey < v_TimeKey 
          WHERE ( NVL(O.NpaDt, '1900-01-01') <> NVL(T.NpaDt, '1900-01-01') )) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                      O.DateModified = pos_3,
                                      O.ModifiedBy = pos_4;
         -----------------------------------------------
         MERGE INTO RBL_MISDB_PROD.AdvAcFinancialDetail O
         USING (SELECT O.ROWID row_id, T.NpaDt, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSERACL-MOC' AS pos_4, v_TimeKey
         FROM RBL_MISDB_PROD.AdvAcFinancialDetail O
                JOIN GTT_AdvAcFinancialDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND O.EffectiveFromTimeKey = v_TimeKey
                AND O.EffectiveToTimeKey >= v_TimeKey
                AND O.EffectiveFromTimeKey = v_TimeKey 
          WHERE ( NVL(O.NpaDt, '1900-01-01') <> NVL(T.NpaDt, '1900-01-01') )) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.NpaDt = src.NpaDt,
                                      O.DateModified = pos_3,
                                      O.ModifiedBy = pos_4,
                                      O.EffectiveToTimeKey = v_TimeKey;
         MERGE INTO GTT_AdvAcFinancialDetail T 
         USING (SELECT T.ROWID row_id, 'D'
         FROM RBL_MISDB_PROD.AdvAcFinancialDetail O
                JOIN GTT_AdvAcFinancialDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND O.EffectiveFromTimeKey = v_TimeKey ) src
         ON ( T.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET T.IsChanged = 'D';
         /***************************************************************************************************************/
         --  ----------For Changes Records
         --UPDATE A SET A.IsChanged='C'
         ------Select * 
         --from GTT_AdvAcFinancialDetail A
         --INNER JOIN DBO.AdvAcFinancialDetail B 
         --ON B.AccountEntityId=A.AccountEntityId   
         --Where B.EffectiveToTimeKey= @vEffectiveto
         --And B.ModifiedBy='SSISUSERACL-MOC'
         /*  New Customers EntityKey ID Update  */
         --DECLARE @EntityKey INT
         v_EntityKey := 0 ;
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvAcFinancialDetail ;
         IF v_EntityKey IS NULL THEN

         BEGIN
            v_EntityKey := 0 ;

         END;
         END IF;
         MERGE INTO GTT_AdvAcFinancialDetail TEMP
         USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
         FROM GTT_AdvAcFinancialDetail TEMP
                JOIN ( SELECT GTT_AdvAcFinancialDetail.AccountEntityId ,
                              (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  )) EntityKey  
                       FROM GTT_AdvAcFinancialDetail 
                        WHERE  NVL(GTT_AdvAcFinancialDetail.IsChanged, 'U') <> 'D' ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId ) src
         ON ( TEMP.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
         ---Where Temp.IsChanged in ('N','C')
         ----UPDATE A
         ----SET A.IsChanged='K' 
         ----FROM GTT_AdvAcFinancialDetail A
         ----	INNER JOIN AdvAcFinancialDetail B
         ----		ON A.AccountEntityId =B.AccountEntityId
         ----		AND B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
         ----		SELECT COUNT(1), AccountEntityId FROM GTT_AdvAcFinancialDetail 
         ----		GROUP BY AccountEntityId
         ----		HAVING COUNT(1)>1
         ------------------------------------------------------------------
         INSERT INTO RBL_MISDB_PROD.AdvAcFinancialDetail
           ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate, NpaDt, BookDebts, UnDrawnAmt, UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason, LimitDisbursed, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key, AccountBlkCode2 )
           ( SELECT ENTITYKEY ,
                    AccountEntityId ,
                    Ac_LastReviewDueDt ,
                    Ac_ReviewTypeAlt_key ,
                    Ac_ReviewDt ,
                    Ac_ReviewAuthAlt_Key ,
                    Ac_NextReviewDueDt ,
                    DrawingPower ,
                    InttRate ,
                    NpaDt ,
                    BookDebts ,
                    UnDrawnAmt ,
                    UnAdjSubSidy ,
                    LastInttRealiseDt ,
                    MocStatus ,
                    MOCReason ,
                    LimitDisbursed ,
                    RefCustomerId ,
                    RefSystemAcId ,
                    AuthorisationStatus ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    CreatedBy ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    SYSDATE D2Ktimestamp  ,
                    MocDate ,
                    MocTypeAlt_Key ,
                    CropDuration ,
                    Ac_ReviewAuthLevelAlt_Key ,
                    AccountBlkCode2 
             FROM GTT_AdvAcFinancialDetail T
              WHERE  NVL(T.IsChanged, 'U') NOT IN ( 'D','K' )
            );
         INSERT INTO RBL_MISDB_PROD.AdvAcFinancialDetail
           ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate, NpaDt, BookDebts, UnDrawnAmt, UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason, LimitDisbursed, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key, AccountBlkCode2 )
           ( SELECT ENTITYKEY ,
                    AccountEntityId ,
                    Ac_LastReviewDueDt ,
                    Ac_ReviewTypeAlt_key ,
                    Ac_ReviewDt ,
                    Ac_ReviewAuthAlt_Key ,
                    Ac_NextReviewDueDt ,
                    DrawingPower ,
                    InttRate ,
                    NpaDt_org ,
                    BookDebts ,
                    UnDrawnAmt ,
                    UnAdjSubSidy ,
                    LastInttRealiseDt ,
                    MocStatus ,
                    MOCReason ,
                    LimitDisbursed ,
                    RefCustomerId ,
                    RefSystemAcId ,
                    AuthorisationStatus ,
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    SYSDATE D2Ktimestamp  ,
                    MocDate ,
                    MocTypeAlt_Key ,
                    CropDuration ,
                    Ac_ReviewAuthLevelAlt_Key ,
                    AccountBlkCode2 
             FROM GTT_AdvAcFinancialDetail T
              WHERE  NVL(T.IsChanged, 'U') <> 'D' --IN ('N','C')

                       AND t.EffectiveToTimeKey > 26267 );
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL
           ( AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate, NpaDt, BookDebts, UnDrawnAmt, UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason, LimitDisbursed, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key, AccountBlkCode2 )
           ( SELECT T.AccountEntityId ,
                    T.Ac_LastReviewDueDt ,
                    T.Ac_ReviewTypeAlt_key ,
                    T.Ac_ReviewDt ,
                    T.Ac_ReviewAuthAlt_Key ,
                    T.Ac_NextReviewDueDt ,
                    T.DrawingPower ,
                    T.InttRate ,
                    NpaDt_org ,
                    T.BookDebts ,
                    T.UnDrawnAmt ,
                    T.UnAdjSubSidy ,
                    T.LastInttRealiseDt ,
                    T.MocStatus ,
                    T.MOCReason ,
                    T.LimitDisbursed ,
                    T.RefCustomerId ,
                    T.RefSystemAcId ,
                    T.AuthorisationStatus ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    T.CreatedBy ,
                    T.DateCreated ,
                    T.ModifiedBy ,
                    T.DateModified ,
                    T.ApprovedBy ,
                    T.DateApproved ,
                    T.MocDate ,
                    T.MocTypeAlt_Key ,
                    T.CropDuration ,
                    T.Ac_ReviewAuthLevelAlt_Key ,
                    T.AccountBlkCode2 
             FROM GTT_AdvAcFinancialDetail T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL tt   ON tt.EffectiveFromTimeKey = v_TimeKey
                    AND tt.EffectiveToTimeKey = v_TimeKey
                    AND tt.AccountEntityId = t.AccountEntityId
              WHERE  tt.AccountEntityId IS NULL );
         /*        AdvAcFinancialDetail  END         */
         -------
         -----------------------------------------------------------------------------------------------------------------------------------------
         /*        AdvAcBalanceDetail  Start         */
         IF utils.object_id('TEMPDB..#AdvAcBalanceDetail') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_AdvAcBalanceDetail ';
         END IF;
         DELETE FROM tt_AdvAcBalanceDetail_10;
         INSERT INTO GTT_AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, UnAppliedIntAmount, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy, UpgradeDate, OverduePrincipal, NotionalInttAmt, PrincipalBalance, Overdueinterest, AdvanceRecovery, PS_NPS_FLAG, DFVAmt, InterestReceivable, OverduePrincipalDt, OverdueIntDt, OverOtherdue, OverdueOtherDt, SourceAssetClass, SourceNpaDate, ASSETCLASSALT_KEY_Org, BALANCE_Org, TOTALPROV_Org, PrincipalBalance_Org )
           ( SELECT NULL EntityKey  ,
                    A.AccountEntityId ,
                    A.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                    B.BalanceInCurrency ,
                    A.Balance Balance  ,
                    b.SignBalance ,
                    B.LastCrDt ,
                    B.OverDue ,
                    A.TotalProvision TotalProv  ,
                    B.RefCustomerId ,
                    B.RefSystemAcId ,
                    B.AuthorisationStatus ,
                    b.EffectiveFromTimeKey ,
                    b.EffectiveToTimeKey ,
                    B.OverDueSinceDt ,
                    B.MocStatus ,
                    B.MocDate ,
                    B.MocTypeAlt_Key ,
                    B.Old_OverDueSinceDt ,
                    B.Old_OverDue ,
                    B.ORG_TotalProv ,
                    B.IntReverseAmt ,
                    B.UnAppliedIntAmount ,
                    B.PS_Balance ,
                    B.NPS_Balance ,
                    B.DateCreated ,
                    B.ModifiedBy ,
                    B.DateModified ,
                    B.ApprovedBy ,
                    B.DateApproved ,
                    B.CreatedBy ,
                    B.UpgradeDate ,
                    b.OverduePrincipal ,
                    B.NotionalInttAmt ,
                    A.PrincOutStd PrincipalBalance  ,
                    B.Overdueinterest ,
                    B.AdvanceRecovery ,
                    B.PS_NPS_FLAG ,
                    B.DFVAmt ,
                    B.InterestReceivable ,
                    B.OverduePrincipalDt ,
                    B.OverdueIntDt ,
                    B.OverOtherdue ,
                    B.OverdueOtherDt ,
                    B.SourceAssetClass ,
                    B.SourceNpaDate ,
                    b.ASSETCLASSALT_KEY ASSETCLASSALT_KEY_Org  ,
                    b.BALANCE BALANCE_Org  ,
                    b.TOTALPROV TOTALPROV_Org  ,
                    b.PrincipalBalance PrincipalBalance_Org  
             FROM GTT_AccountCal A
                    JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityId
                    AND b.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
              WHERE  ( NVL(B.ASSETCLASSALT_KEY, 0) <> NVL(A.FINALASSETCLASSALT_KEY, 0)
                       OR NVL(B.BALANCE, 0) <> NVL(A.BALANCE, 0)
                       OR NVL(B.TOTALPROV, 0) <> NVL(A.TOTALPROVISION, 0)
                       OR NVL(B.PrincipalBalance, 0) <> NVL(A.PrincOutStd, 0) ) );
         -----------------------------------------------------------------------------------------------------------------------------------------
         MERGE INTO RBL_MISDB_PROD.AdvAcBalanceDetail O
         USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSERACL-MOC' AS pos_4
         FROM RBL_MISDB_PROD.AdvAcBalanceDetail O
                JOIN GTT_AdvAcBalanceDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND o.EffectiveFromTimeKey <= v_TimeKey
                AND o.EffectiveToTimeKey >= v_TimeKey
                AND O.EffectiveFromTimeKey < v_TimeKey 
          WHERE ( NVL(O.ASSETCLASSALT_KEY, 0) <> NVL(T.ASSETCLASSALT_KEY, 0)
           OR NVL(O.BALANCE, 0) <> NVL(T.BALANCE, 0)
           OR NVL(O.TOTALPROV, 0) <> NVL(T.TOTALPROV, 0)
           OR NVL(O.PrincipalBalance, 0) <> NVL(T.PrincipalBalance, 0) )) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                      O.DateModified = pos_3,
                                      O.ModifiedBy = pos_4;
         -----------------For Same TimeKey And EffectiveFromTimeKey
         MERGE INTO RBL_MISDB_PROD.AdvAcBalanceDetail O
         USING (SELECT O.ROWID row_id, T.ASSETCLASSALT_KEY, T.BALANCE, T.TOTALPROV, T.PrincipalBalance, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_6, 'SSISUSERACL-MOC' AS pos_7, v_TimeKey
         FROM RBL_MISDB_PROD.AdvAcBalanceDetail O
                JOIN GTT_AdvAcBalanceDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND O.EffectiveFromTimeKey = v_TimeKey
                AND o.EffectiveToTimeKey >= v_TimeKey 
          WHERE ( NVL(O.ASSETCLASSALT_KEY, 0) <> NVL(T.ASSETCLASSALT_KEY, 0)
           OR NVL(O.BALANCE, 0) <> NVL(T.BALANCE, 0)
           OR NVL(O.TOTALPROV, 0) <> NVL(T.TOTALPROV, 0)
           OR NVL(O.PrincipalBalance, 0) <> NVL(T.PrincipalBalance, 0) )) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.ASSETCLASSALT_KEY = src.ASSETCLASSALT_KEY,
                                      O.BALANCE = src.BALANCE,
                                      O.TOTALPROV = src.TOTALPROV,
                                      O.PrincipalBalance = src.PrincipalBalance,
                                      O.DateModified = pos_6,
                                      O.ModifiedBy = pos_7,
                                      O.EffectiveToTimeKey = v_TimeKey;
         MERGE INTO GTT_AdvAcBalanceDetail T
         USING (SELECT T.ROWID row_id, 'D'
         FROM RBL_MISDB_PROD.AdvAcBalanceDetail O
                JOIN GTT_AdvAcBalanceDetail T   ON O.AccountEntityID = T.AccountEntityID
                AND O.EffectiveFromTimeKey = v_TimeKey ) src
         ON ( T.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET t.IsChanged = 'D';
         ----------For Changes Records
         --UPDATE A SET A.IsChanged='C'
         --from #AdvAcBalanceDetail A
         --INNER JOIN DBO.AdvAcBalanceDetail B 
         --ON B.AccountEntityId=A.AccountEntityId            
         --Where B.EffectiveToTimeKey= @vEffectiveto
         --And B.ModifiedBy='SSISUSERACL-MOC'
         /*  New Customers EntityKey ID Update  */
         v_EntityKey := 0 ;
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvAcBalanceDetail ;
         IF v_EntityKey IS NULL THEN

         BEGIN
            v_EntityKey := 0 ;

         END;
         END IF;
         MERGE INTO GTT_AdvAcBalanceDetail TEMP
         USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
         FROM GTT_AdvAcBalanceDetail TEMP
                JOIN ( SELECT GTT_AdvAcBalanceDetail.AccountEntityId ,
                              (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  )) EntityKey  
                       FROM GTT_AdvAcBalanceDetail 
                        WHERE  NVL(GTT_AdvAcBalanceDetail.IsChanged, 'U') <> 'D' ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId ) src
         ON ( TEMP.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
         --Where Temp.IsChanged in ('N','C')
         /***************************************************************************************************************/
         --UPDATE A
         --SET A.IsChanged='K' 
         --FROM #AdvAcBalanceDetail A
         --	INNER JOIN AdvAcBalanceDetail B
         --		ON A.AccountEntityId =B.AccountEntityId
         --		AND B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
         INSERT INTO RBL_MISDB_PROD.AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, UnAppliedIntAmount, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy, UpgradeDate, OverduePrincipal, NotionalInttAmt, PrincipalBalance, Overdueinterest, AdvanceRecovery, PS_NPS_FLAG, DFVAmt, InterestReceivable, OverduePrincipalDt, OverdueIntDt, OverOtherdue, OverdueOtherDt, SourceAssetClass, SourceNpaDate )
           ( SELECT EntityKey ,
                    AccountEntityId ,
                    AssetClassAlt_Key ,
                    BalanceInCurrency ,
                    Balance ,
                    SignBalance ,
                    LastCrDt ,
                    OverDue ,
                    TotalProv ,
                    RefCustomerId ,
                    RefSystemAcId ,
                    AuthorisationStatus ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    OverDueSinceDt ,
                    MocStatus ,
                    MocDate ,
                    MocTypeAlt_Key ,
                    Old_OverDueSinceDt ,
                    Old_OverDue ,
                    ORG_TotalProv ,
                    IntReverseAmt ,
                    UnAppliedIntAmount ,
                    PS_Balance ,
                    NPS_Balance ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    CreatedBy ,
                    UpgradeDate ,
                    OverduePrincipal ,
                    NotionalInttAmt ,
                    PrincipalBalance ,
                    Overdueinterest ,
                    AdvanceRecovery ,
                    PS_NPS_FLAG ,
                    DFVAmt ,
                    InterestReceivable ,
                    OverduePrincipalDt ,
                    OverdueIntDt ,
                    OverOtherdue ,
                    OverdueOtherDt ,
                    SourceAssetClass ,
                    SourceNpaDate 
             FROM GTT_AdvAcBalanceDetail T
              WHERE  NVL(T.IsChanged, 'U') NOT IN ( 'D','K' )
            );
         INSERT INTO RBL_MISDB_PROD.AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, UnAppliedIntAmount, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy, UpgradeDate, OverduePrincipal, NotionalInttAmt, PrincipalBalance, Overdueinterest, AdvanceRecovery, PS_NPS_FLAG, DFVAmt, InterestReceivable, OverduePrincipalDt, OverdueIntDt, OverOtherdue, OverdueOtherDt, SourceAssetClass, SourceNpaDate )
           ( SELECT EntityKey ,
                    AccountEntityId ,
                    ASSETCLASSALT_KEY_Org ,
                    BalanceInCurrency ,
                    BALANCE_Org ,
                    SignBalance ,
                    LastCrDt ,
                    OverDue ,
                    TOTALPROV_Org ,
                    RefCustomerId ,
                    RefSystemAcId ,
                    AuthorisationStatus ,
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    OverDueSinceDt ,
                    MocStatus ,
                    MocDate ,
                    MocTypeAlt_Key ,
                    Old_OverDueSinceDt ,
                    Old_OverDue ,
                    ORG_TotalProv ,
                    IntReverseAmt ,
                    UnAppliedIntAmount ,
                    PS_Balance ,
                    NPS_Balance ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    CreatedBy ,
                    UpgradeDate ,
                    OverduePrincipal ,
                    NotionalInttAmt ,
                    PrincipalBalance_Org ,
                    Overdueinterest ,
                    AdvanceRecovery ,
                    PS_NPS_FLAG ,
                    DFVAmt ,
                    InterestReceivable ,
                    OverduePrincipalDt ,
                    OverdueIntDt ,
                    OverOtherdue ,
                    OverdueOtherDt ,
                    SourceAssetClass ,
                    SourceNpaDate 
             FROM GTT_AdvAcBalanceDetail T
              WHERE  NVL(T.IsChanged, 'U') <> 'D' -- IN ('N','C')

                       AND EffectiveToTimeKey > v_TimeKey );
         INSERT INTO PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail
           ( AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, UnAppliedIntAmount, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy, UpgradeDate, OverduePrincipal, NotionalInttAmt, PrincipalBalance, Overdueinterest, AdvanceRecovery, PS_NPS_FLAG, DFVAmt, InterestReceivable, OverduePrincipalDt, OverdueIntDt, OverOtherdue, OverdueOtherDt, SourceAssetClass, SourceNpaDate )
           ( SELECT T.AccountEntityId ,
                    T.ASSETCLASSALT_KEY_Org ,
                    T.BalanceInCurrency ,
                    T.BALANCE_Org ,
                    T.SignBalance ,
                    T.LastCrDt ,
                    T.OverDue ,
                    T.TOTALPROV_Org ,
                    T.RefCustomerId ,
                    T.RefSystemAcId ,
                    T.AuthorisationStatus ,
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    T.OverDueSinceDt ,
                    T.MocStatus ,
                    T.MocDate ,
                    T.MocTypeAlt_Key ,
                    T.Old_OverDueSinceDt ,
                    T.Old_OverDue ,
                    T.ORG_TotalProv ,
                    T.IntReverseAmt ,
                    T.UnAppliedIntAmount ,
                    T.PS_Balance ,
                    T.NPS_Balance ,
                    T.DateCreated ,
                    T.ModifiedBy ,
                    T.DateModified ,
                    T.ApprovedBy ,
                    T.DateApproved ,
                    T.CreatedBy ,
                    T.UpgradeDate ,
                    T.OverduePrincipal ,
                    T.NotionalInttAmt ,
                    T.PrincipalBalance_Org ,
                    T.Overdueinterest ,
                    T.AdvanceRecovery ,
                    T.PS_NPS_FLAG ,
                    T.DFVAmt ,
                    T.InterestReceivable ,
                    T.OverduePrincipalDt ,
                    T.OverdueIntDt ,
                    T.OverOtherdue ,
                    T.OverdueOtherDt ,
                    T.SourceAssetClass ,
                    T.SourceNpaDate 
             FROM GTT_AdvAcBalanceDetail T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail b   ON b.EffectiveFromTimeKey = v_TimeKey
                    AND b.EffectiveToTimeKey = v_TimeKey
                    AND T.AccountEntityId = b.AccountEntityId
              WHERE  B.AccountEntityId IS NULL );
         utils.commit_transaction;

      END;
   EXCEPTION
      WHEN OTHERS THEN
v_SQLERRM:=SQLERRM;
   BEGIN
      --	------------------------------------------------------
      -------------------ADDED BY PRASHANT----19122023------------
      --insert into pro.AccountCal
      --select * from ##accountcal
      --insert into pro.customercal
      --select * from ##customercal
      
      OPEN  v_cursor FOR
         SELECT v_SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ROLLBACK;
      utils.resetTrancount;/*        AdvAcBalanceDetail  END         */

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCOUNTMERGE_MOC" TO "ADF_CDR_RBL_STGDB";
