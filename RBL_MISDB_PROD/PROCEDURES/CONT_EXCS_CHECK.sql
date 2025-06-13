--------------------------------------------------------
--  DDL for Procedure CONT_EXCS_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CONT_EXCS_CHECK" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT acbd.CustomerACID ,
             acbd.FacilityType ,
             ProductCode ,
             SchemeType ,
             CurrentLimit ,
             DrawingPower ,
             Balance 
        FROM DimBranch DB
               JOIN RBL_MISDB_PROD.AdvAcBasicDetail ACBD   ON ( ACBD.EffectiveFromTimeKey <= 26203
               AND ACBD.EffectiveToTimeKey >= 26203 )
               AND DB.EffectiveFromTimeKey <= 26203
               AND DB.EffectiveToTimeKey >= 26203
               AND DB.BranchCode = ACBD.BranchCode
               JOIN RBL_MISDB_PROD.AdvAcBalanceDetail AB   ON ( AB.EffectiveFromTimeKey <= 26203
               AND AB.EffectiveToTimeKey >= 26203 )
               AND AB.AccountEntityId = ACBD.AccountEntityId
               JOIN RBL_MISDB_PROD.ADVFACCCDETAIL CC   ON ( CC.EffectiveFromTimeKey <= 26203
               AND CC.EffectiveToTimeKey >= 26203 )
               AND CC.AccountEntityId = ACBD.AccountEntityId
               JOIN RBL_MISDB_PROD.AdvAcFinancialDetail AFD   ON ( AFD.EffectiveFromTimeKey <= 26203
               AND AFD.EffectiveToTimeKey >= 26203 )
               AND AFD.AccountEntityId = ACBD.AccountEntityId
               JOIN DimProduct p   ON p.EffectiveToTimeKey = 49999
               AND p.ProductAlt_Key = acbd.ProductAlt_Key

      ------WHERE  ISNULL(Balance,0)>ISNULL(DrawingPower,0) AND ISNULL(DrawingPower,0)>=0
      WHERE  ACBD.SourceAlt_Key = 1 --- ONLY FOR FINALCE TO CHECK CC ACCOUNT CONT EXCESS DATE

               AND acbd.CustomerACID IN ( SELECT A.CustomerAcID 
                                          FROM PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCalBKUP a
                                                 JOIN AdvAcBasicDetail b   ON b.EffectiveToTimeKey = 49999
                                                 AND a.EffectiveToTimeKey = 49999
                                                 AND a.AccountEntityId = b.AccountEntityId
                                           WHERE  SourceAlt_Key = 1
                                          MINUS 
                                          SELECT a.CustomerAcID 
                                          FROM PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal a
                                                 JOIN AdvAcBasicDetail b   ON b.EffectiveToTimeKey = 49999
                                                 AND a.EffectiveToTimeKey = 49999
                                                 AND a.AccountEntityId = b.AccountEntityId
                                           WHERE  SourceAlt_Key = 1 )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AcBuRevisedSegmentCode ,
             ProductSubGroup ,
             Segment ,
             D.ProvisionSecured ,
             ProvisionUnSecured ,
             FinalAssetClassAlt_Key 
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL a
               LEFT JOIN DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
               AND ( SEG.EffectiveFromTimeKey <= 26203
               AND SEG.EffectiveToTimeKey >= 26203 )
               JOIN DimProduct c   ON c.EffectiveToTimeKey = 49999
               AND c.ProductAlt_Key = a.ProductAlt_Key
               JOIN DimProvision_Seg D   ON D.EffectiveToTimeKey = 49999
               AND D.ProvisionAlt_Key = a.ProvisionAlt_Key

      -- AcBuRevisedSegmentCode IN('Agri-Retail','WCF','Agri-Wholesale','MC','SME','CIB','SCF','FIG')
      GROUP BY AcBuRevisedSegmentCode,ProductSubGroup,Segment,D.ProvisionSecured,ProvisionUnSecured,FinalAssetClassAlt_Key
        ORDER BY AcBuRevisedSegmentCode,
                 ProductSubGroup,
                 Segment,
                 D.ProvisionSecured,
                 ProvisionUnSecured,
                 FinalAssetClassAlt_Key ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --select * from pro.CUSTOMERCAL where UCIF_ID in ('RBL004832730','RBL001646250')
   OPEN  v_cursor FOR
      SELECT INVID ,
             FlgUpg ,
             DPD ,
             UcifId UCIF_ID  ,
             A.EffectiveFromTimeKey ,
             c.IssuerName ,
             InitialAssetAlt_Key ,
             FinalAssetClassAlt_Key ,
             DPD ,
             InitialNPIDt ,
             NPIDt ,
             flgdeg 

        --,flgdeg

        ---UPDATE A	set a.FinalAssetClassAlt_Key =3, InitialAssetAlt_Key=3,NPIDt ='2019-09-30', InitialNPIDt='2019-09-30',flgdeg='N'

        --update a

        --	set a.FinalAssetClassAlt_Key =2, InitialAssetAlt_Key=2,NPIDt ='2021-09-19', InitialNPIDt='2021-09-19', flgdeg='D'

        --,a.DEGREASON ='Manual NPA'

        --update  a  set  InitialAssetAlt_Key=6,FinalAssetClassAlt_Key=6,InitialNPIDt='2020-02-11',NPIDt='2020-02-11',flgupg='N'

        --------UPDATE A SET UpgDate =NULL,FLGUPG ='N'

        --update a

        --	set InitialAssetAlt_Key =1, InitialNPIDt =null, FLGDEG ='Y'
        FROM InvestmentFinancialDetail A
               JOIN InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId

               --AND A.EffectiveFromTimeKey>=26218--<=26223 AND A.EffectiveToTimeKey >=26223
               AND A.EffectiveFromTimeKey <= 26223
               AND A.EffectiveToTimeKey >= 26223
               AND B.EffectiveFromTimeKey <= 26223
               AND B.EffectiveToTimeKey >= 26223
               JOIN InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
               AND C.EffectiveFromTimeKey <= 26223
               AND C.EffectiveToTimeKey >= 26223
       WHERE ---ISNULL(FinalAssetClassAlt_Key,1)<>1 --AND INFI 
       --dpd=0 and npidt is not null and
       ----UcifId ='RBL001643204'
       --	UCIFID IN('RBL001646250','RBL004832730')--,'RBL001646250')
        UcifId IN ( 'RBL001643204','RBL002980785','RBL008827709','RBL003034380','RBL004832730','RBL001646250' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --ORDER BY 1,2
   --SELECT * FrOM PRO.AclRunningProcessStatus ORDER BY ID
   --UPDATE PRO.AclRunningProcessStatus SET Completed ='Y' WHERE ID>=23
   UPDATE Automate_Advances
      SET EXT_FLG = 'U'
    WHERE  EXT_FLG = 'Y';
   UPDATE Automate_Advances
      SET EXT_FLG = 'Y'
    WHERE  Timekey = 26205;
   PRO_RBL_MISDB_PROD.InsertDataforAssetClassficationRBL_RESTR(26205,
                                                               NULL,
                                                               'N') ;
   PRO_RBL_MISDB_PROD.MAINPROECESSFORASSETCLASSFICATION_RESTR() ;
   ----EXEC RestructureOutput
   OPEN  v_cursor FOR
      SELECT DISTINCT FinalAssetClassAlt_Key 
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
       WHERE  FinalAssetClassAlt_Key IS NULL ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AppliedProvPer ,
             AppliedNormalProvPer ,
             FinalProvPer ,
             ProvReleasePer ,
             RestrProvPer ,
             PreRestructureNPA_Prov ,
             CurrentNPA_Date ,
             RestructureDt ,
             * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-29'
                AND Current_AssetClass IS NULL

                ----AND (TypeOfRestructure LIKE '%MSME%' ) or

                --and TypeOfRestructure LIKE '%COVID%'  

                --AND Current_AssetClass='STD'

                --and Pre_Restr_AssetClass ='STD'

                --and RestrProvPer =0
                AND PreRestructureNPA_Date IS NOT NULL
                AND CurrentNPA_Date = RestructureDt ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AppliedProvPer ,
             AppliedNormalProvPer ,
             FinalProvPer ,
             ProvReleasePer ,
             RestrProvPer ,
             CurrentNPA_Date ,
             RestructureDt ,
             * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-22'

                --AND (TypeOfRestructure LIKE '%PRUDEN%' )--OR TypeOfRestructure LIKE '%IRAC%'  OR TypeOfRestructure LIKE '%OTHER%' )

                --AND Current_AssetClass<>'STD'

                --AND AppliedProvPer <>(AppliedNormalProvPer +FinalProvPer)
                AND DPD_Breach_Date IS NULL
                AND ( TypeOfRestructure LIKE '%PRUDEN%'
                OR TypeOfRestructure LIKE '%IRCA%'
                OR TypeOfRestructure LIKE '%OTHER%' )
                AND ( ( FacilityType NOT IN ( 'CC','OD' )

                AND NVL(DPD_MaxFin, 0) > 0 )
                OR ( ( FacilityType IN ( 'CC','OD' )

                AND ( NVL(DPD_MaxFin, 0) >= 30
                OR NVL(DPD_MaxNonFin, 0) >= 90 ) ) ) ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT SP_ExpiryExtendedDate ,
             SP_ExpiryDate ,
             CurrentNPA_Date ,
             RestructureDt ,
             * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-24'
                AND BALANCE < 0
                AND ZeroDPD_Date IS NOT NULL
                AND SP_ExpiryExtendedDate IS NULL
                AND utils.dateadd('YY', 1, ZeroDPD_Date) > SP_ExpiryDate ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT CurrentNPA_Date ,
             RestructureDt ,
             * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-22'

                --AND (TypeOfRestructure LIKE '%PRUDEN%' OR TypeOfRestructure LIKE '%IRAC%'  OR TypeOfRestructure LIKE '%OTHER%' )
                AND ( TypeOfRestructure LIKE '%covid%'
                OR TypeOfRestructure LIKE '%msme%' )
                AND Current_AssetClass <> 'STD'
                AND PreRestructureNPA_Date IS NULL

                --AND isnull(CurrentNPA_Date,'1900-01-01') <>isnull(PreRestructureNPA_Date,'1900-01-01')
                AND NVL(CurrentNPA_Date, '1900-01-01') <> NVL(RestructureDt, '1900-01-01')
                AND CurrentNPA_Date < RestructureDt ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-24'
                AND CustomerAcID IN ( '809002735893','809002085981','609000728998','609000720057' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT * 
        FROM RestrOutput 
       WHERE  CreatedDate = '2021-09-24'
                AND CustomerAcID IN ( '809002013083','0007477350014732596','0005369077356537425','0007474500007207120' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   -------UPDATE RESTR DBD BREACH DATE
   OPEN  v_cursor FOR
      SELECT AddlProvPer ,
             ProvReleasePer ,
             FinalProvPer ,
             * 
        FROM PRO_RBL_MISDB_PROD.AdvAcRestructureCal 
       WHERE  AccountEntityId IN ( 1111759,4629051,5665407,1985842 )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT * 
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
       WHERE  CustomerAcID IN ( 'Z011QHG_01316401','Z011L7G_01316401','0007477800001364092','0007476300005905975' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT a.CustomerAcID ,
             D.AcBuRevisedSegmentCode ,
             c.ProductName ,
             c.ProductCode ,
             c.ProductSubGroup ,
             F.CurrentValue CustomerSecurity  ,
             a.ApprRV ,
             a.UsedRV ,
             NetBalance ,
             SecuredAmt ,
             UnSecuredAmt ,
             b.ProvisionSecured ,
             b.ProvisionUnSecured ,
             b.RBIProvisionSecured ,
             b.RBIProvisionUnSecured ,
             TotalProvision * 100 / NVL(NULLIF(NetBalance, 0), 1) ,
             AssetClass 

        --select a.*
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL a
               JOIN DimProvision_Seg b   ON a.ProvisionAlt_Key = b.ProvisionAlt_Key
               AND b.EffectiveToTimeKey = 49999
               AND CustomerAcID IN ( '409000376144','609000747160' )

               JOIN DimProduct c   ON a.ProductAlt_Key = c.ProductAlt_Key
               AND c.EffectiveToTimeKey = 49999
               JOIN DimAcBuSegment D   ON a.ActSegmentCode = D.AcBuSegmentCode
               AND D.EffectiveToTimeKey = 49999
               LEFT JOIN AdvSecurityDetail E   ON e.CustomerEntityId = A.CustomerEntityID
               AND E.EffectiveToTimeKey = 49999
               LEFT JOIN AdvSecurityValueDetail F   ON e.SecurityEntityID = F.SecurityEntityID
               AND F.EffectiveToTimeKey = 49999
       WHERE  CustomerAcID IN ( '409000376144','609000747160' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --where CustomerAcID in('809000416273','809001100487')
   ----select distinct a.*, Balance,DPD_Max DPD_on_28_Sep,(isnull(DPD_Max,0)+2) DPD_on_30_Sep,ReferencePeriod
   ----		,case when (isnull(DPD_Max,0)+2)>=ReferencePeriod then 'Y' ELSE 'N' END NPA_AS_ON_30_SEP
   ----from Manual_Upgrade a	
   ----	inner join pro.ACCOUNTCAL b
   ----		on a.[Account No]=b.CustomerAcID
   ----	inner join AdvAcBasicDetail c
   ----		on c.EffectiveToTimeKey =49999
   ----		and c.AccountEntityId =b.AccountEntityId
   ----	where VALID_UPTO='2099-12-31'
   OPEN  v_cursor FOR
      SELECT A.CustomerACID ,
             P.ProductCode ,
             P.ProductName ,
             P.ProductSubGroup ,
             B.AcBuSegmentCode ,
             B.AcBuRevisedSegmentCode ,
             C.SourceShortNameEnum SourceName  ,
             aa.SecuredStatus Source_SecuredStatus  ,
             CASE 
                  WHEN A.FlgSecured = 'U' THEN 'UNSECURED'
             ELSE 'SECURED'
                END Final_Mapping  

        --select count(1)

        ------select distinct segmentcode
        FROM RBL_TEMPDB.TempAdvAcBasicDetail a
               JOIN PRO_RBL_MISDB.ACCOUNTCAL AC   ON AC.AccountEntityID = A.ACCOUNTENTITYID
               AND ac.FinalAssetClassAlt_Key > 1
               LEFT JOIN RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM aa   ON aa.CustomerAcID = a.CustomerACID
               LEFT JOIN RBL_MISDB.DimAcBuSegment B   ON ( b.EffectiveFromTimeKey <= 26205
               AND b.EffectiveToTimeKey >= 26205 )
               AND AC.ActSegmentCode = B.AcBuSegmentCode
               JOIN RBL_MISDB.DIMSOURCEDB C   ON ( C.EffectiveFromTimeKey <= 26205
               AND C.EffectiveToTimeKey >= 26205 )
               AND C.SourceAlt_Key = A.SourceAlt_Key
               JOIN RBL_MISDB.dimproduct p   ON ( C.EffectiveFromTimeKey <= 26205
               AND C.EffectiveToTimeKey >= 26205 )
               AND a.productalt_key = p.ProductAlt_Key
       WHERE  A.SourceAlt_Key = 1
                AND B.AcBuSegmentCode IS NULL ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT COUNT(1)
   --FROM pro.AccountCal_Hist where EffectiveFromTimeKey=26206 
   --	and (InitialAssetClassAlt_Key =1 AND FinalAssetClassAlt_Key >1)
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key, B.FinalAssetClassAlt_Key, B.FinalNpaDt, B.FinalNpaDt
   ----SELECT COUNT(1)

   FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
          JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.AccountEntityID = B.AccountEntityID
          AND B.EffectiveFromTimeKey = 26206
          AND ( B.InitialAssetClassAlt_Key = 1
          AND B.FinalAssetClassAlt_Key > 1 ) 
    WHERE A.InitialAssetClassAlt_Key = 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.InitialAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                A.InitialNpaDt = src.FinalNpaDt,
                                A.FinalNpaDt = src.FinalNpaDt;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key, B.FinalAssetClassAlt_Key, B.FinalNpaDt, B.FinalNpaDt
   ----SELECT COUNT(1)

   FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
          JOIN ( SELECT DISTINCT CustomerEntityID ,
                                 MAX(FinalAssetClassAlt_Key)  FinalAssetClassAlt_Key  ,
                                 MIN(FinalNpaDt)  FinalNpaDt  
                 FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
                  WHERE  B.EffectiveFromTimeKey = 26206
                           AND ( B.InitialAssetClassAlt_Key = 1
                           AND B.FinalAssetClassAlt_Key > 1 )
                   GROUP BY CustomerEntityID ) B   ON A.CustomerEntityID = B.CustomerEntityID 
    WHERE A.SysAssetClassAlt_Key = 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.SrcAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                A.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                A.SrcNPA_Dt = src.FinalNpaDt,
                                A.SysNPA_Dt = src.FinalNpaDt;
   ----select AccountEntityId from pro.ContExcsSinceDtAccountCal where EffectiveToTimeKey=49999
   ----EXCEPT
   ----select AccountEntityId from pro.ContExcsSinceDtAccountCalBKUP where EffectiveToTimeKey=49999
   ----EXCEPT
   ----select AccountEntityId from pro.ContExcsSinceDtAccountCal where EffectiveToTimeKey=49999
   OPEN  v_cursor FOR
      SELECT D2K.CustomerAcID CustomerAcID_D2K  ,
             D2K.ContExcsSinceDt ContExcsSinceDt_D2K  ,
             D2K.DrawingPower DrawingPower_D2K  ,
             D2K.SanctionAmt SanctionAmt_D2K  ,
             D2K.Balance Balance_D2K  ,
             RBL.CustomerAcID CustomerAcID_RBL  ,
             RBL.ContExcsSinceDt ContExcsSinceDt_RBL  ,
             RBL.DrawingPower DrawingPower_RBL  ,
             RBL.SanctionAmt SanctionAmt_RBL  ,
             RBL.Balance Balance_RBL  
        FROM PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCalBKUP D2K
               FULL JOIN PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal RBL   ON D2K.CustomerAcID = RBL.CustomerAcID
               AND RBL.EffectiveToTimeKey = 49999
       WHERE  D2K.EffectiveToTimeKey = 49999
                AND ( NVL(RBL.CustomerAcID, ' ') <> NVL(D2K.CustomerAcID, ' ')
                OR NVL(RBL.ContExcsSinceDt, '1900-01-01') <> NVL(D2K.ContExcsSinceDt, '1900-01-01') ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --OR  ISNULL(RBL.DrawingPower,0)<>ISNULL(D2K.DrawingPower,0) 
   --OR  ISNULL(RBL.SanctionAmt,0)<>ISNULL(D2K.SanctionAmt,0) 
   --OR  ISNULL(RBL.Balance,0)<>ISNULL(D2K.Balance,0) 
   OPEN  v_cursor FOR
      SELECT b.CustomerAcID ,
             b.InitialAssetClassAlt_Key ,
             b.InitialNpaDt ,
             b.FinalAssetClassAlt_Key ,
             b.FinalNpaDt ,
             b.DegReason 
        FROM VISIONPLUS_ACL_ISSUE a
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist b   ON a.AccountEntityId = b.AccountEntityId
       WHERE  b.InitialAssetClassAlt_Key = 1
                AND FinalAssetClassAlt_Key > 1
        ORDER BY 5 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT A.* ,
             DPD ,
             UTILS.CONVERT_TO_VARCHAR2(DD.Date_,200) ChargeOff_Y_PreDate  
        FROM NPA_Data_30092021 a
               JOIN ( SELECT MAX(effectivefromtimekey)  effectivefromtimekey  ,
                             refsystemacid 
                      FROM AdvFacCreditCardDetail 
                        GROUP BY refsystemacid ) b   ON a.customeracid = b.RefSystemAcId
               JOIN AdvFacCreditCardDetail c   ON b.RefSystemAcId = c.RefSystemAcId
               AND c.EffectiveFromTimeKey = b.effectivefromtimekey
               LEFT JOIN SysDayMatrix DD   ON DD.TimeKey = b.effectivefromtimekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --update InvestmentFinancialDetail set  INITIALNPIDT='2019-09-30',NPIDt='2019-09-30' where RefInvID='158091' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   --update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268652' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   --update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268640' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   --update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268651' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   --update InvestmentFinancialDetail set  INITIALNPIDT='2020-03-31',NPIDt='2020-03-31' where RefInvID='268642' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   --update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268639' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
   OPEN  v_cursor FOR
      SELECT * 
        FROM ReverseFeedData 
       WHERE  DateofData = '2021-07-27'
                AND AccountID IN ( '0005239504505517485','0005243736650445146','0005243736760030515','0005256118801651688','0005369077255463574','0005369077256493950','0005369077351359999','0007477250004312930','0007477250013671037','0007477350012328330','0007477770001161998','0007477770001544235','0007477800001295676','0007477800001751512','0007478650000601385','0007478800002456623','0007478950006745511' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONT_EXCS_CHECK" TO "ADF_CDR_RBL_STGDB";
