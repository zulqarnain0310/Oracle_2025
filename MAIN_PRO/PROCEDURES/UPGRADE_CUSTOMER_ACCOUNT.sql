--------------------------------------------------------
--  DDL for Procedure UPGRADE_CUSTOMER_ACCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : FIRST UPGRADE TO CUSTOMER LEVEL  AFTER THAT ACCOUNT LEVEL
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
             v_PROCESSDATE VARCHAR2(200) ;
   BEGIN
      DECLARE
      V_MAX INT ;
      V_MIN INT;
      V_DysOfDelay INT:=90;
      V_REFPERIODLATESTBS_DATE SMALLINT:=360;
         /*check the customer when all account to cutomer dpdmax must be 0*/


      BEGIN
               SELECT Date_ INTO v_PROCESSDATE 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;
          
        UPDATE GTT_ACCOUNTCAL SET FLGUPG='N';
        UPDATE GTT_CUSTOMERCAL SET FLGUPG='N';

         IF utils.object_id('TEMPDB..GTT_TEMPTABLE') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE ';
         END IF;
         DELETE FROM GTT_TEMPTABLE;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLE');

         INSERT INTO GTT_TEMPTABLE ( 
         	SELECT A.UCIF_ID ,
                 TOTALCOUNT 
         	  FROM ( SELECT A.UCIF_ID ,COUNT(1)  TOTALCOUNT  FROM GTT_CUSTOMERCAL A
                          JOIN GTT_ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                    WHERE  ( A.FlgProcessing = 'N' ) AND A.UCIF_ID IS NOT NULL AND B.ASSET_NORM NOT IN ('ALWYS_STD')
                     GROUP BY A.UCIF_ID 
                     UNION ALL
                        SELECT B.UCIFID,COUNT(1) TOTALCOUNT FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B
                        ON A.RefIssuerID=B.IssuerID
                        AND A.EffectiveFromTimeKey<=V_TIMEKEY AND A.EffectiveToTimeKey>=V_TIMEKEY
                        AND B.EffectiveFromTimeKey<=V_TIMEKEY AND B.EffectiveToTimeKey>=V_TIMEKEY
                        AND A.Asset_Norm NOT IN ('ALWYS_STD')
                        GROUP BY B.UCIFID
                        UNION ALL
                        SELECT A.UCIC_ID,COUNT(1) TOTALCOUNT FROM 
                        CurDat_RBL_MISDB_PROD.DerivativeDetail A
                        WHERE A.EffectiveFromTimeKey<=V_TIMEKEY AND A.EffectiveToTimeKey>=V_TIMEKEY
                        GROUP BY A.UCIC_ID
                     ) A
                   JOIN ( SELECT A.UCIF_ID ,
                                 COUNT(1)  TOTALDPD_MAXCOUNT  
                          FROM GTT_CUSTOMERCAL A
                                 JOIN GTT_ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                           WHERE  ( B.DPD_IntService <= B.RefPeriodIntServiceUPG
                                    AND B.DPD_NoCredit <= B.RefPeriodNoCreditUPG
                                    AND B.DPD_Overdrawn <= B.RefPeriodOverDrawnUPG
                                    AND B.DPD_Overdue <= B.RefPeriodOverdueUPG
                                    AND B.DPD_Renewal <= B.RefPeriodReviewUPG
                                    AND B.DPD_StockStmt <= B.RefPeriodStkStatementUPG )
                                    AND B.InitialAssetClassAlt_Key NOT IN ( 1 )

                                    AND ( A.FlgProcessing = 'N' )
                                    AND B.Asset_Norm NOT IN ( 'ALWYS_NPA','ALWYS_STD' )

                                    AND NVL(A.MocStatusMark, 'N') = 'N'
                                    AND A.UCIF_ID IS NOT NULL
                                    AND NVL(B.UNSERVIEDINT,0)=0 
                                    AND  NVL(B.AccountStatus,'N')<>'Z'
                                    AND ( (FacilityType IN('CC','OD') and NVL(IntOverdue,0)=0) OR (NVL(FacilityType,'') NOT IN('CC','OD')))
                                    
                                    UNION ALL
                                    SELECT B.UCIFID,COUNT(1) TOTALDPD_MAXCOUNT FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                                    INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B
                                    ON A.RefIssuerID=B.IssuerID
                                    AND A.EffectiveFromTimeKey<=V_TIMEKEY AND A.EffectiveToTimeKey>=V_TIMEKEY
                                    AND B.EffectiveFromTimeKey<=V_TIMEKEY AND B.EffectiveToTimeKey>=V_TIMEKEY
                                    WHERE
                                    ((NVL(A.DPD_DivOverdue,0)<=0) and (NVL(A.PartialRedumptionDPD,0)<=0) AND NVL(DPD_BS_Date,0)<V_REFPERIODLATESTBS_DATE
                                    AND NVL(FinalAssetClassAlt_Key,1)<>1
                                    AND A.Asset_Norm NOT IN ('ALWYS_STD'))
                                    GROUP BY B.UCIFID
                                    UNION ALL
                                    SELECT A.UCIC_ID,COUNT(1) TOTALDPD_MAXCOUNT FROM 
                                    CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                                    WHERE A.EffectiveFromTimeKey<=V_TIMEKEY AND A.EffectiveToTimeKey>=V_TIMEKEY
                                    AND ( NVL(A.DPD,0)<=0
                                    AND NVL(FinalAssetClassAlt_Key,1)<>1)
                                    GROUP BY A.UCIC_ID
                                    ) B   ON A.UCIF_ID = B.UCIF_ID
                   AND A.TOTALCOUNT = B.TOTALDPD_MAXCOUNT );
         /*------ UPGRADING CUSTOMER-----------*/
         MERGE INTO GTT_CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'U'
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_TEMPTABLE B   ON A.UCIF_ID = B.UCIF_ID
                JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE ( NOT ( NVL(A.Asset_Norm, 'NORMAL') = 'ALWYS_NPA' )
           AND C.ASSETCLASSGROUP = 'NPA'
           AND NOT ( NVL(A.FlgDeg, 'N') = 'Y' ) )
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';
        
        MERGE INTO  CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
        --UPDATE A SET A.FlgUpg='U'
        USING (SELECT A.ROWID row_id, 'U'
        FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail D on A.RefIssuerID = D.IssuerID 
        AND A.EffectiveFromTimeKey <= V_TIMEKEY and A.EffectiveToTimeKey >= V_TIMEKEY
        AND D.EffectiveFromTimeKey <= V_TIMEKEY and D.EffectiveToTimeKey >= V_TIMEKEY
        INNER JOIN GTT_TEMPTABLE B ON D.Ucifid=B.UCIF_ID
         INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS C ON C.AssetClassAlt_Key=A.FinalAssetClassAlt_Key AND (C.EffectiveFromTimeKey<=V_TIMEKEY AND C.EffectiveToTimeKey>=V_TIMEKEY)
        WHERE  (not(NVL(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(NVL(A.FLGDEG,'N')='Y')) 
        )SRC 
        ON ( A.ROWID = src.row_id )
        WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';
        
        MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
        --UPDATE A SET A.FlgUpg='U'
        USING (SELECT A.ROWID ROW_ID,'U'
        FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A INNER JOIN GTT_TEMPTABLE B ON A.UCIC_ID=B.UCIF_ID
         INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS C ON C.AssetClassAlt_Key=A.FinalAssetClassAlt_Key AND (C.EffectiveFromTimeKey<=V_TIMEKEY AND C.EffectiveToTimeKey>=V_TIMEKEY)
        WHERE  
          C.ASSETCLASSGROUP ='NPA' AND not(NVL(A.FLGDEG,'N')='Y') 
          )SRC
          ON (A.ROWID=SRC.ROW_ID)
          WHEN MATCHED THEN UPDATE SET A.FlgUpg='U';
         
/* BUYOUT UPGARDE */


         IF utils.object_id('TEMPDB..GTT_TEMPTABLERefCustomerID') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLERefCustomerID ';
         END IF;
         DELETE FROM GTT_TEMPTABLERefCustomerID;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLERefCustomerID');

         INSERT INTO GTT_TEMPTABLERefCustomerID ( 
         	SELECT A.RefCustomerID ,
                 TOTALCOUNT 
         	  FROM ( SELECT A.RefCustomerID ,
                          COUNT(1)  TOTALCOUNT  
                   FROM GTT_CUSTOMERCAL A
                          JOIN GTT_ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID
                    WHERE  ( A.FlgProcessing = 'N' )
                             AND A.UCIF_ID IS NULL
                             AND A.RefCustomerID IS NOT NULL
                     GROUP BY A.RefCustomerID ) A
                   JOIN ( SELECT A.RefCustomerID ,
                                 COUNT(1)  TOTALDPD_MAXCOUNT  
                          FROM GTT_CUSTOMERCAL A
                                 JOIN GTT_ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID
                           WHERE  ( B.DPD_IntService <= B.RefPeriodIntServiceUPG
                                    AND B.DPD_NoCredit <= B.RefPeriodNoCreditUPG
                                    AND B.DPD_Overdrawn <= B.RefPeriodOverDrawnUPG
                                    AND B.DPD_Overdue <= B.RefPeriodOverdueUPG
                                    AND B.DPD_Renewal <= B.RefPeriodReviewUPG
                                    AND B.DPD_StockStmt <= B.RefPeriodStkStatementUPG )
                                    AND B.InitialAssetClassAlt_Key NOT IN ( 1 )

                                    AND ( A.FlgProcessing = 'N' )
                                    AND B.Asset_Norm NOT IN ( 'ALWYS_NPA','ALWYS_STD' )

                                    AND NVL(A.MocStatusMark, 'N') = 'N'
                                    AND A.UCIF_ID IS NULL
                                    AND A.RefCustomerID IS NOT NULL
                            GROUP BY A.RefCustomerID ) B   ON A.RefCustomerID = B.RefCustomerID
                   AND A.TOTALCOUNT = B.TOTALDPD_MAXCOUNT );
         /*-----------UPGRADING CUSTOMER----------*/
         MERGE INTO GTT_CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'U'
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_TEMPTABLERefCustomerID B   ON A.RefCustomerID = B.RefCustomerID
                JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE ( NOT ( NVL(A.Asset_Norm, 'NORMAL') = 'ALWYS_NPA' )
           AND C.ASSETCLASSGROUP = 'NPA'
           AND NOT ( NVL(A.FlgDeg, 'N') = 'Y' ) )
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';

-------Changes done in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---

         IF utils.object_id('TEMPDB..GTT_PANUPDATEUPGRADE') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PANUPDATEUPGRADE';
         END IF;
         DELETE FROM GTT_PANUPDATEUPGRADE;
         UTILS.IDENTITY_RESET('GTT_PANUPDATEUPGRADE');

        INSERT INTO GTT_PANUPDATEUPGRADE(
        SELECT A.PANNO,A.TotalCountMAX,B.TotalCount
        FROM
        (
        
        SELECT Count(1) TotalCountMAX,PANNO FROM GTT_CUSTOMERCAL WHERE PANNO IS NOT NULL
        GROUP BY PANNO
        ) A
        INNER JOIN
        (
        SELECT Count(1) TotalCount,PANNO FROM GTT_CUSTOMERCAL WHERE PANNO IS NOT NULL AND FLGUPG='U'
        GROUP BY PANNO
        
        ) B ON A.PANNO=B.PANNO AND A.TotalCountMAX <> B.TotalCount);


                MERGE INTO GTT_CUSTOMERCAL B
                USING(SELECT A.ROWID ROW_ID
                FROM GTT_PANUPDATEUPGRADE A
                INNER JOIN GTT_CUSTOMERCAL B
                ON A.PANNO=B.PANNO
                WHERE B.FLGUPG='U'
                )SRC
                ON (B.ROWID=SRC.ROW_ID)
                WHEN MATCHED THEN UPDATE SET B.FLGUPG='N' ;

/* RFESTR UPGRADE */

    MERGE INTO AdvAcRestructureCal A
    USING (SELECT A.ROWID ROW_ID,B.FlgUpg FlgUpg_B,C.FlgUpg FlgUpg_C,D.ParameterShortNameEnum
                FROM MAIN_PRO.AdvAcRestructureCal A
            INNER JOIN GTT_ACCOUNTCAL B
                ON A.AccountEntityId=B.AccountEntityID
            INNER JOIN GTT_CUSTOMERCAL C
                ON C.CustomerEntityID =B.CustomerEntityID
            INNER JOIN RBL_MISDB_PROD.DimParameter D ON D.EffectiveFromTimeKey <=V_TIMEKEY AND D.EffectiveToTimeKey>=V_TIMEKEY 
                                AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key
            WHERE  D.DimParameterName='TypeofRestructuring' 
                AND ParameterShortNameEnum IN('IRAC','OTHER','MSME_OLD','MSME_COVID','MSME_COVID_RF2','PRUDENTIAL')
                AND C.FlgUpg ='U'
            )SRC
            ON (A.ROWID=SRC.ROW_ID)
    WHEN MATCHED THEN
	UPDATE SET A.FLGUPG= CASE WHEN SRC.ParameterShortNameEnum IN('MSME_OLD','MSME_COVID','MSME_COVID_RF2')
								THEN
									(CASE WHEN----- DPD_Breach_Date IS NOT NULL  and commented by Amar - As disxussed with Ashish Sir on 27/04/2022 at 15:17 time for account should not upgrade in any case with specified period
											 (CASE WHEN NVL(SP_ExpiryDate,'1900-01-01')>=NVL(SP_ExpiryExtendedDate,'1900-01-01') 
													THEN SP_ExpiryDate ELSE SP_ExpiryExtendedDate END)>=V_PROCESSDATE
											THEN 'N'
										ELSE 
											SRC.FlgUpg_C
										END
									)
							WHEN SRC.ParameterShortNameEnum IN('PRUDENTIAL')
								THEN 'N'  -- AS DISCUSSED WITH aSHISH sIR - PRIDENTIAL ACCOUNTS NEVER WILL WILL UPGRADE- WILL BE NPA TILL THEN CLOSED
									--(CASE WHEN DPD_Breach_Date IS NOT NULL OR InvestmentGrade='N'
									--		THEN 'N'
									--	ELSE
									--		C.FlgUpg
									--	END
									--)
							WHEN SRC.ParameterShortNameEnum IN('IRAC','OTHER')
								THEN
									(CASE WHEN DPD_Breach_Date IS NOT NULL OR SP_ExpiryDate>=V_PROCESSDATE
											THEN 'N'
										ELSE
											SRC.FlgUpg_C
										END
									)
						ELSE SRC.FlgUpg_B
					END;

    MERGE INTO GTT_CUSTOMERCAL C
    USING(SELECT C.ROWID ROW_ID
	FROM MAIN_PRO.AdvAcRestructureCal A
		INNER JOIN GTT_ACCOUNTCAL B
			ON A.AccountEntityId=B.AccountEntityID
		INNER JOIN GTT_CUSTOMERCAL C
			ON C.CustomerEntityID =B.CustomerEntityID
		INNER JOIN RBL_MISDB_PROD.DimParameter D ON D.EffectiveFromTimeKey <=V_TIMEKEY AND D.EffectiveToTimeKey>=V_TIMEKEY 
			AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key
			AND D.DimParameterName='TypeofRestructuring' 
	WHERE A.FlgUpg ='N' AND C.FlgUpg ='U'
		 AND ParameterShortNameEnum IN('IRAC','OTHER','MSME_OLD','MSME_COVID','MSME_COVID_RF2','PRUDENTIAL')
         )SRC ON (C.ROWID=SRC.ROW_ID)
         WHEN MATCHED THEN 	UPDATE 
                            SET C.FLGUPG= 'N'
                            ,C.DegReason=',DEGRADEY BY RESTRUCTURE';

/* END OF RESTR UPGRADE */

/*pui UPGRADE */
    V_DysOfDelay :=90;

		MERGE INTO MAIN_PRO.PUI_CAL A
        USING (SELECT A.ROWID ROW_ID
		FROM MAIN_PRO.PUI_CAL A
			INNER JOIN GTT_ACCOUNTCAL B
				ON A.AccountEntityID=B.AccountEntityID
			WHERE b.FinalAssetClassAlt_Key>1
			AND B.DPD_Max=0 AND B.FlgUpg ='U'
            )SRC ON (A.ROWID=SRC.ROW_ID)
            WHEN MATCHED THEN UPDATE
			SET A.FLG_UPG =		(CASE 
									WHEN ActualDCCO_Date IS NOT NULL
										
												OR RevisedDCCO >V_PROCESSDATE
												OR (RevisedDCCO IS NULL AND FinnalDCCO_Date>V_PROCESSDATE)
										  
												AND (
														(NVL(CostOverRunPer,0)<=10)
														OR (NVL(RevisedDebt,0)<=NVL(OriginalDebt,0))
													 )
											THEN 'U'					
									WHEN ( TakeOutFinance='N' ---AND AssetClassSellerBookAlt_key>1
										 )
											THEN 'U'
								END);
        
        MERGE INTO GTT_CUSTOMERCAL C
        USING (SELECT A.ROWID ROW_ID
                FROM MAIN_PRO.PUI_CAL A
            	INNER JOIN GTT_CUSTOMERCAL C
			ON C.CustomerEntityID =A.CustomerEntityID
            WHERE A.Flg_Upg ='N' AND C.FlgUpg ='U'
            )SRC 
            ON (C.ROWID=SRC.ROW_ID)
    WHEN MATCHED THEN UPDATE SET C.FLGUPG= 'N';
	/*END OF PUI WORK*/

-------Changes done in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---

--Added By Mandeep for CoBorrower Work -------------------------------------------------------------


                    MERGE INTO MAIN_PRO.CoBorrowerCal A
                    USING(SELECT A.ROWID ROW_ID,B.FlgUpg,B.Asset_Norm
                    FROM MAIN_PRO.CoBorrowerCal A
                    INNER JOIN GTT_CUSTOMERCAL B
                    ON A.CustomerID=B.RefCustomerID
                    WHERE 
                    B.FlgUpg='U'
                    )SRC 
                    ON (A.ROWID=SRC.ROW_ID)
                    WHEN MATCHED THEN UPDATE SET 
                    A.FlgUpg=SRC.FlgUpg ,
                    A.Asset_Norm=SRC.Asset_Norm;
--UPDATE MAIN_PRO.CoBorrowerCal
--SET FLGUPG='N'
--WHERE FinalAssetClass_AltKey>1
--AND NVL(FlgUpg,'N')='N' --COMMENTED BY MANDEEP 25-09-2023



                MERGE INTO MAIN_PRO.CoBorrowerCal A 
                USING( SELECT A.ROWID ROW_ID
                FROM  MAIN_PRO.CoBorrowerCal A 
                INNER JOIN GTT_CUSTOMERCAL B
                ON A.CustomerID=B.RefCustomerID
                WHERE A.FinalAssetClass_AltKey>1
                AND NVL(A.FlgUpg,'N')='N'
                )SRC ON (A.ROWID=SRC.ROW_ID)
                WHEN MATCHED THEN UPDATE SET FLGUPG='N';



            V_MIN:=1;
            SELECT MAX(CNT)INTO V_MAX 
                FROM 
                (SELECT COUNT(UCIC) AS CNT FROM MAIN_PRO.CoBorrowerCal GROUP BY Cohort_No);
            

                WHILE V_MAX>=V_MIN
                LOOP
                        MERGE INTO MAIN_PRO.CoBorrowerCal B
                        USING (SELECT B.ROWID ROW_ID
                        FROM MAIN_PRO.CoBorrowerCal  A
                            inner join MAIN_PRO.CoBorrowerCal B
                            on B.MAINCUSTID=A.CustomerID
                            and A.CustomerType IN ('Coborrower','CO_OBLIGANT')
                            AND (NVL(A.FlgUpg,'N')='U' OR A.PERC_FinalAssetClass_AltKey=1)
                            AND B.InitialAssetclass_AltKey=1 AND B.PERC_FinalAssetClass_AltKey>1
                            AND B.DegradeReason LIKE '%Co Borrower NPA%'
                            )SRC
                            ON (B.ROWID=SRC.ROW_ID)
                            WHEN MATCHED THEN UPDATE  SET	B.FinalAssetClass_AltKey=1,
                                                            B.FINALNPADT=NULL,
                                                            B.DegradeReason=NULL;
                        
                    V_MIN:=V_MIN+1;
                    END LOOP;
                    END;


                        MERGE INTO MAIN_PRO.CoBorrowerCal A
                        USING ( SELECT A.ROWID ROW_ID
                        FROM MAIN_PRO.CoBorrowerCal A
                        INNER JOIN MAIN_PRO.CoBorrowerCal B
                            ON A.Cohort_No=B.Cohort_No
                            INNER JOIN GTT_CUSTOMERCAL C
                            ON B.CustomerID=C.RefCustomerID
                            WHERE NVL(A.FLGUPG,'N')='U' 
                            AND (NVL(B.FLGUPG,'S')='N'  )
                            AND B.FinalAssetClass_AltKey>1
                        )SRC 
                        ON (A.ROWID=SRC.ROW_ID)
                        WHEN MATCHED THEN UPDATE SET A.FLGUPG='N';


                        MERGE INTO GTT_CUSTOMERCAL A
                        USING (SELECT A.ROWID ROW_ID,B.FLGUPG
                        FROM GTT_CUSTOMERCAL A
                        INNER JOIN MAIN_PRO.CoBorrowerCal B
                        ON A.RefCustomerID=B.CustomerID
                        WHERE A.FLGUPG='U'
                        )SRC 
                        ON (A.ROWID=SRC.ROW_ID)
                        WHEN MATCHED THEN UPDATE SET A.FLGUPG=SRC.FLGUPG;



--SELECT * FROM PRO.CUSTOMERCAL 
--UCIF - CUSTOMER LEVEL -------------


UPDATE   GTT_CUSTOMERCAL SET SysNPA_Dt=NULL,
							 DbtDt=NULL,
							 LossDt=NULL,
							 ErosionDt=NULL,
							 FlgErosion='N',
							 SysAssetClassAlt_Key=1
							 ,FlgDeg='N'
WHERE FlgUpg='U';


/*--------MARKING UPGRADED ACCOUNT --------------*/

        MERGE INTO GTT_ACCOUNTCAL B 
        USING (
        SELECT A.ROWID ROW_ID
                     FROM GTT_CUSTOMERCAL A INNER JOIN GTT_ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
        WHERE  NVL(A.FlgUpg,'U')='U' AND (NVL(A.FlgProcessing,'N')='N')
        )SRC ON (B.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET
                    B.UPGDATE=V_PROCESSDATE
                     ,B.DegReason=NULL
                     ,B.FinalAssetClassAlt_Key=1
                     ,B.FlgDeg='N'
                     ,B.FinalNpaDt=null
                     ,B.FlgUpg='U';


-------------------------------PENDIG BY ZAIN 
        MERGE INTO GTT_ACCOUNTCAL B
        USING (SELECT A.ROWID ROW_ID
                     FROM GTT_CUSTOMERCAL A INNER JOIN GTT_ACCOUNTCAL B 
                     ON A.RefCustomerID=B.RefCustomerID
                    WHERE  NVL(A.FlgUpg,'U')='U' AND (NVL(A.FlgProcessing,'N')='N')
        )SRC ON (B.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET  B.UpgDate=V_PROCESSDATE
                                        ,B.DegReason=NULL
                                         ,B.FinalAssetClassAlt_Key=1
                                         ,B.FlgDeg='N'
                                         ,B.FinalNpaDt=null
                                         ,B.FlgUpg='U';

-------21022023 --- Sudesh --- Investment Upgrade Logic added---


        MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
        USING (SELECT A.ROWID ROW_ID
        FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
        WHERE  NVL(A.FlgUpg,'U')='U' 
        AND A.EffectiveFromTimeKey<=V_TIMEKEY and A.EffectiveToTimeKey>=V_TIMEKEY
        )SRC ON(A.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET  A.UpgDate=V_PROCESSDATE
                                         ,A.DegReason=NULL
                                         ,A.AssetClass_AltKey=1
                                         ,A.FinalAssetClassAlt_Key=1
                                         ,A.FlgDeg='N'
                                         ,A.NPIDt=null
                                         ,A.FlgUpg='U';


-------21022023 --- Sudesh --- Derivative Upgrade Logic added---

                MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                USING(SELECT ROWID ROW_ID
                        FROM  CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                WHERE  NVL(A.FlgUpg,'U')='U' 
                AND A.EffectiveFromTimeKey<=V_TIMEKEY and A.EffectiveToTimeKey>=V_TIMEKEY
                )SRC ON (A.ROWID=SRC.ROW_ID)
                WHEN MATCHED THEN UPDATE SET  A.UpgDate=V_PROCESSDATE
                                             ,A.DegReason=NULL
                                             ,A.AssetClass_AltKey=1
                                             ,A.FlgDeg='N'
                                             ,A.NPIDt=null
                                             ,A.FlgUpg='U';


/* 16-04-2021 AMAR  -- ADDED THIS CODE FOR  COMMING NEW ACCOUNT BECOMING NPA DUE TO 
	EXISTING NPA CUSTOMER  AND ALSO UPGRADEING */


        MERGE INTO GTT_ACCOUNTCAL A
        USING (SELECT A.ROWID ROW_ID
                FROM GTT_ACCOUNTCAL A 
                WHERE InitialAssetClassAlt_Key =1 AND FinalAssetClassAlt_Key =1 AND FlgUpg='U'
        )SRC ON (A.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET FLGUPG='N'
                                    ,UpgDate=NULL;
                
        UPDATE GTT_CUSTOMERCAL A set DegReason=NULL where SysAssetClassAlt_Key=1 and DegReason is not null;

        INSERT INTO GTT_CTE_PERC(UCIF_ID,SYSASSETCLASSALT_KEY,SYSNPA_DT,PercType)
        SELECT UCIF_ID,SYSASSETCLASSALT_KEY,SYSNPA_DT,PercType FROM
        (
        /* ADVANCE DATA */
        SELECT UCIF_ID,MAX(NVL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY ,MIN(SYSNPA_DT) SYSNPA_DT
        ,'ADV' PercType
        FROM GTT_CUSTOMERCAL A WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  NVL(SYSASSETCLASSALT_KEY,1)=1
        GROUP BY  UCIF_ID
        UNION
        /* INVESTMENT DATA */
        SELECT UcifId UCIF_ID,MAX(NVL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT
        ,'INV' PercType
        FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B
        ON A.InvEntityId =B.InvEntityId
        AND A.EffectiveFromTimeKey =V_TIMEKEY AND A.EffectiveToTimeKey =V_TIMEKEY
        AND B.EffectiveFromTimeKey =V_TIMEKEY AND B.EffectiveToTimeKey =V_TIMEKEY
        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C
        ON C.IssuerEntityId=B.IssuerEntityId
        AND C.EffectiveFromTimeKey =V_TIMEKEY AND C.EffectiveToTimeKey =V_TIMEKEY
        WHERE NVL(FinalAssetClassAlt_Key,1)=1
        GROUP BY  UcifId
        /* DERIVATIVE DATA */
        UNION
        SELECT UCIC_ID,MAX(NVL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT
        ,'DER' PercType
        FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
        WHERE  A.EffectiveFromTimeKey =V_TIMEKEY AND A.EffectiveToTimeKey =V_TIMEKEY
        AND NVL(FinalAssetClassAlt_Key,1)=1
        GROUP BY  UCIC_ID
        )A;


/*  FIND LOWEST ASSET CLASS AND IN NPA DATE IN AALL SOURCES */

        EXECUTE IMMEDIATE 'TRUNCATE TABLE GTT_TEMPTABLE_UCFIC1';
        INSERT INTO GTT_TEMPTABLE_UCFIC1(UCIF_ID,SYSASSETCLASSALT_KEY,SYSNPA_DT,PercType)
        SELECT UCIF_ID, MAX(SYSASSETCLASSALT_KEY) SYSASSETCLASSALT_KEY, MIN(SYSNPA_DT)SYSNPA_DT,'XXX' PercType
        FROM GTT_CTE_PERC
        GROUP BY UCIF_ID;
        
        
        MERGE INTO GTT_TEMPTABLE_UCFIC1 A
        USING (SELECT A.ROWID ROW_ID,B.PercType
        FROM GTT_TEMPTABLE_UCFIC1 A
        INNER JOIN GTT_CTE_PERC B
        ON A.UCIF_ID =B.UCIF_ID
        AND A.SYSASSETCLASSALT_KEY =B.SYSASSETCLASSALT_KEY
        )SRC ON (A.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET A.PercType=SRC.PercType; 

/*  UPDATE LOWEST ASSET CLASS AND MIN NPA DATE IN - ADVANCE DATA */


        MERGE INTO GTT_CUSTOMERCAL A
        USING (SELECT A.ROWID ROW_ID,B.SYSASSETCLASSALT_KEY,B.SYSNPA_DT
                    FROM GTT_CUSTOMERCAL A
                    INNER JOIN GTT_TEMPTABLE_UCFIC1 B ON A.UCIF_ID =B.UCIF_ID
         )SRC ON (A.ROWID=SRC.ROW_ID)
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key=SRC.SYSASSETCLASSALT_KEY
        ,A.SysNPA_Dt=SRC.SYSNPA_DT
        ,A.DegReason=CASE WHEN A.SysAssetClassAlt_Key >1 AND SRC.SYSASSETCLASSALT_KEY =1
        THEN 
        NULL
        ELSE  A.DegReason
        END;

 

/* UPDATE INVESTMENT DATA - LOWEST ASSET CLASS AND MIN NPA DATE */

        MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
        USING (SELECT A.ROWID ROW_ID,D.SYSASSETCLASSALT_KEY,D.SYSNPA_DT
            FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B
                    ON A.InvEntityId =B.InvEntityId
                    AND A.EffectiveFromTimeKey =V_TIMEKEY AND A.EffectiveToTimeKey =V_TIMEKEY
                    AND B.EffectiveFromTimeKey =V_TIMEKEY AND B.EffectiveToTimeKey =V_TIMEKEY
        INNER JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C
                    ON C.IssuerEntityId=B.IssuerEntityId
                    AND C.EffectiveFromTimeKey =V_TIMEKEY AND C.EffectiveToTimeKey =V_TIMEKEY
        INNER JOIN GTT_TEMPTABLE_UCFIC1 D ON D.UCIF_ID =C.UcifId
        )SRC ON (A.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key=SRC.SYSASSETCLASSALT_KEY
        ,A.NPIDt=SRC.SYSNPA_DT 
        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key >1 AND SRC.SYSASSETCLASSALT_KEY =1
        THEN 
        NULL
        ELSE  A.DegReason
        END;
 
/*  UPDATE   LOWEST ASSET CLASS AND MIN NPA DATE IN -  DERIVATIVE DATA */


        MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A
        USING ( SELECT A.ROWID ROW_ID,B.SYSASSETCLASSALT_KEY,B.SYSNPA_DT
        FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
        INNER JOIN GTT_TEMPTABLE_UCFIC1 B ON A.UCIC_ID =B.UCIF_ID
        AND A.EffectiveFromTimeKey=V_TIMEKEY AND A.EffectiveToTimeKey=V_TIMEKEY
        )SRC ON (A.ROWID=SRC.ROW_ID)
        WHEN MATCHED THEN UPDATE SET FinalAssetClassAlt_Key=SRC.SYSASSETCLASSALT_KEY
        ,A.NPIDt=SRC.SYSNPA_DT
        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key >1 AND SRC.SYSASSETCLASSALT_KEY =1
        THEN 
        NULL
        ELSE  A.DegReason
        END;
         

        update CurDat_RBL_MISDB_PROD.DerivativeDetail A 
                SET FLGDEG='N',FLGUPG = 'U',UPGDATE = V_PROCESSDATE 
                where  A.EffectiveFromTimeKey=V_TIMEKEY AND A.EffectiveToTimeKey=V_TIMEKEY and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1;

 

        UPDATE CurDat_RBL_MISDB_PROD.DerivativeDetail A SET AssetClass_AltKey=FinalAssetClassAlt_Key
        where  A.EffectiveFromTimeKey=V_TIMEKEY AND A.EffectiveToTimeKey=V_TIMEKEY
                     and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1;

        UPDATE CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A SET AssetClass_AltKey=FinalAssetClassAlt_Key
        where  A.EffectiveFromTimeKey=V_TIMEKEY AND A.EffectiveToTimeKey=V_TIMEKEY
        and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1;
        
        update CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A SET FLGDEG='N',FLGUPG = 'U',UPGDATE = V_PROCESSDATE
        where  A.EffectiveFromTimeKey=V_TIMEKEY AND A.EffectiveToTimeKey=V_TIMEKEY
        and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1;




        EXECUTE IMMEDIATE 'TRUNCTAE TABLE GTT_TEMPTABLE_UCFIC1';
	
	
/* added by amar on 14102021 for check acl and dpd missmatch issue*/
		EXECUTE IMMEDIATE 'IF EXISTS(
					SELECT 1
					FROM GTT_ACCOUNTCAL A   
					WHERE (NVL(A.Asset_Norm,''''NORMAL'''')<>''''ALWYS_STD'''') 
							and NVL(A.Balance,0)>0
							AND A.FinalAssetClassAlt_Key =1
						AND(
							   NVL((CASE WHEN A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,V_PROCESSDATE)  
											ELSE 0 END),0)>=A.REFPERIODINTSERVICE 
							OR NVL((CASE WHEN A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  V_PROCESSDATE) + 1					  ELSE 0 END),0)>=A.REFPERIODOVERDRAWN   
							OR NVL(CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,V_PROCESSDATE)>90)
													THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  V_PROCESSDATE) ELSE		0 END)
											ELSE 0 END,0)>=A.REFPERIODNOCREDIT     
							OR NVL((CASE WHEN A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  V_PROCESSDATE)  						  ELSE 0 END),0) >=A.REFPERIODOVERDUE      
							OR NVL((CASE WHEN A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,V_PROCESSDATE)      
											ELSE 0 END),0)>=A.REFPERIODSTKSTATEMENT
							OR NVL((CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, V_PROCESSDATE)      
											ELSE			0 END),0)>=A.REFPERIODREVIEW         
					   )
		)
	THEN 
		RAISERROR (''''Missmatch in DPD and Asset Class, need to check....'''',16,1);
        END IF;';

         
         UPDATE GTT_CUSTOMERCAL
            SET SysNPA_Dt = NULL,
                DbtDt = NULL,
                LossDt = NULL,
                ErosionDt = NULL,
                FlgErosion = 'N',
                SysAssetClassAlt_Key = 1,
                FlgDeg = 'N'
          WHERE  FlgUpg = 'U';
         /*--------MARKING UPGRADED ACCOUNT --------------*/
         MERGE INTO GTT_ACCOUNTCAL B
         USING (SELECT B.ROWID row_id, v_PROCESSDATE
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE NVL(A.FlgUpg, 'U') = 'U'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.UpgDate = v_PROCESSDATE,
                                      B.DegReason = NULL,
                                      B.FinalAssetClassAlt_Key = 1,
                                      B.FlgDeg = 'N',
                                      B.FinalNpaDt = NULL,
                                      B.FlgUpg = 'U';
         MERGE INTO GTT_ACCOUNTCAL B  
         USING (SELECT B.ROWID row_id, v_PROCESSDATE
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE NVL(A.FlgUpg, 'U') = 'U'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.UpgDate = v_PROCESSDATE,
                                      B.DegReason = NULL,
                                      B.FinalAssetClassAlt_Key = 1,
                                      B.FlgDeg = 'N',
                                      B.FinalNpaDt = NULL,
                                      B.FlgUpg = 'U';
         MERGE INTO GTT_CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM GTT_CUSTOMERCAL A 
          WHERE SysAssetClassAlt_Key = 1
           AND DegReason IS NOT NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = NULL;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLERefCustomerID ';
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Upgrade_Customer_Account_UCIF_ID';


    V_SQLERRM :=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Upgrade_Customer_Account_UCIF_ID';
END;
EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
