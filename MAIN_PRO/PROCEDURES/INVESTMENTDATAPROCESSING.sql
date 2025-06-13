--------------------------------------------------------
--  DDL for Procedure INVESTMENTDATAPROCESSING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INVESTMENTDATAPROCESSING" 
----/*=========================================
 ---- AUTHER : TRILOKI KHANNA
 ---- CREATE DATE : 27-11-2019
 ---- MODIFY DATE : 27-11-2019
 ---- DESCRIPTION : UPDATE InvestmentDataProcessing
 ---- --EXEC [PRO].[InvestmentDataProcessing] @TIMEKEY=26196
 --[PRO].[InvestmentDataProcessing] 26859
 ----=============================================*/

(
  v_TIMEKEY IN NUMBER
)
AS
/*=========================================
-- AUTHOR : TRILOKI KHANNA
-- CREATE DATE : 09-04-2021
-- MODIFY DATE : 09-04-2021
-- DESCRIPTION : Test Case Cover in This SP

--=============================================*/

 --=266669
BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
    V_Table_exists NUMBER(10);
   BEGIN
      DECLARE
         v_PROCESSDATE VARCHAR2(200) ;
         v_SUB_Days NUMBER(10,0) ;
         v_DB1_Days NUMBER(10,0) ;
         v_DB2_Days NUMBER(10,0) ;
         v_MoveToDB1 NUMBER(5,2) ;
         v_MoveToLoss NUMBER(5,2) ;
         v_SubStandard NUMBER(10,0) ;
         v_DoubtfulI NUMBER(10,0) ;
         v_DoubtfulII NUMBER(10,0) ;
         v_DoubtfulIII NUMBER(10,0) ;
         v_Loss NUMBER(10,0) ;

      BEGIN

  SELECT DATE_ INTO v_PROCESSDATE
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;

         SELECT RefValue INTO v_SUB_Days 
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'SUB_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT RefValue INTO v_DB1_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB1_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB2_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB2_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToDB1
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToDB1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToLoss
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToLoss'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_SubStandard
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulI 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-I'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulII
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-II'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulIII
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-III'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_Loss
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Loss'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;


         UPDATE CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail
            SET DPD = 0
          WHERE  EffectiveFromTimeKey <= v_timekey
           AND EffectiveToTimeKey >= v_timekey
           AND NVL(DPD, 0) = 0;
         --/*---------------ASSIGNE DEG REASON---------------*/
         --UPDATE B SET B.DEGREASON= 'DEGRADE BY MTMValue Less Than 1 Rs.' 
         --FROM InvestmentBasicDetail A
         --inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
         --AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
         --inner join CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
         --AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
         --AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
         --where MTMValueINR=1 and InvestmentNature='FD' AND B.AssetClass_AltKey=1
         --AND FLGDEG ='Y'
         ----alter table rbl_tempdb.dbo.TempInvestmentFinancialDetail add PartialRedumptionDPD smallint
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id, 'NORMAL'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET Asset_Norm = 'NORMAL';
         
         MERGE INTO CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id
         FROM CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DPD_DivOverdue = 0,
                                      DPD_Maturity = 0,
                                      DPD = 0,
                                      FLGDEG = 'N',
                                      FLGUPG = 'N',
                                      DEGREASON = NULL,
                                      UPGDATE = NULL,
                                      PartialRedumptionDPD = 0,
                                      DPD_BS_Date = 0;
         --/*UPDATE PREVISOU DAY STATUS AS INITIAL STATUS FOR CURRENT DAY */
         --UPDATE A SET 
         --		InitialAssetAlt_Key=B.FinalAssetClassAlt_Key
         --		,InitialNPIDt =B.NPIDt
         --FROM CURDAT.CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         --	INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         --		ON A.InvEntityId =B.InvEntityId
         --		AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
         --	AND B.EffectiveFromTimeKey<=@timekey-1 AND B.EffectiveToTimeKey>=@timekey-1
         MERGE INTO CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id, a.FinalAssetClassAlt_Key, a.NPIDt
         FROM CurDat_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET InitialAssetAlt_Key = src.FinalAssetClassAlt_Key,
                                      InitialNPIDt = src.NPIDt;
         --		------------------Added by Sudesh for One Time Code Run during LIVE 23102023 Investment Holding Nature Carry Forward--------
         --		UPDATE A SET 
         --		InitialAssetAlt_Key=B.FinalAssetClassAlt_Key
         --		,InitialNPIDt =B.NPIDt
         --FROM CURDAT.CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         --	INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         --		ON SUBSTRING(A.RefInvID,1,charindex('_',A.RefInvID)-1)  =B.RefInvID
         --		AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
         --		AND B.EffectiveFromTimeKey<=@timekey-1 AND B.EffectiveToTimeKey>=@timekey-1
         ----------------------------------------------
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail Bb   ON A.InvEntityId = bb.InvEntityId
                AND bb.EffectiveFromTimeKey <= v_TIMEKEY
                AND bb.EffectiveToTimeKey >= v_TIMEKEY
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail Cc   ON Cc.IssuerEntityId = bb.IssuerEntityId
                AND Cc.EffectiveFromTimeKey <= v_TIMEKEY
                AND Cc.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND NVL(UcifId, ' ') IN ( 'RBL008827709','RBL003034380','RBL002980785' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA';
         /*  mannual npa as per RBL team Mr. Divakar  email dated  17-09-2021 time 14:12 for marked Manual NPA forcefully */
         --======== ADDED BY MANDEEP  FOR WRITE OFF/SETTLEMENT  ==============================---
         -- MAKRKING WRITE OFF ----------------------------
         ----DROP TABLE IF EXISTS #WRITE
         ----SELECT A.UcifId,min(StatusDate)StatusDate into #WRITE
         ----FROM DBO.InvestmentIssuerDetail A
         ----INNER JOIN DBO.RBL_MISDB_PROD.ExceptionFinalStatusType B
         ----ON A.IssuerID=B.ACID
         ----AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
         ----AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
         ----AND B.SourceAlt_Key=7
         ----AND B.StatusType IN ('TWO','WO','WriteOff')
         ----group by A.UcifId
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', CONCAT(A.DEGREASON, ',NPA DUE TO WriteOff Marking ') AS pos_3, CASE 
         WHEN StatusDate < A.NPIDt THEN StatusDate
         ELSE A.NPIDt
            END AS pos_4
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                AND C.ACID = A.RefInvID
                AND C.StatusType IN ( 'TWO','WO','WriteOff' )

                AND C.SourceAlt_key = 7 
          WHERE A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY
           AND A.FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DEGREASON = pos_3,
                                      A.NPIDt = pos_4;
                                      
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'Y', 'NPA DUE TO WriteOff Marking ' AS pos_4, CASE 
         WHEN C.StatusDate IS NOT NULL THEN C.StatusDate
         ELSE v_PROCESSDATE
            END AS pos_5, 2
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                AND C.ACID = A.RefInvID
                AND C.StatusType IN ( 'TWO','WO','WriteOff' )

                AND C.SourceAlt_key = 7 
          WHERE A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY
           AND A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.FLGDEG = 'Y',
                                      A.DEGREASON = pos_4,
                                      A.NPIDt = pos_5,
                                      A.FinalAssetClassAlt_Key = 2;
         -- END OF Write Off ------------------------------
         -- MAKRKING Settlement ----------------------------
         ----DROP TABLE IF EXISTS #Settlement
         ----SELECT A.UcifId,min(StatusDate)StatusDate into #Settlement
         ----FROM DBO.InvestmentIssuerDetail A
         ----INNER JOIN DBO.RBL_MISDB_PROD.ExceptionFinalStatusType B
         ----ON A.IssuerID=B.ACID
         ----AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
         ----AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
         ----AND B.SourceAlt_Key=7
         ----AND B.StatusType IN ('Settlement')
         ----group by A.UcifId
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', CONCAT(A.DEGREASON, ',NPA DUE TO Settlement marking ') AS pos_3, CASE 
         WHEN StatusDate < A.NPIDt THEN StatusDate
         ELSE A.NPIDt
            END AS pos_4
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.RefIssuerID = B.IssuerID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                AND C.ACID = B.IssuerID
                AND C.StatusType IN ( 'Settlement' )

                AND C.SourceAlt_key = 7 
          WHERE A.FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DEGREASON = pos_3,
                                      A.NPIDt = pos_4;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'Y', 'NPA DUE TO Settlement marking ' AS pos_4, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_PROCESSDATE
            END AS pos_5, 2
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.RefIssuerID = B.IssuerID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                AND C.ACID = B.IssuerID
                AND C.StatusType IN ( 'Settlement' )

                AND C.SourceAlt_key = 7 
          WHERE A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.FLGDEG = 'Y',
                                      A.DEGREASON = pos_4,
                                      A.NPIDt = pos_5,
                                      A.FinalAssetClassAlt_Key = 2;
         ----END OF SETTLEMENT --------------------------------------------------------------
         ----  WriteOff/Settlement Marking on basis of  History Data ---------------------------------------
         DELETE FROM GTT_HISTORYDATA;
         UTILS.IDENTITY_RESET('GTT_HISTORYDATA');

         INSERT INTO GTT_HISTORYDATA ( 
         	SELECT DISTINCT A.ACID ,
                          A.StatusType ,
                          A.StatusDate ,
                          MAX(A.EffectiveFromTimeKey)  EffectiveFromTimeKey  
         	  FROM RBL_MISDB_PROD.ExceptionFinalStatusType A
                   LEFT JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.ACID = B.IssuerID
                   AND B.EffectiveFromTimeKey <= v_TIMEKEY
                   AND B.EffectiveToTimeKey >= v_TIMEKEY
         	 WHERE  B.IssuerID IS NULL
                    AND A.StatusType = 'Settlement'
                    AND A.EffectiveFromTimeKey <= v_TIMEKEY
                    AND A.EffectiveToTimeKey >= v_TIMEKEY
         	  GROUP BY A.ACID,A.StatusType,A.StatusDate
         	UNION 
         	SELECT DISTINCT A.ACID ,
                          A.StatusType ,
                          A.StatusDate ,
                          MAX(A.EffectiveFromTimeKey)  EffectiveFromTimeKey  
         	  FROM RBL_MISDB_PROD.ExceptionFinalStatusType A
                   LEFT JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.ACID = B.RefInvID
                   AND B.EffectiveFromTimeKey <= v_TIMEKEY
                   AND B.EffectiveToTimeKey >= v_TIMEKEY
         	 WHERE  B.RefInvID IS NULL
                    AND A.StatusType IN ( 'TWO','WO','WriteOff' )

                    AND A.EffectiveFromTimeKey <= v_TIMEKEY
                    AND A.EffectiveToTimeKey >= v_TIMEKEY
         	  GROUP BY A.ACID,A.StatusType,A.StatusDate );
         DELETE FROM GTT_HISTORYDATA1;
         UTILS.IDENTITY_RESET('GTT_HISTORYDATA1');

         INSERT INTO GTT_HISTORYDATA1 ( 
         	SELECT A.UcifId ,
                 MIN(B.StatusDate)  StatusDate  ,
                 B.StatusType 
         	  FROM CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail A
                   JOIN GTT_HISTORYDATA B   ON A.IssuerID = B.ACID
                   AND B.StatusType = 'Settlement'
                   AND A.EffectiveFromTimeKey <= B.EffectiveFromTimeKey
                   AND A.EffectiveToTimeKey >= B.EffectiveFromTimeKeY
         	  GROUP BY A.UcifId,B.StatusType
         	UNION 
         	SELECT C.UcifId ,
                 MIN(B.StatusDate)  StatusDate  ,
                 B.StatusType 
         	  FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.RefIssuerID = C.IssuerID
                   JOIN GTT_HISTORYDATA B   ON A.RefInvID = B.ACID
                   AND A.EffectiveFromTimeKey <= B.EffectiveFromTimeKey
                   AND A.EffectiveToTimeKey >= B.EffectiveFromTimeKeY
                   AND c.EffectiveFromTimeKey <= B.EffectiveFromTimeKey
                   AND c.EffectiveToTimeKey >= B.EffectiveFromTimeKeY
                   AND B.StatusType IN ( 'TWO','WO','WriteOff' )

         	  GROUP BY C.UcifId,B.StatusType );
         DELETE FROM GTT_HISTORYDATA2;
         UTILS.IDENTITY_RESET('GTT_HISTORYDATA2');

         INSERT INTO GTT_HISTORYDATA2 ( 
         	SELECT A.UcifId ,
                 B.ACID ,
                 B.StatusType 
         	  FROM CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail A
                   JOIN GTT_HISTORYDATA B   ON A.IssuerID = B.ACID
                   AND B.StatusType = 'Settlement'
                   AND A.EffectiveFromTimeKey <= B.EffectiveFromTimeKey
                   AND A.EffectiveToTimeKey >= B.EffectiveFromTimeKeY
         	  GROUP BY A.UcifId,B.ACID,B.StatusType
         	UNION 
         	SELECT C.UcifId ,
                 B.ACID ,
                 B.StatusType 
         	  FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.RefIssuerID = C.IssuerID
                   AND A.EffectiveFromTimeKey <= v_TIMEKEY
                   AND A.EffectiveToTimeKey >= v_TIMEKEY
                   AND C.EffectiveFromTimeKey <= v_TIMEKEY
                   AND C.EffectiveToTimeKey >= v_TIMEKEY
                   JOIN GTT_HISTORYDATA B   ON A.REFINVID = B.ACID
                   AND B.StatusType IN ( 'TWO','WO','WriteOff' )

                   AND A.EffectiveFromTimeKey <= B.EffectiveFromTimeKey
                   AND A.EffectiveToTimeKey >= B.EffectiveFromTimeKeY
         	  GROUP BY C.UcifId,B.ACID,B.StatusType );

         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, CONCAT(CONCAT(DEGREASON, ',NPA DUE TO Linkage By Issuerid='), D.ACID) AS pos_2, CASE 
         WHEN C.StatusDate < A.NPIDt THEN C.StatusDate
         ELSE A.NPIDt
            END AS pos_3
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.REFISSUERID = B.ISSUERID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN GTT_HISTORYDATA1 C   ON B.UcifId = C.UcifId
                AND C.StatusType = 'Settlement'
                LEFT JOIN GTT_HISTORYDATA2 D   ON C.UcifId = D.UcifId 
          WHERE A.FINALASSETCLASSALT_KEY > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = pos_2,
                                      A.NPIDt = pos_3;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'Y', CONCAT('NPA DUE TO Linkage By Issuerid=', D.ACID) AS pos_3, CASE 
         WHEN C.StatusDate IS NOT NULL THEN C.StatusDate
         ELSE v_PROCESSDATE
            END AS pos_4
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.REFISSUERID = B.ISSUERID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN GTT_HISTORYDATA1 C   ON B.UcifId = C.UcifId
                AND C.StatusType = 'Settlement'
                LEFT JOIN GTT_HISTORYDATA2 D   ON C.UcifId = D.UcifId 
          WHERE A.FINALASSETCLASSALT_KEY = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'Y',
                                      A.DEGREASON = pos_3,
                                      A.NPIDt = pos_4;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, CONCAT(CONCAT(DEGREASON, ',NPA DUE TO Linkage By Invid='), D.ACID) AS pos_2, CASE 
         WHEN C.StatusDate < A.NPIDt THEN C.StatusDate
         ELSE A.NPIDt
            END AS pos_3
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.REFISSUERID = B.ISSUERID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN GTT_HISTORYDATA1 C   ON B.UcifId = C.UcifId
                AND C.StatusType IN ( 'TWO','WO','WriteOff' )

                LEFT JOIN GTT_HISTORYDATA2 D   ON C.UcifId = D.UcifId 
          WHERE A.FINALASSETCLASSALT_KEY > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = pos_2,
                                      A.NPIDt = pos_3;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'Y', CONCAT('NPA DUE TO Linkage By Invid=', D.ACID) AS pos_3, CASE 
         WHEN C.StatusDate IS NOT NULL THEN C.StatusDate
         ELSE v_PROCESSDATE
            END AS pos_4
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.REFISSUERID = B.ISSUERID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN GTT_HISTORYDATA1 C   ON B.UcifId = C.UcifId
                AND C.StatusType IN ( 'TWO','WO','WriteOff' )

                LEFT JOIN GTT_HISTORYDATA2 D   ON C.UcifId = D.UcifId 
          WHERE A.FINALASSETCLASSALT_KEY = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'Y',
                                      A.DEGREASON = pos_3,
                                      A.NPIDt = pos_4;
         -- ========  END OF WRITE OFF CR WORK ======================================----------------------------------
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN B.Interest_DividendDueDate IS NOT NULL THEN utils.datediff('DAY', B.Interest_DividendDueDate, v_PROCESSDATE) + 1
         ELSE 0
            END) AS DPD_DivOverdue
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
                JOIN RBL_MISDB_PROD.DIMINSTRUMENTTYPE INS   ON INS.EffectiveFromTimeKey <= v_timekey
                AND INS.EffectiveToTimeKey >= v_timekey
                AND INS.InstrumentTypeAlt_Key = A.InstrTypeAlt_Key 
          WHERE B.Interest_DividendDueDate IS NOT NULL
           AND NVL(INS.InstrumentTypeSubGroup, ' ') IN ( 'BONDS','Preference Shares','CP','CD','PTC' )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DPD_DivOverdue = src.DPD_DivOverdue;
         --Added by mandeep to count balancesheet DPD
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN B.BalanceSheetDate IS NOT NULL THEN utils.datediff('DAY', B.BalanceSheetDate, v_PROCESSDATE)
         ELSE 0
            END) AS DPD_BS_Date
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
                JOIN RBL_MISDB_PROD.DIMINSTRUMENTTYPE INS   ON INS.EffectiveFromTimeKey <= v_timekey
                AND INS.EffectiveToTimeKey >= v_timekey
                AND INS.InstrumentTypeAlt_Key = A.InstrTypeAlt_Key 
          WHERE B.DPD_BS_Date IS NOT NULL
           AND ListedShares = 'Unlisted'

           --and DAY(B.BalanceSheetDate)=31

           --AND MONTH(B.BalanceSheetDate)=03
           AND NVL(INS.InstrumentTypeSubGroup, ' ') IN ( 'Equity' )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DPD_BS_Date = src.DPD_BS_Date;
         --UPDATE B SET DPD_Maturity=(CASE WHEN  a.MaturityDt IS NOT NULL   
         --      THEN   DATEDIFF(DAY,a.MaturityDt,@PROCESSDATE)       ELSE 0 END)
         --FROM InvestmentBasicDetail A
         --inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
         --AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
         --inner join CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
         --AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
         --AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
         --INNER JOIN RBL_MISDB_PROD.DIMINSTRUMENTTYPE INS 
         --ON INS.EffectiveFromTimeKey<=@timekey AND INS.EffectiveToTimeKey>=@timekey
         --AND INS.InstrumentTypeAlt_Key=A.InstrTypeAlt_Key
         --WHERE a.MaturityDt IS NOT  NULL AND ISNULL(B.FinalAssetClassAlt_Key,1)=1
         ----------AND INSTRUMENTTYPEALT_KEY IN(1,3,4) 
         --AND ISNULL(BookValue,0) > 0 AND ISNULL(Interest_DividendDueAmount,0) > 0--1 -> eQUITY, 2->PREFERENTIAL SHAHRES, 3-> BONDS
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN b.PartialRedumptionDueDate IS NOT NULL THEN utils.datediff('DAY', B.PartialRedumptionDueDate, v_PROCESSDATE) + 1
         ELSE 0
            END) AS PartialRedumptionDPD
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
                JOIN RBL_MISDB_PROD.DIMINSTRUMENTTYPE INS   ON INS.EffectiveFromTimeKey <= v_timekey
                AND INS.EffectiveToTimeKey >= v_timekey
                AND INS.InstrumentTypeAlt_Key = A.InstrTypeAlt_Key 
          WHERE b.PartialRedumptionDueDate IS NOT NULL
           AND PartialRedumptionSettledY_N = 'N'

           --AND ISNULL(B.FinalAssetClassAlt_Key,1)=1
           AND NVL(INS.InstrumentTypeSubGroup, ' ') IN ( 'BONDS','Preference Shares','CP','CD','PTC' )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET PartialRedumptionDPD = src.PartialRedumptionDPD;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, CASE 
         WHEN NVL(DPD_DivOverdue, 0) >= NVL(DPD_Maturity, 0)
           AND NVL(DPD_DivOverdue, 0) >= NVL(PartialRedumptionDPD, 0)
           AND NVL(DPD_DivOverdue, 0) >= NVL(DPD_BS_Date, 0) THEN NVL(DPD_DivOverdue, 0)
         WHEN NVL(DPD_Maturity, 0) >= NVL(DPD_DivOverdue, 0)
           AND NVL(DPD_Maturity, 0) >= NVL(PartialRedumptionDPD, 0)
           AND NVL(DPD_Maturity, 0) >= NVL(DPD_BS_Date, 0) THEN NVL(DPD_Maturity, 0)
         WHEN NVL(DPD_BS_Date, 0) >= NVL(DPD_DivOverdue, 0)
           AND NVL(DPD_BS_Date, 0) >= NVL(PartialRedumptionDPD, 0)
           AND NVL(DPD_BS_Date, 0) >= NVL(DPD_Maturity, 0) THEN NVL(DPD_BS_Date, 0)
         ELSE NVL(PartialRedumptionDPD, 0)
            END AS DPD
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
                JOIN RBL_MISDB_PROD.DIMINSTRUMENTTYPE INS   ON INS.EffectiveFromTimeKey <= v_timekey
                AND INS.EffectiveToTimeKey >= v_timekey
                AND INS.InstrumentTypeAlt_Key = A.InstrTypeAlt_Key ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DPD = src.DPD;
         --WHERE  isnull(B.FinalAssetClassAlt_Key,1)=1 AND (ISNULL(DPD_DivOverdue,0)>0 OR ISNULL(DPD_Maturity,0)>0)
         --AND INSTRUMENTTYPEALT_KEY IN(1,3,4) --1 -> eQUITY, 2->PREFERENTIAL SHAHRES, 3-> BONDS
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, CASE 
         WHEN NVL(DPD, 0) < 0 THEN 0
         ELSE NVL(DPD, 0)
            END AS pos_2, CASE 
         WHEN NVL(DPD_MATURITY, 0) < 0 THEN 0
         ELSE NVL(DPD_MATURITY, 0)
            END AS pos_3, CASE 
         WHEN NVL(DPD_DivOverdue, 0) < 0 THEN 0
         ELSE NVL(DPD_DivOverdue, 0)
            END AS pos_4, CASE 
         WHEN NVL(PartialRedumptionDPD, 0) < 0 THEN 0
         ELSE NVL(PartialRedumptionDPD, 0)
            END AS pos_5, CASE 
         WHEN NVL(DPD_BS_Date, 0) < 0 THEN 0
         ELSE NVL(DPD_BS_Date, 0)
            END AS pos_6
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE NVL(DPD, 0) < 0
           OR NVL(DPD_MATURITY, 0) < 0
           OR NVL(DPD_DivOverdue, 0) < 0
           OR B.DPD_BS_Date < 0) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DPD = pos_2,
                                      B.DPD_MATURITY = pos_3,
                                      B.DPD_DivOverdue = pos_4,
                                      B.PartialRedumptionDPD --added by mandeep
                                       = pos_5,
                                      B.DPD_BS_Date --added by mandeep
                                       = pos_6;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, 'Y'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
              --DPD>=90 commented and new added

          WHERE ( DPD_DivOverdue >= 91
           OR PartialRedumptionDPD >= 91
           OR DPD_BS_Date >= 541 )
           AND Asset_Norm = 'NORMAL'
           AND FinalAssetClassAlt_Key = 1) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FLGDEG = 'Y';
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, 'DEGRADE BY Interest_DividendDueDate' AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.Interest_DividendDueDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) = 1
           AND DPD_DivOverdue >= 91
           AND FLGDEG = 'Y') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, CONCAT(CONCAT(DEGREASON, CASE 
                                                                WHEN DPD_DivOverdue >= 91 THEN ','
                                                                ELSE ' '
            END), 'DEGRADE BY Partial Redumption Due Date') AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.Interest_DividendDueDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) = 1
           AND ----------ISNULL(DPD_Maturity,0)>=90 or 
          ( NVL(PartialRedumptionDPD, 0) >= 91 )
           AND FLGDEG = 'Y') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, CONCAT(CONCAT(DEGREASON, CASE 
                                WHEN DPD_BS_Date >= 541 THEN (CASE 
                                                                   WHEN DEGREASON IS NOT NULL THEN ','
                                ELSE ' '
                                   END)
         ELSE ' '
            END), 'NPA due to overdue Balance Sheet Date') AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.BalanceSheetDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) = 1
           AND ----------ISNULL(DPD_Maturity,0)>=90 or 
          ( NVL(DPD_BS_Date, 0) >= 541 )
           AND FLGDEG = 'Y') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         /*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL---------------*/
         /*
         UPDATE B SET FLGDEG ='Y'
         		, B.DEGREASON= 'DEGRADE BY MTMValue Less Than 1 Rs.' 
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
         inner join CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
         AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
         inner join CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
         AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
         AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
         where ISNULL(MTMValueINR,0)<1
         and InvestmentNature='EQUITY' AND ISNULL(B.FinalAssetClassAlt_Key,1)=1 

         */
         /*------------Calculate NpaDt -------------------------------------*/
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A  
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(A.FLGDEG, 'N') = 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND A.DEGREASON = 'DEGRADE BY MTMValue Less Than 1 Rs.') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPIDt = v_ProcessDate;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, utils.dateadd('DAY', NVL(91, 0), utils.dateadd('DAY', -NVL(DPD, 0), v_ProcessDate)) AS NPIDt
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(A.FLGDEG, 'N') = 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND DEGREASON NOT LIKE '%NPA due to overdue Balance Sheet Date%') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPIDt = src.NPIDt;
         ----AND  A.DEGREASON IS NULL
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, utils.dateadd('DAY', NVL(541, 0), utils.dateadd('DAY', -NVL(DPD_BS_Date, 0), v_ProcessDate)) AS NPIDt
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(A.FLGDEG, 'N') = 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND DEGREASON LIKE '%Balance Sheet Date%') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPIDt = src.NPIDt;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                               FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                WHERE  DIMASSETCLASS.AssetClassShortName = 'SUB'
                                                                                         AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                         AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                             FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                              WHERE  DIMASSETCLASS.AssetClassShortName = 'DB1'
                                                                                                       AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                       AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                          FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                           WHERE  DIMASSETCLASS.AssetClassShortName = 'DB2'
                                                                                                                    AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                    AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.NPIDt) <= v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                            FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                             WHERE  DIMASSETCLASS.AssetClassShortName = 'DB3'
                                                                                                                      AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                      AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )   END) AS FinalAssetClassAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(A.FlgDeg, 'N') = 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         /*


         ----IF OBJECT_ID('TEMPDB..GTT_TEMPMINASSETCLASS') IS NOT NULL
         ----  DROP TABLE GTT_TEMPMINASSETCLASS

         ----	SELECT UcifId,MAX(ISNULL(FinalAssetClassAlt_Key,1)) FinalAssetClassAlt_Key
         ----	,MIN(NPIDt) NPIDt 
         ----	 INTO GTT_TEMPMINASSETCLASS 
         ----	 FROM  CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         ----		INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B
         ----			ON A.INVENTITYID=B.INVENTITYID
         ----			AND B.EffectiveFromTimeKey<=@timekey and B.EffectiveToTimeKey>=@timekey
         ----		inner join CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C ON B.IssuerEntityId=C.IssuerEntityId
         ----			AND B.EffectiveFromTimeKey<=@timekey and B.EffectiveToTimeKey>=@timekey
         ----	  WHERE  ISNULL(FinalAssetClassAlt_Key,1)>1
         ----	  AND  A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
         ----	  GROUP BY UcifId


         ----	  ALTER TABLE  GTT_TEMPMINASSETCLASS ADD RefInvID VARCHAR (200)


         ----	  UPDATE A SET RefInvID=B.RefInvID
         ----	 FROM GTT_TEMPMINASSETCLASS  A
         ----	 INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail  B ON A.RefIssuerID=B.RefIssuerID
         ----	  WHERE  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         ----	  AND  A.FinalAssetClassAlt_Key=B.FinalAssetClassAlt_Key AND A.NPIDt=B.NPIDt


         ----	  UPDATE D SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,NPIDt=A.NPIDt,DEGREASON='PERCOLATION BY' + ' ' +A.UcifId
         ----	  FROM GTT_TEMPMINASSETCLASS  A
         ----		inner join CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B ON B.UcifId=B.UcifId
         ----			AND B.EffectiveFromTimeKey<=@timekey and B.EffectiveToTimeKey>=@timekey
         ----		INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail C
         ----			ON B.INVENTITYID=B.INVENTITYID
         ----			AND C.EffectiveFromTimeKey<=@timekey and C.EffectiveToTimeKey>=@timekey
         ----	  INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail  D
         ----			ON A.RefIssuerID=B.RefIssuerID
         ----	   WHERE D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY
         ----	  AND B.AssetClass_AltKey=1
         */
         IF utils.object_id('TEMPDB..GTT_TEMPMINASSETCLASS') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPMINASSETCLASS ';
         END IF;
         DELETE FROM GTT_TEMPMINASSETCLASS;
         UTILS.IDENTITY_RESET('GTT_TEMPMINASSETCLASS');

         INSERT INTO GTT_TEMPMINASSETCLASS ( 
         	SELECT UcifId ,
                 MAX(NVL(FinalAssetClassAlt_Key, 1))  FinalAssetClassAlt_Key  ,
                 MIN(NPIDt)  NPIDt  
         	  FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.INVENTITYID = B.INVENTITYID
                   AND B.EffectiveFromTimeKey <= v_TimeKey
                   AND B.EffectiveToTimeKey >= v_TimeKey
                   JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                   AND B.EffectiveFromTimeKey <= v_TimeKey
                   AND B.EffectiveToTimeKey >= v_TimeKey
         	 WHERE  NVL(FinalAssetClassAlt_Key, 1) > 1
                    AND A.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                    AND A.EFFECTIVETOTIMEKEY >= v_TimeKey
         	  GROUP BY UcifId );
              
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D
         USING (SELECT D.ROWID row_id, A.FinalAssetClassAlt_Key, A.NPIDt
         --,DEGREASON= (CASE WHEN DEGREASON IS NULL THEN
          --(CASE WHEN D.DEGREASON IS NULL THEN  '' ELSE CONCAT(D.DEGREASON,' , ') END)+'PERCOLATION BY' + ' ' +A.UcifId ELSE DEGREASON END)

         FROM GTT_TEMPMINASSETCLASS A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.UcifId = B.UcifId
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D   ON C.InvEntityId = D.InvEntityId 
          WHERE D.EFFECTIVEFROMTIMEKEY <= v_TimeKey
           AND D.EFFECTIVETOTIMEKEY >= v_TimeKey
           AND D.FLGDEG = 'Y') src
         ON ( D.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      D.NPIDt = src.NPIDt;
         /* START ---- ADDED BY MANDEEP TO PERCOLATE ASSET CLASS AND NPA DT ON 06-10-2023  */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D
         USING (SELECT D.ROWID row_id, A.FinalAssetClassAlt_Key, A.NPIDt
         FROM GTT_TEMPMINASSETCLASS A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.UcifId = B.UcifId
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D   ON C.InvEntityId = D.InvEntityId 
          WHERE D.EFFECTIVEFROMTIMEKEY <= v_TimeKey
           AND D.EFFECTIVETOTIMEKEY >= v_TimeKey
           AND D.NPIDt IS NULL) src
         ON ( D.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      D.NPIDt = src.NPIDt;
         /* END ---- ADDED BY MANDEEP TO PERCOLATE ASSET CLASS AND NPA DT ON 06-10-2023  */
         ----------------------------------------------------------------
         ----------------------------------------------------------------
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         USING (SELECT B.ROWID row_id, CONCAT((CASE 
                      WHEN B.DEGREASON IS NULL THEN ' '
         ELSE CONCAT(B.DEGREASON, ' , ')
            END), 'DEGRADE BY Interest_DividendDueDate') AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.Interest_DividendDueDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) > 1
           AND DPD_DivOverdue > 0
           AND FLGDEG = 'N') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN B.DEGREASON IS NULL THEN ' '
         ELSE CONCAT(B.DEGREASON, ' , ')
            END) || 'DEGRADE BY Partial Redumption Due Date' AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.PartialRedumptionDueDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) > 1
           AND PartialRedumptionDPD > 0
           AND FLGDEG = 'N') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN B.DEGREASON IS NULL THEN ' '
         ELSE CONCAT(B.DEGREASON, ' , ')
            END) || 'NPA due to overdue Balance Sheet Date' AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE B.BalanceSheetDate IS NOT NULL
           AND NVL(B.FinalAssetClassAlt_Key, 1) > 1
           AND NVL(DPD_BS_Date, 0) > 365
           AND FLGDEG = 'N') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B 
         USING (SELECT B.ROWID row_id, 'PERCOLATION BY' || ' ' || UcifId AS DEGREASON
         FROM CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON A.IssuerEntityId = C.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_timekey
                AND C.EffectiveToTimeKey >= v_timekey
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey 
          WHERE NVL(B.FinalAssetClassAlt_Key, 1) > 1
           AND DEGREASON IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;--and FLGDEG='N'
         ----------------------------------------------------------------
         --- SELECT * FROM GTT_TEMPMINASSETCLASS  
         --  UPDATE D SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,NPIDt=A.NPIDt,DEGREASON=CONCAT(DEGREASON,', PERCOLATION BY' + ' ' +A.UcifId)
         --FROM GTT_TEMPMINASSETCLASS  A
         --	inner join CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B ON A.UcifId=B.UcifId
         --		AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
         --	INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail C
         --		ON B.IssuerEntityId=C.IssuerEntityId
         --		AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
         --  INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail  D
         --		ON C.InvEntityId=D.InvEntityId
         --   WHERE D.EFFECTIVEFROMTIMEKEY<=@TimeKey AND D.EFFECTIVETOTIMEKEY>=@TimeKey
         --        --AND D.FLGDEG='Y'
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                               FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                WHERE  DIMASSETCLASS.AssetClassShortName = 'SUB'
                                                                                         AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                         AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                             FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                              WHERE  DIMASSETCLASS.AssetClassShortName = 'DB1'
                                                                                                       AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                       AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                          FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                           WHERE  DIMASSETCLASS.AssetClassShortName = 'DB2'
                                                                                                                    AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                    AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.NPIDt) <= v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                            FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                             WHERE  DIMASSETCLASS.AssetClassShortName = 'DB3'
                                                                                                                      AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                      AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         ELSE A.FinalAssetClassAlt_Key
            END) AS FinalAssetClassAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(A.FlgDeg, 'N') <> 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key -- Changes done by Satwaji as per Calypso issue occured as on 01/01/2023
                                       = src.FinalAssetClassAlt_Key;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 1, NULL
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(FinalAssetClassAlt_Key, 0) = 0
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalAssetClassAlt_Key = 1,
                                      NPIDt = NULL;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 'N'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE NVL(FinalAssetClassAlt_Key, 0) > 1
           AND NVL(InitialAssetAlt_Key, 0) > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FlgDeg = 'N';
         /* AMAR 20092023 CHANGES FOR ACCOUNT UPGRADE FROM ADHOC -- EXCEPTION DETAIL DATA FOR WOR/TE */
         
         DELETE FROM GTT_ADHOC_UCICID_STD;
         UTILS.IDENTITY_RESET('GTT_ADHOC_UCICID_STD');

         INSERT INTO GTT_ADHOC_UCICID_STD ( 
         	SELECT UCICID 
         	  FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND AssetClassAlt_Key = 1 );
                    
            MERGE INTO RBL_MISDB_PROD.ExceptionFinalStatusType C 
            USING (SELECT C.ROWID row_id
                    FROM ( SELECT IssuerID 
                            FROM GTT_ADHOC_UCICID_STD A
                            JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.UCICID = B.UcifId
                        GROUP BY IssuerID ) A
                   JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON A.IssuerID = C.ACID
                   AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                   AND C.StatusType IN ( 'Settlement' )
                   AND SourceAlt_Key = 7 ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.EFFECTIVETOTIMEKEY = v_TIMEKEY
            ;
 
            MERGE INTO RBL_MISDB_PROD.ExceptionFinalStatusType C
            USING (SELECT C.ROWID row_id, v_TIMEKEY
            FROM ( SELECT RefInvID 
                    FROM GTT_ADHOC_UCICID_STD A
                  JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.UCICID = B.UcifId
                  JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail C   ON B.IssuerID = C.RefIssuerID
           GROUP BY RefInvID ) A
                   JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON A.RefInvID = C.ACID
                   AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                   AND C.StatusType IN ( 'TWO','WO' )

                   AND SourceAlt_Key = 7 ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.EFFECTIVETOTIMEKEY = v_TIMEKEY
            ;
         /*END EXCEPTION DATA EXPIRE - BY ADHOC CHANGE UPGRADE*/
         /* AMAR 13042023MOC - CHANGES FOR AUTO AND MANUAL EFFECTS  */
         MERGE INTO RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails A 
         USING (SELECT A.ROWID row_id, v_TimeKey
         FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails A 
          WHERE EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND A.MOCTYPE = 'AUTO') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_TimeKey;
         --UPDATE D
         --	 SET D.FinalAssetClassAlt_Key=A.AssetClassAlt_Key
         --		,D.NPIDt=A.NPA_Date
         --		,D.DEGREASON=case when A.AssetClassAlt_Key>1 then 'NPA DUE TO MOC' ELSE NULL END
         --FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails  A		
         --	INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D
         --		ON  A.AccountEntityID=D.InvEntityid
         --		AND D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY 
         --		AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY 
         --		AND A.AccountENtityid is not NULL and MOC
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D
         USING (SELECT D.ROWID row_id, A.AssetClassAlt_Key, A.NPA_Date, CASE 
         WHEN A.AssetClassAlt_Key > 1 THEN 'NPA DUE TO MOC'
         ELSE NULL
            END AS pos_4, CASE 
         WHEN A.AssetClassAlt_Key > 1 THEN 'ALWYS_NPA'
         WHEN A.AssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE D.Asset_Norm
            END AS pos_5
         FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.CustomerEntityID = B.IssuerEntityId
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail D   ON C.InvEntityid = D.InvEntityid
                AND D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND A.CustomerEntityID IS NOT NULL
                AND MOCType_Flag = 'CUST' ) src
         ON ( D.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.FinalAssetClassAlt_Key = src.AssetClassAlt_Key,
                                      D.NPIDt = src.NPA_Date,
                                      D.DEGREASON = pos_4,
                                      D.Asset_Norm = pos_5;
                                      
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.UpgDate = NULL,
                                      A.FlgDeg = 'N',
                                      A.NPIDt = NULL,
                                      A.DBTDate = NULL,
                                      A.FlgUpg = 'N';
         /* END OF MOC CHANGES */
         /*
         ------------------------UPGRAD CUSTOMER ACCOUNT--------------------

         UPDATE A SET FLGUPG='N'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         WHERE    A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey 


         IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
               DROP TABLE #TEMPTABLE

         SELECT A.RefIssuerID,TOTALCOUNT  INTO #TEMPTABLE FROM 
         (
         SELECT A.RefIssuerID,COUNT(1) TOTALCOUNT FROM 
         CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
         GROUP BY A.RefIssuerID
         )
         A INNER JOIN 
         (
         SELECT B.RefIssuerID,COUNT(1) TOTALDPD_MAXCOUNT 
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         WHERE (ISNULL(B.DPD,0)<=0 AND [DPD_BS_Date]<=365 )
            and ISNULL(FinalAssetClassAlt_Key,1) not in(1)
           AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
          GROUP BY B.RefIssuerID
         --
         SELECT B.RefIssuerID,COUNT(1) TOTALDPD_MAXCOUNT 
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail B
         	INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail A
         		ON A.InvEntityId=B.InvEntityId
         		AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
         WHERE (		(a.InvestmentNature='EQUITY' AND ISNULL(MTMValueINR,0)>=1) 					
         		OR (ISNULL(a.InvestmentNature,'')<>'EQUITY' AND  ISNULL(B.DPD,0)<=0) 
         	   )
            and ISNULL(FinalAssetClassAlt_Key,1) not in(1)
           AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
          GROUP BY B.RefIssuerID
          --
         ) B ON A.RefIssuerID=B.RefIssuerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


         ------  -------- UPGRADING CUSTOMER------------- Same Upgrade Code is applicable in Pro.UpgradeCustomerAccount SP 2102023 --- Sudesh

         --UPDATE A SET A.FlgUpg='U'
         --FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A INNER JOIN #TEMPTABLE B ON A.RefIssuerID=B.RefIssuerID
         --WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

         UPDATE A SET A.FlgUpg='U'
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         INNER JOIN #TEMPTABLE B ON A.RefIssuerID=B.RefIssuerID
         				INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail Bb
         					ON A.InvEntityId =bb.InvEntityId

         					AND bb.EffectiveFromTimeKey <=@TIMEKEY AND bb.EffectiveToTimeKey >=@TIMEKEY
         				INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail Cc
         					ON Cc.IssuerEntityId=bb.IssuerEntityId
         					AND Cc.EffectiveFromTimeKey <=@TIMEKEY AND Cc.EffectiveToTimeKey >=@TIMEKEY

         WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
          AND ASSET_NORM='NORMAL'



         UPDATE A SET  A.UpgDate=@PROCESSDATE
                      ,A.DegReason=NULL
         			 ,A.AssetClass_AltKey=1
         			 ,A.FinalAssetClassAlt_Key=1
         			 ,A.FlgDeg='N'
         			 ,A.NPIDt=null
                      ,A.FlgUpg='U'
         			 FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         WHERE  ISNULL(A.FlgUpg,'U')='U' 
         AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


         --=======Added by Mandeep Date 12-12-2022(To remove upgrade flag and upgrade date from loss accounts)============================================================================
         UPDATE A SET  A.UpgDate=NULL
                      ,A.FlgUpg=NULL
         			 FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         WHERE 
         ISNULL(A.FinalAssetClassAlt_Key,1)>1
         AND A.NPIDt IS NOT NULL
         AND A.FlgUpg='U'
         AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

         UPDATE A 
         SET
         A.DEGREASON=NULL
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         WHERE 
         A.FlgUpg='U'
         AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey



         ----UPDATE A SET A.FinalAssetClassAlt_Key=2
         ----			,A.NPIDt='2021-09-19'
         ----			,A.FLGDEG='N'
         ----FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         ----INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail Bb
         ----	ON A.InvEntityId =bb.InvEntityId
         ----	AND bb.EffectiveFromTimeKey <=@TIMEKEY AND bb.EffectiveToTimeKey >=@TIMEKEY
         ----INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail Cc
         ----	ON Cc.IssuerEntityId=bb.IssuerEntityId
         ----	AND Cc.EffectiveFromTimeKey <=@TIMEKEY AND Cc.EffectiveToTimeKey >=@TIMEKEY
         ----WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
         ----AND isnull(UcifId,'') IN('RBL008827709','RBL003034380','RBL002980785')   --  mannual npa as per RBL team Mr. Divakar  email dated  17-09-2021 time 14:12 for marked Manual NPA forcefully --
         ----and FinalAssetClassAlt_Key >1

         ----------------------PROVISION ALT KEY ALL  ACCOUNTS----------------------------------
         --   commented ;rovision code -  provision updating from seperate SP  in final asset class and npat date updation
         UPDATE A SET PROVISIONALT_KEY=0
         from CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail  A
         where  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)



         UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
         ----SELECT *
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
              AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
         	 INNER JOIN RBL_MISDB_PROD.DIMPROVISION_SEG d
         		ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
         		--AND A.DPD BETWEEN d.LowerDPD AND d.UpperDPD
         		AND c.AssetClassShortName=d.PROVISIONSHORTNAMEENUM
         WHERE  C.ASSETCLASSGROUP='NPA'  AND
          (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
           and d.SEGMENT='IRAC'

          UPDATE A 
         	SET TotalProvison =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
         				                    THEN BookValueINR
         						    ELSE (ISNULL(A.BookValueINR,0) * ISNULL(C.PROVISIONUNSECURED,0)/100 )  
         							 END)
         se
         	FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A  
         	INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
         	                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
         	                            AND ISNULL(A.AssetClass_AltKey,1) =B.ASSETCLASSALT_KEY 
         	INNER JOIN RBL_MISDB_PROD.DIMPROVISION_SEG C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
         	                          AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
         	                          AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 

         	WHERE  AssetClass_AltKey>1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  



          -- STD PROVISION ALTKEY --
         UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
         ----SELECT *
         FROM   CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
              AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
         	 INNER JOIN DimProvision_SegSTD d
         		ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
         		  and d.ProvisionName='Other Portfolio' 
         WHERE  C.ASSETCLASSGROUP='STD'  AND
          (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)


         -- STD PROVISION maount --
          UPDATE A 
         	SET TotalProvison =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
         				                    THEN BookValueINR
         						    ELSE (ISNULL(A.BookValueINR,0) * ISNULL(C.PROVISIONUNSECURED,0)/100 )  
         							 END)

         	FROM  CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A  
         	INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
         	                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
         	                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =B.ASSETCLASSALT_KEY 
         	INNER JOIN DimProvision_SegStd C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
         	                          AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
         	                          AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 
         	WHERE  FinalAssetClassAlt_Key=1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  

          OPTION(RECOMPILE)

         --
         */
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'InvestmentDataProcessing';
         --------------Added for DashBoard 04-03-2021
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET CompletedCount = CompletedCount + 1
          WHERE  BandName = 'ASSET CLASSIFICATION';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InvestmentDataProcessing';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDATAPROCESSING" TO "ADF_CDR_RBL_STGDB";
