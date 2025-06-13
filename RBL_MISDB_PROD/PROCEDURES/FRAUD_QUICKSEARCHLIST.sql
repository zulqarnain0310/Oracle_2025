--------------------------------------------------------
--  DDL for Procedure FRAUD_QUICKSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" 
--exec [dbo].[Fraud_QuickSearchlist] 1,24738,'',1,1000

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_MenuID IN NUMBER DEFAULT 24738 ,
  v_Account_id IN VARCHAR2 DEFAULT ' ' ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 10000 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   BEGIN

      BEGIN
         --select * from 	SysCRisMacMenu where menucaption like '%Branch%'
         IF utils.object_id('TempDB..tt_CustNPADetail') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustNPADetail ';
         END IF;
         DELETE FROM tt_CustNPADetail;
         UTILS.IDENTITY_RESET('tt_CustNPADetail');

         INSERT INTO tt_CustNPADetail ( 
         	SELECT A.RefCustomerID ,
                 A.Cust_AssetClassAlt_Key 
         	  FROM RBL_MISDB_PROD.AdvCustNPADetail A
                   JOIN ( SELECT RefCustomerID ,
                                 MIN(EffectiveFromTimeKey)  EffectiveFromTimeKey  
                          FROM AdvCustNPADetail 
                            GROUP BY RefCustomerID ) B   ON A.RefCustomerID = B.RefCustomerID
                   AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey );
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
         IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
            ACLProcessStatusCheck() ;

         END;
         END IF;
         IF ( v_Account_id = ' '
           OR ( v_Account_id IS NULL ) ) THEN

         BEGIN
            IF ( v_OperationFlag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Prashant');
               IF utils.object_id('TempDB..tt_temp_Fraud') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_Fraud ';
               END IF;
               DELETE FROM tt_temp_Fraud;
               UTILS.IDENTITY_RESET('tt_temp_Fraud');

               INSERT INTO tt_temp_Fraud ( 
               	SELECT -- A.Account_ID
               	 AccountEntityId ,
                 CustomerEntityId ,
                 RefCustomerACID ,
                 RefCustomerID ,
                 SourceName ,
                 BranchCode ,
                 BranchName ,
                 AcBuSegmentCode ,
                 AcBuSegmentDescription ,
                 UCIF_ID ,
                 CustomerName ,
                 TOS ,
                 POS ,
                 AssetClassAtFraud ,
                 NPADateAtFraud ,
                 RFA_ReportingByBank ,
                 RFA_DateReportingByBank ,
                 RFA_OtherBankAltKey ,
                 RFA_OtherBankDate ,
                 FraudOccuranceDate ,
                 FraudDeclarationDate ,
                 FraudNature ,
                 FraudArea ,
                 CurrentAssetClassName ,
                 CurrentAssetClassAltKey ,
                 CurrentNPA_Date ,
                 Provisionpreference ,
                 A.AuthorisationStatus ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.CreatedBy ,
                 A.DateCreated ,
                 A.ModifiedBy ,
                 A.DateModified ,
                 A.ApprovedBy ,
                 A.DateApproved ,
                 ApprovedByFirstLevel ,
                 FirstLevelDateApproved ,
                 A.ChangeFields ,
                 A.screenFlag ,
                 A.CrModBy ,
                 A.CrModDate ,
                 A.CrAppBy ,
                 A.CrAppDate ,
                 A.ModAppBy ,
                 A.ModAppDate ,
                 A.AuthorisationStatus_1 
               	  FROM ( SELECT --A.Account_ID
                          B.AccountEntityId ,
                          B.CustomerEntityId ,
                          B.CustomerACID RefCustomerACID  ,
                          B.RefCustomerID ,
                          SourceName ,
                          E.BranchCode ,
                          E.BranchName ,
                          F.AcBuSegmentCode ,
                          F.AcBuSegmentDescription ,
                          UCIF_ID ,
                          CustomerName ,
                          Balance TOS  ,
                          PrincipalBalance POS  ,
                          (CASE 
                                WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                          ELSE R.AssetClassName
                             END) AssetClassAtFraud  ,
                          (CASE 
                                WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                          ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                             END) NPADateAtFraud  ,
                          RFA_ReportingByBank ,
                          (CASE 
                                WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                          ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                             END) RFA_DateReportingByBank  ,
                          RFA_OtherBankAltKey ,
                          (CASE 
                                WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                          ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                             END) RFA_OtherBankDate  ,
                          (CASE 
                                WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                          ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                             END) FraudOccuranceDate  ,
                          (CASE 
                                WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                          ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                             END) FraudDeclarationDate  ,
                          FraudNature ,
                          FraudArea ,
                          L.AssetClassName CurrentAssetClassName  ,
                          H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                          UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                          ProvPref Provisionpreference  ,
                          NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated DateCreated  ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          FirstLevelApprovedBy ApprovedByFirstLevel  ,
                          FirstLevelDateApproved ,
                          NULL ChangeFields  ,
                          A.screenFlag ,
                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                          NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                          CASE 
                               WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                               WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                               WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                               WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                               WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                THEN 'Pending'
                          ELSE NULL
                             END AuthorisationStatus_1  
                         FROM Fraud_Details A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') = 'A'
                         UNION 
                         SELECT B.AccountEntityId ,
                                B.CustomerEntityId ,
                                B.CustomerACID RefCustomerACID  ,
                                B.RefCustomerID ,
                                SourceName ,
                                E.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                UCIF_ID ,
                                CustomerName ,
                                Balance TOS  ,
                                PrincipalBalance POS  ,
                                (CASE 
                                      WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                ELSE R.AssetClassName
                                   END) AssetClassAtFraud  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                   END) NPADateAtFraud  ,
                                RFA_ReportingByBank ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                   END) RFA_DateReportingByBank  ,
                                RFA_OtherBankAltKey ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                   END) RFA_OtherBankDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                   END) FraudOccuranceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                   END) FraudDeclarationDate  ,
                                FraudNature ,
                                FraudArea ,
                                L.AssetClassName CurrentAssetClassName  ,
                                H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                ProvPref Provisionpreference  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                B.EffectiveFromTimeKey ,
                                B.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated DateCreated  ,
                                A.ModifiedBy ,
                                A.DateModified DateModified  ,
                                A.ApprovedBy ,
                                A.DateApproved DateApproved  ,
                                FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                FirstLevelDateApproved ,
                                A.FraudAccounts_ChangeFields ChangeFields  ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  
                         FROM Fraud_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM Fraud_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Fraud' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp_Fraud A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
            --      AND RowNumber <= (@PageNo * @PageSize);
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp16_111') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_111 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant1');
               DELETE FROM tt_temp16_111;
               UTILS.IDENTITY_RESET('tt_temp16_111');

               INSERT INTO tt_temp16_111 ( 
               	SELECT AccountEntityId ,
                       CustomerEntityId ,
                       RefCustomerACID ,
                       RefCustomerID ,
                       SourceName ,
                       BranchCode ,
                       BranchName ,
                       AcBuSegmentCode ,
                       AcBuSegmentDescription ,
                       UCIF_ID ,
                       CustomerName ,
                       TOS ,
                       POS ,
                       AssetClassAtFraud ,
                       NPADateAtFraud ,
                       RFA_ReportingByBank ,
                       RFA_DateReportingByBank ,
                       RFA_OtherBankAltKey ,
                       RFA_OtherBankDate ,
                       FraudOccuranceDate ,
                       FraudDeclarationDate ,
                       FraudNature ,
                       FraudArea ,
                       CurrentAssetClassName ,
                       CurrentAssetClassAltKey ,
                       CurrentNPA_Date ,
                       Provisionpreference ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       ApprovedByFirstLevel ,
                       FirstLevelDateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.AuthorisationStatus_1 
               	  FROM ( SELECT B.AccountEntityId ,
                                B.CustomerEntityId ,
                                B.CustomerACID RefCustomerACID  ,
                                B.RefCustomerID ,
                                SourceName ,
                                E.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                UCIF_ID ,
                                CustomerName ,
                                Balance TOS  ,
                                PrincipalBalance POS  ,
                                (CASE 
                                      WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                ELSE R.AssetClassName
                                   END) AssetClassAtFraud  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                   END) NPADateAtFraud  ,
                                RFA_ReportingByBank ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                   END) RFA_DateReportingByBank  ,
                                RFA_OtherBankAltKey ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                   END) RFA_OtherBankDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                   END) FraudOccuranceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                   END) FraudDeclarationDate  ,
                                FraudNature ,
                                FraudArea ,
                                L.AssetClassName CurrentAssetClassName  ,
                                H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                ProvPref Provisionpreference  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                B.EffectiveFromTimeKey ,
                                B.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated DateCreated  ,
                                A.ModifiedBy ,
                                A.DateModified DateModified  ,
                                A.ApprovedBy ,
                                A.DateApproved DateApproved  ,
                                FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                FirstLevelDateApproved ,
                                A.FraudAccounts_ChangeFields ChangeFields  ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  

                         --               FROM Fraud_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM Fraud_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM Fraud_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Fraud' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_111 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
            --      AND RowNumber <= (@PageNo * @PageSize)
            IF ( v_OperationFlag = 20 ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp20_76') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_76 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant2');
               DELETE FROM tt_temp20_76;
               UTILS.IDENTITY_RESET('tt_temp20_76');

               INSERT INTO tt_temp20_76 ( 
               	SELECT AccountEntityId ,
                       CustomerEntityId ,
                       RefCustomerACID ,
                       RefCustomerID ,
                       SourceName ,
                       BranchCode ,
                       BranchName ,
                       AcBuSegmentCode ,
                       AcBuSegmentDescription ,
                       UCIF_ID ,
                       CustomerName ,
                       TOS ,
                       POS ,
                       AssetClassAtFraud ,
                       NPADateAtFraud ,
                       RFA_ReportingByBank ,
                       RFA_DateReportingByBank ,
                       RFA_OtherBankAltKey ,
                       RFA_OtherBankDate ,
                       FraudOccuranceDate ,
                       FraudDeclarationDate ,
                       FraudNature ,
                       FraudArea ,
                       CurrentAssetClassName ,
                       CurrentAssetClassAltKey ,
                       CurrentNPA_Date ,
                       Provisionpreference ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       ApprovedByFirstLevel ,
                       FirstLevelDateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.AuthorisationStatus_1 
               	  FROM ( SELECT B.AccountEntityId ,
                                B.CustomerEntityId ,
                                B.CustomerACID RefCustomerACID  ,
                                B.RefCustomerID ,
                                SourceName ,
                                E.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                UCIF_ID ,
                                CustomerName ,
                                Balance TOS  ,
                                PrincipalBalance POS  ,
                                (CASE 
                                      WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                ELSE R.AssetClassName
                                   END) AssetClassAtFraud  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                   END) NPADateAtFraud  ,
                                RFA_ReportingByBank ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                   END) RFA_DateReportingByBank  ,
                                RFA_OtherBankAltKey ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                   END) RFA_OtherBankDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                   END) FraudOccuranceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                   END) FraudDeclarationDate  ,
                                FraudNature ,
                                FraudArea ,
                                L.AssetClassName CurrentAssetClassName  ,
                                H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                ProvPref Provisionpreference  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                B.EffectiveFromTimeKey ,
                                B.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated DateCreated  ,
                                A.ModifiedBy ,
                                A.DateModified DateModified  ,
                                A.ApprovedBy ,
                                A.DateApproved DateApproved  ,
                                FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                FirstLevelDateApproved ,
                                A.FraudAccounts_ChangeFields ChangeFields  ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  

                         --               FROM Fraud_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM Fraud_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM Fraud_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey

                                                                  --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                                                                  AND (CASE 
                                                                            WHEN v_AuthLevel = 2
                                                                              AND NVL(AuthorisationStatus, 'A') IN ( '1A','D1' )
                                                                             THEN 1
                                                                            WHEN v_AuthLevel = 1
                                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                                                                             THEN 1
                                                                ELSE 0
                                                                   END) = 1
                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Fraud' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp20_76 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize)

         ------------------------------------------------------------------------------------------------
         ELSE


         ------------------------------------------------------------
         BEGIN
            IF ( v_OperationFlag NOT IN ( 16,17,20 )
             ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               IF utils.object_id('TempDB..tt_temp_Fraud1') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_Fraud1 ';
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( SELECT COUNT(1)  
                           FROM Fraud_Details_Mod 
                            WHERE  RefCustomerACID = v_Account_id
                                     AND EffectiveFromTimeKey <= v_TimeKey
                                     AND EffectiveToTimeKey >= v_TimeKey ) = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE FROM tt_temp_Fraud11;
                  UTILS.IDENTITY_RESET('tt_temp_Fraud11');

                  INSERT INTO tt_temp_Fraud11 ( 
                  	SELECT -- A.Account_ID
                  	 AccountEntityId ,
                    CustomerEntityId ,
                    RefCustomerACID ,
                    RefCustomerID ,
                    SourceName ,
                    BranchCode ,
                    BranchName ,
                    AcBuSegmentCode ,
                    AcBuSegmentDescription ,
                    UCIF_ID ,
                    CustomerName ,
                    TOS ,
                    POS ,
                    AssetClassAtFraud ,
                    NPADateAtFraud ,
                    RFA_ReportingByBank ,
                    RFA_DateReportingByBank ,
                    RFA_OtherBankAltKey ,
                    RFA_OtherBankDate ,
                    FraudOccuranceDate ,
                    FraudDeclarationDate ,
                    FraudNature ,
                    FraudArea ,
                    CurrentAssetClassName ,
                    CurrentAssetClassAltKey ,
                    CurrentNPA_Date ,
                    Provisionpreference ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    ApprovedByFirstLevel ,
                    FirstLevelDateApproved ,
                    A.ChangeFields ,
                    A.screenFlag ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.AuthorisationStatus_1 
                  	  FROM ( SELECT B.AccountEntityId ,
                                   B.CustomerEntityId ,
                                   B.CustomerACID RefCustomerACID  ,
                                   B.RefCustomerID ,
                                   SourceName ,
                                   E.BranchCode ,
                                   E.BranchName ,
                                   F.AcBuSegmentCode ,
                                   F.AcBuSegmentDescription ,
                                   UCIF_ID ,
                                   CustomerName ,
                                   Balance TOS  ,
                                   PrincipalBalance POS  ,
                                   (CASE 
                                         WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                   ELSE R.AssetClassName
                                      END) AssetClassAtFraud  ,
                                   UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) NPADateAtFraud  ,
                                   RFA_ReportingByBank ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                      END) RFA_DateReportingByBank  ,
                                   RFA_OtherBankAltKey ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                      END) RFA_OtherBankDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                      END) FraudOccuranceDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                      END) FraudDeclarationDate  ,
                                   FraudNature ,
                                   FraudArea ,
                                   L.AssetClassName CurrentAssetClassName  ,
                                   H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                   UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                   ProvPref Provisionpreference  ,
                                   (CASE 
                                         WHEN A.AuthorisationStatus IS NOT NULL THEN A.AuthorisationStatus
                                   ELSE NULL
                                      END) AuthorisationStatus  ,
                                   B.EffectiveFromTimeKey ,
                                   B.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated DateCreated  ,
                                   A.ModifiedBy ,
                                   A.DateModified DateModified  ,
                                   A.ApprovedBy ,
                                   A.DateApproved DateApproved  ,
                                   FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                   FirstLevelDateApproved ,
                                   A.FraudAccounts_ChangeFields ChangeFields  ,
                                   A.screenFlag ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                   CASE 
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  

                            --               FROM Fraud_AWO A

                            --WHERE A.EffectiveFromTimeKey <= @TimeKey

                            --               AND A.EffectiveToTimeKey >= @TimeKey

                            --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            FROM Fraud_Details_Mod A
                                   RIGHT JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                   AND F.EffectiveFromTimeKey <= v_TimeKey
                                   AND F.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                   AND G.EffectiveFromTimeKey <= v_TimeKey
                                   AND G.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                   AND I.EffectiveToTimeKey = 49999
                                   LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                   AND L.EffectiveToTimeKey = 49999
                                   LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                   LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                   AND R.EffectiveToTimeKey = 49999
                             WHERE  B.CustomerACID = v_Account_id
                                      AND B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey ) 
                          -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                          --AND ISNULL(B.AuthorisationStatus, 'A') IN  ('NP', 'MP', 'DP', 'RM','1A')

                          --      AND A.EntityKey IN

                          --(

                          --    SELECT MAX(EntityKey)

                          --    FROM Fraud_AWO_Mod

                          --    WHERE EffectiveFromTimeKey <= @TimeKey

                          --          AND EffectiveToTimeKey >= @TimeKey

                          --          AND ISNULL(AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP','D1', 'RM','1A')

                          --    GROUP BY Account_ID

                          --)
                          A
                  	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'Fraud' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp_Fraud11 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY DataPointOwner.DateCreated DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE

               BEGIN
                  DELETE FROM tt_temp_Fraud1;
                  UTILS.IDENTITY_RESET('tt_temp_Fraud1');

                  INSERT INTO tt_temp_Fraud1 ( 
                  	SELECT -- A.Account_ID
                  	 AccountEntityId ,
                    CustomerEntityId ,
                    RefCustomerACID ,
                    RefCustomerID ,
                    SourceName ,
                    BranchCode ,
                    BranchName ,
                    AcBuSegmentCode ,
                    AcBuSegmentDescription ,
                    UCIF_ID ,
                    CustomerName ,
                    TOS ,
                    POS ,
                    AssetClassAtFraud ,
                    NPADateAtFraud ,
                    RFA_ReportingByBank ,
                    RFA_DateReportingByBank ,
                    RFA_OtherBankAltKey ,
                    RFA_OtherBankDate ,
                    FraudOccuranceDate ,
                    FraudDeclarationDate ,
                    FraudNature ,
                    FraudArea ,
                    CurrentAssetClassName ,
                    CurrentAssetClassAltKey ,
                    CurrentNPA_Date ,
                    Provisionpreference ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    ApprovedByFirstLevel ,
                    FirstLevelDateApproved ,
                    A.ChangeFields ,
                    A.screenFlag ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.AuthorisationStatus_1 
                  	  FROM ( SELECT --A.Account_ID
                             B.AccountEntityId ,
                             B.CustomerEntityId ,
                             B.CustomerACID RefCustomerACID  ,
                             B.RefCustomerID ,
                             SourceName ,
                             E.BranchCode ,
                             E.BranchName ,
                             F.AcBuSegmentCode ,
                             F.AcBuSegmentDescription ,
                             UCIF_ID ,
                             CustomerName ,
                             Balance TOS  ,
                             PrincipalBalance POS  ,
                             (CASE 
                                   WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                             ELSE R.AssetClassName
                                END) AssetClassAtFraud  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                END) NPADateAtFraud  ,
                             RFA_ReportingByBank ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                END) RFA_DateReportingByBank  ,
                             RFA_OtherBankAltKey ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                END) RFA_OtherBankDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                END) FraudOccuranceDate  ,
                             (CASE 
                                   WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                             ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                END) FraudDeclarationDate  ,
                             FraudNature ,
                             FraudArea ,
                             L.AssetClassName CurrentAssetClassName  ,
                             H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                             UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                             ProvPref Provisionpreference  ,
                             (CASE 
                                   WHEN A.AuthorisationStatus IS NOT NULL THEN A.AuthorisationStatus
                             ELSE NULL
                                END) AuthorisationStatus  ,
                             B.EffectiveFromTimeKey ,
                             B.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated DateCreated  ,
                             A.ModifiedBy ,
                             A.DateModified DateModified  ,
                             A.ApprovedBy ,
                             A.DateApproved DateApproved  ,
                             FirstLevelApprovedBy ApprovedByFirstLevel  ,
                             FirstLevelDateApproved ,
                             NULL ChangeFields  ,
                             A.screenFlag ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                             CASE 
                                  WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                  WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus_1  
                            FROM Fraud_Details A
                                   JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                   AND F.EffectiveFromTimeKey <= v_TimeKey
                                   AND F.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                   AND G.EffectiveFromTimeKey <= v_TimeKey
                                   AND G.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                   AND I.EffectiveToTimeKey = 49999
                                   LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                   AND L.EffectiveToTimeKey = 49999
                                   LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                   LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                   AND R.EffectiveToTimeKey = 49999
                             WHERE  B.CustomerACID = v_Account_id
                                      AND B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT B.AccountEntityId ,
                                   B.CustomerEntityId ,
                                   B.CustomerACID RefCustomerACID  ,
                                   B.RefCustomerID ,
                                   SourceName ,
                                   E.BranchCode ,
                                   E.BranchName ,
                                   F.AcBuSegmentCode ,
                                   F.AcBuSegmentDescription ,
                                   UCIF_ID ,
                                   CustomerName ,
                                   Balance TOS  ,
                                   PrincipalBalance POS  ,
                                   (CASE 
                                         WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                   ELSE R.AssetClassName
                                      END) AssetClassAtFraud  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                      END) NPADateAtFraud  ,
                                   RFA_ReportingByBank ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                      END) RFA_DateReportingByBank  ,
                                   RFA_OtherBankAltKey ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                      END) RFA_OtherBankDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                      END) FraudOccuranceDate  ,
                                   (CASE 
                                         WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                   ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                      END) FraudDeclarationDate  ,
                                   FraudNature ,
                                   FraudArea ,
                                   L.AssetClassName CurrentAssetClassName  ,
                                   H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                   UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                   ProvPref Provisionpreference  ,
                                   (CASE 
                                         WHEN A.AuthorisationStatus IS NOT NULL THEN A.AuthorisationStatus
                                   ELSE NULL
                                      END) AuthorisationStatus  ,
                                   B.EffectiveFromTimeKey ,
                                   B.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated DateCreated  ,
                                   A.ModifiedBy ,
                                   A.DateModified DateModified  ,
                                   A.ApprovedBy ,
                                   A.DateApproved DateApproved  ,
                                   FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                   FirstLevelDateApproved ,
                                   A.FraudAccounts_ChangeFields ChangeFields  ,
                                   A.screenFlag ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                   CASE 
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                        WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  

                            --               FROM Fraud_AWO A

                            --WHERE A.EffectiveFromTimeKey <= @TimeKey

                            --               AND A.EffectiveToTimeKey >= @TimeKey

                            --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            FROM Fraud_Details_Mod A
                                   RIGHT JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                   AND F.EffectiveFromTimeKey <= v_TimeKey
                                   AND F.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                   AND G.EffectiveFromTimeKey <= v_TimeKey
                                   AND G.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                   AND I.EffectiveToTimeKey = 49999
                                   LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                   AND L.EffectiveToTimeKey = 49999
                                   LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                   LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                   AND R.EffectiveToTimeKey = 49999
                             WHERE  B.CustomerACID = v_Account_id
                                      AND B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey

                                      -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM Fraud_Details_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'Fraud' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp_Fraud1 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY DataPointOwner.DateCreated DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;

            END;
            END IF;
            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
            --      AND RowNumber <= (@PageNo * @PageSize);
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp16_1111') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp161_8 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant4');
               DELETE FROM tt_temp161_8;
               UTILS.IDENTITY_RESET('tt_temp161_8');

               INSERT INTO tt_temp161_8 ( 
               	SELECT AccountEntityId ,
                       CustomerEntityId ,
                       RefCustomerACID ,
                       RefCustomerID ,
                       SourceName ,
                       BranchCode ,
                       BranchName ,
                       AcBuSegmentCode ,
                       AcBuSegmentDescription ,
                       UCIF_ID ,
                       CustomerName ,
                       TOS ,
                       POS ,
                       AssetClassAtFraud ,
                       NPADateAtFraud ,
                       RFA_ReportingByBank ,
                       RFA_DateReportingByBank ,
                       RFA_OtherBankAltKey ,
                       RFA_OtherBankDate ,
                       FraudOccuranceDate ,
                       FraudDeclarationDate ,
                       FraudNature ,
                       FraudArea ,
                       CurrentAssetClassName ,
                       CurrentAssetClassAltKey ,
                       CurrentNPA_Date ,
                       Provisionpreference ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       ApprovedByFirstLevel ,
                       FirstLevelDateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.AuthorisationStatus_1 
               	  FROM ( SELECT B.AccountEntityId ,
                                B.CustomerEntityId ,
                                B.CustomerACID RefCustomerACID  ,
                                B.RefCustomerID ,
                                SourceName ,
                                E.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                UCIF_ID ,
                                CustomerName ,
                                Balance TOS  ,
                                PrincipalBalance POS  ,
                                (CASE 
                                      WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                ELSE R.AssetClassName
                                   END) AssetClassAtFraud  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                   END) NPADateAtFraud  ,
                                RFA_ReportingByBank ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                   END) RFA_DateReportingByBank  ,
                                RFA_OtherBankAltKey ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                   END) RFA_OtherBankDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                   END) FraudOccuranceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                   END) FraudDeclarationDate  ,
                                FraudNature ,
                                FraudArea ,
                                L.AssetClassName CurrentAssetClassName  ,
                                H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                ProvPref Provisionpreference  ,
                                (CASE 
                                      WHEN A.AuthorisationStatus IS NOT NULL THEN A.AuthorisationStatus
                                ELSE NULL
                                   END) AuthorisationStatus  ,
                                B.EffectiveFromTimeKey ,
                                B.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated DateCreated  ,
                                A.ModifiedBy ,
                                A.DateModified DateModified  ,
                                A.ApprovedBy ,
                                A.DateApproved DateApproved  ,
                                FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                FirstLevelDateApproved ,
                                A.FraudAccounts_ChangeFields ChangeFields  ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  

                         --               FROM Fraud_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM Fraud_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.CustomerACID = v_Account_id
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM Fraud_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Fraud' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp161_8 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
            --      AND RowNumber <= (@PageNo * @PageSize)
            IF ( v_OperationFlag = 20 ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp20_761') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp201_8 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant5');
               DELETE FROM tt_temp201_8;
               UTILS.IDENTITY_RESET('tt_temp201_8');

               INSERT INTO tt_temp201_8 ( 
               	SELECT AccountEntityId ,
                       CustomerEntityId ,
                       RefCustomerACID ,
                       RefCustomerID ,
                       SourceName ,
                       BranchCode ,
                       BranchName ,
                       AcBuSegmentCode ,
                       AcBuSegmentDescription ,
                       UCIF_ID ,
                       CustomerName ,
                       TOS ,
                       POS ,
                       AssetClassAtFraud ,
                       NPADateAtFraud ,
                       RFA_ReportingByBank ,
                       RFA_DateReportingByBank ,
                       RFA_OtherBankAltKey ,
                       RFA_OtherBankDate ,
                       FraudOccuranceDate ,
                       FraudDeclarationDate ,
                       FraudNature ,
                       FraudArea ,
                       CurrentAssetClassName ,
                       CurrentAssetClassAltKey ,
                       CurrentNPA_Date ,
                       Provisionpreference ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       ApprovedByFirstLevel ,
                       FirstLevelDateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.AuthorisationStatus_1 
               	  FROM ( SELECT B.AccountEntityId ,
                                B.CustomerEntityId ,
                                B.CustomerACID RefCustomerACID  ,
                                B.RefCustomerID ,
                                SourceName ,
                                E.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                UCIF_ID ,
                                CustomerName ,
                                Balance TOS  ,
                                PrincipalBalance POS  ,
                                (CASE 
                                      WHEN R.AssetClassName IS NULL THEN 'STANDARD'
                                ELSE R.AssetClassName
                                   END) AssetClassAtFraud  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_DateAtFraud,200)
                                   END) NPADateAtFraud  ,
                                RFA_ReportingByBank ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_DateReportingByBank,200)
                                   END) RFA_DateReportingByBank  ,
                                RFA_OtherBankAltKey ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(RFA_OtherBankDate,200)
                                   END) RFA_OtherBankDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudOccuranceDate,200)
                                   END) FraudOccuranceDate  ,
                                (CASE 
                                      WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200) = '01/01/1900' THEN ' '
                                ELSE UTILS.CONVERT_TO_VARCHAR2(FraudDeclarationDate,200)
                                   END) FraudDeclarationDate  ,
                                FraudNature ,
                                FraudArea ,
                                L.AssetClassName CurrentAssetClassName  ,
                                H.Cust_AssetClassAlt_Key CurrentAssetClassAltKey  ,
                                UTILS.CONVERT_TO_VARCHAR2(H.NPADt,200) CurrentNPA_Date  ,
                                ProvPref Provisionpreference  ,
                                (CASE 
                                      WHEN A.AuthorisationStatus IS NOT NULL THEN A.AuthorisationStatus
                                ELSE NULL
                                   END) AuthorisationStatus  ,
                                B.EffectiveFromTimeKey ,
                                B.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated DateCreated  ,
                                A.ModifiedBy ,
                                A.DateModified DateModified  ,
                                A.ApprovedBy ,
                                A.DateApproved DateApproved  ,
                                FirstLevelApprovedBy ApprovedByFirstLevel  ,
                                FirstLevelDateApproved ,
                                A.FraudAccounts_ChangeFields ChangeFields  ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'DP' THEN 'Delete Pending'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'A') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  

                         --               FROM Fraud_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM Fraud_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerACID = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                JOIN AdvAcBalanceDetail J   ON B.AccountEntityId = J.AccountEntityId
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN CustomerBasicDetail D   ON D.CustomerId = B.RefCustomerId
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimBranch E   ON B.BranchCode = E.BranchCode
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAcBuSegment F   ON B.segmentcode = F.AcBuSegmentCode
                                AND F.EffectiveFromTimeKey <= v_TimeKey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimProduct G   ON B.ProductAlt_Key = G.ProductAlt_Key
                                AND G.EffectiveFromTimeKey <= v_TimeKey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN AdvCustNPADetail H   ON D.CustomerEntityId = H.CustomerEntityId
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimAssetClass I   ON A.AssetClassAtFraudAltKey = I.AssetClassAlt_Key
                                AND I.EffectiveToTimeKey = 49999
                                LEFT JOIN DimAssetClass L   ON H.Cust_AssetClassAlt_Key = L.AssetClassAlt_Key
                                AND L.EffectiveToTimeKey = 49999
                                LEFT JOIN tt_CustNPADetail Q   ON Q.RefCustomerID = D.CustomerId
                                LEFT JOIN DimAssetClass R   ON Q.Cust_AssetClassAlt_Key = R.AssetClassAlt_Key
                                AND R.EffectiveToTimeKey = 49999
                          WHERE  B.CustomerACID = v_Account_id
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM Fraud_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey

                                                                  --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                                                                  AND (CASE 
                                                                            WHEN v_AuthLevel = 2
                                                                              AND NVL(AuthorisationStatus, 'A') IN ( '1A','D1' )
                                                                             THEN 1
                                                                            WHEN v_AuthLevel = 1
                                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                                                                             THEN 1
                                                                ELSE 0
                                                                   END) = 1
                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY AccountEntityId,CustomerEntityId,RefCustomerACID,RefCustomerID,SourceName,BranchCode,BranchName,AcBuSegmentCode,AcBuSegmentDescription,UCIF_ID,CustomerName,TOS,POS,AssetClassAtFraud,NPADateAtFraud,RFA_ReportingByBank,RFA_DateReportingByBank,RFA_OtherBankAltKey,RFA_OtherBankDate,FraudOccuranceDate,FraudDeclarationDate,FraudNature,FraudArea,CurrentAssetClassName,CurrentAssetClassAltKey,CurrentNPA_Date,Provisionpreference,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,ApprovedByFirstLevel,FirstLevelDateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.AuthorisationStatus_1 );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RefCustomerACID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Fraud' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp201_8 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_QUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
