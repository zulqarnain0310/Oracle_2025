--------------------------------------------------------
--  DDL for Function CUSTOMERACCOUNTMOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" 
(
  iv_TimeKey IN NUMBER,
  v_CrModApBy IN VARCHAR2 DEFAULT 'MOCUPLOAD' ,
  --,@D2Ktimestamp	        TIMESTAMP     =0 OUTPUT 
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --DECLARE 
   -- @XMLDocument          XML='<DataSet>
   --<AuditMOC>
   --<MOC_TYPE> A</MOC_TYPE>
   --<CustomerId>002686851</CustomerId>
   --<ConstitutionAlt_Key>199</ConstitutionAlt_Key>
   --<CustomerAcId>3008020450000044</CustomerAcId>
   --<SchemeAlt_Key>2</SchemeAlt_Key>
   --<PreMocBalance>20000</PreMocBalance>
   --<InterestReversalChg>5000</InterestReversalChg>
   --<LoanProcessChg>10000</LoanProcessChg>
   --<ServiceTax>100</ServiceTax>
   --<InttSubvention>120</InttSubvention>
   --<OtherMocAmt>250</OtherMocAmt>
   --<FinalSecurityValue>150000</FinalSecurityValue>
   --<FinalSubsidyAmt>5000</FinalSubsidyAmt>
   --<PreMocAssetClassification>1</PreMocAssetClassification>
   --<PostMocAssetClassification>2</PostMocAssetClassification>
   --<PostMoc_NPAdt>''01/05/2016''</PostMoc_NPAdt>
   --<PostMoc_NPAdt>''01/05/2017''</PostMoc_NPAdt>
   --<Remark>A</Remark>
   --<ROWNO>1</ROWNO>
   --</AuditMOC></DataSet>' 
   --,@Remark				Varchar(1000)
   --,@MenuID				INT
   --,@OperationFlag			SMALLINT
   --,@AuthMode				CHAR(2)	
   --,@EffectiveFromTimeKey	INT
   --,@EffectiveToTimeKey	INT
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --,@ErrorMsg				Varchar(max)='' OUTPUT
   --WITH RECOMPILE
   --TRUNCATE TABLE Sample_Data
   --INSERT INTO Sample_Data
   --SELECT * FROM #Sample_Data
   --if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocCustomerDataUpload' 
   --  AND  COLUMN_NAME = 'CustomerEntityID')
   --ALTER TABLE dataupload.MocCustomerDataUpload ADD CustomerEntityID INT
   --if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocAccountDataUpload'  
   -- AND  COLUMN_NAME = 'CustomerEntityID')
   --ALTER TABLE dataupload.MocAccountDataUpload	 ADD CustomerEntityID INT
   --if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocAccountDataUpload'  
   -- AND  COLUMN_NAME = 'AccountEntityid')
   --ALTER TABLE dataupload.MocAccountDataUpload	 ADD AccountEntityid INT
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
   DELETE FROM tt_CUST_AC_MOC_3;
   UTILS.IDENTITY_RESET('tt_CUST_AC_MOC_3');

   INSERT INTO tt_CUST_AC_MOC_3 ( 
   	SELECT A.CustomerEntityId ,
           A.AccountEntityid ,
           NVL(BB.MOCAssetClassification, CL.AssetClassShortNameEnum) MOCAssetClassification  ,
           NVL(BB.NPADATE, NPADT) NPADATE  ,
           AmountofWriteOff ,
           NVL(A.Balance, C.Balance) Balance  ,
           UnservInterestAmt ,
           A.AdditionalProvision ,
           AdditionalProvisionAmount 
   	  FROM DataUpload_RBL_MISDB_PROD.MocAccountDataUpload A
             LEFT JOIN DataUpload_RBL_MISDB_PROD.MocCustomerDataUpload BB   ON A.CustomerEntityID = BB.CustomerEntityID
             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail C   ON C.AccountEntityId = A.AccountEntityId
             AND ( C.EffectiveFromTimeKey <= v_MocTimeKey
             AND C.EffectiveToTimeKey >= v_MocTimeKey )
             JOIN DimAssetClass CL   ON CL.AssetClassAlt_Key = C.AssetClassAlt_Key
             AND ( CL.EffectiveFromTimeKey <= v_MocTimeKey
             AND CL.EffectiveToTimeKey >= v_MocTimeKey )
             JOIN AdvAcFinancialDetail D   ON D.AccountEntityId = A.AccountEntityId
             AND ( D.EffectiveFromTimeKey <= v_MocTimeKey
             AND D.EffectiveToTimeKey >= v_MocTimeKey ) );
   INSERT INTO tt_CUST_AC_MOC_3
     ( SELECT A.CustomerEntityId ,
              B.AccountEntityid ,
              A.MOCAssetClassification ,
              A.NPADATE ,
              0 AmountofWriteOff  ,
              C.Balance ,
              c.UnAppliedIntAmount UnservInterestAmt  ,
              0 AdditionalProvision  ,
              AdditionalProv AdditionalProvisionAmount  
       FROM DataUpload_RBL_MISDB_PROD.MocCustomerDataUpload A
              JOIN AdvAcBasicDetail B   ON A.CustomerEntityID = B.CustomerEntityId
              AND ( B.EffectiveFromTimeKey <= v_MocTimeKey
              AND B.EffectiveToTimeKey >= v_MocTimeKey )
              JOIN RBL_MISDB_PROD.AdvAcBalanceDetail C   ON C.AccountEntityId = B.AccountEntityId
              AND ( C.EffectiveFromTimeKey <= v_MocTimeKey
              AND C.EffectiveToTimeKey >= v_MocTimeKey )
              JOIN AdvAcFinancialDetail D   ON D.AccountEntityId = B.AccountEntityId
              AND ( D.EffectiveFromTimeKey <= v_MocTimeKey
              AND D.EffectiveToTimeKey >= v_MocTimeKey )
              LEFT JOIN tt_CUST_AC_MOC_3 E   ON E.AccountEntityid = B.AccountEntityid
        WHERE  E.AccountEntityid IS NULL );
   INSERT INTO tt_CUST_AC_MOC_3
     ( SELECT A.CustomerEntityId ,
              B.AccountEntityid ,
              CL.AssetClassShortNameEnum MOCAssetClassification  ,
              D.NpaDt NPADATE  ,
              0 AmountofWriteOff  ,
              C.Balance ,
              C.UnAppliedIntAmount UnservInterestAmt  ,
              0 AdditionalProvision  ,
              AdditionalProv AdditionalProvisionAmount  
       FROM ( SELECT CustomerEntityId 
              FROM DataUpload_RBL_MISDB_PROD.MocAccountDataUpload 
                GROUP BY CustomerEntityId ) A
              JOIN AdvAcBasicDetail B   ON A.CustomerEntityID = B.CustomerEntityId
              AND ( B.EffectiveFromTimeKey <= v_MocTimeKey
              AND B.EffectiveToTimeKey >= v_MocTimeKey )
              JOIN RBL_MISDB_PROD.AdvAcBalanceDetail C   ON C.AccountEntityId = B.AccountEntityId
              AND ( C.EffectiveFromTimeKey <= v_MocTimeKey
              AND C.EffectiveToTimeKey >= v_MocTimeKey )
              JOIN DimAssetClass CL   ON CL.AssetClassAlt_Key = C.AssetClassAlt_Key
              AND ( CL.EffectiveFromTimeKey <= v_MocTimeKey
              AND CL.EffectiveToTimeKey >= v_MocTimeKey )
              JOIN AdvAcFinancialDetail D   ON D.AccountEntityId = B.AccountEntityId
              AND ( D.EffectiveFromTimeKey <= v_MocTimeKey
              AND D.EffectiveToTimeKey >= v_MocTimeKey )
              LEFT JOIN tt_CUST_AC_MOC_3 E   ON E.AccountEntityid = B.AccountEntityid
        WHERE  E.AccountEntityid IS NULL );
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CustNpa_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_CustNpa_3;
         UTILS.IDENTITY_RESET('tt_CustNpa_3');

         INSERT INTO tt_CustNpa_3 ( 
         	SELECT A.CustomerEntityId ,
                 CustomerId ,
                 CASE 
                      WHEN NVL(A.MOCAssetClassification, ' ') <> ' ' THEN A.MOCAssetClassification
                 ELSE ACL.AssetClassShortName
                    END PostMocAssetClassification  ,
                 --  , MOCAssetClassification PostMocAssetClassification	
                 CASE 
                      WHEN NVL(A.NPADate, ' ') <> ' ' THEN A.NPADate
                 ELSE B.NPADt
                    END PostMoc_NPAdt  ,
                 NULL PostMoc_DBtdt  ,
                 CASE 
                      WHEN ACL1.AssetClassAlt_Key IS NULL THEN ACL.AssetClassAlt_Key
                 ELSE ACL1.AssetClassAlt_Key
                    END PostMocAssetClassAlt_key  
         	  FROM DataUpload_RBL_MISDB_PROD.MocCustomerDataUpload A
                   LEFT JOIN AdvCustNPADetail B   ON A.CustomerEntityID = b.CustomerEntityID
                   AND ( b.EffectiveFromTimeKey <= v_MocTimeKey
                   AND b.EffectiveToTimeKey >= v_MocTimeKey )
                   LEFT JOIN DimAssetClass ACL   ON B.Cust_AssetClassAlt_Key = ACL.AssetClassAlt_Key
                   AND ( ACL.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ACL.EffectiveToTimeKey >= v_MocTimeKey )
                   LEFT JOIN DimAssetClass ACL1   ON A.MOCAssetClassification = ACL1.AssetClassShortName
                   AND ( ACL1.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ACL1.EffectiveToTimeKey >= v_MocTimeKey )
         	 WHERE  ( CASE 
                         WHEN MOCAssetClassification = ' ' THEN ACL.AssetClassShortName
                  ELSE MOCAssetClassification
                     END <> NVL(ACL.AssetClassShortName, 'STD') ) );
         UPDATE tt_CustNpa_3
            SET PostMoc_NPAdt = NULL
          WHERE  PostMocAssetClassification = 'STD';
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_Npadt_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_Npadt_3;
         UTILS.IDENTITY_RESET('tt_Npadt_3');

         INSERT INTO tt_Npadt_3 ( 
         	SELECT CustomerEntityId ,
                 MAX(PostMocAssetClassAlt_key)  PostMocAssetClassAlt_key  ,
                 UTILS.CONVERT_TO_VARCHAR2('',10) PostMoc_NPAdt  ,
                 UTILS.CONVERT_TO_VARCHAR2('',10) PostMoc_DBtdt  
         	  FROM tt_CustNpa_3 
         	  GROUP BY CustomerEntityId );
         MERGE INTO N 
         USING (SELECT N.ROWID row_id, CASE 
         WHEN NVL(C.PostMoc_NPAdt, ' ') <> ' ' THEN C.PostMoc_NPAdt
         ELSE NULL
            END AS pos_2, CASE 
         WHEN NVL(C.PostMoc_DBtdt, ' ') <> ' ' THEN C.PostMoc_DBtdt
         ELSE NULL
            END AS pos_3
         FROM N ,tt_Npadt_3 N
                JOIN tt_CustNpa_3 C   ON N.CustomerEntityId = C.CustomerEntityId
                AND N.PostMocAssetClassAlt_key = C.PostMocAssetClassAlt_key ) src
         ON ( N.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET C.PostMoc_NPAdt = pos_2,
                                      C.PostMoc_DBtdt = pos_3;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.PostMoc_NPAdt, B.PostMoc_DBtdt, B.PostMocAssetClassAlt_key
         FROM A ,tt_CustNpa_3 A
                JOIN tt_Npadt_3 B   ON A.CustomerEntityId = B.CustomerEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PostMoc_NPAdt = src.PostMoc_NPAdt,
                                      A.PostMoc_DBtdt = src.PostMoc_DBtdt,
                                      A.PostMocAssetClassAlt_key = src.PostMocAssetClassAlt_key;
         DBMS_OUTPUT.PUT_LINE('START MOC FOR ADVCUSTNPADETAIL');
         IF utils.object_id('Tempdb..tt_TmpCustNPA_3') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpCustNPA_3 ';
         END IF;
         DELETE FROM tt_TmpCustNPA_3;
         UTILS.IDENTITY_RESET('tt_TmpCustNPA_3');

         INSERT INTO tt_TmpCustNPA_3 ( 
         	SELECT NPA.* 
         	  FROM AdvCustNPADetail NPA
                   JOIN ( SELECT CustomerEntityId 
                          FROM tt_Npadt_3 
                           WHERE  CustomerEntityId IS NOT NULL

                          ----AND ISNULL(PreMocAssetClassification,'')<>ISNULL(PostMocAssetClassification,'')
                          GROUP BY CustomerEntityId ) T   ON ( NPA.CustomerEntityId = T.CustomerEntityId )
                   AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                   AND NPA.EffectiveToTimeKey >= v_MocTimeKey ) );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,20) || 'Row In Temp Table For ADVCUSTNPADETAIL');
         DBMS_OUTPUT.PUT_LINE('TEST');
         --return
         DBMS_OUTPUT.PUT_LINE('Expire Data');
         MERGE INTO NPA 
         USING (SELECT NPA.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
         FROM NPA ,AdvCustNPADetail NPA
                JOIN tt_TmpCustNPA_3 T   ON NPA.CustomerEntityId = T.CustomerEntityId
                AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                AND NPA.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE NPA.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( NPA.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPA.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE NPA
          WHERE ROWID IN 
         ( SELECT NPA.ROWID
           FROM AdvCustNPADetail NPA
                  JOIN tt_TmpCustNPA_3 T   ON NPA.CustomerEntityId = T.CustomerEntityId
                  AND ( NPA.EffectiveFromTimeKey <= v_MocTimeKey
                  AND NPA.EffectiveToTimeKey >= v_MocTimeKey ),
                NPA
          WHERE  NPA.EffectiveFromTimeKey = v_MocTimeKey
                   AND NPA.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,20) || 'Row In Expire From ADVCUSTNPADETAIL');
         DBMS_OUTPUT.PUT_LINE('INSERT INTO PREMOC.NPA DETAIL ');
         --select * from tt_TmpCustNPA_3
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )
           ( SELECT npa.CustomerEntityId ,
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
             FROM tt_TmpCustNPA_3 NPA
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVCUSTNPADETAIL T   ON ( T.EffectiveFromTimeKey <= v_MocTimeKey
                    AND T.EffectiveToTimeKey >= v_MocTimeKey )
                    AND T.CustomerEntityId = NPA.CustomerEntityId
              WHERE  T.CustomerEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || ' Row Inserted in Premoc.AdvCustNPADetail');
         DBMS_OUTPUT.PUT_LINE('TEST2');
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORD FOR SAME TIME KEY');
         MERGE INTO NPA 
         USING (SELECT NPA.ROWID row_id, v_MocTimeKey, v_MocTimeKey, DM.AssetClassAlt_Key, UTILS.CONVERT_TO_VARCHAR2(PostMoc_NPAdt,200,p_style=>103) AS pos_5, CASE 
         WHEN PostMocAssetClassAlt_key = 6 THEN NULL
         ELSE NVL(SD.PostMoc_DBtdt, DbtDt)
            END AS pos_6, CASE 
         WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt
         ELSE LosDt
            END AS pos_7, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210
         FROM NPA ,AdvCustNPADetail NPA
                JOIN tt_Npadt_3 SD   ON NPA.CustomerEntityId = SD.CustomerEntityId
                JOIN DimAssetClass DM   ON ( DM.EffectiveFromTimeKey <= v_MocTimeKey
                AND DM.EffectiveToTimeKey >= v_MocTimeKey )
                AND SD.PostMocAssetClassAlt_key = DM.AssetClassAlt_Key
                AND DM.AssetClassShortName <> 'STD' 
          WHERE NPA.EffectiveFromTimeKey = v_MocTimeKey
           AND NPA.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( NPA.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPA.EffectiveToTimeKey = v_MocTimeKey,
                                      NPA.EffectiveFromTimeKey = v_MocTimeKey,
                                      SD.Cust_AssetClassAlt_Key = src.AssetClassAlt_Key,
                                      SD.NPADt
                                      --,DbtDt=   ISNULL(SD.PostMoc_DBtdt,DbtDt)
                                       = pos_5,
                                      SD.DbtDt = pos_6,
                                      SD.LosDt
                                      --,CreatedBy=@CrModApBy
                                       --,DateCreated=GETDATE()
                                       = pos_7,
                                      SD.ModifiedBy = v_CrModApBy,
                                      SD.DateModified = SYSDATE,
                                      SD.MocStatus = 'Y',
                                      SD.MocDate = SYSDATE,
                                      SD.MocTypeAlt_Key = 210;
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || ' Row UPdate  IN AdvCustNPADetail');
         DBMS_OUTPUT.PUT_LINE('INSERT IN NPA FOR CURRENT TIME KEY');
         DBMS_OUTPUT.PUT_LINE('11');
         INSERT INTO AdvCustNPADetail
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
         --,D2Ktimestamp          
         , MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )
           ( 
             --declare @MocTimeKey int =4383						
             SELECT NPA.CustomerEntityId ,
                    DM.AssetClassAlt_Key ,
                    NVL(UTILS.CONVERT_TO_VARCHAR2(PostMoc_NPAdt,200,p_style=>103), NPA.NPADt) ,
                    NPA.LastInttChargedDt ,
                    --,ISNULL(SD.PostMoc_DBtdt,DbtDt)
                    --,npa.LosDt
                    CASE 
                         WHEN PostMocAssetClassAlt_key = 6 THEN NULL
                    ELSE NVL(SD.PostMoc_DBtdt, DbtDt)
                       END col  ,
                    CASE 
                         WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt
                    ELSE LosDt
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
             FROM tt_TmpCustNPA_3 NPA
                    JOIN tt_Npadt_3 SD   ON NPA.CustomerEntityId = SD.CustomerEntityId
                    JOIN DimAssetClass DM   ON ( DM.EffectiveFromTimeKey <= v_MocTimeKey
                    AND DM.EffectiveToTimeKey >= v_MocTimeKey )
                    AND SD.PostMocAssetClassAlt_key = DM.AssetClassAlt_Key
                    AND DM.AssetClassShortName <> 'STD'
              WHERE  NOT ( NPA.EffectiveFromTimeKey = v_MocTimeKey
                       AND NPA.EffectiveToTimeKey = v_MocTimeKey ) );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || 'INSERT IN NPA FOR CURRENT TIME KEY');
         DBMS_OUTPUT.PUT_LINE('12');
         DBMS_OUTPUT.PUT_LINE('INSERT IN NPA FOR LIVE');
         INSERT INTO AdvCustNPADetail
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
         --,D2Ktimestamp         
         , MocStatus, MocDate, MocTypeAlt_Key
         ----,WillfulDefault
          ----,WillfulDefaultReasonAlt_Key
          ----,WillfulRemark
          ----,WillfulDefaultDate
         , NPA_Reason )
           ( SELECT NPA.CustomerEntityId ,
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
             FROM tt_TmpCustNPA_3 NPA
              WHERE  NPA.EffectiveToTimeKey > v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,5) || 'INSERT IN NPA FOR LIVE');
         DBMS_OUTPUT.PUT_LINE('UPDATE SOURCE TABLE FOR NPA DETAIL');
         INSERT INTO AdvCustNPADetail
           ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key
         --,WillfulDefault
          --,WillfulDefaultReasonAlt_Key
          --,WillfulRemark
          --,WillfulDefaultDate
         , NPA_Reason )
           ( SELECT B.CustomerEntityId ,
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
                    B.CustomerID ,
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
             FROM tt_Npadt_3 A
                    JOIN CustomerBasicDetail B   ON A.CustomerEntityId = B.CustomerEntityId
                    AND B.EffectiveFromTimeKey <= v_MocTimeKey
                    AND B.EffectiveToTimeKey >= v_MocTimeKey
                    JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.PostMocAssetClassAlt_key, ' ')
                    AND C.EffectiveFromTimeKey <= v_MocTimeKey
                    AND C.EffectiveToTimeKey >= v_MocTimeKey
                    LEFT JOIN AdvCustNPADetail D   ON D.CustomerEntitYID = b.CustomerEntitYID
                    AND ( D.EffectiveFromTimeKey <= v_MocTimeKey
                    AND D.EFFECTIVETOTIMEKEY >= v_MocTimeKey )
              WHERE  NVL(A.PostMocAssetClassAlt_key, ' ') > 1 --AND ISNULL(POSTMOCASSETCLASSIFICATION,'')<>'STD'

                       AND D.CustomerEntitYID IS NULL );
         /*	END MOC FOR ADVCUSTFINANCIALDETAIL*/
         /*	START MOC FOR BALANCE DETAIL*/
         IF utils.object_id('Tempdb..tt_TmpAcBalance_3') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpAcBalance_3 ';
         END IF;
         DELETE FROM tt_TmpAcBalance_3;
         UTILS.IDENTITY_RESET('tt_TmpAcBalance_3');

         INSERT INTO tt_TmpAcBalance_3 ( 
         	SELECT AABD.* 
         	  FROM RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                   JOIN AdvAcBasicDetail ABD   ON ABD.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ABD.EffectiveToTimeKey >= v_MocTimeKey
                   AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                   AND AABD.EffectiveToTimeKey >= v_MocTimeKey )
                   AND AABD.AccountEntityId = ABD.AccountEntityId
                   JOIN tt_CUST_AC_MOC_3 T   ON ( ABD.AccountEntityId = T.AccountEntityId ) );
         DBMS_OUTPUT.PUT_LINE('Expire data');
         MERGE INTO AABD 
         USING (SELECT AABD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM AABD ,RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                JOIN tt_TmpAcBalance_3 T   ON AABD.AccountEntityId = T.AccountEntityId
                AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                AND AABD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE AABD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( AABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET AABD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE AABD
          WHERE ROWID IN 
         ( SELECT AABD.ROWID
           FROM RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                  JOIN tt_TmpAcBalance_3 T   ON AABD.AccountEntityId = T.AccountEntityId
                  AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND AABD.EffectiveToTimeKey >= v_MocTimeKey ),
                AABD
          WHERE  AABD.EffectiveFromTimeKey = v_MocTimeKey
                   AND AABD.EffectiveToTimeKey >= v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('Insert data in Premoc.Balance ');
         INSERT INTO PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail
           ( AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv
         ----,DirectBalance
          ----,InDirectBalance
          ----,LastCrAmt
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy
         ----,PS_NPS_FLAG
         , OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance )
           ( SELECT T.AccountEntityId ,
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
                    T.PrincipalBalance 
             FROM tt_TmpAcBalance_3 T
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.AdvAcBalanceDetail PRE   ON ( PRE.EffectiveFromTimeKey <= v_MocTimeKey
                    AND PRE.EffectiveToTimeKey >= v_MocTimeKey )
                    AND PRE.AccountEntityId = T.AccountEntityId --AND PRE.AccountEntityId IS NULL

              WHERE  PRE.AccountEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO AABD 
         USING (SELECT AABD.ROWID row_id, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, DM.AssetClassAlt_Key
         --,AABD.BalanceInCurrency=((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) 
          --,AABD.Balance=((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0) +ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))
         , T.balance, T.balance
         --,AABD.PS_Balance=CASE WHEN  PS_NPS_FLAG ='PS' THEN ((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) ELSE AABD.PS_Balance END
          --,AABD.NPS_Balance= CASE WHEN  PS_NPS_FLAG ='NPS' THEN((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) ELSE AABD.NPS_Balance END
          ----,AABD.PS_Balance=CASE WHEN  PS_NPS_FLAG ='PS' THEN ((ISNULL(T.Balance,0))) ELSE AABD.PS_Balance END
          ----,AABD.NPS_Balance= CASE WHEN  PS_NPS_FLAG ='NPS' THEN((ISNULL(T.Balance,0))) ELSE AABD.NPS_Balance END
         , CASE 
         WHEN PS_Balance > 0 THEN ((NVL(T.Balance, 0)))
         ELSE AABD.PS_Balance
            END AS pos_10, CASE 
         WHEN NPS_Balance > 0 THEN ((NVL(T.Balance, 0)))
         ELSE AABD.NPS_Balance
            END AS pos_11
         FROM AABD ,RBL_MISDB_PROD.AdvAcBalanceDetail AABD
                JOIN tt_CUST_AC_MOC_3 T   ON AABD.AccountEntityId = T.AccountEntityId
                AND ( AABD.EffectiveFromTimeKey <= v_MocTimeKey
                AND AABD.EffectiveToTimeKey >= v_MocTimeKey )
                LEFT JOIN DimAssetClass DM   ON ( DM.EffectiveFromTimeKey <= v_MocTimeKey
                AND DM.EffectiveToTimeKey >= v_MocTimeKey )
                AND T.MOCAssetClassification = DM.AssetClassShortNameEnum 
          WHERE AABD.EffectiveFromTimeKey = v_MocTimeKey
           AND AABD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( AABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET
         ---- AABD.EffectiveFromTimeKey=@MocTimeKey
          ----,AABD.EffectiveToTimeKey =@MocTimeKey
          AABD.ModifiedBy = v_CrModApBy,
          AABD.DateModified = SYSDATE,
          AABD.MocStatus = 'Y',
          AABD.MocDate = SYSDATE,
          AABD.MocTypeAlt_Key = 210,
          AABD.AssetClassAlt_Key = src.AssetClassAlt_Key,
          AABD.BalanceInCurrency = src.balance,
          AABD.Balance = src.balance,
          AABD.PS_Balance = pos_10,
          AABD.NPS_Balance
          ----select 1
           = pos_11;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         INSERT INTO AdvAcBalanceDetail
           ( AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv
         ----,DirectBalance
          ----,InDirectBalance
          ----,LastCrAmt
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy
         ----,PS_NPS_FLAG
         , OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance )
           ( SELECT A.AccountEntityId ,
                    C.AssetClassAlt_Key ,
                    --,CASE WHEN SD.AccountEntityId IS NULL THEN A.BalanceInCurrency ELSE ((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))  END
                    --,CASE WHEN SD.AccountEntityId IS NULL THEN A.Balance ELSE ((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))  END
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
                    A.TotalProv ,
                    ----,A.DirectBalance
                    ----,A.InDirectBalance
                    ----,A.LastCrAmt
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
                    --,((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)-ISNULL(InterestReversalChg,0))) 
                    --,((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)-ISNULL(InterestReversalChg,0)))
                    ----,CASE WHEN  A.PS_NPS_FLAG ='PS' THEN  ((ISNULL(SD.Balance,0)))	ELSE A.PS_Balance END PS_Balance
                    ----,CASE WHEN  A.PS_NPS_FLAG ='NPS' THEN   ((ISNULL(SD.Balance,0)))   ELSE  A.NPS_Balance END NPS_Balance
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
                    ----,A.PS_NPS_FLAG
                    A.OverduePrincipal ,
                    A.Overdueinterest ,
                    A.AdvanceRecovery ,
                    A.NotionalInttAmt ,
                    A.PrincipalBalance 
             FROM tt_TmpAcBalance_3 A
                    LEFT JOIN tt_CUST_AC_MOC_3 SD   ON A.AccountEntityId = SD.AccountEntityId
                  --AND ISNULL((ISNULL(SD.PreMocBalance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)),0)<>0
                   --AND  (CASE WHEN ISNULL(SD.PreMocBalance,0)>0  AND (ISNULL((ISNULL(SD.PreMocBalance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)),0)<>0)
                   --						THEN 1
                   --				 WHEN ISNULL(SD.PreMocBalance,0)=0 THEN 1		
                   --			END)=1
                   --AND SD

                    LEFT JOIN DimAssetClass c   ON c.AssetClassShortNameEnum = sd.MOCAssetClassification
                    AND c.EffectiveFromTimeKey <= v_MocTimeKey
                    AND c.EffectiveToTimeKey >= v_MocTimeKey
                    LEFT JOIN AdvAcBalanceDetail O   ON A.AccountEntityId = O.AccountEntityId
                    AND ( o.EffectiveFromTimeKey = v_MocTimeKey
                    AND o.EffectiveToTimeKey = v_MocTimeKey )
              WHERE  ( A.EffectiveFromTimeKey <= v_MocTimeKey
                       AND A.EffectiveToTimeKey >= v_MocTimeKey )

                       --AND NOT (o.EffectiveFromTimeKey=@MocTimeKey AND o.EffectiveToTimeKey=@MocTimeKey)
                       AND O.AccountEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         INSERT INTO AdvAcBalanceDetail
           ( AccountEntityId, AssetClassAlt_Key, BalanceInCurrency, Balance, SignBalance, LastCrDt, OverDue, TotalProv
         ----,DirectBalance
          ----,InDirectBalance
          ----,LastCrAmt
         , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, OverDueSinceDt, MocStatus, MocDate, MocTypeAlt_Key, Old_OverDueSinceDt, Old_OverDue, ORG_TotalProv, IntReverseAmt, PS_Balance, NPS_Balance, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CreatedBy
         ----,PS_NPS_FLAG
         , OverduePrincipal, Overdueinterest, AdvanceRecovery, NotionalInttAmt, PrincipalBalance )
           ( SELECT T.AccountEntityId ,
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
                    ----,T.PS_NPS_FLAG
                    T.OverduePrincipal ,
                    T.Overdueinterest ,
                    T.AdvanceRecovery ,
                    T.NotionalInttAmt ,
                    T.PrincipalBalance 
             FROM tt_TmpAcBalance_3 T
              WHERE  T.EffectiveToTimeKey > v_MocTimeKey );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM A ,RBL_MISDB_PROD.AdvAcBalanceDetail A
                JOIN DataUpload_RBL_MISDB_PROD.MocAccountDataUpload C   ON C.AccountEntityId = A.AccountEntityId 
          WHERE NVL(C.AmountofWriteOff, 0) > 0
           AND ( ( A.EffectiveFromTimeKey <= v_MocTimeKey
           AND A.EffectiveToTimeKey >= v_MocTimeKey )
           OR a.EffectiveFromTimeKey >= v_MocTimeKey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
         /*************************************************************************************************
         				 FOR UPDATING A ASSET CLASS IN AdvAcBalance Detail
         		*************************************************************************************************/
         --DROP TABLE IF EXISTS #AssetClassBalance
         --SELECT ABD.CustomerEntityId
         --	, MAX(BAL.AssetClassAlt_Key)AssetClassAlt_Key
         --	INTO #AssetClassBalance
         --FROM AdvAcBalanceDetail BAL
         --INNER JOIN AdvAcBasicDetail ABD
         --	ON  ABD.EffectiveFromTimeKey <= @Timekey AND ABD.EffectiveToTimeKey >= @Timekey
         --	AND ABD.AccountEntityId = BAL.AccountEntityId
         --INNER JOIN tt_TmpCustNPA_3 S
         --	ON  BAL.EffectiveFromTimeKey <= @Timekey AND BAL.EffectiveToTimeKey >= @Timekey
         --	AND S.CustomerEntityId = ABD.CustomerEntityId
         --GROUP BY ABD.CustomerEntityId
         MERGE INTO BAL 
         USING (SELECT BAL.ROWID row_id, A.Cust_AssetClassAlt_Key
         FROM BAL ,RBL_MISDB_PROD.AdvAcBalanceDetail BAL
                JOIN AdvAcBasicDetail ABD   ON ABD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ABD.EffectiveToTimeKey >= v_MocTimeKey
                AND BAL.EffectiveFromTimeKey = v_MocTimeKey
                AND BAL.EffectiveToTimeKey = v_MocTimeKey
                AND ABD.AccountEntityId = BAL.AccountEntityId
                JOIN AdvCustNPADetail A   ON A.CustomerEntityId = ABD.CustomerEntityId
                AND ( A.EffectiveFromTimeKey = v_MocTimeKey
                AND A.EffectiveToTimeKey = v_MocTimeKey ) ) src
         ON ( BAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET AssetClassAlt_Key = src.Cust_AssetClassAlt_Key;
         MERGE INTO BAL 
         USING (SELECT BAL.ROWID row_id, A.TotalProvision
         FROM BAL ,RBL_MISDB_PROD.AdvAcBalanceDetail BAL
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL A   ON A.AccountEntityID = bal.AccountEntityId
                AND ( A.EffectiveFromTimeKey = v_MocTimeKey
                AND A.EffectiveToTimeKey = v_MocTimeKey )
                AND ( BAL.EffectiveFromTimeKey = v_MocTimeKey
                AND BAL.EffectiveToTimeKey = v_MocTimeKey ) ) src
         ON ( BAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TotalProv = src.TotalProvision;
         MERGE INTO BAL 
         USING (SELECT BAL.ROWID row_id, A.FinalAssetClassAlt_Key
         FROM BAL ,RBL_MISDB_PROD.AdvAcBalanceDetail BAL
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL A   ON A.AccountEntityID = bal.AccountEntityId
                AND ( A.EffectiveFromTimeKey = v_MocTimeKey
                AND A.EffectiveToTimeKey = v_MocTimeKey )
                AND ( BAL.EffectiveFromTimeKey = v_MocTimeKey
                AND BAL.EffectiveToTimeKey = v_MocTimeKey ) ) src
         ON ( BAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET AssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         /********************************************/
         /*	ADVACBASIC DETAIL*/
         --	IF OBJECT_ID('Tempdb..#AccountBasic') IS NOT NULL
         --				DROP TABLE #AccountBasic	
         --			SELECT abd.* ,T.SchemeAlt_Key SchemeAlt_Key_Moc
         --				INTO #AccountBasic
         --			FROM AdvAcBasicDetail abd
         --				INNER JOIN (SELECT CustomerAcId,SchemeAlt_Key FROM dataupload.MocAccountDataUpload
         --									WHERE  CustomerId IS NOT NULL	
         --									AND ISNULL(SchemeAlt_Key,0)<>0																	
         --								GROUP BY CustomerAcId,SchemeAlt_Key
         --							) T
         --					ON (abd.CustomerACID=T.CustomerACID)
         --					AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
         --					--AND isnull(abd.SchemeAlt_Key,0)<>isnull(T.SchemeAlt_Key,0)
         --					--and isnull(T.SchemeAlt_Key,0)<>0
         --print 'TEST'
         --return
         --------	PRINT 'Expire Data'
         --------			UPDATE abd SET
         --------					abd.EffectiveToTimeKey =@MocTimeKey -1 
         --------				FROM AdvAcBasicDetail abd
         --------					 INNER JOIN tt_CUST_AC_MOC_3 T
         --------						ON abd.AccountEntityId=T.AccountEntityId
         --------						AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
         --------					WHERE abd.EffectiveFromTimeKey<@MocTimeKey
         --------			DELETE abd 
         --------				FROM AdvAcBasicDetail abd
         --------								  INNER JOIN tt_CUST_AC_MOC_3 T
         --------						ON abd.AccountEntityId=T.AccountEntityId
         --------						AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
         --------					WHERE abd.EffectiveFromTimeKey=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey
         --------			INSERT INTO PreMoc.AdvAcBasicDetail
         --------						(
         --------							BranchCode
         --------							,AccountEntityId
         --------							,CustomerEntityId
         --------							,SystemACID
         --------							,CustomerACID
         --------							,GLAlt_Key
         --------							,ProductAlt_Key
         --------							,GLProductAlt_Key
         --------							,FacilityType
         --------							,SectorAlt_Key
         --------							,SubSectorAlt_Key
         --------							,ActivityAlt_Key
         --------							,IndustryAlt_Key
         --------							,SchemeAlt_Key
         --------							,DistrictAlt_Key
         --------							,AreaAlt_Key
         --------							,VillageAlt_Key
         --------							,StateAlt_Key
         --------							,CurrencyAlt_Key
         --------							,OriginalSanctionAuthAlt_Key
         --------							,OriginalLimitRefNo
         --------							,OriginalLimit
         --------							,OriginalLimitDt
         --------							,DtofFirstDisb
         --------							----,EmpCode
         --------							,FlagReliefWavier
         --------							,UnderLineActivityAlt_Key
         --------							,MicroCredit
         --------							,segmentcode
         --------							,ScrCrError
         --------							,AdjDt
         --------							,AdjReasonAlt_Key
         --------							,MarginType
         --------							,Pref_InttRate
         --------							,CurrentLimitRefNo
         --------							----,ProcessingFeeApplicable
         --------							----,ProcessingFeeAmt
         --------							----,ProcessingFeeRecoveryAmt
         --------							,GuaranteeCoverAlt_Key
         --------							,AccountName
         --------							----,ReferencePeriod
         --------							,AssetClass
         --------							----,D2K_REF_NO
         --------							----,InttAppFreq
         --------							,JointAccount
         --------							,LastDisbDt
         --------							,ScrCrErrorBackup
         --------							,AccountOpenDate
         --------							,Ac_LADDt
         --------							,Ac_DocumentDt
         --------							,CurrentLimit
         --------							,InttTypeAlt_Key
         --------							,InttRateLoadFactor
         --------							,Margin
         --------							----,TwentyPointReference
         --------							----,BSR1bCode
         --------							,CurrentLimitDt
         --------							,Ac_DueDt
         --------							,DrawingPowerAlt_Key
         --------							,RefCustomerId
         --------							----,D2KACID
         --------							,AuthorisationStatus
         --------							,EffectiveFromTimeKey
         --------							,EffectiveToTimeKey
         --------							,CreatedBy
         --------							,DateCreated
         --------							,ModifiedBy
         --------							,DateModified
         --------							,ApprovedBy
         --------							,DateApproved							
         --------							,MocStatus
         --------							,MocDate
         --------							,MocTypeAlt_Key
         --------							--,AcCategegoryAlt_Key
         --------							,OriginalSanctionAuthLevelAlt_Key
         --------							,AcTypeAlt_Key
         --------							,AcCategoryAlt_Key
         --------							,ScrCrErrorSeq
         --------							,SourceAlt_Key
         --------							,LoanSeries
         --------							,LoanRefNo
         --------							,SecuritizationCode
         --------							,Full_Disb
         --------							,OriginalBranchcode
         --------						)
         --------				SELECT 
         --------							abd.BranchCode
         --------							,abd.AccountEntityId
         --------							,abd.CustomerEntityId
         --------							,abd.SystemACID
         --------							,abd.CustomerACID
         --------							,abd.GLAlt_Key
         --------							,abd.ProductAlt_Key
         --------							,abd.GLProductAlt_Key
         --------							,abd.FacilityType
         --------							,abd.SectorAlt_Key
         --------							,abd.SubSectorAlt_Key
         --------							,abd.ActivityAlt_Key
         --------							,abd.IndustryAlt_Key
         --------							,abd.SchemeAlt_Key
         --------							,abd.DistrictAlt_Key
         --------							,abd.AreaAlt_Key
         --------							,abd.VillageAlt_Key
         --------							,abd.StateAlt_Key
         --------							,abd.CurrencyAlt_Key
         --------							,abd.OriginalSanctionAuthAlt_Key
         --------							,abd.OriginalLimitRefNo
         --------							,abd.OriginalLimit
         --------							,abd.OriginalLimitDt
         --------							,abd.DtofFirstDisb
         --------							----,abd.EmpCode
         --------							,abd.FlagReliefWavier
         --------							,abd.UnderLineActivityAlt_Key
         --------							,abd.MicroCredit
         --------							,abd.segmentcode
         --------							,abd.ScrCrError
         --------							,abd.AdjDt
         --------							,abd.AdjReasonAlt_Key
         --------							,abd.MarginType
         --------							,abd.Pref_InttRate
         --------							,abd.CurrentLimitRefNo
         --------							----,abd.ProcessingFeeApplicable
         --------							----,abd.ProcessingFeeAmt
         --------							----,abd.ProcessingFeeRecoveryAmt
         --------							,abd.GuaranteeCoverAlt_Key
         --------							,abd.AccountName
         --------							----,abd.ReferencePeriod
         --------							,abd.AssetClass
         --------							----,abd.D2K_REF_NO
         --------							----,abd.InttAppFreq
         --------							,abd.JointAccount
         --------							,abd.LastDisbDt
         --------							,abd.ScrCrErrorBackup
         --------							,abd.AccountOpenDate
         --------							,abd.Ac_LADDt
         --------							,abd.Ac_DocumentDt
         --------							,abd.CurrentLimit
         --------							,abd.InttTypeAlt_Key
         --------							,abd.InttRateLoadFactor
         --------							,abd.Margin
         --------							----,abd.TwentyPointReference
         --------							----,abd.BSR1bCode
         --------							,abd.CurrentLimitDt
         --------							,abd.Ac_DueDt
         --------							,abd.DrawingPowerAlt_Key
         --------							,abd.RefCustomerId
         --------							----,abd.D2KACID
         --------							,abd.AuthorisationStatus
         --------							,@MocTimeKey EffectiveFromTimeKey
         --------							,@MocTimeKey EffectiveToTimeKey
         --------							,abd.CreatedBy
         --------							,abd.DateCreated
         --------							,abd.ModifiedBy
         --------							,abd.DateModified
         --------							,abd.ApprovedBy
         --------							,abd.DateApproved							
         --------							,'Y' MocStatus            
         --------							,GETDATE() MocDate   
         --------							,abd.MocTypeAlt_Key
         --------							--,abd.AcCategoryAlt_Key
         --------							,abd.OriginalSanctionAuthLevelAlt_Key
         --------							,abd.AcTypeAlt_Key
         --------							,abd.AcCategoryAlt_Key
         --------							,abd.ScrCrErrorSeq
         --------							,abd.SourceAlt_Key
         --------							,abd.LoanSeries
         --------							,abd.LoanRefNo
         --------							,ABD.SecuritizationCode
         --------							,ABD.Full_Disb
         --------							,ABD.OriginalBranchcode
         --------					FROM AdvAcBasicDetail abd
         --------						INNER JOIN tt_CUST_AC_MOC_3 b
         --------							on abd.AccountEntityId=b.AccountEntityid
         --------							and abd.EffectiveFromTimeKey<=@MocTimeKey and abd.EffectiveToTimeKey>=@MocTimeKey
         --------							and isnull(b.AmountofWriteOff,0)>0
         --------						LEFT JOIN PreMoc.AdvAcBasicDetail T				
         --------							ON(T.EffectiveFromTimeKey<=@MocTimeKey AND T.EffectiveToTimeKey>=@MocTimeKey)
         --------							AND T.CustomerACID=abd.CustomerACID
         --------					WHERE T.CustomerEntityId IS NULL
         --------print 'TEST2111'
         --------			PRINT 'UPDATE RECORD FOR SAME TIME KEY'
         --------				 UPDATE abd SET
         --------		       			abd.EffectiveToTimeKey =@MocTimeKey
         --------						,abd.EffectiveFromTimeKey =@MocTimeKey												
         --------						,MocStatus= 'Y'               
         --------						,MocDate= GetDate()                
         --------						,MocTypeAlt_Key= 210   
         --------						,abd.SchemeAlt_Key=abd.SchemeAlt_Key--a.SchemeAlt_Key_Moc 
         --------						,ModifiedBy=@CrModApBy
         --------						,DateModified=getdate()
         --------				FROM AdvAcBasicDetail abd
         --------						INNER JOIN  tt_CUST_AC_MOC_3 A
         --------							ON (ABD.EffectiveFromTimeKey<=@MocTimeKey AND ABD.EffectiveToTimeKey>=@MocTimeKey)
         --------							AND ABD.AccountEntityId = A.AccountEntityId																				   
         --------						WHERE ABD.EffectiveFromTimeKey=@MocTimeKey AND ABD.EffectiveToTimeKey=@MocTimeKey
         --------			PRINT 'INSERT IN ACCOUNT FOR CURRENT TIME KEY'
         --------			INSERT INTO AdvAcBasicDetail 
         --------						(
         --------							BranchCode
         --------							,AccountEntityId
         --------							,CustomerEntityId
         --------							,SystemACID
         --------							,CustomerACID
         --------							,GLAlt_Key
         --------							,ProductAlt_Key
         --------							,GLProductAlt_Key
         --------							,FacilityType
         --------							,SectorAlt_Key
         --------							,SubSectorAlt_Key
         --------							,ActivityAlt_Key
         --------							,IndustryAlt_Key
         --------							,SchemeAlt_Key
         --------							,DistrictAlt_Key
         --------							,AreaAlt_Key
         --------							,VillageAlt_Key
         --------							,StateAlt_Key
         --------							,CurrencyAlt_Key
         --------							,OriginalSanctionAuthAlt_Key
         --------							,OriginalLimitRefNo
         --------							,OriginalLimit
         --------							,OriginalLimitDt
         --------							,Pref_InttRate
         --------							,CurrentLimitRefNo
         --------							----,ProcessingFeeApplicable
         --------							----,ProcessingFeeAmt
         --------							----,ProcessingFeeRecoveryAmt
         --------							,GuaranteeCoverAlt_Key
         --------							,AccountName
         --------							----,ReferencePeriod
         --------							,AssetClass
         --------							----,D2K_REF_NO
         --------							----,InttAppFreq
         --------							,JointAccount
         --------							,LastDisbDt
         --------							,ScrCrErrorBackup
         --------							,AccountOpenDate
         --------							,Ac_LADDt
         --------							,Ac_DocumentDt
         --------							,CurrentLimit
         --------							,InttTypeAlt_Key
         --------							,InttRateLoadFactor
         --------							,Margin
         --------							----,TwentyPointReference
         --------							----,BSR1bCode
         --------							,CurrentLimitDt
         --------							,Ac_DueDt
         --------							,DrawingPowerAlt_Key
         --------							,RefCustomerId
         --------							----,D2KACID
         --------							,AuthorisationStatus
         --------							,EffectiveFromTimeKey
         --------							,EffectiveToTimeKey
         --------							,CreatedBy
         --------							,DateCreated
         --------							,ModifiedBy
         --------							,DateModified
         --------							,ApprovedBy
         --------							,DateApproved							
         --------							,MocStatus
         --------							,MocDate
         --------							,MocTypeAlt_Key
         --------							,IsLAD
         --------							,FacilitiesNo
         --------							,FincaleBasedIndustryAlt_key
         --------							,AcCategoryAlt_Key
         --------							,OriginalSanctionAuthLevelAlt_Key
         --------							,AcTypeAlt_Key
         --------							,ScrCrErrorSeq
         --------							,D2k_OLDAscromID
         --------							,BSRUNID
         --------							,AdditionalProv
         --------							,ProjectCost
         --------							,DtofFirstDisb
         --------							----,EmpCode
         --------							,FlagReliefWavier
         --------							,UnderLineActivityAlt_Key
         --------							,MicroCredit
         --------							,segmentcode
         --------							,ScrCrError
         --------							,AdjDt
         --------							,AdjReasonAlt_Key
         --------							,MarginType
         --------							,AclattestDevelopment
         --------							,SourceAlt_Key
         --------							,LoanSeries
         --------							,LoanRefNo
         --------							,SecuritizationCode
         --------							,Full_Disb
         --------							,OriginalBranchcode
         --------						)
         --------					--declare @MocTimeKey int =4383						
         --------					SELECT 
         --------							BranchCode
         --------							,AccountEntityId
         --------							,CustomerEntityId
         --------							,SystemACID
         --------							,abd.CustomerACID
         --------							,GLAlt_Key
         --------							,ProductAlt_Key
         --------							,GLProductAlt_Key
         --------							,FacilityType
         --------							,SectorAlt_Key
         --------							,SubSectorAlt_Key
         --------							,ActivityAlt_Key
         --------							,IndustryAlt_Key
         --------							,ABD.SchemeAlt_Key_Moc
         --------							,DistrictAlt_Key
         --------							,AreaAlt_Key
         --------							,VillageAlt_Key
         --------							,StateAlt_Key
         --------							,CurrencyAlt_Key
         --------							,OriginalSanctionAuthAlt_Key
         --------							,OriginalLimitRefNo
         --------							,OriginalLimit
         --------							,OriginalLimitDt
         --------							,Pref_InttRate
         --------							,CurrentLimitRefNo
         --------							----,ProcessingFeeApplicable
         --------							----,ProcessingFeeAmt
         --------							----,ProcessingFeeRecoveryAmt
         --------							,GuaranteeCoverAlt_Key
         --------							,AccountName
         --------							----,ReferencePeriod
         --------							,AssetClass
         --------							----,D2K_REF_NO
         --------							----,InttAppFreq
         --------							,JointAccount
         --------							,LastDisbDt
         --------							,ScrCrErrorBackup
         --------							,AccountOpenDate
         --------							,Ac_LADDt
         --------							,Ac_DocumentDt
         --------							,CurrentLimit
         --------							,InttTypeAlt_Key
         --------							,InttRateLoadFactor
         --------							,Margin
         --------							----,TwentyPointReference
         --------							----,BSR1bCode
         --------							,CurrentLimitDt
         --------							,Ac_DueDt
         --------							,DrawingPowerAlt_Key
         --------							,RefCustomerId
         --------							----,D2KACID
         --------							,AuthorisationStatus
         --------							,@MocTimeKey EffectiveFromTimeKey
         --------							,@MocTimeKey EffectiveToTimeKey
         --------							,@CrModApBy CreatedBy
         --------							,GETDATE() DateCreated
         --------							,ModifiedBy
         --------							,DateModified
         --------							,ApprovedBy
         --------							,DateApproved							
         --------							,'Y' MocStatus
         --------							,GETDATE() MocDate
         --------							,210 MocTypeAlt_Key
         --------							,IsLAD
         --------							,FacilitiesNo
         --------							,FincaleBasedIndustryAlt_key
         --------							,AcCategoryAlt_Key
         --------							,OriginalSanctionAuthLevelAlt_Key
         --------							,AcTypeAlt_Key
         --------							,ScrCrErrorSeq
         --------							,D2k_OLDAscromID
         --------							,BSRUNID
         --------							,AdditionalProv
         --------							,ProjectCost
         --------							,DtofFirstDisb
         --------							----,EmpCode
         --------							,FlagReliefWavier
         --------							,UnderLineActivityAlt_Key
         --------							,MicroCredit
         --------							,segmentcode
         --------							,ScrCrError
         --------							,AdjDt
         --------							,AdjReasonAlt_Key
         --------							,MarginType
         --------							,AclattestDevelopment
         --------							,SourceAlt_Key
         --------							,LoanSeries
         --------							,LoanRefNo
         --------							,SecuritizationCode
         --------							,Full_Disb
         --------							,OriginalBranchcode
         --------					FROM tt_CUST_AC_MOC_3 abd
         --------						where (ABD.EffectiveFromTimeKey<=@MocTimeKey AND ABD.EffectiveToTimeKey>=@MocTimeKey)
         --------						and NOT(EffectiveFromTimeKey=@MocTimeKey AND EffectiveToTimeKey=@MocTimeKey)
         --------		PRINT 'INSERT IN ACCOUNT FOR LIVE'
         --------				INSERT INTO AdvAcBasicDetail 
         --------						(
         --------							BranchCode
         --------							,AccountEntityId
         --------							,CustomerEntityId
         --------							,SystemACID
         --------							,CustomerACID
         --------							,GLAlt_Key
         --------							,ProductAlt_Key
         --------							,GLProductAlt_Key
         --------							,FacilityType
         --------							,SectorAlt_Key
         --------							,SubSectorAlt_Key
         --------							,ActivityAlt_Key
         --------							,IndustryAlt_Key
         --------							,SchemeAlt_Key
         --------							,DistrictAlt_Key
         --------							,AreaAlt_Key
         --------							,VillageAlt_Key
         --------							,StateAlt_Key
         --------							,CurrencyAlt_Key
         --------							,OriginalSanctionAuthAlt_Key
         --------							,OriginalLimitRefNo
         --------							,OriginalLimit
         --------							,OriginalLimitDt
         --------							,Pref_InttRate
         --------							,CurrentLimitRefNo
         --------							----,ProcessingFeeApplicable
         --------							----,ProcessingFeeAmt
         --------							----,ProcessingFeeRecoveryAmt
         --------							,GuaranteeCoverAlt_Key
         --------							,AccountName
         --------							----,ReferencePeriod
         --------							,AssetClass
         --------							----,D2K_REF_NO
         --------							----,InttAppFreq
         --------							,JointAccount
         --------							,LastDisbDt
         --------							,ScrCrErrorBackup
         --------							,AccountOpenDate
         --------							,Ac_LADDt
         --------							,Ac_DocumentDt
         --------							,CurrentLimit
         --------							,InttTypeAlt_Key
         --------							,InttRateLoadFactor
         --------							,Margin
         --------							----,TwentyPointReference
         --------							----,BSR1bCode
         --------							,CurrentLimitDt
         --------							,Ac_DueDt
         --------							,DrawingPowerAlt_Key
         --------							,RefCustomerId
         --------							----,D2KACID
         --------							,AuthorisationStatus
         --------							,EffectiveFromTimeKey
         --------							,EffectiveToTimeKey
         --------							,CreatedBy
         --------							,DateCreated
         --------							,ModifiedBy
         --------							,DateModified
         --------							,ApprovedBy
         --------							,DateApproved							
         --------							,MocStatus
         --------							,MocDate
         --------							,MocTypeAlt_Key
         --------							,IsLAD
         --------							,FacilitiesNo
         --------							,FincaleBasedIndustryAlt_key
         --------							,AcCategoryAlt_Key
         --------							,OriginalSanctionAuthLevelAlt_Key
         --------							,AcTypeAlt_Key
         --------							,ScrCrErrorSeq
         --------							,D2k_OLDAscromID
         --------							,BSRUNID
         --------							,AdditionalProv
         --------							,ProjectCost
         --------							,DtofFirstDisb
         --------							----,EmpCode
         --------							,FlagReliefWavier
         --------							,UnderLineActivityAlt_Key
         --------							,MicroCredit
         --------							,segmentcode
         --------							,ScrCrError
         --------							,AdjDt
         --------							,AdjReasonAlt_Key
         --------							,MarginType
         --------							,AclattestDevelopment
         --------							,SourceAlt_Key
         --------							,LoanSeries
         --------							,LoanRefNo
         --------							,SecuritizationCode
         --------							,Full_Disb
         --------							,OriginalBranchcode
         --------						)
         --------				--declare @MocTimeKey int =4383						
         --------					SELECT 
         --------							BranchCode
         --------							,AccountEntityId
         --------							,CustomerEntityId
         --------							,SystemACID
         --------							,CustomerACID
         --------							,GLAlt_Key
         --------							,ProductAlt_Key
         --------							,GLProductAlt_Key
         --------							,FacilityType
         --------							,SectorAlt_Key
         --------							,SubSectorAlt_Key
         --------							,ActivityAlt_Key
         --------							,IndustryAlt_Key
         --------							,SchemeAlt_Key
         --------							,DistrictAlt_Key
         --------							,AreaAlt_Key
         --------							,VillageAlt_Key
         --------							,StateAlt_Key
         --------							,CurrencyAlt_Key
         --------							,OriginalSanctionAuthAlt_Key
         --------							,OriginalLimitRefNo
         --------							,OriginalLimit
         --------							,OriginalLimitDt
         --------							,Pref_InttRate
         --------							,CurrentLimitRefNo
         --------							----,ProcessingFeeApplicable
         --------							----,ProcessingFeeAmt
         --------							----,ProcessingFeeRecoveryAmt
         --------							,GuaranteeCoverAlt_Key
         --------							,AccountName
         --------							----,ReferencePeriod
         --------							,AssetClass
         --------							----,D2K_REF_NO
         --------							----,InttAppFreq
         --------							,JointAccount
         --------							,LastDisbDt
         --------							,ScrCrErrorBackup
         --------							,AccountOpenDate
         --------							,Ac_LADDt
         --------							,Ac_DocumentDt
         --------							,CurrentLimit
         --------							,InttTypeAlt_Key
         --------							,InttRateLoadFactor
         --------							,Margin
         --------							----,TwentyPointReference
         --------							----,BSR1bCode
         --------							,CurrentLimitDt
         --------							,Ac_DueDt
         --------							,DrawingPowerAlt_Key
         --------							,RefCustomerId
         --------							----,D2KACID
         --------							,AuthorisationStatus
         --------							,@MocTimeKey+1 EffectiveFromTimeKey
         --------							,EffectiveToTimeKey
         --------							,CreatedBy
         --------							,DateCreated
         --------							,ModifiedBy
         --------							,DateModified
         --------							,ApprovedBy
         --------							,DateApproved							
         --------							,MocStatus
         --------							,MocDate
         --------							,MocTypeAlt_Key
         --------							,IsLAD
         --------							,FacilitiesNo
         --------							,FincaleBasedIndustryAlt_key
         --------							,AcCategoryAlt_Key
         --------							,OriginalSanctionAuthLevelAlt_Key
         --------							,AcTypeAlt_Key
         --------							,ScrCrErrorSeq
         --------							,D2k_OLDAscromID
         --------							,BSRUNID
         --------							,AdditionalProv
         --------							,ProjectCost
         --------							,DtofFirstDisb
         --------							----,EmpCode
         --------							,FlagReliefWavier
         --------							,UnderLineActivityAlt_Key
         --------							,MicroCredit
         --------							,segmentcode
         --------							,ScrCrError
         --------							,AdjDt
         --------							,AdjReasonAlt_Key
         --------							,MarginType
         --------							,AclattestDevelopment
         --------							,SourceAlt_Key
         --------							,LoanSeries
         --------							,LoanRefNo
         --------							,SecuritizationCode
         --------							,Full_Disb
         --------							,OriginalBranchcode
         --------					FROM tt_CUST_AC_MOC_3
         --------				WHERE EffectiveToTimeKey>@MocTimeKey
         --------				UPDATE A
         --------					SET A.EffectiveToTimeKey=@MocTimeKey-1
         --------				FROM ADVACBASICDETAIL A
         --------					INNER JOIN DataUpload.MocAccountDataUpload C
         --------						ON C.AccountEntityId=a.AccountEntityId
         --------					WHERE ISNULL(C.AmountofWriteOff,0)>0		
         --------						AND ((A.EffectiveFromTimeKey<=@MocTimeKey AND A.EffectiveToTimeKey>=@MocTimeKey)
         --------								OR (a.EffectiveFromTimeKey>=@MocTimeKey)
         --------							)
         /* CUSTOMERBASIC DETAIL*/
         /*		
          IF OBJECT_ID('Tempdb..#CustomerBasic') IS NOT NULL
         				DROP TABLE #CustomerBasic	


         			SELECT cbd.* 
         				INTO #CustomerBasic
         			FROM CustomerBasicDetail cbd
         				INNER JOIN (SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
         									WHERE  CustomerId IS NOT NULL
         									AND  (ISNULL(ConstitutionAlt_Key,0)<>0)																		
         								GROUP BY CustomerId,ConstitutionAlt_Key
         							) T
         					ON (cbd.CustomerId=T.CustomerId)
         					AND (cbd.EffectiveFromTimeKey<=@MocTimeKey AND cbd.EffectiveToTimeKey>=@MocTimeKey)
         					AND ISNULL(CBD.ConstitutionAlt_Key,0)<>ISNULL(T.ConstitutionAlt_Key,0)
         					and ISNULL(T.ConstitutionAlt_Key,0)<>0


         print 'TEST'

         --return
         	PRINT 'Expire Data'
         			UPDATE CBD SET
         					CBD.EffectiveToTimeKey =@MocTimeKey -1 
         				FROM CustomerBasicDetail CBD
         					--INNER JOIN sample_data T		--COMMENTED BY HAMID ON 24 NOV 2018				
         					 INNER JOIN #CustomerBasic T
         						ON CBD.CustomerId=T.CustomerId
         						AND (CBD.EffectiveFromTimeKey<=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey)
         					WHERE CBD.EffectiveFromTimeKey<@MocTimeKey

         			DELETE CBD 
         				FROM CustomerBasicDetail CBD
         					--INNER JOIN sample_data T		--COMMENTED BY HAMID ON 24 NOV 2018				
         					 INNER JOIN #CustomerBasic T
         						ON CBD.CustomerId=T.CustomerId
         						AND (CBD.EffectiveFromTimeKey<=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey)
         					WHERE  CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey


         --select * from #CustomerBasic
         			INSERT INTO PreMoc.CustomerBasicDetail
         					(
         					CustomerEntityId
         					,CustomerId
         					,D2kCustomerid
         					,ParentBranchCode
         					,CustomerName
         					,CustomerInitial
         					,CustomerSinceDt
         					,ConsentObtained
         					,ConstitutionAlt_Key
         					,OccupationAlt_Key
         					,ReligionAlt_Key
         					,CasteAlt_Key
         					,FarmerCatAlt_Key
         					,GaurdianSalutationAlt_Key
         					,GaurdianName
         					,GuardianType
         					,CustSalutationAlt_Key
         					,MaritalStatusAlt_Key
         					,DegUpgFlag
         					,ProcessingFlag
         					,MOCLock
         					,MoveNpaDt
         					,AssetClass
         					,BIITransactionCode
         					,D2K_REF_NO
         					,CustomerNameBackup
         					,ScrCrErrorBackup
         					,ScrCrError
         					,ReferenceAcNo
         					,CustCRM_RatingAlt_Key
         					,CustCRM_RatingDt
         					,AuthorisationStatus
         					,EffectiveFromTimeKey
         					,EffectiveToTimeKey
         					,CreatedBy
         					,DateCreated
         					,ModifiedBy
         					,DateModified
         					,ApprovedBy
         					,DateApproved					
         					,FLAG
         					,MocStatus
         					,MocDate
         					,BaselProcessing
         					,MocTypeAlt_Key
         					,CommonMocTypeAlt_Key
         					,LandHolding
         					,ScrCrErrorSeq
         					,CustType
         					,ServProviderAlt_Key
         					,NonCustTypeAlt_Key
         					,Remark
         					)
         				select
         					cbd.CustomerEntityId
         					,cbd.CustomerId
         					,cbd.D2kCustomerid
         					,cbd.ParentBranchCode
         					,cbd.CustomerName
         					,cbd.CustomerInitial
         					,cbd.CustomerSinceDt
         					,cbd.ConsentObtained
         					,cbd.ConstitutionAlt_Key
         					,cbd.OccupationAlt_Key
         					,cbd.ReligionAlt_Key
         					,cbd.CasteAlt_Key
         					,cbd.FarmerCatAlt_Key
         					,cbd.GaurdianSalutationAlt_Key
         					,cbd.GaurdianName
         					,cbd.GuardianType
         					,cbd.CustSalutationAlt_Key
         					,cbd.MaritalStatusAlt_Key
         					,cbd.DegUpgFlag
         					,cbd.ProcessingFlag
         					,cbd.MOCLock
         					,cbd.MoveNpaDt
         					,cbd.AssetClass
         					,cbd.BIITransactionCode
         					,cbd.D2K_REF_NO
         					,cbd.CustomerNameBackup
         					,cbd.ScrCrErrorBackup
         					,cbd.ScrCrError
         					,cbd.ReferenceAcNo
         					,cbd.CustCRM_RatingAlt_Key
         					,cbd.CustCRM_RatingDt
         					,cbd.AuthorisationStatus
         					,@MocTimeKey EffectiveFromTimeKey
         					,@MocTimeKey EffectiveToTimeKey
         					,@CrModApBy CreatedBy
         					,GETDATE() DateCreated
         					,cbd.ModifiedBy
         					,cbd.DateModified
         					,cbd.ApprovedBy
         					,cbd.DateApproved					
         					,cbd.FLAG
         					,'Y' MocStatus            
         					,GETDATE() MocDate   
         					,cbd.BaselProcessing
         					,cbd.MocTypeAlt_Key
         					,cbd.CommonMocTypeAlt_Key
         					,cbd.LandHolding
         					,cbd.ScrCrErrorSeq
         					,cbd.CustType
         					,cbd.ServProviderAlt_Key
         					,cbd.NonCustTypeAlt_Key
         					,cbd.Remark
         					FROM #CustomerBasic CBD
         						LEFT JOIN PreMoc.CustomerBasicDetail T				
         							ON(T.EffectiveFromTimeKey<=@MocTimeKey AND T.EffectiveToTimeKey>=@MocTimeKey)
         							AND T.CustomerId=CBD.CustomerId
         					WHERE T.CustomerEntityId IS NULL

         print 'TEST2'
         			PRINT 'UPDATE RECORD FOR SAME TIME KEY'
         				 UPDATE CBD SET
         		       			CBD.EffectiveToTimeKey =@MocTimeKey
         						,CBD.EffectiveFromTimeKey =@MocTimeKey												
         						,MocStatus= 'Y'               
         						,MocDate= GetDate()                
         						,MocTypeAlt_Key= 210   
         						,CBD.ConstitutionAlt_Key=SD.ConstitutionAlt_Key 
         						,ModifiedBy=@CrModApBy
         						,DateModified=getdate()
         				FROM CustomerBasicDetail CBD
         						INNER JOIN 
         								(SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
         										WHERE ISNULL(ConstitutionAlt_Key,0)<>0
         										GROUP BY CustomerId,ConstitutionAlt_Key
         									)SD							
         								ON CBD.CustomerId = SD.CustomerId																				   
         						WHERE (CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey=@MocTimeKey)


         						PRINT 'INSERT IN CustomerBasicDetail FOR CURRENT TIME KEY'
         			INSERT INTO CustomerBasicDetail 
         						(
         							CustomerEntityId
         							,CustomerId
         							,D2kCustomerid
         							,ParentBranchCode
         							,CustomerName
         							,CustomerInitial
         							,CustomerSinceDt
         							,ConsentObtained
         							,ConstitutionAlt_Key
         							,OccupationAlt_Key
         							,ReligionAlt_Key
         							,CasteAlt_Key
         							,FarmerCatAlt_Key
         							,GaurdianSalutationAlt_Key
         							,GaurdianName
         							,GuardianType
         							,CustSalutationAlt_Key
         							,MaritalStatusAlt_Key
         							,DegUpgFlag
         							,ProcessingFlag
         							,MOCLock
         							,MoveNpaDt
         							,AssetClass
         							,BIITransactionCode
         							,D2K_REF_NO
         							,CustomerNameBackup
         							,ScrCrErrorBackup
         							,ScrCrError
         							,ReferenceAcNo
         							,CustCRM_RatingAlt_Key
         							,CustCRM_RatingDt
         							,AuthorisationStatus
         							,EffectiveFromTimeKey
         							,EffectiveToTimeKey
         							,CreatedBy
         							,DateCreated
         							,ModifiedBy
         							,DateModified
         							,ApprovedBy
         							,DateApproved							
         							,FLAG
         							,MocStatus
         							,MocDate
         							,BaselProcessing
         							,MocTypeAlt_Key
         							,CommonMocTypeAlt_Key
         							,LandHolding
         							,ScrCrErrorSeq
         							,CustType
         							,ServProviderAlt_Key
         							,NonCustTypeAlt_Key
         							,Remark
         						)
         				--declare @MocTimeKey int =4383						
         					SELECT 
         							CustomerEntityId
         							,SD.CustomerId
         							,D2kCustomerid
         							,ParentBranchCode
         							,CustomerName
         							,CustomerInitial
         							,CustomerSinceDt
         							,ConsentObtained
         							,SD.ConstitutionAlt_Key
         							,OccupationAlt_Key
         							,ReligionAlt_Key
         							,CasteAlt_Key
         							,FarmerCatAlt_Key
         							,GaurdianSalutationAlt_Key
         							,GaurdianName
         							,GuardianType
         							,CustSalutationAlt_Key
         							,MaritalStatusAlt_Key
         							,DegUpgFlag
         							,ProcessingFlag
         							,MOCLock
         							,MoveNpaDt
         							,AssetClass
         							,BIITransactionCode
         							,D2K_REF_NO
         							,CustomerNameBackup
         							,ScrCrErrorBackup
         							,ScrCrError
         							,ReferenceAcNo
         							,CustCRM_RatingAlt_Key
         							,CustCRM_RatingDt
         							,AuthorisationStatus
         							,@MocTimeKey EffectiveFromTimeKey
         							,@MocTimeKey EffectiveToTimeKey
         							,@CrModApBy CreatedBy
         							,GETDATE() DateCreated
         							,ModifiedBy
         							,DateModified
         							,ApprovedBy
         							,DateApproved							
         							,FLAG
         							,'Y' MocStatus
         							,GETDATE() MocDate
         							,BaselProcessing
         							,210 MocTypeAlt_Key
         							,CommonMocTypeAlt_Key
         							,LandHolding
         							,ScrCrErrorSeq
         							,CustType
         							,ServProviderAlt_Key
         							,NonCustTypeAlt_Key
         							,Remark  
         					FROM #CustomerBasic CBD
         						INNER JOIN  
         								(SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
         												WHERE ISNULL(ConstitutionAlt_Key,0)<>0
         												GROUP BY CustomerId,ConstitutionAlt_Key
         								)SD						
         								ON CBD.CustomerId = SD.CustomerId								  						  
         						WHERE NOT(CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey=@MocTimeKey)



         		PRINT 'INSERT IN CustomerBasicDetail FOR LIVE'
         			INSERT INTO CustomerBasicDetail 
         						(
         							CustomerEntityId
         							,CustomerId
         							,D2kCustomerid
         							,ParentBranchCode
         							,CustomerName
         							,CustomerInitial
         							,CustomerSinceDt
         							,ConsentObtained
         							,ConstitutionAlt_Key
         							,OccupationAlt_Key
         							,ReligionAlt_Key
         							,CasteAlt_Key
         							,FarmerCatAlt_Key
         							,GaurdianSalutationAlt_Key
         							,GaurdianName
         							,GuardianType
         							,CustSalutationAlt_Key
         							,MaritalStatusAlt_Key
         							,DegUpgFlag
         							,ProcessingFlag
         							,MOCLock
         							,MoveNpaDt
         							,AssetClass
         							,BIITransactionCode
         							,D2K_REF_NO
         							,CustomerNameBackup
         							,ScrCrErrorBackup
         							,ScrCrError
         							,ReferenceAcNo
         							,CustCRM_RatingAlt_Key
         							,CustCRM_RatingDt
         							,AuthorisationStatus
         							,EffectiveFromTimeKey
         							,EffectiveToTimeKey
         							,CreatedBy
         							,DateCreated
         							,ModifiedBy
         							,DateModified
         							,ApprovedBy
         							,DateApproved							
         							,FLAG
         							,MocStatus
         							,MocDate
         							,BaselProcessing
         							,MocTypeAlt_Key
         							,CommonMocTypeAlt_Key
         							,LandHolding
         							,ScrCrErrorSeq
         							,CustType
         							,ServProviderAlt_Key
         							,NonCustTypeAlt_Key
         							,Remark
         						)
         				--declare @MocTimeKey int =4383						
         					SELECT 
         							CustomerEntityId
         							,CBD.CustomerId
         							,D2kCustomerid
         							,ParentBranchCode
         							,CustomerName
         							,CustomerInitial
         							,CustomerSinceDt
         							,ConsentObtained
         							,CBD.ConstitutionAlt_Key
         							,OccupationAlt_Key
         							,ReligionAlt_Key
         							,CasteAlt_Key
         							,FarmerCatAlt_Key
         							,GaurdianSalutationAlt_Key
         							,GaurdianName
         							,GuardianType
         							,CustSalutationAlt_Key
         							,MaritalStatusAlt_Key
         							,DegUpgFlag
         							,ProcessingFlag
         							,MOCLock
         							,MoveNpaDt
         							,AssetClass
         							,BIITransactionCode
         							,D2K_REF_NO
         							,CustomerNameBackup
         							,ScrCrErrorBackup
         							,ScrCrError
         							,ReferenceAcNo
         							,CustCRM_RatingAlt_Key
         							,CustCRM_RatingDt
         							,AuthorisationStatus
         							,@MocTimeKey+1 EffectiveFromTimeKey
         							,EffectiveToTimeKey
         							,CreatedBy
         							,DateCreated
         							,ModifiedBy
         							,DateModified
         							,ApprovedBy
         							,DateApproved							
         							,FLAG
         							,MocStatus
         							,MocDate
         							,BaselProcessing
         							,MocTypeAlt_Key
         							,CommonMocTypeAlt_Key
         							,LandHolding
         							,ScrCrErrorSeq
         							,CustType
         							,ServProviderAlt_Key
         							,NonCustTypeAlt_Key
         							,Remark  
         					FROM #CustomerBasic CBD
         				WHERE CBD.EffectiveToTimeKey>@MocTimeKey

         */
         /*   ADVCUSTFINANCIAL DETAIL */
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_TempCustBalance_New_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_TempCustBalance_New_3;
         UTILS.IDENTITY_RESET('tt_TempCustBalance_New_3');

         INSERT INTO tt_TempCustBalance_New_3 ( 
         	SELECT ABD.CustomerEntityId ,
                 ABD.BranchCode ,
                 SUM(NVL(BAL.Balance, 0))  Balance  ,
                 MAX(BAL.AssetClassAlt_Key)  AssetClassAlt_Key  
         	  FROM RBL_MISDB_PROD.AdvAcBalanceDetail BAL
                 --INNER JOIN Sample_Data S
                  --	ON BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey
                  --	AND S.AccountEntityId = BAL.AccountEntityId

                   JOIN AdvAcBasicDetail ABD   ON ABD.EffectiveFromTimeKey <= v_MocTimeKey
                   AND ABD.EffectiveToTimeKey >= v_MocTimeKey
                   AND BAL.EffectiveFromTimeKey = v_MocTimeKey
                   AND BAL.EffectiveToTimeKey = v_MocTimeKey
                   AND ABD.AccountEntityId = BAL.AccountEntityId
         	  GROUP BY ABD.CustomerEntityId,ABD.BranchCode );
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AdvCustFinancialDetail_O_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AdvCustFinancialDetail_O_3;
         UTILS.IDENTITY_RESET('tt_AdvCustFinancialDetail_O_3');

         INSERT INTO tt_AdvCustFinancialDetail_O_3 ( 
         	SELECT F.* 
         	  FROM AdvCustFinancialDetail F
                   JOIN tt_TempCustBalance_New_3 N   ON F.EffectiveFromTimeKey <= v_MocTimeKey
                   AND EffectiveToTimeKey >= v_MocTimeKey
                   AND N.CustomerEntityId = F.CustomerEntityId
                   AND N.BranchCode = F.BranchCode );
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM ACFD ,AdvCustFinancialDetail ACFD
                JOIN tt_TempCustBalance_New_3 T   ON ACFD.CustomerEntityId = T.CustomerEntityId
                AND ACFD.BranchCode = T.BranchCode
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE ACFD
          WHERE ROWID IN 
         ( SELECT ACFD.ROWID
           FROM AdvCustFinancialDetail ACFD
                  JOIN tt_TempCustBalance_New_3 T   ON ACFD.CustomerEntityId = T.CustomerEntityId
                  AND ACFD.BranchCode = T.BranchCode
                  AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ),
                ACFD
          WHERE  ACFD.EffectiveFromTimeKey = v_MocTimeKey
                   AND ACFD.EffectiveToTimeKey >= v_MocTimeKey );
         INSERT INTO PreMoc_RBL_MISDB_PROD.AdvCustFinancialDetail
           ( CustomerEntityId, BranchCode, TotLimitFunded, TotLimitNF, TotOsFunded, TotOsNF, TotOverDue, TotCadu, TotCad, Cust_AssetClassAlt_Key, TotProvision, TotAdditionalProvision, TotGenericAddlProvision, TotUnappliedInt, EntityClosureDate, EntityClosureReasonAlt_Key, Old_Cust_AssetClassAlt_Key, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key )
           ( SELECT T.CustomerEntityId ,
                    T.BranchCode ,
                    T.TotLimitFunded ,
                    T.TotLimitNF ,
                    T.TotOsFunded ,
                    T.TotOsNF ,
                    T.TotOverDue ,
                    T.TotCadu ,
                    T.TotCad ,
                    T.Cust_AssetClassAlt_Key ,
                    T.TotProvision ,
                    T.TotAdditionalProvision ,
                    T.TotGenericAddlProvision ,
                    T.TotUnappliedInt ,
                    T.EntityClosureDate ,
                    T.EntityClosureReasonAlt_Key ,
                    T.Old_Cust_AssetClassAlt_Key ,
                    T.RefCustomerId ,
                    T.AuthorisationStatus ,
                    v_MocTimeKey EffectiveFromTimeKey  ,
                    v_MocTimeKey EffectiveToTimeKey  ,
                    T.CreatedBy ,
                    T.DateCreated ,
                    T.ModifiedBy ,
                    T.DateModified ,
                    T.ApprovedBy ,
                    T.DateApproved ,
                    'Y' MocStatus  ,
                    SYSDATE MocDate  ,
                    T.MocTypeAlt_Key 
             FROM tt_AdvCustFinancialDetail_O_3 T
                    JOIN tt_TempCustBalance_New_3 N   ON T.EffectiveFromTimeKey <= v_MocTimeKey
                    AND T.EffectiveToTimeKey >= v_MocTimeKey
                    AND T.CustomerEntityId = N.CustomerEntityId
                    AND T.BranchCode = N.BranchCode
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.AdvCustFinancialDetail PRE   ON ( PRE.EffectiveFromTimeKey <= v_MocTimeKey
                    AND PRE.EffectiveToTimeKey >= v_MocTimeKey )
                    AND PRE.CustomerEntityId = T.CustomerEntityId
                    AND PRE.BranchCode = T.BranchCode
              WHERE  PRE.CustomerEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey, v_MocTimeKey, v_CrModApBy, v_CrModApBy, SYSDATE, SYSDATE, 210, T.AssetClassAlt_Key, T.Balance
         FROM ACFD ,AdvCustFinancialDetail ACFD
                JOIN tt_TempCustBalance_New_3 T   ON ACFD.CustomerEntityId = T.CustomerEntityId
                AND ACFD.BranchCode = T.BranchCode
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey = v_MocTimeKey
           AND ACFD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveFromTimeKey = v_MocTimeKey,
                                      ACFD.EffectiveToTimeKey = v_MocTimeKey,
                                      ACFD.CreatedBy = v_CrModApBy,
                                      ACFD.ModifiedBy = v_CrModApBy,
                                      ACFD.DateModified = SYSDATE,
                                      ACFD.MocDate = SYSDATE,
                                      ACFD.MocTypeAlt_Key = 210,
                                      ACFD.Cust_AssetClassAlt_Key = src.AssetClassAlt_Key,
                                      ACFD.TotOsFunded = src.Balance;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         INSERT INTO AdvCustFinancialDetail
           ( CustomerEntityId, BranchCode, TotLimitFunded, TotLimitNF, TotOsFunded, TotOsNF, TotOverDue, TotCadu, TotCad, Cust_AssetClassAlt_Key, TotProvision, TotAdditionalProvision, TotGenericAddlProvision, TotUnappliedInt, EntityClosureDate, EntityClosureReasonAlt_Key, Old_Cust_AssetClassAlt_Key, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key )
           ( SELECT A.CustomerEntityId ,
                    A.BranchCode ,
                    TotLimitFunded ,
                    TotLimitNF ,
                    NVL(A.Balance, 0) TotOsFunded  ,
                    TotOsNF ,
                    TotOverDue ,
                    TotCadu ,
                    TotCad ,
                    A.AssetClassAlt_Key Cust_AssetClassAlt_Key  ,
                    TotProvision ,
                    TotAdditionalProvision ,
                    TotGenericAddlProvision ,
                    TotUnappliedInt ,
                    EntityClosureDate ,
                    EntityClosureReasonAlt_Key ,
                    O.Cust_AssetClassAlt_Key ,
                    RefCustomerId ,
                    AuthorisationStatus ,
                    v_MocTimeKey EffectiveFromTimeKey  ,
                    v_MocTimeKey EffectiveToTimeKey  ,
                    CreatedBy ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    'Y' MocStatus  ,
                    SYSDATE MocDate  ,
                    MocTypeAlt_Key 
             FROM tt_TempCustBalance_New_3 A
                    LEFT JOIN AdvCustFinancialDetail O   ON A.CustomerEntityId = O.CustomerEntityId
                    AND A.BranchCode = O.BranchCode
                    AND ( O.EffectiveFromTimeKey = v_MocTimeKey
                    AND O.EffectiveToTimeKey = v_MocTimeKey )
              WHERE  O.CustomerEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         INSERT INTO AdvCustFinancialDetail
           ( CustomerEntityId, BranchCode, TotLimitFunded, TotLimitNF, TotOsFunded, TotOsNF, TotOverDue, TotCadu, TotCad, Cust_AssetClassAlt_Key, TotProvision, TotAdditionalProvision, TotGenericAddlProvision, TotUnappliedInt, EntityClosureDate, EntityClosureReasonAlt_Key, Old_Cust_AssetClassAlt_Key, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key )
           ( SELECT T.CustomerEntityId ,
                    T.BranchCode ,
                    NVL(T.TotLimitFunded, 0) ,
                    TotLimitNF ,
                    TotOsFunded ,
                    TotOsNF ,
                    TotOverDue ,
                    TotCadu ,
                    TotCad ,
                    Cust_AssetClassAlt_Key ,
                    TotProvision ,
                    TotAdditionalProvision ,
                    TotGenericAddlProvision ,
                    TotUnappliedInt ,
                    EntityClosureDate ,
                    EntityClosureReasonAlt_Key ,
                    T.Cust_AssetClassAlt_Key ,
                    RefCustomerId ,
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
                    MocTypeAlt_Key 
             FROM tt_AdvCustFinancialDetail_O_3 T
              WHERE  T.EffectiveToTimeKey > v_MocTimeKey );
         DBMS_OUTPUT.PUT_LINE('EXcelUpload_SecurityValueDetail finish');
         /****************************************************/
         /*	ADVACFINANCIALDETAIL TABLE	*/
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AdvAcFinancialDetail_ORG_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AdvAcFinancialDetail_ORG_3;
         UTILS.IDENTITY_RESET('tt_AdvAcFinancialDetail_ORG_3');

         INSERT INTO tt_AdvAcFinancialDetail_ORG_3 ( 
         	SELECT F.* 
         	  FROM AdvAcFinancialDetail F
                   JOIN AdvAcBasicDetail B   ON ( F.EffectiveFromTimeKey <= v_MocTimeKey
                   AND F.EffectiveToTimeKey >= v_MocTimeKey )
                   AND ( B.EffectiveFromTimeKey <= v_MocTimeKey
                   AND B.EffectiveToTimeKey >= v_MocTimeKey )
                   AND F.AccountEntityId = B.AccountEntityId
                   JOIN ( SELECT CustomerEntityID ,
                                 MIN(UTILS.CONVERT_TO_VARCHAR2(NVL(NPADATE, '1900-01-01'),200))  PostMoc_NPAdt  
                          FROM tt_CUST_AC_MOC_3 
                            GROUP BY CustomerEntityID ) C   ON C.CustomerEntityID = B.CustomerEntityID

         	--AND F.AccountEntityId = S.AccountEntityId
         	WHERE  NVL(F.NpaDt, '1900-01-01') <> PostMoc_NPAdt );
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AdvAcFinancialDetail_New_3  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AdvAcFinancialDetail_New_3;
         UTILS.IDENTITY_RESET('tt_AdvAcFinancialDetail_New_3');

         INSERT INTO tt_AdvAcFinancialDetail_New_3 ( 
         	SELECT O.AccountEntityId ,
                 NVL(S.PostMoc_NPAdt, '1900-01-01') NpaDt  
         	  FROM tt_AdvAcFinancialDetail_ORG_3 O
                   JOIN AdvAcBasicDetail B   ON ( O.EffectiveFromTimeKey <= v_MocTimeKey
                   AND O.EffectiveToTimeKey >= v_MocTimeKey )
                   AND ( B.EffectiveFromTimeKey <= v_MocTimeKey
                   AND B.EffectiveToTimeKey >= v_MocTimeKey )
                   AND O.AccountEntityId = B.AccountEntityId
                   JOIN ( SELECT CustomerEntityID ,
                                 MIN(UTILS.CONVERT_TO_VARCHAR2(NVL(NPADATE, '1900-01-01'),200))  PostMoc_NPAdt  
                          FROM tt_CUST_AC_MOC_3 S
                            GROUP BY CustomerEntityID ) S   ON S.CustomerEntityID = B.CustomerEntityID );
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM ACFD ,AdvAcFinancialDetail ACFD
                JOIN tt_AdvAcFinancialDetail_New_3 T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey < v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE ACFD
          WHERE ROWID IN 
         ( SELECT ACFD.ROWID
           FROM AdvAcFinancialDetail ACFD
                  JOIN tt_AdvAcFinancialDetail_New_3 T   ON ACFD.AccountEntityId = T.AccountEntityId
                  AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                  AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ),
                ACFD
          WHERE  ACFD.EffectiveFromTimeKey = v_MocTimeKey
                   AND ACFD.EffectiveToTimeKey >= v_MocTimeKey );
         INSERT INTO PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL
           ( AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
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
           ( SELECT T.AccountEntityId ,
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
             FROM tt_AdvAcFinancialDetail_ORG_3 T
                    JOIN tt_AdvAcFinancialDetail_New_3 N   ON T.EffectiveFromTimeKey <= v_MocTimeKey
                    AND T.EffectiveToTimeKey >= v_MocTimeKey
                    AND T.AccountEntityId = N.AccountEntityId
                    LEFT JOIN PreMoc_RBL_MISDB_PROD.ADVACFINANCIALDETAIL PRE   ON ( PRE.EffectiveFromTimeKey <= v_MocTimeKey
                    AND PRE.EffectiveToTimeKey >= v_MocTimeKey )
                    AND PRE.AccountEntityId = T.AccountEntityId
              WHERE  PRE.AccountEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('UPDATE RECORED FOR CURRENT TIME KEY');
         MERGE INTO ACFD 
         USING (SELECT ACFD.ROWID row_id, v_MocTimeKey, v_MocTimeKey, v_CrModApBy, SYSDATE, 'Y', SYSDATE, 210, T.NpaDt
         FROM ACFD ,AdvAcFinancialDetail ACFD
                JOIN tt_AdvAcFinancialDetail_New_3 T   ON ACFD.AccountEntityId = T.AccountEntityId
                AND ( ACFD.EffectiveFromTimeKey <= v_MocTimeKey
                AND ACFD.EffectiveToTimeKey >= v_MocTimeKey ) 
          WHERE ACFD.EffectiveFromTimeKey = v_MocTimeKey
           AND ACFD.EffectiveToTimeKey = v_MocTimeKey) src
         ON ( ACFD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACFD.EffectiveFromTimeKey = v_MocTimeKey,
                                      ACFD.EffectiveToTimeKey = v_MocTimeKey,
                                      ModifiedBy = v_CrModApBy,
                                      DateModified = SYSDATE,
                                      MocStatus = 'Y',
                                      MocDate = SYSDATE,
                                      MocTypeAlt_Key = 210,
                                      ACFD.NpaDt = src.NpaDt;
         DBMS_OUTPUT.PUT_LINE('Insert data for Current TimeKey');
         INSERT INTO AdvAcFinancialDetail
           ( AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
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
           ( SELECT A.AccountEntityId ,
                    Ac_LastReviewDueDt ,
                    Ac_ReviewTypeAlt_key ,
                    Ac_ReviewDt ,
                    Ac_ReviewAuthAlt_Key ,
                    Ac_NextReviewDueDt ,
                    DrawingPower ,
                    InttRate ,
                    ----,IrregularType
                    ----,IrregularityDt
                    A.NpaDt ,
                    BookDebts ,
                    UnDrawnAmt ,
                    ----,TotalDI
                    ----,UnAppliedIntt
                    ----,LegalExp
                    UnAdjSubSidy ,
                    LastInttRealiseDt ,
                    'Y' MocStatus  ,
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
                    v_MocTimeKey EffectiveFromTimeKey  ,
                    v_MocTimeKey EffectiveToTimeKey  ,
                    CreatedBy ,
                    DateCreated ,
                    ModifiedBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    SYSDATE MocDate  ,
                    MocTypeAlt_Key ,
                    CropDuration ,
                    Ac_ReviewAuthLevelAlt_Key 
             FROM tt_AdvAcFinancialDetail_New_3 A
                    LEFT JOIN AdvAcFinancialDetail O   ON A.AccountEntityId = O.AccountEntityId
                    AND ( O.EffectiveFromTimeKey = v_MocTimeKey
                    AND O.EffectiveToTimeKey = v_MocTimeKey )
              WHERE  o.AccountEntityId IS NULL );
         DBMS_OUTPUT.PUT_LINE('Insert data for live TimeKey');
         INSERT INTO AdvAcFinancialDetail
           ( AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
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
           ( SELECT AccountEntityId ,
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
             FROM tt_AdvAcFinancialDetail_ORG_3 T
              WHERE  T.EffectiveToTimeKey > v_MocTimeKey );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, v_MocTimeKey - 1 AS EffectiveToTimeKey
         FROM A ,AdvAcFinancialDetail A
                JOIN DataUpload_RBL_MISDB_PROD.MocAccountDataUpload C   ON C.AccountEntityId = A.AccountEntityId 
          WHERE NVL(C.AmountofWriteOff, 0) > 0
           AND ( ( A.EffectiveFromTimeKey <= v_MocTimeKey
           AND A.EffectiveToTimeKey >= v_MocTimeKey )
           OR a.EffectiveFromTimeKey >= v_MocTimeKey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERACCOUNTMOC" TO "ADF_CDR_RBL_STGDB";
