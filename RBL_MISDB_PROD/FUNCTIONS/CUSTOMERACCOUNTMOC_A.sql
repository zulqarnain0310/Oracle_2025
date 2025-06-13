--------------------------------------------------------
--  DDL for Function CUSTOMERACCOUNTMOC_A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" 
(
  iv_TimeKey IN NUMBER,
  v_CrModApBy IN VARCHAR2 DEFAULT 'MOCUPLOAD' ,
  --,@D2Ktimestamp	        TIMESTAMP     =0 OUTPUT 
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --,@ErrorMsg				Varchar(max)='' OUTPUT
   --WITH RECOMPILE
   --TRUNCATE TABLE Sample_Data
   --INSERT INTO Sample_Data
   --SELECT * FROM #Sample_Data
   v_PROCESSINGDATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_SetID NUMBER(10,0) := ( SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 
     FROM PRO_RBL_MISDB_PROD.ProcessMonitor 
    WHERE  TimeKey = v_TIMEKEY );
   v_MocTimeKey NUMBER(10,0) := v_Timekey;
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT dmy /*END:SQLDEV*/
   SELECT TIMEKEY 

     INTO v_TIMEKEY
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY;
   BEGIN
      DECLARE
         v_EntityKey NUMBER(10,0) := 0;

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CustNpa_6  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_CustNpa_6;
         UTILS.IDENTITY_RESET('tt_CustNpa_6');

         INSERT INTO tt_CustNpa_6 ( 
         	SELECT A.CustomerEntityID ,
                 A.RefCustomerID CustomerID  ,
                 ACL.AssetClassShortName AssetClassShortName  ,
                 ACL1.AssetClassShortName PostMoc_AssetClassShortName  ,
                 A.SysNPA_Dt NPADate  ,
                 B.SysNPA_Dt PostMoc_NPAdt  ,
                 a.DbtDt ,
                 b.DbtDt PostMoc_DBtdt  ,
                 ACL.AssetClassAlt_Key ,
                 acl1.AssetClassAlt_Key PostMocAssetClassAlt_key  ,
                 A.LossDt ,
                 B.LossDt PostMoc_LossDt  
         	  FROM PreMoc_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.CustomerEntityID = b.CustomerEntityID
                   AND ( A.EffectiveFromTimeKey <= v_MocTimeKey
                   AND A.EffectiveToTimeKey >= v_MocTimeKey )
                   JOIN DimAssetClass ACL   ON A.SysAssetClassAlt_Key = ACL.AssetClassAlt_Key
                   AND ( ACL.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ACL.EffectiveToTimeKey >= v_MocTimeKey )
                   JOIN DimAssetClass ACL1   ON B.SysAssetClassAlt_Key = ACL1.AssetClassAlt_Key
                   AND ( ACL1.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ACL1.EffectiveToTimeKey >= v_MocTimeKey )
         	 WHERE  ( ACL.AssetClassShortName <> ACL1.AssetClassShortName )
                    OR ( A.SysNPA_Dt <> B.SysNPA_Dt ) );
         UPDATE tt_CustNpa_6
            SET PostMoc_NPAdt = NULL
          WHERE  PostMoc_AssetClassShortName = 'STD';
         DBMS_OUTPUT.PUT_LINE('START MOC FOR ADVCUSTNPADETAIL');
         IF utils.object_id('Tempdb..tt_TmpCustNPA_6') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpCustNPA_6 ';
         END IF;
         DELETE FROM tt_TmpCustNPA_6;
         UTILS.IDENTITY_RESET('tt_TmpCustNPA_6');

         INSERT INTO tt_TmpCustNPA_6 ( 
         	SELECT NPA.* 
         	  FROM AdvCustNPADetail NPA
                   JOIN tt_CustNpa_6 B   ON npa.CustomerEntityId = B.CustomerEntityID
                   AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                   AND NPA.EffectiveToTimeKey >= v_MocTimeKey ) );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,20) || 'Row In Temp Table For ADVCUSTNPADETAIL');
         DBMS_OUTPUT.PUT_LINE('TEST');
         --return
         DBMS_OUTPUT.PUT_LINE('Expire Data');
         MERGE INTO NPA 
         USING (SELECT NPA.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
         FROM NPA ,AdvCustNPADetail NPA
                JOIN tt_TmpCustNPA_6 T   ON NPA.CustomerEntityId = T.CustomerEntityId
                AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                AND NPA.EffectiveToTimeKey >= v_MocTimeKey )
                JOIN DimAssetClass ACL   ON ACL.EffectiveFromTimeKey <= v_TimeKey
                AND ACL.EffectiveToTimeKey >= v_TimeKey
                AND ACL.AssetClassAlt_Key = T.Cust_AssetClassAlt_Key 
          WHERE ( NPA.EffectiveFromTimeKey < v_MocTimeKey
           OR ACL.AssetClassShortName = 'STD' )) src
         ON ( NPA.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPA.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE NPA
          WHERE ROWID IN 
         ( SELECT NPA.ROWID
           FROM AdvCustNPADetail NPA
                  JOIN tt_TmpCustNPA_6 T   ON NPA.CustomerEntityId = T.CustomerEntityId
                  AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                  AND NPA.EffectiveToTimeKey >= v_MocTimeKey ),
                NPA
          WHERE  NPA.EffectiveFromTimeKey = v_MocTimeKey
                   AND NPA.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,20) || 'Row In Expire From ADVCUSTNPADETAIL');
         DBMS_OUTPUT.PUT_LINE('INSERT INTO PREMOC.NPA DETAIL ');
         --select * from tt_TmpCustNPA_6
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL ;
         INSERT INTO PreM.AdvCustNPADetail
           ( EntityKey, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  npa.CustomerEntityId ,
                  npa.Cust_AssetClassAlt_Key ,
                  npa.NPADt ,
                  npa.LastInttChargedDt ,
                  npa.DbtDt ,
                  npa.LosDt ,
                  npa.DefaultReason1Alt_Key ,
                  npa.DefaultReason2Alt_Key ,
                  npa.StaffAccountability ,
                  npa.LastIntBooked ,
                  npa.RefCustomerID ,
                  npa.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  npa.CreatedBy ,
                  npa.DateCreated ,
                  npa.ModifiedBy ,
                  npa.DateModified ,
                  npa.ApprovedBy ,
                  npa.DateApproved ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  210 MocTypeAlt_Key  ,
                  ----,NPA.WillfulDefault
                  ----,NPA.WillfulDefaultReasonAlt_Key
                  ----,NPA.WillfulRemark
                  ----,NPA.WillfulDefaultDate
                  NPA.NPA_Reason 
             FROM tt_TmpCustNPA_6 NPA
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL T   ON ( T.EffectiveFromTimeKey <= v_MocTimeKey
                    AND T.EffectiveToTimeKey >= v_MocTimeKey )
                    AND T.CustomerEntityId = NPA.CustomerEntityId
            WHERE  T.CustomerEntityId IS NULL;
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || ' Row Inserted in Premoc.AdvCustNPADetail');
         DBMS_OUTPUT.PUT_LINE('TEST2');
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORD FOR SAME TIME KEY');
         MERGE INTO NPA 
         USING (SELECT NPA.ROWID row_id, DM.AssetClassAlt_Key, SD.PostMoc_NPAdt
         --,DbtDt=   ISNULL(SD.PostMoc_DBtdt,DbtDt)
         , CASE 
         WHEN PostMocAssetClassAlt_key = 6 THEN NULL
         ELSE NVL(SD.PostMoc_DBtdt, sd.DbtDt)
            END AS pos_4, CASE 
         WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt
         ELSE PostMoc_LossDt
            END AS pos_5, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210
         FROM NPA ,AdvCustNPADetail NPA
                JOIN tt_CustNpa_6 sd   ON SD.CustomerEntityId = sd.CustomerEntityId
                JOIN DimAssetClass DM   ON ( DM.EffectiveFromTimeKey <= v_MocTimeKey
                AND DM.EffectiveToTimeKey >= v_MocTimeKey )
                AND SD.PostMocAssetClassAlt_key = DM.AssetClassAlt_Key
                AND DM.AssetClassShortName <> 'STD' 
          WHERE NPA.EffectiveFromTimeKey = v_MocTimeKey
           AND NPA.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( NPA.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET sd.Cust_AssetClassAlt_Key = src.AssetClassAlt_Key,
                                      sd.NPADt = src.PostMoc_NPAdt,
                                      sd.DbtDt = pos_4,
                                      sd.LosDt
                                      --,CreatedBy=@CrModApBy
                                       --,DateCreated=GETDATE()
                                       = pos_5,
                                      sd.ModifiedBy = v_CrModApBy,
                                      sd.DateModified = SYSDATE,
                                      sd.MocStatus = 'Y',
                                      sd.MocDate = SYSDATE,
                                      sd.MocTypeAlt_Key = 210;
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || ' Row UPdate  IN AdvCustNPADetail');
         DBMS_OUTPUT.PUT_LINE('INSERT IN NPA FOR CURRENT TIME KEY');
         DBMS_OUTPUT.PUT_LINE('11');
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM AdvCustNPADetail ;
         INSERT INTO AdvCustNPADetail
           ( EntityKey, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
         --,D2Ktimestamp          
         , MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )

           --declare @MocTimeKey int =4383						
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  NPA.CustomerEntityId ,
                  DM.AssetClassAlt_Key ,
                  NVL(UTILS.CONVERT_TO_VARCHAR2(PostMoc_NPAdt,200,p_style=>103), NPA.NPADt) ,
                  NPA.LastInttChargedDt ,
                  --,ISNULL(SD.PostMoc_DBtdt,DbtDt)
                  --,npa.LosDt
                  CASE 
                       WHEN PostMocAssetClassAlt_key = 6 THEN NULL
                  ELSE NVL(SD.PostMoc_DBtdt, sd.DbtDt)
                     END col  ,
                  CASE 
                       WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt
                  ELSE NPA.LosDt
                     END col  ,
                  NPA.DefaultReason1Alt_Key ,
                  NPA.DefaultReason2Alt_Key ,
                  NPA.StaffAccountability ,
                  NPA.LastIntBooked ,
                  NPA.RefCustomerID ,
                  NPA.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  v_CrModApBy ,
                  SYSDATE ,
                  NPA.ModifiedBy ,
                  --,@CrModApBy
                  NPA.DateModified ,
                  NPA.ApprovedBy ,
                  NPA.DateApproved ,
                  --,NPA.D2Ktimestamp          
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  210 MocTypeAlt_Key  ,
                  ----,NPA.WillfulDefault
                  ----,NPA.WillfulDefaultReasonAlt_Key
                  ----,NPA.WillfulRemark
                  ----,NPA.WillfulDefaultDate
                  NPA.NPA_Reason 
             FROM tt_TmpCustNPA_6 NPA
                    JOIN tt_CustNpa_6 SD   ON NPA.CustomerEntityId = SD.CustomerEntityId
                    JOIN DimAssetClass DM   ON ( DM.EffectiveFromTimeKey <= v_MocTimeKey
                    AND DM.EffectiveToTimeKey >= v_MocTimeKey )
                    AND SD.PostMocAssetClassAlt_key = DM.AssetClassAlt_Key
                    LEFT JOIN AdvCustNPADetail AA   ON AA.EffectiveFromTimeKey = v_TimeKey
                    AND AA.EffectiveToTimeKey = v_TimeKey
                    AND NPA.CustomerEntityId = AA.CustomerEntityId
            WHERE  AA.CustomerEntityId IS NULL
                     AND dm.AssetClassGroup = 'NPA';
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || 'INSERT IN NPA FOR CURRENT TIME KEY');
         DBMS_OUTPUT.PUT_LINE('12');
         DBMS_OUTPUT.PUT_LINE('INSERT IN NPA FOR LIVE');
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM AdvCustNPADetail ;
         INSERT INTO AdvCustNPADetail
           ( EntityKey, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
         --,D2Ktimestamp         
         , MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  NPA.CustomerEntityId ,
                  NPA.Cust_AssetClassAlt_Key ,
                  NPA.NPADt ,
                  NPA.LastInttChargedDt ,
                  NPA.DbtDt ,
                  NPA.LosDt ,
                  NPA.DefaultReason1Alt_Key ,
                  NPA.DefaultReason2Alt_Key ,
                  NPA.StaffAccountability ,
                  NPA.LastIntBooked ,
                  NPA.RefCustomerID ,
                  NPA.AuthorisationStatus ,
                  v_MocTimeKey + 1 EffectiveFromTimeKey  ,
                  NPA.EffectiveToTimeKey ,
                  NPA.CreatedBy ,
                  NPA.DateCreated ,
                  NPA.ModifiedBy ,
                  --,@CrModApBy
                  NPA.DateModified ,
                  NPA.ApprovedBy ,
                  NPA.DateApproved ,
                  --,NPA.D2Ktimestamp         
                  MocStatus ,
                  MocDate ,
                  MocTypeAlt_Key ,
                  ----,NPA.WillfulDefault
                  ----,NPA.WillfulDefaultReasonAlt_Key
                  ----,NPA.WillfulRemark
                  ----,NPA.WillfulDefaultDate
                  NPA.NPA_Reason 
             FROM tt_TmpCustNPA_6 NPA
            WHERE  NPA.EffectiveToTimeKey > v_MocTimeKey;
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || 'INSERT IN NPA FOR LIVE');
         DBMS_OUTPUT.PUT_LINE('UPDATE SOURCE TABLE FOR NPA DETAIL');
         -------ADD FRESH NPA RECORDS FROM MOC
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM AdvCustNPADetail ;
         INSERT INTO AdvCustNPADetail
           ( ENTITYKEY, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key
         --,WillfulDefault
          --,WillfulDefaultReasonAlt_Key
          --,WillfulRemark
          --,WillfulDefaultDate
         , NPA_Reason )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  A.CustomerEntityId ,
                  C.AssetClassAlt_Key ,
                  ---,CONVERT(DATE, A.PostMoc_NPAdt,103)
                  A.PostMoc_NPAdt ,
                  NULL LastInttChargedDt  ,
                  A.PostMoc_DBtdt DbtDt  ,
                  LosDt ,
                  NULL DefaultReason1Alt_Key  ,
                  NULL DefaultReason2Alt_Key  ,
                  NULL StaffAccountability  ,
                  NULL LastIntBooked  ,
                  A.CustomerID ,
                  NULL AuthorisationStatus  ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  v_CrModApBy CreatedBy  ,
                  SYSDATE DateCreated  ,
                  NULL ModifiedBy  ,
                  NULL DateModified  ,
                  NULL ApprovedBy  ,
                  NULL DateApproved  ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  210 MocTypeAlt_Key  ,
                  ----,NULL WillfulDefault
                  ----,NULL WillfulDefaultReasonAlt_Key
                  ----,NULL WillfulRemark
                  ----,NULL WillfulDefaultDate
                  NULL NPA_Reason  
             FROM tt_CustNpa_6 A
                    JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.PostMocAssetClassAlt_key, ' ')
                    AND C.EffectiveFromTimeKey <= v_MocTimeKey
                    AND C.EffectiveToTimeKey >= v_MocTimeKey
                    LEFT JOIN AdvCustNPADetail D   ON D.CustomerEntitYID = A.CustomerEntitYID
                    AND ( D.EffectiveFromTimeKey <= v_MocTimeKey
                    AND D.EFFECTIVETOTIMEKEY >= v_MocTimeKey )
            WHERE  NVL(c.AssetClassGroup, ' ') = 'NPA' --AND ISNULL(POSTMOCASSETCLASSIFICATION,'')<>'STD'

                     AND D.CustomerEntitYID IS NULL;
         /*	START MOC FOR BALANCE DETAIL*/
         TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AcDataMoc  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AcDataMoc;
         UTILS.IDENTITY_RESET('tt_AcDataMoc');

         INSERT INTO tt_AcDataMoc ( 
         	SELECT CustomerEntityID ,
                 RefCustomerID CustomerID  ,
                 CustomerAcID ,
                 AccountEntityID ,
                 AddlProvision ,
                 TotalProvision TotalProv  ,
                 Balance ,
                 UnserviedInt UnAppliedIntAmount  ,
                 DFVAmt ,
                 FlgRestructure ,
                 RestructureDate ,
                 FlgFITL ,
                 FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                 FinalNpaDt NpaDate  ,
                 RePossession ,
                 PrincOutStd PrincipalBalance  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',30) RefSystemAcId  
         	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SystemACID
         FROM A ,tt_AcDataMoc A
                JOIN AdvAcBasicDetail B   ON B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                AND A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RefSystemAcId = src.SystemACID;
         IF utils.object_id('Tempdb..tt_TmpAcBalance_6') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpAcBalance_6 ';
         END IF;
         DELETE FROM tt_TmpAcBalance_6;
         UTILS.IDENTITY_RESET('tt_TmpAcBalance_6');

         INSERT INTO tt_TmpAcBalance_6 ( 
         	SELECT A.* 
         	  FROM RBL_MISDB_PROD.AdvAcBalanceDetail a
                   JOIN tt_AcDataMoc b   ON a.EffectiveFromTimeKey <= v_MocTimeKey
                   AND a.EffectiveToTimeKey >= v_MocTimeKey
                   AND a.AccountEntityId = b.AccountEntityId
         	 WHERE  ( A.AssetClassAlt_Key <> b.AssetClassAlt_Key
                    OR NVL(A.BAlance, 0) <> NVL(b.Balance, 0)
                    OR NVL(A.UnAppliedIntAmount, 0) = NVL(B.UnAppliedIntAmount, 0)
                    OR NVL(A.PrincipalBalance, 0) = NVL(B.PrincipalBalance, 0)
                    OR NVL(A.TotalProv, 0) = NVL(B.TotalProv, 0)
                    OR NVL(A.DFVAmt, 0) = NVL(B.DFVAmt, 0) ) );
         DBMS_OUTPUT.PUT_LINE('Expire data');
         MERGE INTO AABD 
         USING (SELECT AABD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM AABD ,RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                JOIN tt_TmpAcBalance_6 T   ON AABD.AccountEntityId = T.AccountEntityId
                AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                AND AABD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE AABD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( AABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET AABD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE AABD
          WHERE ROWID IN 
         ( SELECT AABD.ROWID
           FROM RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                  JOIN tt_TmpAcBalance_6 T   ON AABD.AccountEntityId = T.AccountEntityId
                  AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND AABD.EffectiveToTimeKey >= v_MocTimeKey ),
                AABD
          WHERE  AABD.EffectiveFromTimeKey = v_MocTimeKey
                   AND AABD.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('Insert data in Premoc.Balance ');
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail ;
         INSERT INTO PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv
         ----,DirectBalance
          ----,InDirectBalance
          ----,LastCrAmt
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy
         ----,PS_NPS_FLAG
         , OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance, UnAppliedIntAmount, DFVAmt )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  T.AccountEntityId ,
                  T.AssetClassAlt_Key ,
                  T.BalanceInCurrency ,
                  T.Balance ,
                  T.SignBalance ,
                  T.LastCrDt ,
                  T.OverDue ,
                  T.TotalProv ,
                  ----,T.DirectBalance
                  ----,T.InDirectBalance
                  ----,T.LastCrAmt
                  T.RefCustomerId ,
                  T.RefSystemAcId ,
                  T.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  T.OverDueSinceDt ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  T.MocTypeAlt_Key ,
                  T.Old_OverDueSinceDt ,
                  T.Old_OverDue ,
                  T.ORG_TotalProv ,
                  T.IntReverseAmt ,
                  T.PS_Balance ,
                  T.NPS_Balance ,
                  T.DateCreated ,
                  T.ModifiedBy ,
                  T.DateModified ,
                  T.ApprovedBy ,
                  T.DateApproved ,
                  T.CreatedBy ,
                  ----,T.PS_NPS_FLAG
                  T.OverduePrincipal ,
                  T.Overdueinterest ,
                  T.AdvanceRecovery ,
                  T.NotionalInttAmt ,
                  T.PrincipalBalance ,
                  t.UnAppliedIntAmount ,
                  T.DFVAmt 
             FROM tt_TmpAcBalance_6 T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail PRE   ON ( PRE.EffectiveFromTimeKey <= v_MocTimeKey
                    AND PRE.EffectiveToTimeKey >= v_MocTimeKey )
                    AND PRE.AccountEntityId = T.AccountEntityId --AND PRE.AccountEntityId IS NULL

            WHERE  PRE.AccountEntityId IS NULL;
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO AABD 
         USING (SELECT AABD.ROWID row_id, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, bb.AssetClassAlt_Key, bb.balance, bb.balance, CASE 
         WHEN aabd.PS_Balance > 0 THEN ((NVL(bb.Balance, 0)))
         ELSE AABD.PS_Balance
            END AS pos_10, CASE 
         WHEN aabd.NPS_Balance > 0 THEN ((NVL(bb.Balance, 0)))
         ELSE AABD.NPS_Balance
            END AS pos_11, bb.UnAppliedIntAmount, bb.PrincipalBalance, bb.TotalProv, BB.DFVAmt
         ----select 1

         FROM AABD ,RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                JOIN tt_TmpAcBalance_6 T   ON AABD.AccountEntityId = T.AccountEntityId
                JOIN tt_AcDataMoc bb   ON bb.AccountEntityId = t.AccountEntityId 
          WHERE AABD.EffectiveFromTimeKey = v_MocTimeKey
           AND AABD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( AABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET AABD.ModifiedBy = v_CrModApBy,
                                      AABD.DateModified = SYSDATE,
                                      AABD.MocStatus = 'Y',
                                      AABD.MocDate = SYSDATE,
                                      AABD.MocTypeAlt_Key = 210,
                                      AABD.AssetClassAlt_Key = src.AssetClassAlt_Key,
                                      AABD.BalanceInCurrency = src.balance,
                                      AABD.Balance = src.balance,
                                      AABD.PS_Balance = pos_10,
                                      AABD.NPS_Balance = pos_11,
                                      aabd.UnAppliedIntAmount = src.UnAppliedIntAmount,
                                      aabd.PrincipalBalance = src.PrincipalBalance,
                                      aabd.TotalProv = src.TotalProv,
                                      AABD.DFVAmt = src.DFVAmt;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvAcBalanceDetail ;
         INSERT INTO AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy
         ----,PS_NPS_FLAG
         , OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance, UnAppliedIntAmount, DFVAmt )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  A.AccountEntityId ,
                  sd.AssetClassAlt_Key ,
                  CASE 
                       WHEN SD.AccountEntityId IS NULL THEN A.BalanceInCurrency
                  ELSE ((NVL(SD.Balance, 0)))
                     END col  ,
                  CASE 
                       WHEN SD.AccountEntityId IS NULL THEN A.Balance
                  ELSE ((NVL(SD.Balance, 0)))
                     END col  ,
                  A.SignBalance ,
                  A.LastCrDt ,
                  A.OverDue ,
                  sd.TotalProv ,
                  A.RefCustomerId ,
                  A.RefSystemAcId ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.OverDueSinceDt ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  210 MocTypeAlt_Key  ,
                  A.Old_OverDueSinceDt ,
                  A.Old_OverDue ,
                  A.ORG_TotalProv ,
                  A.IntReverseAmt ,
                  CASE 
                       WHEN A.PS_Balance > 0 THEN ((NVL(SD.Balance, 0)))
                  ELSE A.PS_Balance
                     END PS_Balance  ,
                  CASE 
                       WHEN A.NPS_Balance > 0 THEN ((NVL(SD.Balance, 0)))
                  ELSE A.NPS_Balance
                     END NPS_Balance  ,
                  SYSDATE DateCreated  ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  v_CrModApBy CreatedBy  ,
                  A.OverduePrincipal ,
                  A.Overdueinterest ,
                  A.AdvanceRecovery ,
                  A.NotionalInttAmt ,
                  sd.PrincipalBalance ,
                  sd.UnAppliedIntAmount ,
                  SD.DFVAmt 
             FROM tt_TmpAcBalance_6 A
                    LEFT JOIN tt_AcDataMoc SD   ON A.AccountEntityId = SD.AccountEntityId
                    LEFT JOIN RBL_MISDB_PROD.AdvAcBalanceDetail O   ON A.AccountEntityId = O.AccountEntityId
                    AND ( o.EffectiveFromTimeKey = v_MocTimeKey
                    AND o.EffectiveToTimeKey = v_MocTimeKey )
            WHERE  O.AccountEntityId IS NULL;
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         SELECT MAX(EntityKey)  

           INTO v_EntityKey
           FROM RBL_MISDB_PROD.AdvAcBalanceDetail ;
         INSERT INTO RBL_MISDB_PROD.AdvAcBalanceDetail
           ( EntityKey, AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy, OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance, UnAppliedIntAmount, DFVAmt )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  T.AccountEntityId ,
                  T.AssetClassAlt_Key ,
                  T.BalanceInCurrency ,
                  T.Balance ,
                  T.SignBalance ,
                  T.LastCrDt ,
                  T.OverDue ,
                  T.TotalProv ,
                  T.RefCustomerId ,
                  T.RefSystemAcId ,
                  T.AuthorisationStatus ,
                  v_MocTimeKey + 1 ,
                  T.EffectiveToTimeKey ,
                  T.OverDueSinceDt ,
                  T.MocStatus ,
                  T.MocDate ,
                  T.MocTypeAlt_Key ,
                  T.Old_OverDueSinceDt ,
                  T.Old_OverDue ,
                  T.ORG_TotalProv ,
                  T.IntReverseAmt ,
                  T.PS_Balance ,
                  T.NPS_Balance ,
                  T.DateCreated ,
                  T.ModifiedBy ,
                  T.DateModified ,
                  T.ApprovedBy ,
                  T.DateApproved ,
                  T.CreatedBy ,
                  T.OverduePrincipal ,
                  T.Overdueinterest ,
                  T.AdvanceRecovery ,
                  T.NotionalInttAmt ,
                  T.PrincipalBalance ,
                  t.UnAppliedIntAmount ,
                  T.DFVAmt 
             FROM tt_TmpAcBalance_6 T
            WHERE  T.EffectiveToTimeKey > v_MocTimeKey;
         /********************************************/
         /*	ADVACBASIC DETAIL*/
         IF utils.object_id('Tempdb..tt_AccountBasic') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountBasic ';
         END IF;
         DELETE FROM tt_AccountBasic;
         UTILS.IDENTITY_RESET('tt_AccountBasic');

         INSERT INTO tt_AccountBasic ( 
         	SELECT abd.* 
         	  FROM AdvAcBasicDetail abd
                   JOIN tt_AcDataMoc t   ON ( abd.AccountEntityId = T.AccountEntityId )
                   AND ( abd.EffectiveFromTimeKey <= v_MocTimeKey
                   AND abd.EffectiveToTimeKey >= v_MocTimeKey )
         	 WHERE  NVL(ABD.AdditionalProv, 0) <> NVL(T.AddlProvision, 0) );
         SELECT MAX(AC_KEY)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.ADVACBASICDETAIL ;
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVACBASICDETAIL
           ( AC_KEY, BranchCode, AccountEntityId, CustomerEntityId, SystemACID, CustomerACID, GLAlt_Key, ProductAlt_Key, GLProductAlt_Key, FacilityType, SectorAlt_Key, SubSectorAlt_Key, ActivityAlt_Key, IndustryAlt_Key, SchemeAlt_Key, DistrictAlt_Key, AreaAlt_Key, VillageAlt_Key, StateAlt_Key, CurrencyAlt_Key, OriginalSanctionAuthAlt_Key, OriginalLimitRefNo, OriginalLimit, OriginalLimitDt, DtofFirstDisb, EmpCode, FlagReliefWavier, UnderLineActivityAlt_Key, MicroCredit, segmentcode, ScrCrError, AdjDt, AdjReasonAlt_Key, MarginType, Pref_InttRate, CurrentLimitRefNo, ProcessingFeeApplicable, ProcessingFeeAmt, ProcessingFeeRecoveryAmt, GuaranteeCoverAlt_Key, AccountName, ReferencePeriod, AssetClass, D2K_REF_NO, InttAppFreq, JointAccount, LastDisbDt, ScrCrErrorBackup, AccountOpenDate, Ac_LADDt, Ac_DocumentDt, CurrentLimit, InttTypeAlt_Key, InttRateLoadFactor, Margin, TwentyPointReference, BSR1bCode, CurrentLimitDt, Ac_DueDt, DrawingPowerAlt_Key, RefCustomerId, D2KACID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key, AcCategegoryAlt_Key, OriginalSanctionAuthLevelAlt_Key, AcTypeAlt_Key, AcCategoryAlt_Key, ScrCrErrorSeq, SourceAlt_Key, LoanSeries, LoanRefNo, SecuritizationCode, Full_Disb, OriginalBranchcode )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  abd.BranchCode ,
                  abd.AccountEntityId ,
                  abd.CustomerEntityId ,
                  abd.SystemACID ,
                  abd.CustomerACID ,
                  abd.GLAlt_Key ,
                  abd.ProductAlt_Key ,
                  abd.GLProductAlt_Key ,
                  abd.FacilityType ,
                  abd.SectorAlt_Key ,
                  abd.SubSectorAlt_Key ,
                  abd.ActivityAlt_Key ,
                  abd.IndustryAlt_Key ,
                  abd.SchemeAlt_Key ,
                  abd.DistrictAlt_Key ,
                  abd.AreaAlt_Key ,
                  abd.VillageAlt_Key ,
                  abd.StateAlt_Key ,
                  abd.CurrencyAlt_Key ,
                  abd.OriginalSanctionAuthAlt_Key ,
                  abd.OriginalLimitRefNo ,
                  abd.OriginalLimit ,
                  abd.OriginalLimitDt ,
                  abd.DtofFirstDisb ,
                  abd.EmpCode ,
                  abd.FlagReliefWavier ,
                  abd.UnderLineActivityAlt_Key ,
                  abd.MicroCredit ,
                  abd.segmentcode ,
                  abd.ScrCrError ,
                  abd.AdjDt ,
                  abd.AdjReasonAlt_Key ,
                  abd.MarginType ,
                  abd.Pref_InttRate ,
                  abd.CurrentLimitRefNo ,
                  abd.ProcessingFeeApplicable ,
                  abd.ProcessingFeeAmt ,
                  abd.ProcessingFeeRecoveryAmt ,
                  abd.GuaranteeCoverAlt_Key ,
                  abd.AccountName ,
                  abd.ReferencePeriod ,
                  abd.AssetClass ,
                  abd.D2K_REF_NO ,
                  abd.InttAppFreq ,
                  abd.JointAccount ,
                  abd.LastDisbDt ,
                  abd.ScrCrErrorBackup ,
                  abd.AccountOpenDate ,
                  abd.Ac_LADDt ,
                  abd.Ac_DocumentDt ,
                  abd.CurrentLimit ,
                  abd.InttTypeAlt_Key ,
                  abd.InttRateLoadFactor ,
                  abd.Margin ,
                  abd.TwentyPointReference ,
                  abd.BSR1bCode ,
                  abd.CurrentLimitDt ,
                  abd.Ac_DueDt ,
                  abd.DrawingPowerAlt_Key ,
                  abd.RefCustomerId ,
                  abd.D2KACID ,
                  abd.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  abd.CreatedBy ,
                  abd.DateCreated ,
                  abd.ModifiedBy ,
                  abd.DateModified ,
                  abd.ApprovedBy ,
                  abd.DateApproved ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  abd.MocTypeAlt_Key ,
                  abd.AcCategoryAlt_Key ,
                  abd.OriginalSanctionAuthLevelAlt_Key ,
                  abd.AcTypeAlt_Key ,
                  abd.AcCategoryAlt_Key ,
                  abd.ScrCrErrorSeq ,
                  abd.SourceAlt_Key ,
                  abd.LoanSeries ,
                  abd.LoanRefNo ,
                  ABD.SecuritizationCode ,
                  ABD.Full_Disb ,
                  ABD.OriginalBranchcode 
             FROM AdvAcBasicDetail abd
                    JOIN tt_AccountBasic b   ON abd.AccountEntityId = b.AccountEntityid
                    AND abd.EffectiveFromTimeKey <= v_MocTimeKey
                    AND abd.EffectiveToTimeKey >= v_MocTimeKey
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVACBASICDETAIL T   ON ( T.EffectiveFromTimeKey <= v_MocTimeKey
                    AND T.EffectiveToTimeKey >= v_MocTimeKey )
                    AND T.CustomerACID = abd.CustomerACID
            WHERE  T.CustomerEntityId IS NULL;
         MERGE INTO abd 
         USING (SELECT abd.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM abd ,AdvAcBasicDetail abd
                JOIN tt_AccountBasic T   ON abd.AccountEntityId = T.AccountEntityId
                AND ( abd.EffectiveFromTimeKey <= v_MocTimeKey
                AND abd.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE abd.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( abd.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET abd.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE abd
          WHERE ROWID IN 
         ( SELECT abd.ROWID
           FROM AdvAcBasicDetail abd
                  JOIN tt_AccountBasic T   ON abd.AccountEntityId = T.AccountEntityId,
                abd
          WHERE  abd.EffectiveFromTimeKey = v_MocTimeKey
                   AND abd.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('TEST2111');
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORD FOR SAME TIME KEY');
         MERGE INTO abd 
         USING (SELECT abd.ROWID row_id, 'Y', SYSDATE, 210, A.AddlProvision, v_CrModApBy, SYSDATE
         FROM abd ,AdvAcBasicDetail abd
                JOIN tt_AcDataMoc A   ON ( ABD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ABD.EffectiveToTimeKey >= v_MocTimeKey )
                AND ABD.AccountEntityId = A.AccountEntityId 
          WHERE ABD.EffectiveFromTimeKey = v_MocTimeKey
           AND ABD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( abd.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET abd.MocStatus = 'Y',
                                      abd.MocDate = SYSDATE,
                                      abd.MocTypeAlt_Key = 210,
                                      abd.AdditionalProv = src.AddlProvision,
                                      abd.ModifiedBy = v_CrModApBy,
                                      abd.DateModified = SYSDATE;
         --------			PRINT 'INSERT IN ACCOUNT FOR CURRENT TIME KEY'
         SELECT MAX(AC_KEY)  

           INTO v_EntityKey
           FROM AdvAcBasicDetail ;
         INSERT INTO AdvAcBasicDetail
           ( Ac_Key, BranchCode, AccountEntityId, CustomerEntityId, SystemACID, CustomerACID, GLAlt_Key, ProductAlt_Key, GLProductAlt_Key, FacilityType, SectorAlt_Key, SubSectorAlt_Key, ActivityAlt_Key, IndustryAlt_Key, SchemeAlt_Key, DistrictAlt_Key, AreaAlt_Key, VillageAlt_Key, StateAlt_Key, CurrencyAlt_Key, OriginalSanctionAuthAlt_Key, OriginalLimitRefNo, OriginalLimit, OriginalLimitDt, Pref_InttRate, CurrentLimitRefNo
         ----,ProcessingFeeApplicable
          ----,ProcessingFeeAmt
          ----,ProcessingFeeRecoveryAmt
         , GuaranteeCoverAlt_Key, AccountName
         ----,ReferencePeriod
         , AssetClass
         ----,D2K_REF_NO
          ----,InttAppFreq
         , JointAccount, LastDisbDt, ScrCrErrorBackup, AccountOpenDate, Ac_LADDt, Ac_DocumentDt, CurrentLimit, InttTypeAlt_Key, InttRateLoadFactor, Margin
         ----,TwentyPointReference
          ----,BSR1bCode
         , CurrentLimitDt, Ac_DueDt, DrawingPowerAlt_Key, RefCustomerId
         ----,D2KACID
         , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key, IsLAD
         --	,FacilitiesNo
         , FincaleBasedIndustryAlt_key, AcCategoryAlt_Key, OriginalSanctionAuthLevelAlt_Key, AcTypeAlt_Key, ScrCrErrorSeq
         ---,D2k_OLDAscromID
         , BSRUNID, AdditionalProv, ProjectCost, DtofFirstDisb
         ----,EmpCode
         , FlagReliefWavier, UnderLineActivityAlt_Key, MicroCredit, segmentcode, ScrCrError, AdjDt, AdjReasonAlt_Key, MarginType, AclattestDevelopment, SourceAlt_Key, LoanSeries, LoanRefNo, SecuritizationCode, Full_Disb, OriginalBranchcode )

           --declare @MocTimeKey int =4383						
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  ABD.BranchCode ,
                  ABD.AccountEntityId ,
                  ABD.CustomerEntityId ,
                  ABD.SystemACID ,
                  ABD.CustomerACID ,
                  ABD.GLAlt_Key ,
                  ABD.ProductAlt_Key ,
                  ABD.GLProductAlt_Key ,
                  ABD.FacilityType ,
                  ABD.SectorAlt_Key ,
                  ABD.SubSectorAlt_Key ,
                  ABD.ActivityAlt_Key ,
                  ABD.IndustryAlt_Key ,
                  ABD.SchemeAlt_Key ,
                  ABD.DistrictAlt_Key ,
                  ABD.AreaAlt_Key ,
                  ABD.VillageAlt_Key ,
                  ABD.StateAlt_Key ,
                  ABD.CurrencyAlt_Key ,
                  ABD.OriginalSanctionAuthAlt_Key ,
                  ABD.OriginalLimitRefNo ,
                  ABD.OriginalLimit ,
                  ABD.OriginalLimitDt ,
                  ABD.Pref_InttRate ,
                  ABD.CurrentLimitRefNo ,
                  ----,ProcessingFeeApplicable
                  ----,ProcessingFeeAmt
                  ----,ProcessingFeeRecoveryAmt
                  ABD.GuaranteeCoverAlt_Key ,
                  ABD.AccountName ,
                  ----,ReferencePeriod
                  ABD.AssetClass ,
                  ----,D2K_REF_NO
                  ----,InttAppFreq
                  ABD.JointAccount ,
                  ABD.LastDisbDt ,
                  ABD.ScrCrErrorBackup ,
                  ABD.AccountOpenDate ,
                  ABD.Ac_LADDt ,
                  ABD.Ac_DocumentDt ,
                  ABD.CurrentLimit ,
                  ABD.InttTypeAlt_Key ,
                  ABD.InttRateLoadFactor ,
                  ABD.Margin ,
                  ----,TwentyPointReference
                  ----,BSR1bCode
                  ABD.CurrentLimitDt ,
                  ABD.Ac_DueDt ,
                  ABD.DrawingPowerAlt_Key ,
                  ABD.RefCustomerId ,
                  ----,D2KACID
                  ABD.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  v_CrModApBy CreatedBy  ,
                  SYSDATE DateCreated  ,
                  ABD.ModifiedBy ,
                  ABD.DateModified ,
                  ABD.ApprovedBy ,
                  ABD.DateApproved ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  210 MocTypeAlt_Key  ,
                  ABD.IsLAD ,
                  --,FacilitiesNo
                  ABD.FincaleBasedIndustryAlt_key ,
                  ABD.AcCategoryAlt_Key ,
                  ABD.OriginalSanctionAuthLevelAlt_Key ,
                  ABD.AcTypeAlt_Key ,
                  ABD.ScrCrErrorSeq ,
                  --,D2k_OLDAscromID
                  ABD.BSRUNID ,
                  T.AddlProvision ,
                  ABD.ProjectCost ,
                  ABD.DtofFirstDisb ,
                  ----,EmpCode
                  ABD.FlagReliefWavier ,
                  ABD.UnderLineActivityAlt_Key ,
                  ABD.MicroCredit ,
                  ABD.segmentcode ,
                  ABD.ScrCrError ,
                  ABD.AdjDt ,
                  ABD.AdjReasonAlt_Key ,
                  ABD.MarginType ,
                  ABD.AclattestDevelopment ,
                  ABD.SourceAlt_Key ,
                  ABD.LoanSeries ,
                  ABD.LoanRefNo ,
                  ABD.SecuritizationCode ,
                  ABD.Full_Disb ,
                  ABD.OriginalBranchcode 
             FROM tt_AccountBasic abd
                    JOIN tt_AcDataMoc T   ON T.AccountEntityID = ABD.AccountEntityId
                    LEFT JOIN AdvAcBasicDetail bb   ON ( bb.EffectiveFromTimeKey = v_MocTimeKey
                    AND bb.EffectiveToTimeKey = v_MocTimeKey )
            WHERE  ( ABD.EffectiveFromTimeKey <= v_MocTimeKey
                     AND ABD.EffectiveToTimeKey >= v_MocTimeKey )
                     AND bb.AccountEntityId IS NULL;
         --------		PRINT 'INSERT IN ACCOUNT FOR LIVE'
         SELECT MAX(AC_KEY)  

           INTO v_EntityKey
           FROM AdvAcBasicDetail ;
         INSERT INTO AdvAcBasicDetail
           ( Ac_Key, BranchCode, AccountEntityId, CustomerEntityId, SystemACID, CustomerACID, GLAlt_Key, ProductAlt_Key, GLProductAlt_Key, FacilityType, SectorAlt_Key, SubSectorAlt_Key, ActivityAlt_Key, IndustryAlt_Key, SchemeAlt_Key, DistrictAlt_Key, AreaAlt_Key, VillageAlt_Key, StateAlt_Key, CurrencyAlt_Key, OriginalSanctionAuthAlt_Key, OriginalLimitRefNo, OriginalLimit, OriginalLimitDt, Pref_InttRate, CurrentLimitRefNo
         ----,ProcessingFeeApplicable
          ----,ProcessingFeeAmt
          ----,ProcessingFeeRecoveryAmt
         , GuaranteeCoverAlt_Key, AccountName
         ----,ReferencePeriod
         , AssetClass
         ----,D2K_REF_NO
          ----,InttAppFreq
         , JointAccount, LastDisbDt, ScrCrErrorBackup, AccountOpenDate, Ac_LADDt, Ac_DocumentDt, CurrentLimit, InttTypeAlt_Key, InttRateLoadFactor, Margin
         ----,TwentyPointReference
          ----,BSR1bCode
         , CurrentLimitDt, Ac_DueDt, DrawingPowerAlt_Key, RefCustomerId
         ----,D2KACID
         , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key, IsLAD
         --,FacilitiesNo
         , FincaleBasedIndustryAlt_key, AcCategoryAlt_Key, OriginalSanctionAuthLevelAlt_Key, AcTypeAlt_Key, ScrCrErrorSeq
         --,D2k_OLDAscromID
         , BSRUNID, AdditionalProv, ProjectCost, DtofFirstDisb
         ----,EmpCode
         , FlagReliefWavier, UnderLineActivityAlt_Key, MicroCredit, segmentcode, ScrCrError, AdjDt, AdjReasonAlt_Key, MarginType, AclattestDevelopment, SourceAlt_Key, LoanSeries, LoanRefNo, SecuritizationCode, Full_Disb, OriginalBranchcode )

           --declare @MocTimeKey int =4383						
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  BranchCode ,
                  AccountEntityId ,
                  CustomerEntityId ,
                  SystemACID ,
                  CustomerACID ,
                  GLAlt_Key ,
                  ProductAlt_Key ,
                  GLProductAlt_Key ,
                  FacilityType ,
                  SectorAlt_Key ,
                  SubSectorAlt_Key ,
                  ActivityAlt_Key ,
                  IndustryAlt_Key ,
                  SchemeAlt_Key ,
                  DistrictAlt_Key ,
                  AreaAlt_Key ,
                  VillageAlt_Key ,
                  StateAlt_Key ,
                  CurrencyAlt_Key ,
                  OriginalSanctionAuthAlt_Key ,
                  OriginalLimitRefNo ,
                  OriginalLimit ,
                  OriginalLimitDt ,
                  Pref_InttRate ,
                  CurrentLimitRefNo ,
                  ----,ProcessingFeeApplicable
                  ----,ProcessingFeeAmt
                  ----,ProcessingFeeRecoveryAmt
                  GuaranteeCoverAlt_Key ,
                  AccountName ,
                  ----,ReferencePeriod
                  AssetClass ,
                  ----,D2K_REF_NO
                  ----,InttAppFreq
                  JointAccount ,
                  LastDisbDt ,
                  ScrCrErrorBackup ,
                  AccountOpenDate ,
                  Ac_LADDt ,
                  Ac_DocumentDt ,
                  CurrentLimit ,
                  InttTypeAlt_Key ,
                  InttRateLoadFactor ,
                  Margin ,
                  ----,TwentyPointReference
                  ----,BSR1bCode
                  CurrentLimitDt ,
                  Ac_DueDt ,
                  DrawingPowerAlt_Key ,
                  RefCustomerId ,
                  ----,D2KACID
                  AuthorisationStatus ,
                  v_MocTimeKey + 1 EffectiveFromTimeKey  ,
                  EffectiveToTimeKey ,
                  CreatedBy ,
                  DateCreated ,
                  ModifiedBy ,
                  DateModified ,
                  ApprovedBy ,
                  DateApproved ,
                  MocStatus ,
                  MocDate ,
                  MocTypeAlt_Key ,
                  IsLAD ,
                  --,FacilitiesNo
                  FincaleBasedIndustryAlt_key ,
                  AcCategoryAlt_Key ,
                  OriginalSanctionAuthLevelAlt_Key ,
                  AcTypeAlt_Key ,
                  ScrCrErrorSeq ,
                  ---,D2k_OLDAscromID
                  BSRUNID ,
                  AdditionalProv ,
                  ProjectCost ,
                  DtofFirstDisb ,
                  ----,EmpCode
                  FlagReliefWavier ,
                  UnderLineActivityAlt_Key ,
                  MicroCredit ,
                  segmentcode ,
                  ScrCrError ,
                  AdjDt ,
                  AdjReasonAlt_Key ,
                  MarginType ,
                  AclattestDevelopment ,
                  SourceAlt_Key ,
                  LoanSeries ,
                  LoanRefNo ,
                  SecuritizationCode ,
                  Full_Disb ,
                  OriginalBranchcode 
             FROM tt_AccountBasic 
            WHERE  EffectiveToTimeKey > v_MocTimeKey;
         /****************************************************/
         /*	ADVACFINANCIALDETAIL TABLE	*/
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AdvAcFin  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AdvAcFin;
         UTILS.IDENTITY_RESET('tt_AdvAcFin');

         INSERT INTO tt_AdvAcFin ( 
         	SELECT F.* 
         	  FROM AdvAcFinancialDetail F
                   JOIN tt_AcDataMoc B   ON ( F.EffectiveFromTimeKey <= v_MocTimeKey
                   AND F.EffectiveToTimeKey >= v_MocTimeKey )
                   AND F.AccountEntityId = B.AccountEntityId

         	--AND F.AccountEntityId = S.AccountEntityId
         	WHERE  NVL(F.NpaDt, '1900-01-01') <> NVL(B.NpaDate, '1900-01-01') );
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL ;
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL
           ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
         ----,IrregularType
          ----,IrregularityDt
         , NpaDt, BookDebts, UnDrawnAmt
         ----,TotalDI
          ----,UnAppliedIntt
          ----,LegalExp
         , UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason
         ----,WriteOffAmt_HO
          ----,InterestRateCodeAlt_Key
          ----,WriteOffDt
          ----,OD_Dt
         , LimitDisbursed
         ----,WriteOffAmt_BR
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  T.AccountEntityId ,
                  T.Ac_LastReviewDueDt ,
                  T.Ac_ReviewTypeAlt_key ,
                  T.Ac_ReviewDt ,
                  T.Ac_ReviewAuthAlt_Key ,
                  T.Ac_NextReviewDueDt ,
                  T.DrawingPower ,
                  T.InttRate ,
                  ----,T.IrregularType
                  ----,T.IrregularityDt
                  T.NpaDt ,
                  T.BookDebts ,
                  T.UnDrawnAmt ,
                  ----,T.TotalDI
                  ----,T.UnAppliedIntt
                  ----,T.LegalExp
                  T.UnAdjSubSidy ,
                  T.LastInttRealiseDt ,
                  'Y' MocStatus  ,
                  T.MOCReason ,
                  ----,T.WriteOffAmt_HO
                  ----,T.InterestRateCodeAlt_Key
                  ----,T.WriteOffDt
                  ----,T.OD_Dt
                  T.LimitDisbursed ,
                  ----,T.WriteOffAmt_BR
                  T.RefCustomerId ,
                  T.RefSystemAcId ,
                  T.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  T.CreatedBy ,
                  T.DateCreated ,
                  T.ModifiedBy ,
                  T.DateModified ,
                  T.ApprovedBy ,
                  T.DateApproved ,
                  SYSDATE MocDate  ,
                  T.MocTypeAlt_Key ,
                  T.CropDuration ,
                  T.Ac_ReviewAuthLevelAlt_Key 
             FROM tt_AdvAcFin T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL PRE   ON ( PRE.EffectiveFromTimeKey <= v_MocTimeKey
                    AND PRE.EffectiveToTimeKey >= v_MocTimeKey )
                    AND PRE.AccountEntityId = T.AccountEntityId
            WHERE  PRE.AccountEntityId IS NULL;
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM ACFD ,AdvAcFinancialDetail ACFD
                JOIN tt_AdvAcFin T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE ACFD
          WHERE ROWID IN 
         ( SELECT ACFD.ROWID
           FROM AdvAcFinancialDetail ACFD
                  JOIN tt_AdvAcFin T   ON ACFD.AccountEntityId = T.AccountEntityId
                  AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ),
                ACFD
          WHERE  ACFD.EffectiveFromTimeKey = v_MocTimeKey
                   AND ACFD.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, BB.NpaDate
         FROM ACFD ,AdvAcFinancialDetail ACFD
                JOIN tt_AdvAcFin T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey )
                JOIN tt_AcDataMoc bb   ON BB.AccountEntityId = T.AccountEntityId 
          WHERE ACFD.EffectiveFromTimeKey = v_MocTimeKey
           AND ACFD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ModifiedBy = v_CrModApBy,
                                      DateModified = SYSDATE,
                                      MocStatus = 'Y',
                                      MocDate = SYSDATE,
                                      MocTypeAlt_Key = 210,
                                      ACFD.NpaDt = src.NpaDate;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM AdvAcFinancialDetail ;
         INSERT INTO AdvAcFinancialDetail
           ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
         ----,IrregularType
          ----,IrregularityDt
         , NpaDt, BookDebts, UnDrawnAmt
         ----,TotalDI
          ----,UnAppliedIntt
          ----,LegalExp
         , UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason
         ----,WriteOffAmt_HO
          ----,InterestRateCodeAlt_Key
          ----,WriteOffDt
          ----,OD_Dt
         , LimitDisbursed
         ----,WriteOffAmt_BR
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  A.AccountEntityId ,
                  A.Ac_LastReviewDueDt ,
                  A.Ac_ReviewTypeAlt_key ,
                  A.Ac_ReviewDt ,
                  A.Ac_ReviewAuthAlt_Key ,
                  A.Ac_NextReviewDueDt ,
                  A.DrawingPower ,
                  A.InttRate ,
                  ----,IrregularType
                  ----,IrregularityDt
                  T.NpaDate ,
                  A.BookDebts ,
                  A.UnDrawnAmt ,
                  ----,TotalDI
                  ----,UnAppliedIntt
                  ----,LegalExp
                  A.UnAdjSubSidy ,
                  A.LastInttRealiseDt ,
                  'Y' MocStatus  ,
                  A.MOCReason ,
                  ----,WriteOffAmt_HO
                  ----,InterestRateCodeAlt_Key
                  ----,WriteOffDt
                  ----,OD_Dt
                  A.LimitDisbursed ,
                  ----,WriteOffAmt_BR
                  A.RefCustomerId ,
                  A.RefSystemAcId ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  SYSDATE MocDate  ,
                  A.MocTypeAlt_Key ,
                  A.CropDuration ,
                  A.Ac_ReviewAuthLevelAlt_Key 
             FROM tt_AdvAcFin A
                    JOIN tt_AcDataMoc T   ON A.AccountEntityId = T.AccountEntityId
                    LEFT JOIN AdvAcFinancialDetail O   ON ( O.EffectiveFromTimeKey = v_MocTimeKey
                    AND O.EffectiveToTimeKey = v_MocTimeKey )
                    AND O.AccountEntityId = A.AccountEntityId
            WHERE  o.AccountEntityId IS NULL;
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL ;
         INSERT INTO AdvAcFinancialDetail
           ( EntityKey, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
         ----,IrregularType
          ----,IrregularityDt
         , NpaDt, BookDebts, UnDrawnAmt
         ----,TotalDI
          ----,UnAppliedIntt
          ----,LegalExp
         , UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason
         ----,WriteOffAmt_HO
          ----,InterestRateCodeAlt_Key
          ----,WriteOffDt
          ----,OD_Dt
         , LimitDisbursed
         ----,WriteOffAmt_BR
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  AccountEntityId ,
                  Ac_LastReviewDueDt ,
                  Ac_ReviewTypeAlt_key ,
                  Ac_ReviewDt ,
                  Ac_ReviewAuthAlt_Key ,
                  Ac_NextReviewDueDt ,
                  DrawingPower ,
                  InttRate ,
                  --,IrregularType
                  ----,IrregularityDt
                  NpaDt ,
                  BookDebts ,
                  UnDrawnAmt ,
                  ----,TotalDI
                  ----,UnAppliedIntt
                  ----,LegalExp
                  UnAdjSubSidy ,
                  LastInttRealiseDt ,
                  MocStatus ,
                  MOCReason ,
                  ----,WriteOffAmt_HO
                  ----,InterestRateCodeAlt_Key
                  ----,WriteOffDt
                  ----,OD_Dt
                  LimitDisbursed ,
                  ----,WriteOffAmt_BR
                  RefCustomerId ,
                  RefSystemAcId ,
                  AuthorisationStatus ,
                  v_MocTimeKey + 1 EffectiveFromTimeKey  ,
                  EffectiveToTimeKey ,
                  CreatedBy ,
                  DateCreated ,
                  ModifiedBy ,
                  DateModified ,
                  ApprovedBy ,
                  DateApproved ,
                  MocDate ,
                  MocTypeAlt_Key ,
                  CropDuration ,
                  Ac_ReviewAuthLevelAlt_Key 
             FROM tt_AdvAcFin T
            WHERE  T.EffectiveToTimeKey > v_MocTimeKey;
         /****************************************************/
         /*	AdvAcOtherDetail TABLE	*/
         IF  --SQLDEV: NOT RECOGNIZED
         ---755 FUNDED INTEREST TERM LOAN
         IF #FITL_CHANGE  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_FITL_cHANGE;
         UTILS.IDENTITY_RESET('tt_FITL_cHANGE');

         INSERT INTO tt_FITL_cHANGE ( 
         	SELECT A.AccountEntityID ,
                 B.RefSystemAcId ,
                 B.FlgFitl 
         	  FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL A
                   JOIN tt_AcDataMoc B   ON ( A.EffectiveFromTimeKey = v_MocTimeKey
                   AND A.EffectiveToTimeKey = v_MocTimeKey )
                   AND B.AccountEntityId = B.AccountEntityId
         	 WHERE  NVL(a.FlgFITL, 'A') <> NVL(b.FlgFitl, 'A') );
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AccOth  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AccOth;
         UTILS.IDENTITY_RESET('tt_AccOth');

         INSERT INTO tt_AccOth ( 
         	SELECT A.* 
         	  FROM AdvAcOtherDetail A
                   JOIN tt_FITL_cHANGE B   ON A.AccountEntityId = B.AccountEntityId
                   AND ( A.EffectiveFromTimeKey = v_MocTimeKey
                   AND A.EffectiveToTimeKey = v_MocTimeKey ) );
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.AdvAcOtherDetail ;
         INSERT INTO PreMoc_RBL_MISDB_PROD.AdvAcOtherDetail
           ( EntityKey, AccountEntityId, GovGurAmt, SplCatg1Alt_Key, SplCatg2Alt_Key, RefinanceAgencyAlt_Key, RefinanceAmount, BankAlt_Key, TransferAmt, ProjectId, ConsortiumId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, SplCatg3Alt_Key, SplCatg4Alt_Key, MocTypeAlt_Key, GovGurExpDt )

           ---,SplFlag							
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  A.AccountEntityId ,
                  A.GovGurAmt ,
                  A.SplCatg1Alt_Key ,
                  A.SplCatg2Alt_Key ,
                  A.RefinanceAgencyAlt_Key ,
                  A.RefinanceAmount ,
                  A.BankAlt_Key ,
                  A.TransferAmt ,
                  A.ProjectId ,
                  A.ConsortiumId ,
                  A.RefSystemAcId ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  A.SplCatg3Alt_Key ,
                  A.SplCatg4Alt_Key ,
                  A.MocTypeAlt_Key ,
                  A.GovGurExpDt 

             ---,SplFlag		
             FROM tt_AccOth A
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.AdvAcOtherDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeLey >= v_TimeKey )
                    AND a.AccountEntityId = B.AccountEntityID
            WHERE  B.AccountEntityId IS NULL;
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM ACFD ,AdvAcOtherDetail ACFD
                JOIN tt_AccOth T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE ACFD
          WHERE ROWID IN 
         ( SELECT ACFD.ROWID
           FROM AdvAcOtherDetail ACFD
                  JOIN tt_AccOth T   ON ACFD.AccountEntityId = T.AccountEntityId
                  AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ),
                ACFD
          WHERE  ACFD.EffectiveFromTimeKey = v_MocTimeKey
                   AND ACFD.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, 755
         FROM ACFD ,AdvAcOtherDetail ACFD
                JOIN tt_AccOth T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey )
                JOIN tt_AcDataMoc bb   ON BB.AccountEntityId = T.AccountEntityId
                AND BB.FlgFITL = 'Y' 
          WHERE ACFD.EffectiveFromTimeKey = v_MocTimeKey
           AND ACFD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.ModifiedBy = v_CrModApBy,
                                      ACFD.DateModified = SYSDATE,
                                      ACFD.MocStatus = 'Y',
                                      ACFD.MocDate = SYSDATE,
                                      ACFD.MocTypeAlt_Key = 210,
                                      ACFD.SplCatg4Alt_Key = 755;
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, CASE 
         WHEN ACFD.SplCatg1Alt_Key = 755 THEN NULL
         ELSE ACFD.SplCatg1Alt_Key
            END AS pos_7, CASE 
         WHEN ACFD.SplCatg2Alt_Key = 755 THEN NULL
         ELSE ACFD.SplCatg2Alt_Key
            END AS pos_8, CASE 
         WHEN ACFD.SplCatg3Alt_Key = 755 THEN NULL
         ELSE ACFD.SplCatg3Alt_Key
            END AS pos_9, CASE 
         WHEN ACFD.SplCatg4Alt_Key = 755 THEN NULL
         ELSE ACFD.SplCatg4Alt_Key
            END AS pos_10
         FROM ACFD ,AdvAcOtherDetail ACFD
                JOIN tt_AccOth T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey )
                JOIN tt_AcDataMoc bb   ON BB.AccountEntityId = T.AccountEntityId
                AND BB.FlgFITL = 'N' 
          WHERE ACFD.EffectiveFromTimeKey = v_MocTimeKey
           AND ACFD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.ModifiedBy = v_CrModApBy,
                                      ACFD.DateModified = SYSDATE,
                                      ACFD.MocStatus = 'Y',
                                      ACFD.MocDate = SYSDATE,
                                      ACFD.MocTypeAlt_Key = 210,
                                      ACFD.SplCatg1Alt_Key = pos_7,
                                      ACFD.SplCatg2Alt_Key = pos_8,
                                      ACFD.SplCatg3Alt_Key = pos_9,
                                      ACFD.SplCatg4Alt_Key = pos_10;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM AdvAcOtherDetail ;
         INSERT INTO AdvAcOtherDetail
           ( EntityKey, AccountEntityId, GovGurAmt, SplCatg1Alt_Key, SplCatg2Alt_Key, RefinanceAgencyAlt_Key, RefinanceAmount, BankAlt_Key, TransferAmt, ProjectId, ConsortiumId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, SplCatg3Alt_Key, SplCatg4Alt_Key, MocTypeAlt_Key, GovGurExpDt )

           ---,SplFlag							
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  T.AccountEntityId ,
                  A.GovGurAmt ,
                  A.SplCatg1Alt_Key ,
                  A.SplCatg2Alt_Key ,
                  A.RefinanceAgencyAlt_Key ,
                  A.RefinanceAmount ,
                  A.BankAlt_Key ,
                  A.TransferAmt ,
                  A.ProjectId ,
                  A.ConsortiumId ,
                  T.RefSystemAcId ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  'Y' MocStatus  ,
                  SYSDATE MocDate  ,
                  A.SplCatg3Alt_Key ,
                  755 SplCatg4Alt_Key  ,
                  A.MocTypeAlt_Key ,
                  A.GovGurExpDt 

             ---,SplFlag		
             FROM tt_FITL_cHANGE T
                    LEFT JOIN tt_AccOth A   ON T.AccountEntityID = A.AccountEntityId
                    LEFT JOIN AdvAcOtherDetail B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                    AND B.EffectiveToTimeKey = v_TimeKey )
                    AND a.AccountEntityId = B.AccountEntityID
            WHERE  B.AccountEntityId IS NULL
                     AND T.FlgFITL = 'Y';
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         SELECT MAX(ENTITYKEY)  

           INTO v_EntityKey
           FROM AdvAcOtherDetail ;
         INSERT INTO AdvAcOtherDetail
           ( EntityKey, AccountEntityId, GovGurAmt, SplCatg1Alt_Key, SplCatg2Alt_Key, RefinanceAgencyAlt_Key, RefinanceAmount, BankAlt_Key, TransferAmt, ProjectId, ConsortiumId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, SplCatg3Alt_Key, SplCatg4Alt_Key, MocTypeAlt_Key, GovGurExpDt )

           ---,SplFlag							
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  A.AccountEntityId ,
                  A.GovGurAmt ,
                  A.SplCatg1Alt_Key ,
                  A.SplCatg2Alt_Key ,
                  A.RefinanceAgencyAlt_Key ,
                  A.RefinanceAmount ,
                  A.BankAlt_Key ,
                  A.TransferAmt ,
                  A.ProjectId ,
                  A.ConsortiumId ,
                  A.RefSystemAcId ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey + EffectiveFromTimeKey ,
                  A.EffectiveToTimeKey ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  MocStatus ,
                  SYSDATE MocDate  ,
                  A.SplCatg3Alt_Key ,
                  A.SplCatg4Alt_Key ,
                  A.MocTypeAlt_Key ,
                  A.GovGurExpDt 

             ---,SplFlag		
             FROM tt_AccOth A
            WHERE  a.EffectiveToTimeKey > v_MocTimeKey;
         /*	ExceptionalDegrationDetail	*/
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ExcpSplFlgs  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ExcpSplFlgs;
         UTILS.IDENTITY_RESET('tt_ExcpSplFlgs');

         INSERT INTO tt_ExcpSplFlgs ( 
         	SELECT * 
         	  FROM ( SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'Inherent Weakness' SplFlg  ,
                          WeakAccount FlgValue  ,
                          0 SplFlgAltKey  ,
                          WeakAccountDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
                   UNION ALL 
                   SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'SARFAESI' SplFlg  ,
                          Sarfaesi FlgValue  ,
                          0 SplFlgAltKey  ,
                          SarfaesiDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
                   UNION ALL 
                   SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'Unusual Bounce' SplFlg  ,
                          FlgUnusualBounce FlgValue  ,
                          0 SplFlgAltKey  ,
                          UnusualBounceDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
                   UNION ALL 
                   SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'Uncleared Effect' SplFlg  ,
                          FlgUnClearedEffect FlgValue  ,
                          0 SplFlgAltKey  ,
                          UnClearedEffectDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
                   UNION ALL 
                   SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'Repossesed' SplFlg  ,
                          RePossession FlgValue  ,
                          0 SplFlgAltKey  ,
                          RepossessionDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
                   UNION ALL 
                   SELECT RefCustomerID CustomerID  ,
                          CustomerACId ,
                          'Fraud Committed' SplFlg  ,
                          FlgFraud FlgValue  ,
                          0 SplFlgAltKey  ,
                          FraudDate FlgDate  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL  ) A );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, b.ParameterAlt_Key
         FROM A ,tt_ExcpSplFlgs A
                JOIN DimParameter B   ON DimParameterName = 'UploadFLagType'
                AND ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND B.ParameterShortName = A.SplFlg ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.SplFlgAltKey = src.ParameterAlt_Key;
         /* DELETE MATCHED RECORDS WITH FLG AND DATE */
         DELETE B
          WHERE ROWID IN 
         ( SELECT B.ROWID
           FROM ExceptionalDegrationDetail A
                  JOIN tt_ExcpSplFlgs B   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                  AND A.EffectiveToTimeKey >= v_TimeKey )
                  AND A.CUSTOMERID = B.CUSTOMERID
                  AND A.ACCOUNTID = B.CustomerAcID
                  AND A.FlagAlt_Key = B.SplFlgAltKey
                  AND b.FlgValue = 'Y'
                  AND NVL(A.Date, '1900-01-01') = NVL(B.FlgDate, '1900-01-01'),
                B );
         /* DELETE MATCHED RECORDS WITH FLG AND DATE */
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ActionData  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ActionData;
         UTILS.IDENTITY_RESET('tt_ActionData');

         INSERT INTO tt_ActionData ( 
         	SELECT B.CustomerID ,
                 B.CustomerAcID ,
                 B.SplFlgAltKey ,
                 B.FlgDate ,
                 B.FlgValue ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.CreatedBy ,
                 A.DateCreated ,
                 A.ModifiedBy ,
                 A.DateModified ,
                 A.ApprovedBy ,
                 A.DateApproved ,
                 A.MarkingAlt_Key ,
                 A.Amount ,
                 'DateChange' ActionType  
         	  FROM ExceptionalDegrationDetail A
                   JOIN tt_ExcpSplFlgs B   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey )
                   AND A.CustomerID = B.CUSTOMERID
                   AND A.AccountID = B.CustomerAcID
                   AND A.FlagAlt_Key = B.SplFlgAltKey
                   AND b.FlgValue = 'Y'
                   AND NVL(A.Date_, '1900-01-01') <> NVL(B.FlgDate, '1900-01-01') );
         INSERT INTO tt_ActionData
           ( SELECT B.CustomerID ,
                    B.CustomerAcID ,
                    B.SplFlgAltKey ,
                    B.FlgDate ,
                    B.FlgValue ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.MarkingAlt_Key ,
                    A.Amount ,
                    'NewTobeAdd' ActionType  
             FROM tt_ExcpSplFlgs b
                    LEFT JOIN ExceptionalDegrationDetail a   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
                    AND A.CustomerID = B.CUSTOMERID
                    AND A.AccountID = B.CustomerAcID
                    AND A.FlagAlt_Key = B.SplFlgAltKey
              WHERE  b.FlgValue = 'Y'
                       AND A.CustomerID IS NULL );
         INSERT INTO tt_ActionData
           ( SELECT B.CustomerID ,
                    B.CustomerAcID ,
                    B.SplFlgAltKey ,
                    B.FlgDate ,
                    B.FlgValue ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.MarkingAlt_Key ,
                    A.Amount ,
                    'ToBeRemoved' ActionType  
             FROM tt_ExcpSplFlgs b
                    JOIN ExceptionalDegrationDetail a   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
                    AND A.CustomerID = B.CUSTOMERID
                    AND A.AccountID = B.CustomerAcID
                    AND A.FlagAlt_Key = B.SplFlgAltKey
              WHERE  b.FlgValue = 'N' );
         IF  --SQLDEV: NOT RECOGNIZED
         IF #DateChange  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_OrgData;
         UTILS.IDENTITY_RESET('tt_OrgData');

         INSERT INTO tt_OrgData ( 
         	SELECT A.* 
         	  FROM ExceptionalDegrationDetail A
                   JOIN tt_ActionData B   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey )
                   AND A.CustomerID = B.CUSTOMERID
                   AND A.AccountID = B.CustomerAcID
                   AND A.FlagAlt_Key = B.SplFlgAltKey
         	 WHERE  b.ActionType IN ( 'DateChange','ToBeRemoved' )
          );
         SELECT MAX(Entity_Key)  

           INTO v_EntityKey
           FROM PreMoc_RBL_MISDB_PROD.ExceptionalDegrationDetail ;
         INSERT INTO PreMoc_RBL_MISDB_PROD.ExceptionalDegrationDetail
           ( Entity_Key, DegrationAlt_Key, SourceAlt_Key, AccountID, CustomerID, FlagAlt_Key, Date_, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MarkingAlt_Key, Amount )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  DegrationAlt_Key ,
                  A.SourceAlt_Key ,
                  A.AccountID ,
                  A.CustomerID ,
                  A.FlagAlt_Key ,
                  A.Date ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  A.MarkingAlt_Key ,
                  A.Amount 
             FROM tt_OrgData A
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ExceptionalDegrationDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey )
                    AND A.CustomerID = B.CustomerID
                    AND a.AccountID = B.AccountID
                    AND a.FlagAlt_Key = b.FlagAlt_Key
            WHERE  B.CustomerID IS NULL;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM B ,ExceptionalDegrationDetail B
                JOIN tt_ActionData T   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND B.EffectiveFromTimeKey < v_MocTimeKey
                AND T.CustomerID = B.CustomerID
                AND T.CustomerAcID = B.AccountID
                AND T.SplFlgAltKey = b.FlagAlt_Key 
          WHERE ActionType IN ( 'DateChange','ToBeRemoved' )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE B
          WHERE ROWID IN 
         ( SELECT B.ROWID
           FROM ExceptionalDegrationDetail B
                  JOIN tt_ActionData T   ON ( B.EffectiveFromTimeKey = v_TimeKey
                  AND B.EffectiveToTimeKey > v_TimeKey )
                  AND B.EffectiveFromTimeKey < v_MocTimeKey
                  AND T.CustomerID = B.CustomerID
                  AND T.CustomerAcID = B.AccountID
                  AND T.SplFlgAltKey = b.FlagAlt_Key,
                B
          WHERE  ActionType IN ( 'DateChange','ToBeRemoved' )
          );
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, T.FlgDate
         FROM B ,ExceptionalDegrationDetail B
                JOIN tt_ActionData T   ON ( B.EffectiveFromTimeKey = v_TimeKey
                AND B.EffectiveToTimeKey = v_TimeKey )
                AND B.EffectiveFromTimeKey < v_MocTimeKey
                AND T.CustomerID = B.CustomerID
                AND T.CustomerAcID = B.AccountID
                AND T.SplFlgAltKey = b.FlagAlt_Key 
          WHERE ActionType IN ( 'DateChang' )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Date_ = src.FlgDate;
         ---- MOC TIMEEY INSERT
         SELECT MAX(Entity_Key)  

           INTO v_EntityKey
           FROM ExceptionalDegrationDetail ;
         INSERT INTO ExceptionalDegrationDetail
           ( Entity_Key, DegrationAlt_Key, SourceAlt_Key, AccountID, CustomerID, FlagAlt_Key, Date_, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MarkingAlt_Key, Amount )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  DegrationAlt_Key ,
                  B.SourceAlt_Key ,
                  A.CustomerAcID AccountID  ,
                  A.CustomerID ,
                  A.SplFlgAltKey FlagAlt_Key  ,
                  A.FlgDate Date_  ,
                  NULL AuthorisationStatus  ,
                  v_MocTimeKey EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  A.MarkingAlt_Key ,
                  A.Amount 
             FROM tt_ActionData A
                    LEFT JOIN ExceptionalDegrationDetail B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey )
                    AND A.CustomerID = B.CustomerID
                    AND a.CustomerAcID = B.AccountID
                    AND a.SplFlgAltKey = b.FlagAlt_Key
            WHERE  B.CustomerID IS NULL
                     AND A.FlgValue = 'Y';
         /* INSERT DATA ON FUTURE TIMEKEY */
         SELECT MAX(Entity_Key)  

           INTO v_EntityKey
           FROM ExceptionalDegrationDetail ;
         INSERT INTO ExceptionalDegrationDetail
           ( Entity_Key, DegrationAlt_Key, SourceAlt_Key, AccountID, CustomerID, FlagAlt_Key, Date_, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MarkingAlt_Key, Amount )
           SELECT v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) EntityKey  ,
                  DegrationAlt_Key ,
                  A.SourceAlt_Key ,
                  A.AccountID ,
                  A.CustomerID ,
                  A.FlagAlt_Key ,
                  A.Date ,
                  A.AuthorisationStatus ,
                  v_MocTimeKey + 1 EffectiveFromTimeKey  ,
                  v_MocTimeKey EffectiveToTimeKey  ,
                  A.CreatedBy ,
                  A.DateCreated ,
                  A.ModifiedBy ,
                  A.DateModified ,
                  A.ApprovedBy ,
                  A.DateApproved ,
                  A.MarkingAlt_Key ,
                  A.Amount 
             FROM tt_OrgData A
            WHERE  A.EffectiveToTimeKey > v_MocTimeKey;
         v_Result := 1 ;
         utils.commit_transaction;
         RETURN v_Result;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
      OPEN  v_cursor FOR
         SELECT utils.error_line ,
                SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_Result := -1 ;
      RETURN v_Result;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC_A" TO "ADF_CDR_RBL_STGDB";
