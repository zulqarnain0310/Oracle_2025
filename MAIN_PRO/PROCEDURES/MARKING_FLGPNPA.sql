--------------------------------------------------------
--  DDL for Procedure MARKING_FLGPNPA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."MARKING_FLGPNPA" /*=========================================
AUTHER : TRILOKI SHANKER KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-09-2019
DESCRIPTION : MARKING OF FlgPNPA AND DEG REASON 
EXEC [PRO].[Marking_FlgPNPA] 26281
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN
   DECLARE  V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         --declare @TIMEKEY int=26279
         v_ProcessDate VARCHAR2(200);
         ----DECLARE @PNPAProcessDate DATE  =(SELECT EOMONTH(DATE) FROM RBL_MISDB_PROD.SYSDAYMATRIX WHERE CAST(DATE AS DATE) =@ProcessDate)--(SELECT DATE FROM RBL_MISDB_PROD.SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY
         v_PNPAProcessDate VARCHAR2(200);--APPLIED LOGIC OF 30DAYS ROLLING PERIOD AS ADVISED BY sITARAM sIR ON CALL AFTER DISCUSSED WITH sHARMA sIR AND aSHISH SIR
         v_PNPA_DAYS NUMBER(10,0) ;

      BEGIN

        SELECT DATE_ INTO v_ProcessDate
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TIMEKEY ;         
        v_PNPAProcessDate := utils.dateadd('DD', 30, v_ProcessDate);
        v_PNPA_DAYS := utils.datediff('DAY', v_PROCESSDATE, v_PNPAProcessDate);

         /*--------------------INTIAL LEVEL FlgPNPA SET N-------------------------------------------- */
         MERGE INTO GTT_AccountCal A
         USING (SELECT A.ROWID row_id
         FROM GTT_AccountCal A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgPNPA = 'N',
                                      A.PNPA_DATE = NULL,
                                      A.PnpaAssetClassAlt_key = NULL,
                                      A.PNPA_Reason = NULL;
         MERGE INTO GTT_CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id
         FROM GTT_CUSTOMERCAL A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgPNPA = 'N',
                                      PNPA_Dt = NULL,
                                      PNPA_Class_Key = NULL;
         /*---------------UPDATE FlgPNPA FLAG AT ACCOUNT LEVEL----------------------------------------------------*/
         MERGE INTO GTT_AccountCal A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN ( (A.DPD_INTSERVICE + v_PNPA_DAYS) >= A.REFPERIODINTSERVICE ) THEN 'Y'
         WHEN ( (A.DPD_NOCREDIT + v_PNPA_DAYS) >= A.REFPERIODNOCREDIT ) THEN 'Y'
         WHEN ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= A.REFPERIODOVERDUE ) THEN 'Y'
         WHEN ( (A.DPD_STOCKSTMT + v_PNPA_DAYS) >= A.REFPERIODSTKSTATEMENT ) THEN 'Y'
         WHEN ( (A.DPD_RENEWAL + v_PNPA_DAYS) >= A.RefPeriodReview ) THEN 'Y'
         WHEN ( (A.DPD_Overdrawn + v_PNPA_DAYS) >= A.REFPERIODOVERDRAWN ) THEN 'Y'
         ELSE 'N'
            END) AS FlgPNPA
         FROM GTT_AccountCal A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( a.FinalAssetClassAlt_Key IN ( SELECT AssetClassAlt_Key 
                                                FROM RBL_MISDB_PROD.DimAssetClass 
                                                 WHERE  AssetClassShortNameEnum IN ( 'STD' )

                                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                                          AND EffectiveToTimeKey >= v_TIMEKEY )
          )
           AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )
           AND ( NVL(B.FlgProcessing, 'N') = 'N' )
           AND NVL(A.FLGMOC, 'N') <> 'Y'
           AND NVL(A.BALANCE, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgPNPA = src.FlgPNPA;
         DELETE FROM GTT_PNPA_REASON_DATE;
         /*----------------------------------HANDLE TO RESTRUCTURE ACCOUNT ----------------------------------*/
         --UPDATE A SET A.FlgPNPA='Y',a.PNPA_Reason='Account Restructured after 01-04-2015', A.PNPA_DATE=@PNPAPROCESSDATE
         --FROM PRO.AccountCal A INNER JOIN Curdat.AdvAcRestructureDetail B ON A.AccountEntityID=B.AccountEntityId
         --AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)
         --WHERE B.RestructureDt IS NOT NULL AND RestructureDt >= '2015-04-01' and RestructureDt >= DATEADD(YEAR,-1,@PNPAPROCESSDATE) AND ISNULL(FinalAssetClassAlt_Key,1)=1 AND ISNULL(A.Balance,0)>0
         /*-------------------------REVERSING DEGRADED ACCOUNT THROUGH NORMAL PROCESS--------------*/
         ----UPDATE B SET B.FlgPNPA=
         ----(CASE WHEN ISNULL(SDR_INVOKED,'N')='Y' AND  DATEADD(DAY,@PNPA_DAYS, SDR_REFER_DATE) >DATEADD(MONTH,-18,@PNPAPROCESSDATE) THEN 'N'
         ----ELSE B.FlgPNPA
         ---- END)
         ---- ,b.PNPA_Reason=(CASE WHEN ISNULL(SDR_INVOKED,'N')='Y' AND  DATEADD(DAY,@PNPA_DAYS, SDR_REFER_DATE) >DATEADD(MONTH,-18,@PNPAPROCESSDATE) THEN null
         ----ELSE b.PNPA_Reason
         ---- END)
         ---- ,B.PNPA_DATE=(CASE WHEN ISNULL(SDR_INVOKED,'N')='Y' AND  DATEADD(DAY,@PNPA_DAYS, SDR_REFER_DATE) >DATEADD(MONTH,-18,@PNPAPROCESSDATE) THEN  NULL ELSE B.PNPA_DATE END )
         ----FROM  Curdat.AdvAcRestructureDetail A INNER JOIN PRO.AccountCal
         ---- B ON A.AccountEntityId=B.AccountEntityID
         ---- AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
         ---- WHERE  CustomerEntityID  NOT IN(SELECT CustomerEntityID FROM AdvAcProjectDetail WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
         ---- AND   A.SDR_REFER_DATE IS NOT NULL   AND ISNULL(FinalAssetClassAlt_Key,1)=1 AND ISNULL(B.Balance,0)>0
         /*-------------------------ASSIGNE PNPA REASON-------------------------------------------------*/
         
         INSERT INTO GTT_PNPA_REASON_DATE
           ( SELECT A.AccountEntityID ,
                    utils.dateadd('DAY', -(A.DPD_INTSERVICE + v_PNPA_DAYS - NVL(A.REFPERIODINTSERVICE, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    'DEGRADE BY INT NOT SERVICED' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND ( (A.DPD_INTSERVICE + v_PNPA_DAYS) >= NVL(REFPERIODINTSERVICE, 0) ) )
             UNION 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_OVERDRAWN + v_PNPA_DAYS - NVL(REFPERIODOVERDRAWN, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    'DEGRADE BY CONTI EXCESS' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND ( (A.DPD_OVERDRAWN + v_PNPA_DAYS) >= NVL(REFPERIODOVERDRAWN, 0) ) )
             UNION ALL 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_NOCREDIT + v_PNPA_DAYS - NVL(RefPeriodNoCredit, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    'DEGRADE BY NO CREDIT' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND (A.DPD_NOCREDIT + v_PNPA_DAYS) >= NVL(RefPeriodNoCredit, 0) )
             UNION ALL 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_OVERDUE + v_PNPA_DAYS - NVL(RefPeriodOverdue, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    'DEGRADE BY OVERDUE' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= NVL(RefPeriodOverdue, 0) ) )
             UNION ALL 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_OVERDUE + v_PNPA_DAYS - NVL(RefPeriodOverdue, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    'DEGRADE BY DEBIT BALANCE' PNPA_Reason  
             FROM GTT_AccountCal A
                    JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                    AND ( C.EffectiveFromTimeKey <= v_TimeKey
                    AND C.EffectiveToTimeKey >= v_TimeKey )
              WHERE  ( A.FlgPNPA = 'Y'
                       AND ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= NVL(RefPeriodOverdue, 0) ) )
                       AND A.DebitSinceDt IS NOT NULL
                       AND NVL(C.SrcSysProductCode, 'N') = 'SAVING'
             UNION ALL 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_STOCKSTMT + v_PNPA_DAYS - NVL(RefPeriodStkStatement, 0)), v_PNPAProcessDate) PNPA_DATE  ,
                    ' DEGRADE BY STOCK STATEMENT' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND (A.DPD_STOCKSTMT + v_PNPA_DAYS) >= NVL(RefPeriodStkStatement, 0) )
             UNION ALL 
             SELECT A.ACCOUNTENTITYID ,
                    utils.dateadd('DAY', -(A.DPD_RENEWAL + v_PNPA_DAYS - NVL(RefPeriodReview, 0)), v_PNPAPROCESSDATE) PNPA_DATE  ,
                    ' DEGRADE BY REVIEW DUE DATE' PNPA_Reason  
             FROM GTT_AccountCal A
              WHERE  ( A.FlgPNPA = 'Y'
                       AND (A.DPD_RENEWAL + v_PNPA_DAYS) >= NVL(RefPeriodReview, 0) ) );
         
            MERGE INTO GTT_AccountCal A 
            USING (SELECT A.ROWID row_id, B.PNPA_DATE, B.PNPA_Reason
            FROM GTT_AccountCal a
                   JOIN (
                            SELECT AccountEntityID ,
                                           MIN(PNPA_DATE)  PNPA_DATE  ,
                                           STRING_AGG(PNPA_Reason, ',') PNPA_Reason  
                   FROM GTT_PNPA_REASON_DATE 
                   GROUP BY AccountEntityID  
                   ) B   ON a.AccountEntityID = b.AccountEntityID ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.PNPA_DATE = src.PNPA_DATE,
                                         A.PNPA_Reason = src.PNPA_Reason
            ;
         /*			
         UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+',DEGRADE BY INT NOT SERVICED' 
                      ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_INTSERVICE+@PNPA_DAYS-ISNULL(A.REFPERIODINTSERVICE,0)),@PNPAProcessDate)
         FROM PRO.AccountCal A 
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  --AND ABD.ReferencePeriod=91
         ----INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE  (A.FlgPNPA='Y' AND ((A.DPD_INTSERVICE+@PNPA_DAYS)>=ISNULL(REFPERIODINTSERVICE,0))) 
         --AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
         ----AND C.NPANorms='DPD91'


         UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY CONTI EXCESS'
                    ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDRAWN+@PNPA_DAYS-ISNULL(REFPERIODOVERDRAWN,0)),@PNPAProcessDate)
         FROM PRO.AccountCal A 
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  --AND ABD.ReferencePeriod=91
         ----INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDRAWN+@PNPA_DAYS)>=ISNULL(REFPERIODOVERDRAWN,0))) 
         --AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
         ----AND C.NPANorms='DPD91'

         UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY OVERDUE'    
               ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)          
         FROM PRO.AccountCal A 
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  ----AND ABD.ReferencePeriod=91
         ----INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE  (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0)))  
         ----AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
         ----AND C.NPANorms='DPD91'


         UPDATE A SET A.PNPA_Reason= 'DEGRADE BY DEBIT BALANCE'    
               ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)          
         FROM PRO.AccountCal A
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  ----AND ABD.ReferencePeriod=91

         INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0)))  
         AND A.DebitSinceDt IS NOT NULL AND ISNULL(C.SrcSysProductCode,'N')='SAVING'
         --AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
         ----AND C.NPANorms='DPD91'


         UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY NO CREDIT'   
                  ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_NOCREDIT+@PNPA_DAYS-ISNULL(RefPeriodNoCredit,0) ),@PNPAProcessDate)
         FROM PRO.AccountCal A --INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  ----AND ABD.ReferencePeriod=91
         --INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE   (A.FlgPNPA='Y' AND (A.DPD_NOCREDIT+@PNPA_DAYS)>=ISNULL(RefPeriodNoCredit,0))
         ---AND C.NPANorms='DPD91'


         UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY STOCK STATEMENT' 
                     ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_STOCKSTMT+@PNPA_DAYS-ISNULL(RefPeriodStkStatement,0) ),@PNPAProcessDate)   
         FROM PRO.AccountCal A ---INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  ----AND ABD.ReferencePeriod=91
         ---INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         WHERE  (A.FlgPNPA='Y' AND (A.DPD_STOCKSTMT+@PNPA_DAYS)>=ISNULL(RefPeriodStkStatement,0))  
         --AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
         ---AND C.NPANorms='DPD91'

         UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY REVIEW DUE DATE'   
         ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_RENEWAL+@PNPA_DAYS-ISNULL(RefPeriodReview,0) ),@PNPAPROCESSDATE)    
         FROM PRO.AccountCal A--- INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
         ----INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
          INNER JOIN AdvAcBasicDetail ABD
         	  ON A.AccountEntityID=ABD.AccountEntityId
         	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         	  ----AND ABD.ReferencePeriod=91
         WHERE  (A.FlgPNPA='Y' AND (A.DPD_RENEWAL+@PNPA_DAYS)>=ISNULL(RefPeriodReview,0)) 
          --AND isnull(C.ProductSubGroup,'N') NOT in('KCC')
          -----AND C.NPANorms='DPD91'



         --------UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+',DEGRADE BY INT NOT SERVICED' 
         --------             ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_INTSERVICE+@PNPA_DAYS-ISNULL(RefPeriodIntService,0)),@PNPAProcessDate)
         --------FROM PRO.AccountCal A 
         -------- INNER JOIN AdvAcBasicDetail ABD
         --------	  ON A.AccountEntityID=ABD.AccountEntityId
         --------	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         --------	  ------AND ABD.ReferencePeriod=366

         ----------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         --------WHERE  (A.FlgPNPA='Y' AND ((A.DPD_INTSERVICE+@PNPA_DAYS)>=ISNULL(RefPeriodIntService,0))) 
         ----------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         ------------AND C.NPANorms='DPD366'

         --------UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY CONTI EXCESS'
         --------           ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDRAWN+@PNPA_DAYS-ISNULL(REFPERIODOVERDRAWN,0)),@PNPAProcessDate)
         --------FROM PRO.AccountCal A 
         -------- INNER JOIN AdvAcBasicDetail ABD
         --------	  ON A.AccountEntityID=ABD.AccountEntityId
         --------	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         --------	  ----AND ABD.ReferencePeriod=366

         -----------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         --------WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDRAWN+@PNPA_DAYS)>=ISNULL(REFPERIODOVERDRAWN,0))) 
         ----------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         -----------AND C.NPANorms='DPD366'


         --------UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY OVERDUE'    
         --------      ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)          
         --------FROM PRO.AccountCal A 
         -------- INNER JOIN AdvAcBasicDetail ABD
         --------	  ON A.AccountEntityID=ABD.AccountEntityId
         --------	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         --------	  ----AND ABD.ReferencePeriod=366

         -----------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         --------WHERE  (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0)))  
         ----------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         -----------AND C.NPANorms='DPD366'


         ----UPDATE A SET A.PNPA_Reason= 'DEGRADE BY DEBIT BALANCE'    
         ----      ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)          
         ----FROM PRO.AccountCal A

         ---- INNER JOIN AdvAcBasicDetail ABD
         ----	  ON A.AccountEntityID=ABD.AccountEntityId
         ----	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         ----	  AND ABD.ReferencePeriod=366
         ----	INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         ----WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0)))  
         ----AND A.DebitSinceDt IS NOT NULL AND ISNULL(C.SrcSysProductCode,'N')='SAVING'
         ------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         -------AND C.NPANorms='DPD366'


         ----UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY NO CREDIT'   
         ----         ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_NOCREDIT+@PNPA_DAYS-ISNULL(RefPeriodNoCredit,0) ),@PNPAProcessDate)
         ----FROM PRO.AccountCal A --INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
         ---- INNER JOIN AdvAcBasicDetail ABD
         ----	  ON A.AccountEntityID=ABD.AccountEntityId
         ----	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         ----	  ----AND ABD.ReferencePeriod=366
         --------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         ----WHERE   (A.FlgPNPA='Y' AND (A.DPD_NOCREDIT+@PNPA_DAYS)>=ISNULL(RefPeriodNoCredit,0))
         -------AND C.NPANorms='DPD366'

         ----UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY STOCK STATEMENT' 
         ----            ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_STOCKSTMT+@PNPA_DAYS-RefPeriodStkStatement ),@PNPAProcessDate)   
         ----FROM PRO.AccountCal A ---INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
         ---- INNER JOIN AdvAcBasicDetail ABD
         ----	  ON A.AccountEntityID=ABD.AccountEntityId
         ----	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         ----	  ----AND ABD.ReferencePeriod=366

         -------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         ----WHERE  (A.FlgPNPA='Y' AND (A.DPD_STOCKSTMT+@PNPA_DAYS)>=ISNULL(RefPeriodStkStatement,0))  
         ------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         ------AND C.NPANorms='DPD366'

         ----UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY REVIEW DUE DATE'   
         ----,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_RENEWAL+@PNPA_DAYS-ISNULL(RefPeriodReview,0) ),@PNPAPROCESSDATE)    
         ----FROM PRO.AccountCal A--- INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI
         ---- INNER JOIN AdvAcBasicDetail ABD
         ----	  ON A.AccountEntityID=ABD.AccountEntityId
         ----	  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)
         ----	  ----AND ABD.ReferencePeriod=366

         ------INNER JOIN RBL_MISDB_PROD.DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         ----WHERE  (A.FlgPNPA='Y' AND (A.DPD_RENEWAL+@PNPA_DAYS)>=ISNULL(RefPeriodReview,0)) 
         ------AND isnull(C.ProductSubGroup,'N')  in('KCC')
         --------AND C.NPANorms='DPD366'
         */
         /*-------------------UPDATE PNPA FLAG AT CUSTOMER LEVEL------------------------------------------*/
         MERGE INTO GTT_CUSTOMERCAL B 
         USING (SELECT B.ROWID row_id, 'Y'
         FROM GTT_AccountCal A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE A.FlgPNPA = 'Y'
           AND ( B.FlgProcessing = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FlgPNPA = 'Y';
         IF utils.object_id('TEMPDB..GTT_TEMPTABLEPNPA') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLEPNPA ';
         END IF;
         
         DELETE FROM GTT_TEMPTABLEPNPA;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLEPNPA');

         INSERT INTO GTT_TEMPTABLEPNPA ( 
         	SELECT A.CustomerEntityID ,
                 MIN(A.PNPA_DATE)  PNPA_DATE  ,
                 ( SELECT AssetClassAlt_Key 
                   FROM RBL_MISDB_PROD.DimAssetClass 
                    WHERE  AssetClassShortName = 'SUB'
                             AND EffectiveFromTimeKey <= v_Timekey
                             AND EffectiveToTimeKey >= v_Timekey ) PNPA_Class_Key  
         	  FROM GTT_AccountCal A
                   JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
         	 WHERE  B.FLGPNPA = 'Y'
                    AND ( B.FLGPROCESSING = 'N' )
         	  GROUP BY A.CustomerEntityID );
         MERGE INTO GTT_CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, B.PNPA_DATE, 'Y', b.PNPA_Class_Key
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_TEMPTABLEPNPA B   ON A.CustomerEntityID = B.CustomerEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PNPA_DT = src.PNPA_DATE,
                                      A.FlgPNPA = 'Y',
                                      A.PNPA_Class_Key = src.PNPA_Class_Key;
         MERGE INTO GTT_AccountCal A
         USING (SELECT a.ROWID row_id, b.PNPA_Dt, 'Y', b.PNPA_Class_Key
         FROM GTT_AccountCal A
                JOIN GTT_CUSTOMERCAL b   ON a.CustomerEntityID = b.CustomerEntityID
                AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )
                AND b.FlgPNPA = 'Y' ) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.PNPA_DATE = src.PNPA_Dt,
                                      a.FlgPNPA = 'Y',
                                      a.PnpaAssetClassAlt_key = src.PNPA_Class_Key;
         MERGE INTO GTT_AccountCal A
         USING (SELECT A.ROWID row_id, 'Link By AccountId' || ' ' || B.CustomerAcID AS PNPA_Reason
         FROM GTT_AccountCal A
                JOIN GTT_AccountCal B   ON A.CustomerEntityID = B.CustomerEntityID
                AND A.FlgPNPA = 'Y'
                AND A.FlgPNPA = 'Y'

                --AND A.CustomerEntityID= 1376663
                AND A.PNPA_Reason IS NULL
                AND B.PNPA_Reason IS NOT NULL
                AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.PNPA_Reason
                                      --SELECT A.PNPA_Reason,B.PNPA_Reason, *  
                                       = src.PNPA_Reason;
         /*-------------------UPDATE PNPA FLAG AT UCIF LEVEL------------------------------------------*/
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, 'Y'
         FROM GTT_AccountCal A
                JOIN GTT_CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE A.FlgPNPA = 'Y'
           AND ( B.FlgProcessing = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FlgPNPA = 'Y';
         IF utils.object_id('TEMPDB..GTT_CTE_CUSTOMERWISEBALANCEP') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CTE_CUSTOMERWISEBALANCEP ';
         END IF;
         DELETE FROM GTT_CTE_CUSTOMERWISEBALANCEP;
         UTILS.IDENTITY_RESET('GTT_CTE_CUSTOMERWISEBALANCEP');

         INSERT INTO GTT_CTE_CUSTOMERWISEBALANCEP ( 
         	SELECT A.UcifEntityID ,
                 MIN(A.PNPA_DATE)  PNPA_DATE  ,
                 ( SELECT AssetClassAlt_Key 
                   FROM RBL_MISDB_PROD.DimAssetClass 
                    WHERE  AssetClassShortName = 'SUB'
                             AND EffectiveFromTimeKey <= v_TIMEKEY
                             AND EffectiveToTimeKey >= v_TIMEKEY ) PNPA_Class_Key  
         	  FROM GTT_AccountCal A
                   JOIN GTT_CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID
         	 WHERE  B.FLGPNPA = 'Y'
                    AND ( B.FLGPROCESSING = 'N' )
         	  GROUP BY A.UcifEntityID );
         MERGE INTO GTT_CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.PNPA_DATE, 'Y', b.PNPA_Class_Key
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_CTE_CUSTOMERWISEBALANCEP B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PNPA_DT = src.PNPA_DATE,
                                      A.FlgPNPA = 'Y',
                                      a.PNPA_Class_Key = src.PNPA_Class_Key;
         MERGE INTO GTT_AccountCal A
         USING (SELECT a.ROWID row_id, b.PNPA_DATE, 'Y', b.PNPA_Class_Key
         FROM GTT_AccountCal A
                JOIN GTT_CTE_CUSTOMERWISEBALANCEP b   ON a.UcifEntityID = b.UcifEntityID
                AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' ) ) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.PNPA_DATE = src.PNPA_DATE,
                                      a.FlgPNPA = 'Y',
                                      a.PnpaAssetClassAlt_key = src.PNPA_Class_Key;
         MERGE INTO GTT_AccountCal A
         USING (SELECT A.ROWID row_id, 'PERCOLATION BY UCIF ' || ' ' || B.UCIF_ID AS PNPA_Reason
         FROM GTT_AccountCal A
                JOIN GTT_AccountCal b   ON a.UcifEntityID = b.UcifEntityID 
          WHERE b.FlgPNPA = 'Y'
           AND A.FlgPNPA = 'Y'
           AND A.PNPA_Reason IS NULL
           AND B.PNPA_Reason IS NOT NULL
           AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.PNPA_Reason = src.PNPA_Reason;
        
         ------/*----------------UPDATE FOR PnpaAssetClassAlt_key--------------------------------------------------*/
        
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Marking_FlgPNPA';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLEPNPA ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CTE_CUSTOMERWISEBALANCEP ';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

    V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Marking_FlgPNPA';

   END;END;
   
EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGPNPA" TO "ADF_CDR_RBL_STGDB";
