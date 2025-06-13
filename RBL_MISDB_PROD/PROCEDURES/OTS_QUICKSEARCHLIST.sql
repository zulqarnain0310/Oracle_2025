--------------------------------------------------------
--  DDL for Procedure OTS_QUICKSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 16 ,
  v_MenuID IN NUMBER DEFAULT 14553 ,
  v_Account_id IN VARCHAR2 DEFAULT ' ' ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
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
               IF utils.object_id('TempDB..tt_temp_OTS') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_OTS ';
               END IF;
               DELETE FROM tt_temp_OTS;
               UTILS.IDENTITY_RESET('tt_temp_OTS');

               INSERT INTO tt_temp_OTS ( 
               	SELECT -- A.Account_ID
               	 A.Account_ID ,
                 A.Customer_ID ,
                 A.CustomerName ,
                 A.UCIC_ID ,
                 A.SourceName ,
                 A.BranchCode ,
                 A.BranchName ,
                 A.AcBuSegmentCode ,
                 A.AcBuSegmentDescription ,
                 A.Scheme_code ,
                 A.SchemeType ,
                 A.SchemeDescription ,
                 A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                 A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                 A.SACTION_DATE ,
                 A.Date_Approval_Settlement ,
                 A.Approving_Authority ,
                 A.Principal_OS ,
                 A.Interest_Due_time_Settlement ,
                 A.Fees_Charges_Settlement ,
                 A.Total_Dues_Settlement ,
                 A.Settlement_Amount ,
                 A.AmtSacrificePOS ,
                 A.AmtWaiverIOS ,
                 A.AmtWaiverChgOS ,
                 A.TotalAmtSacrifice ,
                 A.SettlementFailed ,
                 A.Actual_Write_Off_Amount ,
                 A.Actual_Write_Off_Date ,
                 A.Account_Closure_Date ,
                 A.AccountEntityId ,
                 A.AuthorisationStatus ,
                 A.AuthorisationStatus_1 ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.CreatedBy ,
                 A.DateCreated ,
                 A.ModifiedBy ,
                 A.DateModified ,
                 A.ApprovedBy ,
                 A.DateApproved ,
                 A.ChangeFields ,
                 A.screenFlag ,
                 A.CrModBy ,
                 A.CrModDate ,
                 A.CrAppBy ,
                 A.CrAppDate ,
                 A.ModAppBy ,
                 A.ModAppDate 
               	  FROM ( SELECT --A.Account_ID
                          B.CustomerACID Account_ID  ,
                          B.RefCustomerId Customer_ID  ,
                          D.CustomerName ,
                          D.UCIF_ID UCIC_ID  ,
                          C.SourceName ,
                          B.BranchCode ,
                          E.BranchName ,
                          F.AcBuSegmentCode ,
                          F.AcBuSegmentDescription ,
                          G.ProductCode Scheme_code  ,
                          G.SchemeType ,
                          G.ProductName SchemeDescription  ,
                          H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                          NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                          B.DtofFirstDisb SACTION_DATE  ,
                          A.Date_Approval_Settlement ,
                          A.Approving_Authority ,
                          NVL(A.Principal_OS, 0) Principal_OS  ,
                          NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                          NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                          NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                          NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                          NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                          NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                          NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                          NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                          CASE 
                               WHEN A.SettlementFailed = 'Y' THEN 20
                          ELSE 10
                             END SettlementFailed  ,
                          j.Amount Actual_Write_Off_Amount  ,
                          j.StatusDate Actual_Write_Off_Date  ,
                          A.Account_Closure_Date ,
                          A.AccountEntityId ,
                          NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                          CASE 
                               WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                               WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                               WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                               WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                               WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                THEN 'Pending'
                          ELSE NULL
                             END AuthorisationStatus_1  ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          NULL ChangeFields  ,
                          A.screenFlag ,
                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                          NVL(A.DateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') = 'A'
                         UNION 
                         SELECT B.CustomerACID Account_ID  ,
                                B.RefCustomerId Customer_ID  ,
                                D.CustomerName ,
                                D.UCIF_ID UCIC_ID  ,
                                C.SourceName ,
                                B.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                G.ProductCode Scheme_code  ,
                                G.SchemeType ,
                                G.ProductName SchemeDescription  ,
                                H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                B.DtofFirstDisb SACTION_DATE  ,
                                A.Date_Approval_Settlement ,
                                A.Approving_Authority ,
                                --,A.Principal_OS
                                --,A.Interest_Due_time_Settlement
                                --,A.Fees_Charges_Settlement
                                --,A.Total_Dues_Settlement
                                --,A.Settlement_Amount
                                --,A.AmtSacrificePOS
                                --,A.AmtWaiverIOS
                                --,A.AmtWaiverChgOS
                                --,A.TotalAmtSacrifice
                                NVL(A.Principal_OS, 0) Principal_OS  ,
                                NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                CASE 
                                     WHEN A.SettlementFailed = 'Y' THEN 20
                                ELSE 10
                                   END SettlementFailed  ,
                                J.Amount Actual_Write_Off_Amount  ,
                                J.StatusDate Actual_Write_Off_Date  ,
                                A.Account_Closure_Date ,
                                A.AccountEntityId ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ChangeFields ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM OTS_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                          GROUP BY RefCustomerAcid )
                        ) A
               	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'OTS' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp_OTS A ) 
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
               IF utils.object_id('TempDB..tt_temp16_155') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_155 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant1');
               DELETE FROM tt_temp16_155;
               UTILS.IDENTITY_RESET('tt_temp16_155');

               INSERT INTO tt_temp16_155 ( 
               	SELECT A.Account_ID ,
                       A.Customer_ID ,
                       A.CustomerName ,
                       A.UCIC_ID ,
                       A.SourceName ,
                       A.BranchCode ,
                       A.BranchName ,
                       A.AcBuSegmentCode ,
                       A.AcBuSegmentDescription ,
                       A.Scheme_code ,
                       A.SchemeType ,
                       A.SchemeDescription ,
                       A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                       A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                       A.SACTION_DATE ,
                       A.Date_Approval_Settlement ,
                       A.Approving_Authority ,
                       A.Principal_OS ,
                       A.Interest_Due_time_Settlement ,
                       A.Fees_Charges_Settlement ,
                       A.Total_Dues_Settlement ,
                       A.Settlement_Amount ,
                       A.AmtSacrificePOS ,
                       A.AmtWaiverIOS ,
                       A.AmtWaiverChgOS ,
                       A.TotalAmtSacrifice ,
                       A.SettlementFailed ,
                       A.Actual_Write_Off_Amount ,
                       A.Actual_Write_Off_Date ,
                       A.Account_Closure_Date ,
                       A.AccountEntityId ,
                       A.AuthorisationStatus ,
                       A.AuthorisationStatus_1 ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT B.CustomerACID Account_ID  ,
                                B.RefCustomerId Customer_ID  ,
                                D.CustomerName ,
                                D.UCIF_ID UCIC_ID  ,
                                C.SourceName ,
                                B.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                G.ProductCode Scheme_code  ,
                                G.SchemeType ,
                                G.ProductName SchemeDescription  ,
                                H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                B.DtofFirstDisb SACTION_DATE  ,
                                A.Date_Approval_Settlement ,
                                A.Approving_Authority ,
                                --,A.Principal_OS
                                --,A.Interest_Due_time_Settlement
                                --,A.Fees_Charges_Settlement
                                --,A.Total_Dues_Settlement
                                --,A.Settlement_Amount
                                --,A.AmtSacrificePOS
                                --,A.AmtWaiverIOS
                                --,A.AmtWaiverChgOS
                                --,A.TotalAmtSacrifice
                                NVL(A.Principal_OS, 0) Principal_OS  ,
                                NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                CASE 
                                     WHEN A.SettlementFailed = 'Y' THEN 20
                                ELSE 10
                                   END SettlementFailed  ,
                                J.Amount Actual_Write_Off_Amount  ,
                                J.StatusDate Actual_Write_Off_Date  ,
                                A.Account_Closure_Date ,
                                A.AccountEntityId ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ChangeFields ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM OTS_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                          GROUP BY RefCustomerAcid )
                        ) A
               	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'OTS' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_155 A ) 
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
               IF utils.object_id('TempDB..tt_temp20_120') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_120 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant2');
               DELETE FROM tt_temp20_120;
               UTILS.IDENTITY_RESET('tt_temp20_120');

               INSERT INTO tt_temp20_120 ( 
               	SELECT A.Account_ID ,
                       A.Customer_ID ,
                       A.CustomerName ,
                       A.UCIC_ID ,
                       A.SourceName ,
                       A.BranchCode ,
                       A.BranchName ,
                       A.AcBuSegmentCode ,
                       A.AcBuSegmentDescription ,
                       A.Scheme_code ,
                       A.SchemeType ,
                       A.SchemeDescription ,
                       A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                       A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                       A.SACTION_DATE ,
                       A.Date_Approval_Settlement ,
                       A.Approving_Authority ,
                       A.Principal_OS ,
                       A.Interest_Due_time_Settlement ,
                       A.Fees_Charges_Settlement ,
                       A.Total_Dues_Settlement ,
                       A.Settlement_Amount ,
                       A.AmtSacrificePOS ,
                       A.AmtWaiverIOS ,
                       A.AmtWaiverChgOS ,
                       A.TotalAmtSacrifice ,
                       A.SettlementFailed ,
                       A.Actual_Write_Off_Amount ,
                       A.Actual_Write_Off_Date ,
                       A.Account_Closure_Date ,
                       A.AccountEntityId ,
                       A.AuthorisationStatus ,
                       A.AuthorisationStatus_1 ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT B.CustomerACID Account_ID  ,
                                B.RefCustomerId Customer_ID  ,
                                D.CustomerName ,
                                D.UCIF_ID UCIC_ID  ,
                                C.SourceName ,
                                B.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                G.ProductCode Scheme_code  ,
                                G.SchemeType ,
                                G.ProductName SchemeDescription  ,
                                H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                B.DtofFirstDisb SACTION_DATE  ,
                                A.Date_Approval_Settlement ,
                                A.Approving_Authority ,
                                --,A.Principal_OS
                                --,A.Interest_Due_time_Settlement
                                --,A.Fees_Charges_Settlement
                                --,A.Total_Dues_Settlement
                                --,A.Settlement_Amount
                                --,A.AmtSacrificePOS
                                --,A.AmtWaiverIOS
                                --,A.AmtWaiverChgOS
                                --,A.TotalAmtSacrifice
                                NVL(A.Principal_OS, 0) Principal_OS  ,
                                NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                CASE 
                                     WHEN A.SettlementFailed = 'Y' THEN 20
                                ELSE 10
                                   END SettlementFailed  ,
                                J.Amount Actual_Write_Off_Amount  ,
                                J.StatusDate Actual_Write_Off_Date  ,
                                A.Account_Closure_Date ,
                                A.AccountEntityId ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ChangeFields ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM OTS_Details_Mod 
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
               	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'OTS' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp20_120 A ) 
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
               DBMS_OUTPUT.PUT_LINE('A');
               IF utils.object_id('TempDB..tt_temp_OTS8') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_OTS8 ';
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( SELECT COUNT(1)  
                           FROM OTS_Details_Mod 
                            WHERE  RefCustomerACID = v_Account_id
                                     AND EffectiveFromTimeKey <= v_TimeKey
                                     AND EffectiveToTimeKey >= v_TimeKey ) = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE FROM tt_temp_OTS8;
                  UTILS.IDENTITY_RESET('tt_temp_OTS8');

                  INSERT INTO tt_temp_OTS8 ( 
                  	SELECT A.Account_ID ,
                          A.Customer_ID ,
                          A.CustomerName ,
                          A.UCIC_ID ,
                          A.SourceName ,
                          A.BranchCode ,
                          A.BranchName ,
                          A.AcBuSegmentCode ,
                          A.AcBuSegmentDescription ,
                          A.Scheme_code ,
                          A.SchemeType ,
                          A.SchemeDescription ,
                          A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                          A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                          A.SACTION_DATE ,
                          A.Date_Approval_Settlement ,
                          A.Approving_Authority ,
                          A.Principal_OS ,
                          A.Interest_Due_time_Settlement ,
                          A.Fees_Charges_Settlement ,
                          A.Total_Dues_Settlement ,
                          A.Settlement_Amount ,
                          A.AmtSacrificePOS ,
                          A.AmtWaiverIOS ,
                          A.AmtWaiverChgOS ,
                          A.TotalAmtSacrifice ,
                          A.SettlementFailed ,
                          A.Actual_Write_Off_Amount ,
                          A.Actual_Write_Off_Date ,
                          A.Account_Closure_Date ,
                          A.AccountEntityId ,
                          A.AuthorisationStatus ,
                          A.AuthorisationStatus_1 ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.ChangeFields ,
                          A.screenFlag ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT B.CustomerACID Account_ID  ,
                                   B.RefCustomerId Customer_ID  ,
                                   D.CustomerName ,
                                   D.UCIF_ID UCIC_ID  ,
                                   C.SourceName ,
                                   B.BranchCode ,
                                   E.BranchName ,
                                   F.AcBuSegmentCode ,
                                   F.AcBuSegmentDescription ,
                                   G.ProductCode Scheme_code  ,
                                   G.SchemeType ,
                                   G.ProductName SchemeDescription  ,
                                   H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                   NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                   B.DtofFirstDisb SACTION_DATE  ,
                                   A.Date_Approval_Settlement ,
                                   A.Approving_Authority ,
                                   --,A.Principal_OS
                                   --,A.Interest_Due_time_Settlement
                                   --,A.Fees_Charges_Settlement
                                   --,A.Total_Dues_Settlement
                                   --,A.Settlement_Amount
                                   --,A.AmtSacrificePOS
                                   --,A.AmtWaiverIOS
                                   --,A.AmtWaiverChgOS
                                   --,A.TotalAmtSacrifice
                                   NVL(A.Principal_OS, 0) Principal_OS  ,
                                   NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                   NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                   NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                   NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                   NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                   NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                   NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                   NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                   CASE 
                                        WHEN A.SettlementFailed = 'Y' THEN 20
                                   ELSE 10
                                      END SettlementFailed  ,
                                   J.Amount Actual_Write_Off_Amount  ,
                                   J.StatusDate Actual_Write_Off_Date  ,
                                   A.Account_Closure_Date ,
                                   A.AccountEntityId ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   CASE 
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ChangeFields ,
                                   A.screenFlag ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                            --               FROM OTS_AWO A

                            --WHERE A.EffectiveFromTimeKey <= @TimeKey

                            --               AND A.EffectiveToTimeKey >= @TimeKey

                            --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            FROM OTS_Details_Mod A
                                   RIGHT JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
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
                                   LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                             WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey
                                      AND B.CustomerACID = v_Account_id ) 
                          -- AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')

                          --                  AND A.EntityKey IN

                          --            (

                          --                SELECT MAX(EntityKey)

                          --                FROM OTS_AWO_Mod

                          --                WHERE EffectiveFromTimeKey <= @TimeKey

                          --                      AND EffectiveToTimeKey >= @TimeKey

                          --                      --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')

                          --  AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A','D1')

                          --	THEN 1 

                          --         when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')

                          --	THEN 1

                          --	ELSE 0									

                          --	END

                          --)=1

                          --                GROUP BY EntityKey

                          --            )
                          A
                  	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'OTS' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp_OTS8 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY DataPointOwner.DateCreated DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Prashant3');
                  DELETE FROM tt_temp_OTS1;
                  UTILS.IDENTITY_RESET('tt_temp_OTS1');

                  INSERT INTO tt_temp_OTS1 ( 
                  	SELECT -- A.Account_ID
                  	 A.Account_ID ,
                    A.Customer_ID ,
                    A.CustomerName ,
                    A.UCIC_ID ,
                    A.SourceName ,
                    A.BranchCode ,
                    A.BranchName ,
                    A.AcBuSegmentCode ,
                    A.AcBuSegmentDescription ,
                    A.Scheme_code ,
                    A.SchemeType ,
                    A.SchemeDescription ,
                    A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                    A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                    A.SACTION_DATE ,
                    A.Date_Approval_Settlement ,
                    A.Approving_Authority ,
                    A.Principal_OS ,
                    A.Interest_Due_time_Settlement ,
                    A.Fees_Charges_Settlement ,
                    A.Total_Dues_Settlement ,
                    A.Settlement_Amount ,
                    A.AmtSacrificePOS ,
                    A.AmtWaiverIOS ,
                    A.AmtWaiverChgOS ,
                    A.TotalAmtSacrifice ,
                    A.SettlementFailed ,
                    A.Actual_Write_Off_Amount ,
                    A.Actual_Write_Off_Date ,
                    A.Account_Closure_Date ,
                    A.AccountEntityId ,
                    A.AuthorisationStatus ,
                    A.AuthorisationStatus_1 ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ChangeFields ,
                    A.screenFlag ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
                  	  FROM ( SELECT --A.Account_ID
                             B.CustomerACID Account_ID  ,
                             B.RefCustomerId Customer_ID  ,
                             D.CustomerName ,
                             D.UCIF_ID UCIC_ID  ,
                             C.SourceName ,
                             B.BranchCode ,
                             E.BranchName ,
                             F.AcBuSegmentCode ,
                             F.AcBuSegmentDescription ,
                             G.ProductCode Scheme_code  ,
                             G.SchemeType ,
                             G.ProductName SchemeDescription  ,
                             H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                             NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                             B.DtofFirstDisb SACTION_DATE  ,
                             A.Date_Approval_Settlement ,
                             A.Approving_Authority ,
                             --,A.Principal_OS
                             --,A.Interest_Due_time_Settlement
                             --,A.Fees_Charges_Settlement
                             --,A.Total_Dues_Settlement
                             --,A.Settlement_Amount
                             --,A.AmtSacrificePOS
                             --,A.AmtWaiverIOS
                             --,A.AmtWaiverChgOS
                             --,A.TotalAmtSacrifice
                             NVL(A.Principal_OS, 0) Principal_OS  ,
                             NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                             NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                             NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                             NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                             NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                             NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                             NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                             NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                             CASE 
                                  WHEN A.SettlementFailed = 'Y' THEN 20
                             ELSE 10
                                END SettlementFailed  ,
                             J.Amount Actual_Write_Off_Amount  ,
                             J.StatusDate Actual_Write_Off_Date  ,
                             A.Account_Closure_Date ,
                             A.AccountEntityId ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             CASE 
                                  WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                  WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                  WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                  WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus_1  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             NULL ChangeFields  ,
                             A.screenFlag ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  

                            --               FROM OTS_AWO A

                            --WHERE A.EffectiveFromTimeKey <= @TimeKey

                            --               AND A.EffectiveToTimeKey >= @TimeKey

                            --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            FROM OTS_Details A
                                   JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
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
                                   LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                             WHERE  B.CustomerACID = v_Account_id
                                      AND B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT B.CustomerACID Account_ID  ,
                                   B.RefCustomerId Customer_ID  ,
                                   D.CustomerName ,
                                   D.UCIF_ID UCIC_ID  ,
                                   C.SourceName ,
                                   B.BranchCode ,
                                   E.BranchName ,
                                   F.AcBuSegmentCode ,
                                   F.AcBuSegmentDescription ,
                                   G.ProductCode Scheme_code  ,
                                   G.SchemeType ,
                                   G.ProductName SchemeDescription  ,
                                   H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                   NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                   B.DtofFirstDisb SACTION_DATE  ,
                                   A.Date_Approval_Settlement ,
                                   A.Approving_Authority ,
                                   --,A.Principal_OS
                                   --,A.Interest_Due_time_Settlement
                                   --,A.Fees_Charges_Settlement
                                   --,A.Total_Dues_Settlement
                                   --,A.Settlement_Amount
                                   --,A.AmtSacrificePOS
                                   --,A.AmtWaiverIOS
                                   --,A.AmtWaiverChgOS
                                   --,A.TotalAmtSacrifice
                                   NVL(A.Principal_OS, 0) Principal_OS  ,
                                   NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                   NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                   NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                   NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                   NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                   NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                   NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                   NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                   CASE 
                                        WHEN A.SettlementFailed = 'Y' THEN 20
                                   ELSE 10
                                      END SettlementFailed  ,
                                   J.Amount Actual_Write_Off_Amount  ,
                                   J.StatusDate Actual_Write_Off_Date  ,
                                   A.Account_Closure_Date ,
                                   A.AccountEntityId ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   CASE 
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                        WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ChangeFields ,
                                   A.screenFlag ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                            --               FROM OTS_AWO A

                            --WHERE A.EffectiveFromTimeKey <= @TimeKey

                            --               AND A.EffectiveToTimeKey >= @TimeKey

                            --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                            FROM OTS_Details_Mod A
                                   RIGHT JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
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
                                   LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                   AND J.EffectiveFromTimeKey <= v_TimeKey
                                   AND J.EffectiveToTimeKey >= v_TimeKey
                                   AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                             WHERE  B.CustomerACID = v_Account_id
                                      AND B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey

                                      -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM OTS_Details_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','D1','RM','1A' )

                                                             GROUP BY RefCustomerAcid )
                           ) A
                  	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'OTS' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp_OTS1 A ) 
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
               IF utils.object_id('TempDB..tt_temp16_1551') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp161_9 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant4');
               DELETE FROM tt_temp161_9;
               UTILS.IDENTITY_RESET('tt_temp161_9');

               INSERT INTO tt_temp161_9 ( 
               	SELECT A.Account_ID ,
                       A.Customer_ID ,
                       A.CustomerName ,
                       A.UCIC_ID ,
                       A.SourceName ,
                       A.BranchCode ,
                       A.BranchName ,
                       A.AcBuSegmentCode ,
                       A.AcBuSegmentDescription ,
                       A.Scheme_code ,
                       A.SchemeType ,
                       A.SchemeDescription ,
                       A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                       A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                       A.SACTION_DATE ,
                       A.Date_Approval_Settlement ,
                       A.Approving_Authority ,
                       A.Principal_OS ,
                       A.Interest_Due_time_Settlement ,
                       A.Fees_Charges_Settlement ,
                       A.Total_Dues_Settlement ,
                       A.Settlement_Amount ,
                       A.AmtSacrificePOS ,
                       A.AmtWaiverIOS ,
                       A.AmtWaiverChgOS ,
                       A.TotalAmtSacrifice ,
                       A.SettlementFailed ,
                       A.Actual_Write_Off_Amount ,
                       A.Actual_Write_Off_Date ,
                       A.Account_Closure_Date ,
                       A.AccountEntityId ,
                       A.AuthorisationStatus ,
                       A.AuthorisationStatus_1 ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT B.CustomerACID Account_ID  ,
                                B.RefCustomerId Customer_ID  ,
                                D.CustomerName ,
                                D.UCIF_ID UCIC_ID  ,
                                C.SourceName ,
                                B.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                G.ProductCode Scheme_code  ,
                                G.SchemeType ,
                                G.ProductName SchemeDescription  ,
                                H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                B.DtofFirstDisb SACTION_DATE  ,
                                A.Date_Approval_Settlement ,
                                A.Approving_Authority ,
                                --,A.Principal_OS
                                --,A.Interest_Due_time_Settlement
                                --,A.Fees_Charges_Settlement
                                --,A.Total_Dues_Settlement
                                --,A.Settlement_Amount
                                --,A.AmtSacrificePOS
                                --,A.AmtWaiverIOS
                                --,A.AmtWaiverChgOS
                                --,A.TotalAmtSacrifice
                                NVL(A.Principal_OS, 0) Principal_OS  ,
                                NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                CASE 
                                     WHEN A.SettlementFailed = 'Y' THEN 20
                                ELSE 10
                                   END SettlementFailed  ,
                                J.Amount Actual_Write_Off_Amount  ,
                                J.StatusDate Actual_Write_Off_Date  ,
                                A.Account_Closure_Date ,
                                A.AccountEntityId ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ChangeFields ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.CustomerACID = v_Account_id
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM OTS_Details_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY RefCustomerAcid )
                        ) A
               	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'OTS' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp161_9 A ) 
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
               IF utils.object_id('TempDB..tt_temp20_1201') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp201_9 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Prashant5');
               DELETE FROM tt_temp201_9;
               UTILS.IDENTITY_RESET('tt_temp201_9');

               INSERT INTO tt_temp201_9 ( 
               	SELECT A.Account_ID ,
                       A.Customer_ID ,
                       A.CustomerName ,
                       A.UCIC_ID ,
                       A.SourceName ,
                       A.BranchCode ,
                       A.BranchName ,
                       A.AcBuSegmentCode ,
                       A.AcBuSegmentDescription ,
                       A.Scheme_code ,
                       A.SchemeType ,
                       A.SchemeDescription ,
                       A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT ,
                       A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT ,
                       A.SACTION_DATE ,
                       A.Date_Approval_Settlement ,
                       A.Approving_Authority ,
                       A.Principal_OS ,
                       A.Interest_Due_time_Settlement ,
                       A.Fees_Charges_Settlement ,
                       A.Total_Dues_Settlement ,
                       A.Settlement_Amount ,
                       A.AmtSacrificePOS ,
                       A.AmtWaiverIOS ,
                       A.AmtWaiverChgOS ,
                       A.TotalAmtSacrifice ,
                       A.SettlementFailed ,
                       A.Actual_Write_Off_Amount ,
                       A.Actual_Write_Off_Date ,
                       A.Account_Closure_Date ,
                       A.AccountEntityId ,
                       A.AuthorisationStatus ,
                       A.AuthorisationStatus_1 ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ChangeFields ,
                       A.screenFlag ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT B.CustomerACID Account_ID  ,
                                B.RefCustomerId Customer_ID  ,
                                D.CustomerName ,
                                D.UCIF_ID UCIC_ID  ,
                                C.SourceName ,
                                B.BranchCode ,
                                E.BranchName ,
                                F.AcBuSegmentCode ,
                                F.AcBuSegmentDescription ,
                                G.ProductCode Scheme_code  ,
                                G.SchemeType ,
                                G.ProductName SchemeDescription  ,
                                H.NPADt NPA_DATE_AT_THE_TIME_OF_SETTLEMENT  ,
                                NVL(I.AssetClassName, 'STANDARD') AssetClasS_AT_THE_TIME_OF_SETTLEMENT  ,
                                B.DtofFirstDisb SACTION_DATE  ,
                                A.Date_Approval_Settlement ,
                                A.Approving_Authority ,
                                --,A.Principal_OS
                                --,A.Interest_Due_time_Settlement
                                --,A.Fees_Charges_Settlement
                                --,A.Total_Dues_Settlement
                                --,A.Settlement_Amount
                                --,A.AmtSacrificePOS
                                --,A.AmtWaiverIOS
                                --,A.AmtWaiverChgOS
                                --,A.TotalAmtSacrifice
                                NVL(A.Principal_OS, 0) Principal_OS  ,
                                NVL(A.Interest_Due_time_Settlement, 0) Interest_Due_time_Settlement  ,
                                NVL(A.Fees_Charges_Settlement, 0) Fees_Charges_Settlement  ,
                                NVL(A.Total_Dues_Settlement, 0) Total_Dues_Settlement  ,
                                NVL(A.Settlement_Amount, 0) Settlement_Amount  ,
                                NVL(A.AmtSacrificePOS, 0) AmtSacrificePOS  ,
                                NVL(A.AmtWaiverIOS, 0) AmtWaiverIOS  ,
                                NVL(A.AmtWaiverChgOS, 0) AmtWaiverChgOS  ,
                                NVL(A.TotalAmtSacrifice, 0) TotalAmtSacrifice  ,
                                CASE 
                                     WHEN A.SettlementFailed = 'Y' THEN 20
                                ELSE 10
                                   END SettlementFailed  ,
                                J.Amount Actual_Write_Off_Amount  ,
                                J.StatusDate Actual_Write_Off_Date  ,
                                A.Account_Closure_Date ,
                                A.AccountEntityId ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'A' THEN 'Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'DP' THEN 'Delete'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = 'R' THEN 'Rejected'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') = '1A' THEN '1A Authorized'
                                     WHEN NVL(A.AuthorisationStatus, 'Z') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ChangeFields ,
                                A.screenFlag ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.FirstLevelApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  

                         --               FROM OTS_AWO A

                         --WHERE A.EffectiveFromTimeKey <= @TimeKey

                         --               AND A.EffectiveToTimeKey >= @TimeKey

                         --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                         FROM OTS_Details_Mod A
                                JOIN AdvAcBasicDetail B   ON A.RefCustomerAcid = B.CustomerACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
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
                                LEFT JOIN DimAssetClass I   ON H.Cust_AssetClassAlt_Key = I.AssetClassAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ExceptionFinalStatusType J   ON J.ACID = B.CustomerACID
                                AND J.EffectiveFromTimeKey <= v_TimeKey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND J.StatusType IN ( 'AWO (With OTS)','AWO (Without OTS)' )

                          WHERE  B.CustomerACID = v_Account_id
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM OTS_Details_Mod 
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
               	  GROUP BY A.Account_ID,A.Customer_ID,A.CustomerName,A.UCIC_ID,A.SourceName,A.BranchCode,A.BranchName,A.AcBuSegmentCode,A.AcBuSegmentDescription,A.Scheme_code,A.SchemeType,A.SchemeDescription,A.NPA_DATE_AT_THE_TIME_OF_SETTLEMENT,A.AssetClasS_AT_THE_TIME_OF_SETTLEMENT,A.SACTION_DATE,A.Date_Approval_Settlement,A.Approving_Authority,A.Principal_OS,A.Interest_Due_time_Settlement,A.Fees_Charges_Settlement,A.Total_Dues_Settlement,A.Settlement_Amount,A.AmtSacrificePOS,A.AmtWaiverIOS,A.AmtWaiverChgOS,A.TotalAmtSacrifice,A.SettlementFailed,A.Actual_Write_Off_Amount,A.Actual_Write_Off_Date,A.Account_Closure_Date,A.AccountEntityId,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.ChangeFields,A.screenFlag,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Account_id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'OTS' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp201_9 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_QUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
