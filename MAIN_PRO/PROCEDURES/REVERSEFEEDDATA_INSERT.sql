--------------------------------------------------------
--  DDL for Procedure REVERSEFEEDDATA_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."REVERSEFEEDDATA_INSERT" /*==============================================
 AUTHER : Triloki Khanna
 CREATE DATE : 27-12-2019
 MODIFY DATE : 27-12-2019
 DESCRIPTION : INSERT DATA FOR RBL_MISDB_PROD.ReverseFeedData ID
 EXEC PRO.ReverseFeedData_Insert


 ================================================*/
AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
   v_vEffectiveto NUMBER(10,0);

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT Timekey - 1 

     INTO v_vEffectiveto
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --DELETE FROM RBL_MISDB_PROD.ReverseFeedData
   --  if EXISTS  ( select  1  from RBL_MISDB_PROD.ReverseFeedData where  [EffectiveFromTimeKey]= @Timekey)
   --	  begin
   --		 print 'NO NEDD TO INSERT DATA'
   --	  end 
   --else
   --begin
   DELETE RBL_MISDB_PROD.ReverseFeedData

    WHERE  EffectiveFromTimeKey = v_TIMEKEY
             AND EffectiveToTimeKey = v_TIMEKEY;
   IF utils.object_id('TEMPDB..tt_ReverseFeedData') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReverseFeedData ';
   END IF;
   DELETE FROM tt_ReverseFeedData;
   INSERT INTO tt_ReverseFeedData
     ( DateofData, BranchCode, CustomerID, AccountID, AssetClass, AssetSubClass, NPADate, NPAReason, LoanSeries, LoanRefNo, FundID, NPAStatus, LoanRating, OrgNPAStatus, OrgLoanRating, SourceAlt_Key, SourceSystemName, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT v_DATE DateofData  ,
              A.BranchCode BranchCode  ,
              B.RefCustomerID CustomerID  ,
              A.CustomerAcID AccountID  ,
              CASE 
                   WHEN A.FinalAssetClassAlt_Key = 1 THEN 'STD'
                   WHEN A.FinalAssetClassAlt_Key = 2 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 3 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 4 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 5 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 6 THEN 'NPA'   END AssetClass  ,
              CASE 
                   WHEN A.FinalAssetClassAlt_Key = 1 THEN 'STD'
                   WHEN A.FinalAssetClassAlt_Key = 2 THEN 'SUB'
                   WHEN A.FinalAssetClassAlt_Key = 3 THEN 'DB1'
                   WHEN A.FinalAssetClassAlt_Key = 4 THEN 'DB2'
                   WHEN A.FinalAssetClassAlt_Key = 5 THEN 'DB3'
                   WHEN A.FinalAssetClassAlt_Key = 6 THEN 'LOS'   END AssetSubClass  ,
              A.FinalNpaDt NPADate  ,
              A.NPA_Reason NPAReason  ,
              B.LoanSeries LoanSeries  ,
              B.LoanRefNo LoanRefNo  ,
              B.SecuritizationCode FundID  ,
              CASE 
                   WHEN D.SourceName = 'BR.NET' THEN CASE 
                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 1 AND 30 THEN 'STD01' --'SMA1'

                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 31 AND 60 THEN 'STD02' --'SMA2'

                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 61 AND 90 THEN 'STD03' -- 'SMA3'

                                                          WHEN FINALASSETCLASSALT_KEY = '1' THEN '1' --STD

                                                          WHEN FINALASSETCLASSALT_KEY = '2' THEN 'SSA1' --'SSD'

                                                          WHEN FINALASSETCLASSALT_KEY = '3' THEN 'DBF1'
                                                          WHEN FINALASSETCLASSALT_KEY = '4' THEN 'DBF2'
                                                          WHEN FINALASSETCLASSALT_KEY = '5' THEN 'DBF3'
                                                          WHEN FINALASSETCLASSALT_KEY = '6' THEN 'LOA'   END   END NPAStatus  ,
              CASE 
                   WHEN D.SourceName = 'PROFILE' THEN 
                   --CASE WHEN FINALASSETCLASSALT_KEY='1' AND  DPD_Max BETWEEN 1 AND 30  THEN '1'

                   --WHEN FINALASSETCLASSALT_KEY='1'  AND  DPD_Max BETWEEN 31 AND 60 THEN '2'

                   --WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 61 AND 90  THEN '3'
                   CASE 
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 1 AND 15 THEN '0'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 16 AND 30 THEN '1'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 31 AND 60 THEN '2'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 61 AND 90 THEN '3'
                        WHEN FINALASSETCLASSALT_KEY = '1' THEN '0'
                        WHEN FINALASSETCLASSALT_KEY = '2' THEN '4'
                        WHEN FINALASSETCLASSALT_KEY = '3' THEN '5'
                        WHEN FINALASSETCLASSALT_KEY = '4' THEN '6'
                        WHEN FINALASSETCLASSALT_KEY = '5' THEN '7'
                        WHEN FINALASSETCLASSALT_KEY = '6' THEN '8'   END   END LoanRating  ,
              CASE 
                   WHEN D.SourceName = 'BR.NET' THEN AccountStatus   END OrgNPAStatus  ,
              CASE 
                   WHEN D.SourceName = 'PROFILE' THEN AccountStatus   END OrgLoanRating  ,
              A.SourceAlt_Key SourceAlt_Key  ,
              D.SourceName SourceSystemName  ,
              A.EffectiveFromTimeKey ,
              A.EffectiveToTimeKey EffectiveToTimeKey  
       FROM MAIN_PRO.ACCOUNTCAL A
              JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID
              AND A.EffectiveFromTimeKey <= v_TIMEKEY
              AND A.EffectiveToTimeKey >= v_TIMEKEY
              AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.ASSETCLASSALT_KEY = A.FinalAssetClassAlt_Key
              AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              JOIN RBL_MISDB_PROD.DimSourceDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
              AND D.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND D.EFFECTIVETOTIMEKEY >= v_TIMEKEY

       --WHERE  D.SourceShortNameEnum='PROFILE' AND ( (A.AccountStatus IN ('0','1','2','3') AND A.FinalAssetClassAlt_Key>1 AND A.BALANCE>=0)

       --or (A.AccountStatus not IN ('0','1','2','3') AND A.FinalAssetClassAlt_Key=1 AND A.BALANCE>=0 )

       --or PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key )

       --AND A.BALANCE>=0
       WHERE  D.SourceShortNameEnum = 'PROFILE'
                AND PrvAssetClassAlt_Key <> FinalAssetClassAlt_Key
                AND A.Balance >= 0
       UNION 
       SELECT v_DATE DateofData  ,
              --,A.BRANCHCODE AS BranchCode  --Change logic as per bank mail dated 21/01/2020 Branch code should be 3 digits Triloki Khanna
              --,RIGHT(A.BRANCHCODE,3) AS BRANCHCODE
              A.OriginalBranchcode BRANCHCODE  ,
              B.RefCustomerID CustomerID  ,
              A.CustomerAcID AccountID  ,
              CASE 
                   WHEN A.FinalAssetClassAlt_Key = 1 THEN 'STD'
                   WHEN A.FinalAssetClassAlt_Key = 2 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 3 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 4 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 5 THEN 'NPA'
                   WHEN A.FinalAssetClassAlt_Key = 6 THEN 'NPA'   END AssetClass  ,
              CASE 
                   WHEN A.FinalAssetClassAlt_Key = 1 THEN 'STD'
                   WHEN A.FinalAssetClassAlt_Key = 2 THEN 'SUB'
                   WHEN A.FinalAssetClassAlt_Key = 3 THEN 'DB1'
                   WHEN A.FinalAssetClassAlt_Key = 4 THEN 'DB2'
                   WHEN A.FinalAssetClassAlt_Key = 5 THEN 'DB3'
                   WHEN A.FinalAssetClassAlt_Key = 6 THEN 'LOS'   END AssetSubClass  ,
              A.FinalNpaDt NPADate  ,
              A.NPA_Reason NPAReason  ,
              B.LoanSeries LoanSeries  ,
              B.LoanRefNo LoanRefNo  ,
              B.SecuritizationCode FundID  ,
              --,CASE WHEN D.SourceName='BR.NET'  THEN 
              --    CASE WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 1 AND 30   THEN 'SMA1'
              --	 WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 31 AND 60  THEN 'SMA2'
              --	 WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 61 AND 90  THEN 'SMA3'
              --	 WHEN FINALASSETCLASSALT_KEY='1' THEN 'STD'
              --	 WHEN FINALASSETCLASSALT_KEY='2' THEN 'SSD'
              --	 WHEN FINALASSETCLASSALT_KEY='3' THEN 'DBF1'
              --	 WHEN FINALASSETCLASSALT_KEY='4' THEN 'DBF2'
              --	 WHEN FINALASSETCLASSALT_KEY='5' THEN 'DBF3'
              --	 WHEN FINALASSETCLASSALT_KEY='6' THEN 'LOA' END END AS    NPAStatus
              --,CASE WHEN D.SourceName='PROFILE' THEN
              --  CASE WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 1 AND 30  THEN '1'
              --	 WHEN FINALASSETCLASSALT_KEY='1'  AND  DPD_Max BETWEEN 31 AND 60 THEN '2'
              --	 WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 61 AND 90  THEN '3'
              --	 WHEN FINALASSETCLASSALT_KEY='1' THEN '0'
              --	 WHEN FINALASSETCLASSALT_KEY='2' THEN '4'
              --	 WHEN FINALASSETCLASSALT_KEY='3' THEN '5'
              --	 WHEN FINALASSETCLASSALT_KEY='4' THEN '6'
              --	 WHEN FINALASSETCLASSALT_KEY='5' THEN '7'
              --	 WHEN FINALASSETCLASSALT_KEY='6' THEN '8' END  END AS   LoanRating
              CASE 
                   WHEN D.SourceName = 'BR.NET' THEN CASE 
                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 1 AND 30 THEN 'STD01' --'SMA1'

                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 31 AND 60 THEN 'STD02' --'SMA2'

                                                          WHEN FINALASSETCLASSALT_KEY = '1'
                                                            AND DPD_Max BETWEEN 61 AND 90 THEN 'STD03' -- 'SMA3'

                                                          WHEN FINALASSETCLASSALT_KEY = '1' THEN '1' --STD

                                                          WHEN FINALASSETCLASSALT_KEY = '2' THEN 'SSA1' --'SSD'

                                                          WHEN FINALASSETCLASSALT_KEY = '3' THEN 'DBF1'
                                                          WHEN FINALASSETCLASSALT_KEY = '4' THEN 'DBF2'
                                                          WHEN FINALASSETCLASSALT_KEY = '5' THEN 'DBF3'
                                                          WHEN FINALASSETCLASSALT_KEY = '6' THEN 'LOA'   END   END NPAStatus  ,
              CASE 
                   WHEN D.SourceName = 'PROFILE' THEN 
                   --CASE WHEN FINALASSETCLASSALT_KEY='1' AND  DPD_Max BETWEEN 1 AND 30  THEN '1'

                   --WHEN FINALASSETCLASSALT_KEY='1'  AND  DPD_Max BETWEEN 31 AND 60 THEN '2'

                   --WHEN FINALASSETCLASSALT_KEY='1' AND   DPD_Max BETWEEN 61 AND 90  THEN '3'
                   CASE 
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 1 AND 15 THEN '0'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 16 AND 30 THEN '1'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 31 AND 60 THEN '2'
                        WHEN FINALASSETCLASSALT_KEY = '1'
                          AND DPD_Max BETWEEN 61 AND 90 THEN '3'
                        WHEN FINALASSETCLASSALT_KEY = '1' THEN '0'
                        WHEN FINALASSETCLASSALT_KEY = '2' THEN '4'
                        WHEN FINALASSETCLASSALT_KEY = '3' THEN '5'
                        WHEN FINALASSETCLASSALT_KEY = '4' THEN '6'
                        WHEN FINALASSETCLASSALT_KEY = '5' THEN '7'
                        WHEN FINALASSETCLASSALT_KEY = '6' THEN '8'   END   END LoanRating  ,
              CASE 
                   WHEN D.SourceName = 'BR.NET' THEN AccountStatus   END OrgNPAStatus  ,
              CASE 
                   WHEN D.SourceName = 'PROFILE' THEN AccountStatus   END OrgLoanRating  ,
              A.SourceAlt_Key SourceAlt_Key  ,
              D.SourceName SourceSystemName  ,
              A.EffectiveFromTimeKey ,
              A.EffectiveToTimeKey EffectiveToTimeKey  
       FROM MAIN_PRO.ACCOUNTCAL A
              JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID
              AND A.EffectiveFromTimeKey <= v_TIMEKEY
              AND A.EffectiveToTimeKey >= v_TIMEKEY
              AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.ASSETCLASSALT_KEY = A.FinalAssetClassAlt_Key
              AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              JOIN RBL_MISDB_PROD.DimSourceDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
              AND D.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND D.EFFECTIVETOTIMEKEY >= v_TIMEKEY

       --WHERE  D.SourceShortNameEnum='BR.NET' AND ( (A.AccountStatus IN ('STD') AND A.FinalAssetClassAlt_Key>1 AND A.BALANCE>=0)

       --or (A.AccountStatus not IN ('STD') AND A.FinalAssetClassAlt_Key=1 AND A.BALANCE>=0 )

       --or PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key )
       WHERE  D.SourceShortNameEnum = 'BR.NET'
                AND A.Balance >= 0
                AND PrvAssetClassAlt_Key <> FinalAssetClassAlt_Key );
   INSERT INTO RBL_MISDB_PROD.ReverseFeedData
     ( DateofData, BranchCode, CustomerID, AccountID, AssetClass, AssetSubClass, NPADate, NPAReason, LoanSeries, LoanRefNo, FundID, NPAStatus, LoanRating, OrgNPAStatus, OrgLoanRating, SourceAlt_Key, SourceSystemName, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT A.DateofData ,
              A.BranchCode ,
              A.CustomerID ,
              A.AccountID ,
              A.AssetClass ,
              A.AssetSubClass ,
              A.NPADate ,
              A.NPAReason ,
              A.LoanSeries ,
              A.LoanRefNo ,
              A.FundID ,
              A.NPAStatus ,
              A.LoanRating ,
              A.OrgNPAStatus ,
              A.OrgLoanRating ,
              A.SourceAlt_Key ,
              A.SourceSystemName ,
              A.EffectiveFromTimeKey ,
              A.EffectiveToTimeKey 
       FROM tt_ReverseFeedData A );--					LEFT JOIN RBL_MISDB_PROD.ReverseFeedData B ON A.AccountID=B.AccountID
   --					 AND B.EFFECTIVETOTimekey=49999
   --WHERE  
   --			       ( 
   --				   CASE WHEN  B.AccountID IS NULL THEN 1			 WHEN B.AccountID IS NOT NULL AND 	 A.AssetSubClass<>B.AssetSubClass
   --																						 OR ISNULL(A.NPADate,'1900-01-01') <> ISNULL(B.NPADate,'1900-01-01')
   --						  THEN 1 END )=1 
   -- UPDATE AA
   --SET 
   -- EffectiveToTimeKey = @vEffectiveto
   --FROM RBL_MISDB_PROD.ReverseFeedData AA
   --LEFT JOIN tt_ReverseFeedData B ON  AA.AccountID=B.AccountID AND B.EffectiveToTimeKey =49999
   --WHERE AA.EffectiveToTimeKey = 49999
   --and B.AccountID is null
   --   UPDATE AA
   --SET 
   -- EffectiveToTimeKey = @vEffectiveto
   --FROM RBL_MISDB_PROD.ReverseFeedData AA
   --WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY
   --AND  EXISTS (SELECT 1 FROM tt_ReverseFeedData BB
   --				WHERE AA.AccountID=BB.AccountID
   --				AND BB.EffectiveToTimeKey =49999
   --				AND AA.AssetSubClass<>BB.AssetSubClass 
   --				OR ISNULL(AA.NPADate,'1900-01-01') <> ISNULL(BB.NPADate,'1900-01-01')
   --				)
   --END 
   --delete A from
   --(select ROW_NUMBER() over (partition by 
   --AccountEntityId
   --order by AccountEntityId ) duplicate , AccountEntityId
   -- from CURDAT.AdvAcBalanceDetail WHERE EffectiveToTimeKey=49999 ) A
   --where duplicate > 1
   --delete A from
   --(select ROW_NUMBER() over (partition by 
   --AccountEntityId
   --order by AccountEntityId ) duplicate , AccountEntityId
   -- from CURDAT.AdvAcFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
   --where duplicate > 1
   --delete A from
   --(select ROW_NUMBER() over (partition by 
   --AccountEntityId
   --order by AccountEntityId ) duplicate , AccountEntityId
   -- from CURDAT.AdvAcCal WHERE EffectiveToTimeKey=49999 ) A
   --where duplicate > 1
   --delete A from
   --(select ROW_NUMBER() over (partition by 
   --CustomerEntityId,BranchCode
   --order by CustomerEntityId,BranchCode ) duplicate , CustomerEntityId,BranchCode
   -- from CURDAT.AdvCustFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
   --where duplicate > 1
   --delete A from
   --(select ROW_NUMBER() over (partition by 
   --CustomerEntityId,BranchCode
   --order by CustomerEntityId,BranchCode ) duplicate , CustomerEntityId,BranchCode
   -- from CURDAT.AdvCustNonFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
   --where duplicate > 1
   --update a set InttRate=b.Pref_InttRate
   -- from CURDAT.AdvAcFinancialDetail a
   --inner join CURDAT.AdvAcBasicDetail b
   --on a.AccountEntityId=b.AccountEntityId
   --where a.EffectiveToTimeKey=49999
   --and b.EffectiveToTimeKey=49999

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."REVERSEFEEDDATA_INSERT" TO "ADF_CDR_RBL_STGDB";
