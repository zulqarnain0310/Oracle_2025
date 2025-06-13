--------------------------------------------------------
--  DDL for Procedure INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" 
AS
   v_TimeKey NUMBER(10,0);
   v_Mocdate VARCHAR2(200);
   --DROP TABLE #AccountCal_Hist,#CustomerCal_Hist,#AccountLevelMOC_Mod,#CustomerLevelMOC_Mod,#AccountCal,#CustomerCal,#DimAcBuSegment  
   --select * from #DimAcBuSegment 
   v_cursor SYS_REFCURSOR;
--@TimeKey INT =NULL

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_,200) 

     INTO v_Mocdate
     FROM SysDayMatrix 
    WHERE  Timekey = v_TimeKey;
   IF ( utils.object_id('TEMPDB..tt_MOC_DATA_39') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOC_DATA_39 ';
   END IF;
   DELETE FROM tt_MOC_DATA_39;
   UTILS.IDENTITY_RESET('tt_MOC_DATA_39');

   INSERT INTO tt_MOC_DATA_39 ( 
   	SELECT a.CustomerEntityID 
   	  FROM CalypsoInvMOC_ChangeDetails A
             JOIN CustomerBasicDetail CBD   ON A.EffectiveFromTimeKey <= v_TimeKey
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND CBD.EffectivefromTimeKey <= v_TimeKey
             AND CBD.EffectiveToTimeKey >= v_TIMEKEY
             AND CBD.CustomerEntityId = A.CustomerEntityID
   	 WHERE  MOC_Date = v_Mocdate

   	--and cbd.CustomerId='2074381'
   	GROUP BY a.CustomerEntityID );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_UcifEntityID
      ON tt_MOC_DATA_39 ( CustomerEntityId)';
   IF ( utils.object_id('TEMPDB..tt_InvestmentFinancialDetai_3') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_InvestmentFinancialDetai_3 ';
   END IF;
   DELETE FROM tt_InvestmentFinancialDetai_3;
   UTILS.IDENTITY_RESET('tt_InvestmentFinancialDetai_3');

   INSERT INTO tt_InvestmentFinancialDetai_3 ( 
   	SELECT DISTINCT UTILS.CONVERT_TO_NVARCHAR2(v_Mocdate,30,p_style=>105) Process_Date  ,
                    B.BRANCHCODE ,
                    ISSUERID ,
                    ISSUERNAME ,
                    REF_TXN_SYS_CUST_ID ,
                    ISSUER_CATEGORY_CODE ,
                    UCIFID ,
                    PANNO ,
                    INVID ,
                    b.ISIN ,
                    I.InstrumentTypeName ,
                    INSTRNAME ,
                    b.INVESTMENTNATURE ,
                    EXPOSURETYPE ,
                    MATURITYDT ,
                    HOLDINGNATURE ,
                    BOOKTYPE ,
                    BOOKVALUE ,
                    MTMVALUE ,
                    INTEREST_DIVIDENDDUEDATE ,
                    INTEREST_DIVIDENDDUEAMOUNT ,
                    DPD ,
                    FLGDEG ,
                    DEGREASON ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN 'N'
                    ELSE FLGUPG
                       END) FLGUPG  ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN NULL
                    ELSE UPGDATE
                       END) UPGDATE  ,
                    TOTALPROVISON ,
                    AC.AssetClassShortName ASSETCLASS  ,
                    C.PartialRedumptionDueDate ,
                    c.PartialRedumptionSettledY_N ,
                    c.NPIDt ,
                    c.BalanceSheetDate ,
                    c.ListedShares ,
                    c.DPD_BS_Date ,
                    c.BookValueINR ,
                    a.IssuerEntityId ,
                    c.InitialAssetAlt_Key ,
                    c.FinalAssetClassAlt_Key ,
                    c.FlgMoc ,
                    C.MOC_Reason 
   	  FROM InvestmentIssuerDetail a
             JOIN tt_MOC_DATA_39 BB   ON A.IssuerEntityId = BB.CustomerEntityID
             JOIN InvestmentBasicDetail B   ON A.IssuerEntityId = B.IssuerEntityId
             AND a.EffectiveFromTimeKey <= v_TimeKey
             AND a.EffectiveToTimeKey >= v_TimeKey
             AND b.EffectiveFromTimeKey <= v_TimeKey
             AND b.EffectiveToTimeKey >= v_TimeKey
             JOIN InvestmentFinancialDetail c   ON b.InvEntityId = c.InvEntityId
             AND c.EffectiveFromTimeKey <= v_TimeKey
             AND c.EffectiveToTimeKey >= v_TimeKey
             JOIN DimAssetClass AC   ON AC.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey
             AND AC.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
             LEFT JOIN DimInstrumentType I   ON I.EffectiveFromTimeKey <= v_TimeKey
             AND I.EffectiveToTimeKey >= v_TimeKey
             AND B.InstrTypeAlt_Key = I.InstrumentTypeAlt_Key );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID
      ON tt_InvestmentFinancialDetai_3 ( ISSUERID)';
   -------------------------------------------------  
   --IF(OBJECT_ID('TEMPDB..#CustomerCal_HIST')IS NOT NULL)  
   --   DROP TABLE #CustomerCal_HIST  
   --SELECT 
   --A.CustomerEntityID,RefCustomerID ,CustomerName,PANNo,AadharCardNo,CurntQtrRv,MOCReason,DbtDt ,FlgMoc,CustMoveDescription 
   --INTO #CustomerCal_HIST  
   --FROM Pro.CustomerCal_HIST A
   --INNER JOIN tt_MOC_DATA_39 B                        ON A.UcifEntityID=B.UcifEntityID
   --WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  
   --OPTION(RECOMPILE)  
   --CREATE NONCLUSTERED INDEX INX_CustomerEntityID ON #CustomerCal_HIST(CustomerEntityID)  
   --INCLUDE (RefCustomerID)  
   ---------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_CalypsoAccountLevelMOC_M_2') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CalypsoAccountLevelMOC_M_2 ';
   END IF;
   DELETE FROM tt_CalypsoAccountLevelMOC_M_2;
   UTILS.IDENTITY_RESET('tt_CalypsoAccountLevelMOC_M_2');

   INSERT INTO tt_CalypsoAccountLevelMOC_M_2 ( 
   	SELECT A.AccountEntityID ,
           A.AccountID ,
           ChangeField ,
           EffectiveFromTimekey ,
           EffectiveToTimekey ,
           CreatedBy ,
           DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           ApprovedBy ,
           DateApproved 
   	  FROM CalypsoAccountLevelMOC_Mod A
             JOIN ( SELECT AccountEntityID ,
                           AccountID ,
                           MAX(UploadID)  UploadID  
                    FROM CalypsoAccountLevelMOC_Mod 
                     WHERE  EffectiveFromTimeKey <= v_Timekey
                              AND EffectiveToTimeKey >= v_Timekey
                      GROUP BY AccountEntityID,AccountID ) B   ON A.AccountEntityID = B.AccountEntityID
             AND A.UploadId = b.UploadID
   	 WHERE  MOCDate = v_Mocdate
              AND A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_AccountID
      ON tt_CalypsoAccountLevelMOC_M_2 ( AccountID)';
   --select * from #AccountLevelMOC_Mod
   ---------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_CalypsoCustomerLevelMOC__2') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CalypsoCustomerLevelMOC__2 ';
   END IF;
   DELETE FROM tt_CalypsoCustomerLevelMOC__2;
   UTILS.IDENTITY_RESET('tt_CalypsoCustomerLevelMOC__2');

   INSERT INTO tt_CalypsoCustomerLevelMOC__2 ( 
   	SELECT Entity_Key ,
           A.CustomerEntityID ,
           ChangeField ,
           EffectiveFromTimekey ,
           EffectiveToTimekey ,
           CreatedBy ,
           DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           ApprovedBy ,
           DateApproved ,
           AuthorisationStatus 
   	  FROM CalypsoCustomerLevelMOC_Mod A
             JOIN ( SELECT CustomerEntityID ,
                           CustomerID ,
                           MAX(UploadID)  UploadID  
                    FROM CalypsoCustomerLevelMOC_Mod 
                     WHERE  EffectiveFromTimeKey <= v_Timekey
                              AND EffectiveToTimeKey >= v_Timekey
                      GROUP BY CustomerEntityID,CustomerID ) B   ON A.CustomerEntityID = B.CustomerEntityID
             AND A.UploadID = b.UploadID
   	 WHERE  MOCDate = v_Mocdate
              AND ChangeField IS NOT NULL
              AND EffectiveFromTimeKey <= v_Timekey
              AND EffectiveToTimeKey >= v_Timekey );
   --and AuthorisationStatus<>'R'
   --select * from #CustomerLevelMOC_Mod
   --select * from CustomerLevelMOC_Mod where CustomerID='2074381'
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID2
      ON tt_CalypsoCustomerLevelMOC__2 ( CustomerEntityID)';
   IF ( utils.object_id('TEMPDB..tt_InvestmentFinancialDetai_4') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_InvestmentFinancialDetai_4 ';
   END IF;
   DELETE FROM tt_InvestmentFinancialDetai_4;
   UTILS.IDENTITY_RESET('tt_InvestmentFinancialDetai_4');

   INSERT INTO tt_InvestmentFinancialDetai_4 ( 
   	SELECT a.EntityKey ,
           a.InvEntityId ,
           RefInvID ,
           a.HoldingNature ,
           CurrencyAlt_Key ,
           CurrencyConvRate ,
           a.BookType ,
           a.BookValue ,
           a.BookValueINR ,
           a.MTMValue ,
           MTMValueINR ,
           EncumberedMTM ,
           AssetClass_AltKey ,
           a.NPIDt ,
           a.TotalProvison ,
           a.AuthorisationStatus ,
           a.EffectiveFromTimeKey ,
           a.EffectiveToTimeKey ,
           a.CreatedBy ,
           a.DateCreated ,
           a.ModifiedBy ,
           a.DateModified ,
           a.ApprovedBy ,
           a.DateApproved ,
           DBTDate ,
           LatestBSDate ,
           a.Interest_DividendDueDate ,
           a.Interest_DividendDueAmount ,
           a.PartialRedumptionDueDate ,
           a.PartialRedumptionSettledY_N ,
           a.FLGDEG ,
           a.DEGREASON ,
           a.DPD ,
           a.FLGUPG ,
           a.UpgDate ,
           PROVISIONALT_KEY ,
           InitialAssetAlt_Key ,
           InitialNPIDt ,
           a.RefIssuerID ,
           DPD_Maturity ,
           DPD_DivOverdue ,
           FinalAssetClassAlt_Key ,
           PartialRedumptionDPD ,
           Asset_Norm ,
           id.ISIN ,
           a.AssetClass ,
           GL_Code ,
           GL_Description ,
           OVERDUE_AMOUNT ,
           FlgSMA ,
           SMA_Dt ,
           SMA_Class ,
           SMA_Reason ,
           AddlProvision ,
           AddlProvisionPer ,
           MocBy ,
           MOC_Date ,
           FlgMoc ,
           MOC_Reason ,
           b.IssuerEntityId ,
           b.BranchCode ,
           id.ISSUERNAME ,
           id.REF_TXN_SYS_CUST_ID ,
           id.ISSUER_CATEGORY_CODE ,
           id.UCIFID ,
           id.PANNO ,
           id.INSTRUMENTTYPENAME ,
           InstrName ,
           INVESTMENTNATURE ,
           EXPOSURETYPE ,
           MATURITYDT ,
           id.BalanceSheetDate ,
           id.ListedShares ,
           id.DPD_BS_Date 
   	  FROM PreMoc_RBL_MISDB_PROD.InvestmentFinancialDetail a
             LEFT JOIN InvestmentIssuerDetail b   ON a.RefIssuerID = b.IssuerID
             AND b.EffectiveFromTimeKey <= v_TimeKey
             AND b.EffectiveToTimeKey >= v_TimeKey
           --left JOIN InvestmentBasicDetail c
            --		ON b.IssuerEntityId=c.IssuerEntityId
            --		--and a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey
            --		and c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey
            --LEFT JOIN DimInstrumentType I
            --		ON I.EffectiveFromTimeKey<=@TimeKey AND I.EffectiveToTimeKey>=@TimeKey
            --		AND c.InstrTypeAlt_Key=I.InstrumentTypeAlt_Key

             LEFT JOIN INVESTMENT_DATA ID   ON a.RefInvID = id.INVID
             AND UTILS.CONVERT_TO_VARCHAR2(ID.Process_Date,200,p_style=>105) = v_Mocdate
   	 WHERE  a.EffectiveFromTimeKey <= v_TimeKey
              AND a.EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID1
      ON tt_InvestmentFinancialDetai_4 ( RefIssuerID)';
   --------------------------------------------  
   --IF(OBJECT_ID('TEMPDB..#CustomerCal')IS NOT NULL)  
   --   DROP TABLE #CustomerCal  
   --SELECT CustomerEntityID,RefCustomerID ,CustomerName,PANNo,AadharCardNo,CurntQtrRv,MOCReason,DbtDt,FlgMoc,CustMoveDescription     
   --INTO #CustomerCal  
   --FROM PreMoc.CustomerCal  
   --WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  
   --OPTION(RECOMPILE)  
   --CREATE NONCLUSTERED INDEX INX_CustomerEntityID1 ON #CustomerCal(CustomerEntityID)  
   --INCLUDE (RefCustomerID)  
   ------------------------------------------------------  
   --IF(OBJECT_ID('TEMPDB..#DimAcBuSegment')IS NOT NULL)  
   --   DROP TABLE #DimAcBuSegment  
   --SELECT   
   --DENSE_RANK()OVER(PARTITION BY AcBuRevisedSegmentCode ORDER BY AcBuSegmentCode) RN,  
   --AcBuSegmentCode,  
   --AcBuRevisedSegmentCode,  
   --AcBuSegmentDescription   
   --INTO #DimAcBuSegment  
   --FROM DimAcBuSegment  
   --WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  
   --OPTION(RECOMPILE)  
   ---------------------PreMOC_DATA----------------------  
   IF utils.object_id('Tempdb..tt_Final_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_2 ';
   END IF;
   --DECLARE  @TimeKey AS INT=26479
   DELETE FROM tt_Final_2;
   UTILS.IDENTITY_RESET('tt_Final_2');

   INSERT INTO tt_Final_2 SELECT 'Post Moc' Moc_Status  ,
                                 v_Mocdate CurrentProcessingDate  ,
                                 ROW_NUMBER() OVER ( ORDER BY A.IssuerEntityId, A.INVID  ) SrNo  ,
                                 ---------RefColumns---------  
                                 'Calypso' SourceName  ,
                                 A.BRANCHCODE ,
                                 ISSUERID ,
                                 ISSUERNAME ,
                                 REF_TXN_SYS_CUST_ID ,
                                 ISSUER_CATEGORY_CODE ,
                                 UCIFID ,
                                 PANNO ,
                                 INVID ,
                                 A.ISIN ,
                                 A.INSTRUMENTTYPENAME ,
                                 INSTRNAME ,
                                 A.INVESTMENTNATURE ,
                                 EXPOSURETYPE ,
                                 MATURITYDT ,
                                 HOLDINGNATURE ,
                                 BOOKTYPE ,
                                 A.BOOKVALUE ,
                                 MTMVALUE ,
                                 INTEREST_DIVIDENDDUEDATE ,
                                 INTEREST_DIVIDENDDUEAMOUNT ,
                                 DPD ,
                                 FLGDEG ,
                                 DEGREASON ,
                                 A.FLGUPG ,
                                 A.UPGDATE ,
                                 TOTALPROVISON ,
                                 A.ASSETCLASS ,
                                 A.PartialRedumptionDueDate ,
                                 A.PartialRedumptionSettledY_N ,
                                 A.NPIDt ,
                                 A.BalanceSheetDate ,
                                 A.ListedShares ,
                                 A.DPD_BS_Date ,
                                 A.BookValueINR ,
                                 v_Mocdate MOC_Dt  ,
                                 COALESCE(ALM.CreatedBy, CLM.CreatedBy, MOC2.Createdby) MakerID  ,
                                 NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
                                 NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
                                 NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
                                 NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
                                 NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
                                 NVL(A.MOC_Reason, ' ') MOCReason  ,
                                 clm.AuthorisationStatus 
        FROM tt_InvestmentFinancialDetai_3 A
               JOIN tt_CalypsoAccountLevelMOC_M_2 ALM   ON ALM.AccountId = A.InvID
               LEFT JOIN tt_CalypsoCustomerLevelMOC__2 CLM   ON A.IssuerEntityId = CLM.CustomerEntityId
             --INNER JOIN CalypsoInvMOC_ChangeDetails MOC1               ON MOC1.CustomerEntityId=CLM.CustomerEntityId  
              --                                                 AND MOC1.EffectiveFromTimeKey<=@TimeKey  
              --                                                 AND MOC1.EffectiveToTimeKey>=@TimeKey 
              --												 AND MOC1.MOCType_Flag = 'CUST'

               JOIN CalypsoInvMOC_ChangeDetails MOC2   ON MOC2.AccountEntityID = ALM.AccountEntityID
               AND MOC2.EffectiveFromTimeKey <= v_TimeKey
               AND MOC2.EffectiveToTimeKey >= v_TimeKey
               AND MOC2.MOCType_Flag = 'ACCT'
               JOIN DimAssetClass D   ON D.AssetClassAlt_Key = NVL(A.InitialAssetAlt_Key, 1)
               AND D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass E   ON E.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
               AND E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey
       WHERE  ( A.FlgMoc = 'Y' --and invID = '158086'
               )
      UNION 
      --select * from CalypsoCustomerLevelMOC_Mod

      --select * from CalypsoAccountLevelMOC_Mod where AccountId = '158086'
      ALL 
      SELECT 'Pre Moc' Moc_Status  ,
             v_Mocdate CurrentProcessingDate  ,
             ROW_NUMBER() OVER ( ORDER BY A.IssuerEntityId, A.RefInvID  ) SrNo  ,
             ---------RefColumns---------  
             'Calypso' SourceName  ,
             --,CONVERT(VARCHAR(20),A.ContiExcessDt,103)                         AS ContiExcessDt  
             A.BRANCHCODE ,
             A.RefIssuerID IssuerID  ,
             ISSUERNAME ,
             REF_TXN_SYS_CUST_ID ,
             ISSUER_CATEGORY_CODE ,
             UCIFID ,
             PANNO ,
             A.RefInvID InvID  ,
             A.ISIN ,
             A.INSTRUMENTTYPENAME ,
             INSTRNAME ,
             A.INVESTMENTNATURE ,
             EXPOSURETYPE ,
             MATURITYDT ,
             A.HOLDINGNATURE ,
             A.BOOKTYPE ,
             A.BOOKVALUE ,
             A.MTMVALUE ,
             A.INTEREST_DIVIDENDDUEDATE ,
             A.INTEREST_DIVIDENDDUEAMOUNT ,
             A.DPD ,
             A.FLGDEG ,
             A.DEGREASON ,
             A.FLGUPG ,
             A.UPGDATE ,
             A.TOTALPROVISON ,
             E.AssetClassShortName AssetClass  ,
             A.PartialRedumptionDueDate ,
             A.PartialRedumptionSettledY_N ,
             A.NPIDt ,
             A.BalanceSheetDate ,
             A.ListedShares ,
             A.DPD_BS_Date ,
             A.BookValueINR ,
             --,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt  
             v_Mocdate MOC_Dt  ,
             --,COalesce(ALM.CreatedBy,CLM.CreatedBy,MOC.Createdby)              AS MakerID  
             --,ISNULL(ALM.DateCreated,CLM.DateCreated)                          AS MakerDate  
             --,ISNULL(ALM.ApprovedByFirstLevel,CLM.ApprovedByFirstLevel)        AS CheckerID  
             --,ISNULL(ALM.DateApprovedFirstLevel,CLM.DateApprovedFirstLevel)    AS CheckerDate  
             --,ISNULL(ALM.ApprovedBy,CLM.ApprovedBy)                            AS ReviewerID   
             --,ISNULL(ALM.DateApproved,CLM.DateApproved)                        AS ReviewerDate  
             --,ISNULL(A.MOC_Reason,'')                                          AS MOCReason  
             ----,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
             ----,DABS.AcBuSegmentDescription  
             -- --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
             ----,CASE WHEN SourceName='FIS' THEN 'FI'
             ----	  WHEN SourceName='VisionPlus' THEN 'Credit Card'
             ----	else DABS.AcBuRevisedSegmentCode end                       AS AcBuSegmentCode 
             ------,DABS.AcBuSegmentDescription  
             ----,CASE WHEN SourceName='FIS' THEN 'FI'
             ----	  WHEN SourceName='VisionPlus' THEN 'Credit Card'
             ----	else DABS.AcBuSegmentDescription end                        AS AcBuSegmentDescription
             --,clm.AuthorisationStatus
             COALESCE(ALM.CreatedBy, CLM.CreatedBy, MOC2.createdBy) MakerID  ,
             NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
             NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
             NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
             NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
             NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
             NVL(A.MOC_Reason, ' ') MOCReason  ,
             --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
             --,CASE WHEN SourceName='FIS' THEN 'FI'
             --	  WHEN SourceName='VisionPlus' THEN 'Credit Card'
             --	else DABS.AcBuRevisedSegmentCode end                       AS AcBuSegmentCode 
             ----,DABS.AcBuSegmentDescription  
             --,CASE WHEN SourceName='FIS' THEN 'FI'
             --	  WHEN SourceName='VisionPlus' THEN 'Credit Card'
             --	else DABS.AcBuSegmentDescription end                        AS AcBuSegmentDescription
             clm.AuthorisationStatus 
        FROM tt_InvestmentFinancialDetai_4 A
               JOIN tt_CalypsoAccountLevelMOC_M_2 ALM   ON ALM.AccountId = A.RefInvID
               LEFT JOIN tt_CalypsoCustomerLevelMOC__2 CLM   ON A.IssuerEntityId = CLM.CustomerEntityId
             --LEFT JOIN CalypsoInvMOC_ChangeDetails MOC1               ON MOC1.CustomerEntityId=CLM.CustomerEntityId  
              --                                                 AND MOC1.EffectiveFromTimeKey<=@TimeKey  
              --                                                 AND MOC1.EffectiveToTimeKey>=@TimeKey 
              --												 AND MOC1.MOCType_Flag = 'CUST'

               JOIN CalypsoInvMOC_ChangeDetails MOC2   ON MOC2.AccountEntityID = ALM.AccountEntityID
               AND MOC2.EffectiveFromTimeKey <= v_TimeKey
               AND MOC2.EffectiveToTimeKey >= v_TimeKey
               AND MOC2.MOCType_Flag = 'ACCT'
               LEFT JOIN InvestmentFinancialDetail X   ON A.InvEntityId = X.InvEntityId
               AND X.EffectiveFromTimeKey <= v_Timekey - 1
               AND X.EffectiveToTimekey >= v_Timekey - 1
               JOIN DimAssetClass D   ON D.AssetClassAlt_Key = NVL(A.InitialAssetAlt_Key, 1)
               AND D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass E   ON E.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
               AND E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey
               JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey

      --INNER JOIN DimSourceDB H                                ON H.SourceAlt_Key=A.SourceAlt_Key  

      --                                                           AND H.EffectiveFromTimeKey<=@TimeKey  

      --                                                           AND H.EffectiveToTimeKey>=@TimeKey  

      --LEFT JOIN #DimAcBuSegment   DABS                        ON A.ActSegmentCode=DABS.AcBuSegmentCode  

      --AND DABS.RN=1  
      WHERE  A.RefInvID IN ( SELECT InvID 
                             FROM tt_InvestmentFinancialDetai_3 A
                              WHERE  ( A.FlgMoc = 'Y' ) )

        ORDER BY InvID,
                 IssuerID,
                 Moc_Status DESC;
   UPDATE tt_Final_2
      SET MakerID = 'System',
          CheckerID = 'System',
          ReviewerID = 'System'
    WHERE  MakerID IS NULL
     OR CheckerID IS NULL
     OR ReviewerID IS NULL;
   UPDATE tt_Final_2
      SET AuthorisationStatus = 'A'
    WHERE  AuthorisationStatus IS NULL;
   INSERT INTO RBL_MISDB_PROD.MOCVerificationReport_Account_RDM
     SELECT * 
       FROM tt_Final_2 
       ORDER BY SrNo,
                IssuerID,
                InvID,
                Moc_Status DESC;
   OPEN  v_cursor FOR
      SELECT SrNo ,
             Moc_Status ,
             CurrentProcessingDate ,
             SourceName ,
             BRANCHCODE ,
             ISSUERID ,
             ISSUERNAME ,
             REF_TXN_SYS_CUST_ID ,
             ISSUER_CATEGORY_CODE ,
             UCIFID ,
             PANNO ,
             INVID ,
             ISIN ,
             INSTRUMENTTYPENAME ,
             INSTRNAME ,
             INVESTMENTNATURE ,
             EXPOSURETYPE ,
             --, [MATURITYDT]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(MATURITYDT,200,p_style=>105),10,p_style=>23) MATURITYDT  ,
             HOLDINGNATURE ,
             BOOKTYPE ,
             BOOKVALUE ,
             MTMVALUE ,
             INTEREST_DIVIDENDDUEDATE ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(INTEREST_DIVIDENDDUEDATE,200,p_style=>105),10,p_style=>23) INTEREST_DIVIDENDDUEDATE  ,
             INTEREST_DIVIDENDDUEAMOUNT ,
             DPD ,
             FLGDEG Fresh_Degrade_Y_N_  ,
             DEGREASON ,
             FLGUPG ,
             --, [UPGDATE]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(UPGDATE,200,p_style=>105),10,p_style=>23) UPGDATE  ,
             TOTALPROVISON ,
             ASSETCLASS ,
             --, [PartialRedumptionDueDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(PartialRedumptionDueDate,200,p_style=>105),10,p_style=>23) PartialRedumptionDueDate  ,
             PartialRedumptionSettledY_N ,
             --, [NPIDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(NPIDt,200,p_style=>105),10,p_style=>23) NPIDt  ,
             --,[BalanceSheetDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(BalanceSheetDate,200,p_style=>105),10,p_style=>23) BalanceSheetDate  ,
             ListedShares ,
             DPD_BS_Date ,
             BookValueINR ,
             MOC_Dt ,
             MakerID ,
             --, [MakerDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(MakerDate,200,p_style=>105),10,p_style=>23) MakerDate  ,
             CheckerID ,
             --, [CheckerDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(CheckerDate,200,p_style=>105),10,p_style=>23) CheckerDate  ,
             ReviewerID ,
             --, [ReviewerDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(ReviewerDate,200,p_style=>105),10,p_style=>23) ReviewerDate  ,
             MOCReason ,
             AuthorisationStatus 
        FROM RBL_MISDB_PROD.MOCVerificationReport_Account_RDM  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENT_MOCVERIFICATIONACCOUNTREPORT_RDM_02052024" TO "ADF_CDR_RBL_STGDB";
