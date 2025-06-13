--------------------------------------------------------
--  DDL for Procedure SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" 
(
  v_SourceType IN VARCHAR2
)
AS
   v_Dateofdata VARCHAR2(200);
   --set @Dateofdata='2022-07-01'
   v_RF_Date VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT DISTINCT date_of_data 

     INTO v_Dateofdata
     FROM dwh_DWH_STG.account_data_finacle ;
   SELECT MAX(DateofData)  

     INTO v_RF_Date
     FROM ReverseFeedData ;
   v_dateofdata := v_RF_Date ;---add
   IF ( v_Dateofdata = v_RF_Date ) THEN
    DECLARE
      v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' );
      v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' );
      v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
        FROM Automate_Advances 
       WHERE  Timekey = v_TimeKey - 2 );

   BEGIN
      IF utils.object_id('TempDB..tt_ReverseFeedDataInsertSyn_3') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReverseFeedDataInsertSyn_3 ';
      END IF;
      DELETE FROM tt_ReverseFeedDataInsertSyn_3;
      UTILS.IDENTITY_RESET('tt_ReverseFeedDataInsertSyn_3');

      INSERT INTO tt_ReverseFeedDataInsertSyn_3 ( 
      	SELECT * 
      	  FROM ReverseFeedDataInsertSync_Customer 
      	 WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date );
      IF ( v_SourceType = 'Finacle' ) THEN

      BEGIN
         ------------Finacle
         DBMS_OUTPUT.PUT_LINE('Finacle ');
         IF utils.object_id('TempDB..tt_Finacle') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle ';
         END IF;
         DELETE FROM tt_Finacle;
         UTILS.IDENTITY_RESET('tt_Finacle');

         INSERT INTO tt_Finacle ( 
         	SELECT A.RefCustomerID CustomerID  ,
                 A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                 A.SysNPA_Dt FinalNpaDt  ,
                 B.SourceAssetClass ,
                 B.SourceNpaDate ,
                 Z.UpgDate ,
                 DA.AssetClassAlt_Key BankAssetClass  ,
                 a.SourceAlt_Key ,
                 a.UCIF_ID 
         	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                   JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey
                   JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                   AND DS.EffectiveFromTimeKey <= v_Timekey
                   AND DS.EffectiveToTimeKey >= v_Timekey
                   JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                   AND A.SourceAlt_Key = DA.SourceAlt_Key
                   AND DA.EffectiveFromTimeKey <= v_Timekey
                   AND DA.EffectiveToTimeKey >= v_Timekey
                   LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                   AND Z.EffectiveFromTimeKey <= v_Timekey
                   AND Z.EffectiveToTimeKey >= v_Timekey
         	 WHERE  DS.SourceName = 'Finacle'
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey

                    --and CAST(RC.ProcessDate AS Date)=@Date
                    AND RC.SourceName = 'Finacle' );
         --ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where B.RefCustomerID=R.CustomerID
         --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
         --And R.ProcessDate=@PreviousDate)
         ----And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date )
         --AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
         --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
         --Delete        a
         --from          tt_Finacle a
         --inner join    ReverseFeedData b
         --on            a.CustomerID=b.CustomerID
         --where         b.DateofData=@Date
         ---------------------
         /* =================================Added by Prashant to change the Finacle logic=========================== */
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( 
                     --Select 'FinacleAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN Pro.CustomerCal_Hist C ON A.CustomerID=C.RefCustomerID

                     --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

                     --where B.SourceName='Finacle'

                     --And A.AssetSubClass<>'STD'

                     --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 

                     --union

                     --Select 'FinacleAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ --ISNULL(Convert(Varchar(10),isnull(A.UpgradeDate,@date),105),'') 

                     --'' as DataUtility

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN Pro.CustomerCal_Hist C ON A.CustomerID=C.RefCustomerID

                     --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

                     --where B.SourceName='Finacle'

                     --And A.AssetSubClass='STD'

                     --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 

                     --UNION
                     SELECT 'FinacleAssetClassification' TableName  ,
                            A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || v_Date || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
                     FROM tt_Finacle A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey ) 
                   --where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

                   -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                   --		 UNION

                   --		 	 Select 'FinacleAssetClassification' AS TableName,

                   --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                   --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility

                   --		 from tt_Finacle A

                   --		  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                   --			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

                   --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   --		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1

                   --		 ANd (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNPADate,'') OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))

                   --	 UNION

                   --	 	 Select 'FinacleAssetClassification' AS TableName,

                   --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                   --Convert(Varchar(10),@Date,105) +'|'+ --ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  

                   --'' as DataUtility

                   --	 from tt_Finacle A

                   --	  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                   --			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

                   --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   --	 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1

                   ----------------
                   A
              GROUP BY TableName,DataUtility ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      /*	
      		IF (@SourceType ='Ganaseva')
      		BEGIN
      				IF OBJECT_ID('TempDB..#Ganaseva') Is Not Null
      			Drop Table #Ganaseva

      			Select A.RefCustomerID,A.SrcAssetClassAlt_Key,A.SrcNPA_Dt,B.SourceAssetClass,B.SourceNpaDate,a.SysAssetClassAlt_Key,a.SysNPA_Dt,
      			DA.AssetClassAlt_Key BankAssetClass,z.UpgDate,a.UCIF_ID,a.SourceAlt_Key
      				 INto #Ganaseva
      			 from Pro.CUSTOMERCAL A
      			Inner Join curdat.AdvCustOtherDetail B ON A.CustomerEntityID=B.CustomerEntityID
      			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
      			Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key
      			ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey
      			Inner Join DimAssetClassMapping_Customer DA ON DA.AssetClassShortName=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key
      			ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey
      			LEFT JOIN PRO.ACCOUNTCAL Z ON A.CustomerEntityID=Z.CustomerEntityID AND
                  Z.EffectiveFromTimeKey<=@Timekey ANd Z.EffectiveToTimeKey>=@Timekey 
      			Where DS.SourceName='Ganaseva' AND
      			A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
      			ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID
      			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
      			And R.ProcessDate=@PreviousDate)
      			And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.RefCustomerID and DateofData=@Date )
      			-- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
      			--X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
      			AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
      			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)


      			Delete        a
      			from          #Ganaseva a
      			inner join    ReverseFeedData b
      			on            a.RefCustomerID=b.CustomerID
      			where         b.DateofData=@Date
      			----------------

      --		 Select 'GanasevaAssetClassification' AS TableName,
      --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+
      --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.NPADate,@date),105),'')  as DataUtility
      Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.CustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ Convert(Varchar(10),DateofData,103) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,103),'')  as DataUtility 

      		 from ReverseFeedData A
      		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
      And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      		 where B.SourceName='Ganaseva'
      		 And A.AssetSubClass<>'STD'
      		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      		  ------Changes for NPADate on 22/04/2022

      		 union





      --		 Select 'GanasevaAssetClassification' AS TableName,
      --A.refCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+
      --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.SysNPA_Dt,@date),105),'')  as DataUtility
      Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+
      Convert(Varchar(10),@Date,103) +'|'+ ISNULL(Convert(Varchar(10),A.SysNPA_Dt,103),'')  as DataUtility 

       from Pro.CustomerCal_hist A wITH (NOLOCK)
      			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key
      			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      			 where B.SourceName='Ganaseva'
      			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 
      			 ANd  ISNULL(A.SysNPA_Dt,'')<>ISNULL(A.SrcNPA_Dt,'')     
      			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


      		 ----------Added on 04/04/2022
      		 UNION

      --				 Select 'GanasevaAssetClassification' AS TableName,
      --A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+
      --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.SysNPA_Dt,@date),105),'')  as DataUtility
      Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ 
      Convert(Varchar(10),@Date,103) +'|'+ ISNULL(Convert(Varchar(10),A.SysNPA_Dt,103),'')  as DataUtility 

      		 from #Ganaseva A
      		 Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key
      			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      		 where A.BankAssetClass=1 And A.SysAssetClassAlt_Key>1

      		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
      		 UNION

      				Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ 
      Convert(Varchar(10),@Date,103) +'|'+ ISNULL(Convert(Varchar(10),A.SysNPA_Dt,103),'')  as DataUtility  from #Ganaseva A
      Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key
      			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      		 where A.BankAssetClass>1 And A.SysAssetClassAlt_Key>1
      		 And ( ISNULL(A.SourceNpaDate,'')<>ISNULL(A.SysNPA_Dt,'') OR (A.BankAssetClass<> A.SysAssetClassAlt_Key))

      		 union

      		 			 Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.CustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ 
      Convert(Varchar(10),@Date,103) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,103),'')  as DataUtility  from ReverseFeedData A
      Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key
      			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      	 where B.SourceName='Ganaseva'
      	 And A.AssetSubClass='STD'
      	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

      	  --------------Added on 04/04/2022
      	 UNION

      	 		 Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ 
      Convert(Varchar(10),@Date,103) +'|'+ ISNULL(Convert(Varchar(10),A.SysNPA_Dt,103),'')  as DataUtility 
      	 from #Ganaseva A
      	 Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key
      			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      	 Where A.BankAssetClass>1 And A.SysAssetClassAlt_Key=1
      	    END
      */
      IF ( v_SourceType = 'ECBF' ) THEN

      BEGIN
         --------------ECBF
         --Select * from (
         IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD ';
         END IF;
         DELETE FROM tt_ACCOUNTCAL_DPD;
         UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD');

         INSERT INTO tt_ACCOUNTCAL_DPD ( 
         	SELECT CustomerEntityID ,
                 MAX(DPD_Max)  DPD_Max  
         	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         	  GROUP BY CustomerEntityID );
         IF utils.object_id('TempDB..tt_ECBF_3') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_3 ';
         END IF;
         DELETE FROM tt_ECBF_3;
         UTILS.IDENTITY_RESET('tt_ECBF_3');

         INSERT INTO tt_ECBF_3 ( 
         	SELECT RefCustomerID ,
                 FinalAssetClassAlt_Key ,
                 FinalNpaDt ,
                 SourceAssetClass ,
                 SourceNpaDate ,
                 BankAssetClass ,
                 ProductType ,
                 ClientName ,
                 ClientCustId ,
                 SystemClassification ,
                 SystemSubClassification ,
                 DPD ,
                 UserClassification ,
                 UserSubClassification ,
                 NpaDate ,
                 CurrentDate ,
                 UCIF_ID ,
                 SrcSysClassName 
         	  FROM ( SELECT A.RefCustomerID ,
                          A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                          A.SysNPA_Dt FinalNpaDt  ,
                          B.SourceAssetClass ,
                          B.SourceNpaDate ,
                          DA.AssetClassAlt_Key BankAssetClass  ,
                          DP.ProductName ProductType  ,
                          A.CustomerName ClientName  ,
                          A.RefCustomerID ClientCustId  ,
                          E.AssetClassGroup SystemClassification  ,
                          CASE 
                               WHEN E.SrcSysClassCode = 'SS' THEN 'SBSTD'
                               WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                               WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                               WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                               WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                          ELSE E.SrcSysClassCode
                             END SystemSubClassification  ,
                          MAX(AD.DPD_Max)  DPD  ,
                          'NPA' UserClassification  ,
                          'SBSTD' UserSubClassification  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105) NpaDate  ,
                          v_Date CurrentDate  ,
                          a.UCIF_ID ,
                          E.SrcSysClassName 
                   FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                          JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                          JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                          AND B.EffectiveFromTimeKey <= v_Timekey
                          AND B.EffectiveToTimeKey >= v_Timekey
                          JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                          AND DS.EffectiveFromTimeKey <= v_Timekey
                          AND DS.EffectiveToTimeKey >= v_Timekey
                        --Inner Join Pro.CUSTOMERCAL C ON C.CustomerEntityID=A.CustomerEntityID

                          JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                          AND E.EffectiveFromTimeKey <= v_Timekey
                          AND E.EffectiveToTimeKey >= v_Timekey
                          JOIN DimAssetClassMapping_Customer DA
                        --ON DA.AssetClassShortName=B.SourceAssetClass  
                         -- > Edited  by Prashant by dated 03/07/2024
                           ON DA.SrcSysClassCode = B.SourceAssetClass
                          AND A.SourceAlt_Key = DA.SourceAlt_Key
                          AND DA.EffectiveFromTimeKey <= v_Timekey
                          AND DA.EffectiveToTimeKey >= v_Timekey
                          LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                          AND Z.EffectiveFromTimeKey <= v_Timekey
                          AND Z.EffectiveToTimeKey >= v_Timekey
                          LEFT JOIN tt_ACCOUNTCAL_DPD AD   ON AD.CustomerEntityID = Z.CustomerEntityID
                          JOIN DimProduct DP   ON DP.ProductAlt_Key = Z.ProductAlt_Key
                          AND DP.EffectiveFromTimeKey <= v_Timekey
                          AND DP.EffectiveToTimeKey >= v_Timekey
                    WHERE  DS.SourceName = 'ECBF'
                             AND RC.SourceName = 'ECBF'

                   --ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID

                   --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')

                   --And R.ProcessDate=@PreviousDate)

                   --And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date )

                   ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                   ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND

                   --AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 

                   --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
                   GROUP BY A.RefCustomerID,A.SysAssetClassAlt_Key,A.SysNPA_Dt,B.SourceAssetClass,B.SourceNpaDate,DA.AssetClassAlt_Key,DP.ProductName,A.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.SysNPA_Dt,a.UCIF_ID,E.SrcSysClassName ) A
         	  GROUP BY RefCustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,UCIF_ID,SrcSysClassName );
         --Delete        a
         --from          tt_ECBF_3 a
         --inner join    ReverseFeedData b
         --on            a.RefCustomerID=b.CustomerID
         --where         b.DateofData=@Date
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( 
                     --Select CustomerID as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                     --Convert(Varchar(10),DateofData,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                     -- from (

                     --Select 

                     --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                     --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                     --, DPD , UserClassification, UserSubClassification, NpaDate, CurrentDate,CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData

                     --from (

                     --Select DISTINCT A.ProductName ProductType,

                     --A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,

                     --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 

                     --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification

                     --,max(A.DPD) as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,

                     --Convert(Varchar(10),A.DateofData,105)as CurrentDate,CustomerID,UCIF_ID,E.SrcSysClassName,DateofData

                     --  from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='ECBF'

                     -- And A.AssetSubClass<>'STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By A.ProductName ,

                     -- A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode  

                     --,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105),CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData

                     --)A

                     --)T

                     ---------------Changes for npadate on 22/04/2022

                     -----------Added on 04/04/2022-----

                     --UNION

                     --Select ClientCustId as CustomerID,
                     SELECT SUBSTR(ClientCustId, 2, LENGTH(ClientCustId)) CustomerID ,--added by Prashant--06072024---as per new CR-------

                            UCIF_ID UCIC  ,
                            SystemSubClassification Asset_Code  ,
                            SrcSysClassName DESCRIPTION  ,
                            UTILS.CONVERT_TO_VARCHAR2(CurrentDate,10,p_style=>105) Asset_Code_Date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>105), ' ') D2KNpaDate  
                     FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
                                   ProductType ,
                                   ClientName ,
                                   ClientCustId ,
                                   SystemClassification ,
                                   SystemSubClassification ,
                                   DPD ,
                                   UserClassification ,
                                   UserSubClassification ,
                                   NpaDate ,
                                   CurrentDate ,
                                   UCIF_ID ,
                                   SrcSysClassName 
                            FROM ( SELECT DISTINCT ProductType ,
                                                   ClientName ,
                                                   ClientCustId ,
                                                   SystemClassification ,
                                                   SystemSubClassification ,
                                                   MAX(DPD)  DPD  ,
                                                   UserClassification ,
                                                   UserSubClassification ,
                                                   NpaDate ,
                                                   CurrentDate ,
                                                   UCIF_ID ,
                                                   SrcSysClassName 
              FROM tt_ECBF_3 A

            --where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1
            GROUP BY ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,UserClassification,UserSubClassification,NpaDate,CurrentDate,UCIF_ID,SrcSysClassName ) A ) T ) 
                   -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                   --UNION

                   --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                   --Convert(Varchar(10),CurrentDate,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                   -- from (

                   --Select 

                   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                   --ProductType,

                   --ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD

                   --, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --from (

                   --Select DISTINCT ProductType,

                   --ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, max(DPD)DPD

                   --, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --  from tt_ECBF_3 A

                   --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1

                   --And (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')  OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))

                   --GROUP BY ProductType,

                   --ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --)A

                   --)T

                   --Union

                   --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                   --Convert(Varchar(10),CurrentDate,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                   -- from (

                   --Select 

                   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --from (

                   --Select DISTINCT A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification

                   --,max(A.DPD) as DPD,E.AssetClassGroup as UserClassification,

                   --(Case When max(A.DPD)=0 Then 'DPD0' When max(A.DPD) BETWEEN 1 AND 30 Then 'DPD30' When max(A.DPD) BETWEEN 31 AND 60 Then 'DPD60' 

                   --When max(A.DPD) BETWEEN 61 AND 90 Then 'DPD90' When max(A.DPD) BETWEEN 91 AND 180 Then 'DPD180' When max(A.DPD) BETWEEN 181 AND 365 Then 'PD1YR' END )

                   -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate,

                   -- UCIF_ID,e.SrcSysClassName

                   --  from ReverseFeedData A

                   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                   --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.AssetClassShortName

                   --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                   ----Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID

                   -- where B.SourceName='ECBF'

                   -- And A.AssetSubClass='STD'

                   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                   -- Group By 

                   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.AssetClassShortName 

                   --  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105),UCIF_ID,SrcSysClassName

                   --)A

                   --)T

                   --------------Added on 04/04/2022

                   --UNION

                   --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                   --Convert(Varchar(10),CurrentDate,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                   -- from (

                   --Select 

                   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --from (

                   --Select DISTINCT ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, max(DPD)DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --  from tt_ECBF_3 A

                   --  where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1

                   --group by ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --,  UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --)A

                   --)T
                   A
              GROUP BY CustomerID,UCIC,Asset_Code,DESCRIPTION,Asset_Code_Date,D2KNpaDate ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --)A
      --Group By CustomerID,UCIC,Asset_Code,Description,Asset_Code_Date,D2KNpaDate
      IF ( v_SourceType = 'Indus' ) THEN

      BEGIN
         --------------Indus
         --  Select * from (
         --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),DateofData,105) as asset_code_date,ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as [D2K NPA date],A.CustomerID as [Customer ID],A.UCIF_ID as UCIC from ReverseFeedData A
         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
         --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         -- where B.SourceName='Indus'
         -- --And A.AssetSubClass<>'STD'
         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -- UNION 
         -- Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC 
         -- from Pro.AccountCal_hist A wITH (NOLOCK)
         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
         --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         -- where B.SourceName='Indus'
         -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
         -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date
         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -- )A
         -- Group By Asset_Code,Description,Asset_Code_Date,[D2K NPA date],[Customer ID],UCIC
         IF utils.object_id('TempDB..tt_Indus') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus ';
         END IF;
         DELETE FROM tt_Indus;
         UTILS.IDENTITY_RESET('tt_Indus');

         INSERT INTO tt_Indus ( 
         	SELECT A.RefCustomerID ,
                 A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                 A.SysNPA_Dt FinalNpaDt  ,
                 B.SourceAssetClass ,
                 B.SourceNpaDate ,
                 DA.AssetClassAlt_Key BankAssetClass  ,
                 UpgDate ,
                 a.SourceAlt_Key ,
                 a.UCIF_ID 
         	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                   JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey
                   JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                   AND DS.EffectiveFromTimeKey <= v_Timekey
                   AND DS.EffectiveToTimeKey >= v_Timekey
                   JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                   AND A.SourceAlt_Key = DA.SourceAlt_Key
                   AND DA.EffectiveFromTimeKey <= v_Timekey
                   AND DA.EffectiveToTimeKey >= v_Timekey
                   LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                   AND Z.EffectiveFromTimeKey <= v_Timekey
                   AND Z.EffectiveToTimeKey >= v_Timekey
         	 WHERE  DS.SourceName = 'Indus'
                    AND RC.SourceName = 'Indus' );
         ----ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID
         ----And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
         ----And R.ProcessDate=@PreviousDate)
         ----And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date)
         ------ NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
         ------X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
         ----and NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
         ----Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
         --Delete        a
         --from          tt_Indus a
         --inner join    ReverseFeedData b
         --on            a.RefCustomerID=b.CustomerID
         --where         b.DateofData=@Date
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( 
                     --Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date'

                     --			Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),DateofData,105) as asset_code_date,

                     --			ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as [D2K NPA date],A.CustomerID as [Customer ID],A.UCIF_ID as UCIC

                     --			from ReverseFeedData A

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --				And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Indus'

                     --			 And A.AssetSubClass<>'STD'

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --			 ------Changes for NPADate on 22/04/2022

                     --		 union

                     ----Select RefCustomerID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),SysNPA_Dt,106),' ','-') as 'Value Date'

                     --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,

                     --			ISNULL(Convert(Varchar(10),A.SysNPA_Dt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC

                     -- from Pro.CustomerCal_Hist A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Indus'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --			 -----------Added on 11/04/2022

                     --		 UNION
                     SELECT E.AssetClassShortNameEnum asset_code  ,
                            E.SrcSysClassName DESCRIPTION  ,
                            v_Date asset_code_date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') D2K_NPA_date  ,
                            A.RefCustomerID Customer_ID  ,
                            A.UCIF_ID UCIC  
                     FROM tt_Indus A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey ) 
                   --where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

                   -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                   -- UNION

                   --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,

                   --	ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC

                   -- from tt_Indus A

                   --  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --		And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                   --		Inner JOIN DimAssetClass E ON  A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   -- where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1

                   -- And (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')  OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))

                   -- Union

                   --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,

                   --	ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as [D2K NPA date],A.CustomerID as [Customer ID],A.UCIF_ID as UCIC from ReverseFeedData A

                   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                   --Inner JOIN DimAssetClass E ON  A.AssetClass=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   -- where B.SourceName='Indus'

                   -- And A.AssetSubClass='STD'

                   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                   -- -----------Added on 11/04/2022

                   -- UNION

                   -- Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,

                   --	ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC

                   -- from tt_Indus A

                   -- Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --		And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                   --		Inner JOIN DimAssetClass E ON  A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   -- where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1
                   A
              GROUP BY Asset_Code,DESCRIPTION,Asset_Code_Date,D2K_NPA_date,Customer_ID,UCIC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_SourceType = 'MiFin' ) THEN

      BEGIN
         --------------MiFin
         --Select * from (
         --Select A.CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),DateofData,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.NPADate,106),' ','-'),'')  as D2kNpaDate from ReverseFeedData A
         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
         --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         -- where B.SourceName='MiFin'
         -- --And A.AssetSubClass<>'STD'
         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -- UNION 
         -- Select A.RefCustomerID as CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.FinalNpaDt,106),' ','-'),'')  as D2kNpaDate 
         -- from Pro.AccountCal_hist A wITH (NOLOCK)
         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
         --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         -- where B.SourceName='MiFin'
         -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
         -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date
         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -- )A
         -- Group By CustomerID,UCIF_ID,AssetClassShortNameEnum,AssetClassName,Asset_Code_Date,D2kNpaDate
         IF utils.object_id('TempDB..tt_MiFin') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin ';
         END IF;
         DELETE FROM tt_MiFin;
         UTILS.IDENTITY_RESET('tt_MiFin');

         INSERT INTO tt_MiFin ( 
         	SELECT A.RefCustomerID ,
                 A.SysAssetClassAlt_Key ,
                 A.SysNPA_Dt ,
                 B.SourceAssetClass ,
                 B.SourceNpaDate ,
                 DA.AssetClassAlt_Key BankAssetClass  ,
                 UpgDate ,
                 a.SourceAlt_Key ,
                 a.UCIF_ID 
         	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                   JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey
                   JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                   AND DS.EffectiveFromTimeKey <= v_Timekey
                   AND DS.EffectiveToTimeKey >= v_Timekey
                   JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                   AND A.SourceAlt_Key = DA.SourceAlt_Key
                   AND DA.EffectiveFromTimeKey <= v_Timekey
                   AND DA.EffectiveToTimeKey >= v_Timekey
                   LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                   AND Z.EffectiveFromTimeKey <= v_Timekey
                   AND Z.EffectiveToTimeKey >= v_Timekey
         	 WHERE  DS.SourceName = 'MiFin'
                    AND RC.SourceName = 'MiFin' );
         --A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
         --ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID
         --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
         --And R.ProcessDate=@PreviousDate)
         --And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date )
         ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
         ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
         --and NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
         --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
         --Delete        a
         --from          tt_MiFin a
         --inner join    ReverseFeedData b
         --on            a.RefCustomerID=b.CustomerID
         --where         b.DateofData=@Date
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( 
                     --Select CustomerID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) 

                     --	Select A.CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),DateofData,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.NPADate,106),' ','-'),'')  as D2kNpaDate

                     --	from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

                     --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='MiFin'

                     -- And A.AssetSubClass<>'STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     ------Changes for NPADate on 22/04/2022

                     --		 union

                     --Select A.refCustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.SysNPA_Dt,106),' ','-'),'')  as D2kNpaDate

                     --			from Pro.CUSTOMERCAL A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Mifin'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -----------Added on 11/04/2022

                     --UNION
                     SELECT A.refCustomerID CustomerID  ,
                            A.UCIF_ID ,
                            E.AssetClassShortNameEnum ,
                            E.AssetClassName ,
                            REPLACE(v_Date, ' ', '-') Asset_Code_Date  ,
                            NVL(REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,20,p_style=>106), ' ', '-'), ' ') D2kNpaDate  
                     FROM tt_MiFin A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey ) 
                   --where A.BankAssetClass=1 And A.SysAssetClassAlt_Key>1

                   -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                   --	 UNION

                   --	Select A.refCustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.SysNPA_Dt,106),' ','-'),'')  as D2kNpaDate

                   --		 from tt_MiFin A

                   --	 Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --		And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                   --		Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   --	 where A.BankAssetClass>1 And A.SysAssetClassAlt_Key>1

                   --	 And (ISNULL(A.SysNPA_Dt,'')<>ISNULL(A.SourceNPADate,'')   OR (A.BankAssetClass<> A.SysAssetClassAlt_Key))

                   --	 UNION

                   --	 	Select A.CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.NPADate,106),' ','-'),'')  as D2kNpaDate

                   --		from ReverseFeedData A

                   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                   --Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   -- where B.SourceName='MiFin'

                   -- And A.AssetSubClass='STD'

                   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                   -- -----------Added on 11/04/2022

                   --	 UNION

                   --	Select A.RefCustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.SysNPA_Dt,106),' ','-'),'')  as D2kNpaDate

                   --	from tt_MiFin A Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                   --Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                   --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                   --	 where A.BankAssetClass>1 And A.SysAssetClassAlt_Key=1
                   A
              GROUP BY CustomerID,UCIF_ID,AssetClassShortNameEnum,AssetClassName,Asset_Code_Date,D2kNpaDate ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      /*
      		IF (@SourceType ='VisionPlus')
      		BEGIN
      		        --------------VisionPlus
      				Select * from(

      				Select 'VisionPlusAssetClassification' AS TableName,('UCIC'+'|'+'CIF ID'+'|'+'asset_code'+'|'+'description'+'|'+'asset_code_date'+'|'+'D2K NPA date') as DataUtility
      				UNION 
      				Select'VisionPlusAssetClassification' AS TableName, (A.UCIF_ID+'|'+A.CustomerID+'|'+E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+Convert(Varchar(10),DateofData,105))+'|'+ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility
      				  from ReverseFeedData A
      				Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      				And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      				Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
      				And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      				 where B.SourceName='VisionPlus'
      				 --And A.AssetSubClass<>'STD'
      				 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

      				 UNION

      				 Select'VisionPlusAssetClassification' AS TableName, (A.UCIF_ID+'|'+A.RefCustomerID+'|'+E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+Convert(Varchar(10),@Date,105))+'|'+ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility
      				  from Pro.AccountCal_hist A wITH (NOLOCK)
      				Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      				And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      				Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
      				And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      				 where B.SourceName='VisionPlus'
      				 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
      				 ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date
      				 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      				 )A Order By 2 Desc
      		END	

      */
      ------------MetaGrid
      IF ( v_SourceType = 'MetaGrid' ) THEN

      BEGIN
         --------------MetaGrid
         --Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
         --Replace(convert(varchar(20),DateofData,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.AssetSubClass<>'STD' Then Replace(convert(varchar(20),A.NPADate,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
         -- from ReverseFeedData A
         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
         --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         -- where B.SourceName='MetaGrid'
         -- --And A.AssetSubClass<>'STD'
         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         IF utils.object_id('TempDB..tt_MetaGrid_3') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_3 ';
         END IF;
         DELETE FROM tt_MetaGrid_3;
         UTILS.IDENTITY_RESET('tt_MetaGrid_3');

         INSERT INTO tt_MetaGrid_3 ( 
         	SELECT A.RefCustomerID ,
                 A.RefCustomerID CustomerId  ,
                 A.UCIF_ID ,
                 A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                 A.SysNPA_Dt FinalNpaDt  ,
                 B.SourceAssetClass ,
                 B.SourceNpaDate ,
                 DA.AssetClassAlt_Key BankAssetClass  ,
                 A.SourceAlt_Key 
         	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                   JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey
                   JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                   AND DS.EffectiveFromTimeKey <= v_Timekey
                   AND DS.EffectiveToTimeKey >= v_Timekey
                   JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                   AND A.SourceAlt_Key = DA.SourceAlt_Key
                   AND DA.EffectiveFromTimeKey <= v_Timekey
                   AND DA.EffectiveToTimeKey >= v_Timekey
                   LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                   AND Z.EffectiveFromTimeKey <= v_Timekey
                   AND Z.EffectiveToTimeKey >= v_Timekey
         	 WHERE  DS.SourceName = 'MetaGrid'
                    AND RC.SourceName = 'Metagrid' );
         --ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID
         --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
         --And R.ProcessDate=@PreviousDate)
         --And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date )
         ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
         ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
         --AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
         --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
         --Delete        a
         --from          tt_MetaGrid_3 a
         --inner join    ReverseFeedData b
         --on            a.RefCustomerID=b.CustomerID
         --where         b.DateofData=@Date
         --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE'
         --		Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
         --			Replace(convert(varchar(20),DateofData,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.AssetSubClass<>'STD' Then Replace(convert(varchar(20),A.NPADate,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
         --		from ReverseFeedData A
         --		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
         --		Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key
         --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         --		 where B.SourceName='MetaGrid'
         --		 And A.AssetSubClass<>'STD'
         --		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         --------Changes for NPADate on 22/04/2022
         --	 union
         --Select A.RefCustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),A.SysNPA_Dt,105),'-','') as 'ENPA_D2K_NPA_DATE'
         --Select A.RefCustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
         --				Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.SysAssetClassAlt_Key<>1 Then Replace(convert(varchar(20),A.SysNPA_Dt,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
         -- from Pro.CustomerCal_Hist A wITH (NOLOCK)
         --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
         --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
         --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key
         --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
         --			 where B.SourceName='MetaGrid'
         --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 
         --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     
         --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -----------Added on 11/04/2022
         --UNION
         OPEN  v_cursor FOR
            SELECT A.CustomerID CIF_ID  ,
                   A.UCIF_ID UCIC  ,
                   E.SrcSysClassCode ENPA_ASSET_CODE  ,
                   CASE 
                        WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                   ELSE E.SrcSysClassName
                      END ENPA_DESCRIPTION  ,
                   REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                   CASE 
                        WHEN A.FinalAssetClassAlt_Key <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ')
                   ELSE NULL
                      END ENPA_D2K_NPA_DATE  
              FROM tt_MetaGrid_3 A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1
      -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
      --	 UNION
      --	Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
      --		Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.FinalAssetClassAlt_Key<>1 Then Replace(convert(varchar(20),A.FinalNpaDt,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
      --	 from tt_MetaGrid_3 A
      --	 Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --	And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      --	Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
      --	And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      --	 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
      --	 And (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')  OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))
      --	 UNION
      --	 	Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
      --		Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.AssetClass<>1 Then Replace(convert(varchar(20),A.NPADate,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
      --	  from ReverseFeedData A
      --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      --Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key
      --	And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      -- where B.SourceName='MetaGrid'
      -- And A.AssetSubClass='STD'
      -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      -- -----------Added on 11/04/2022
      --	 UNION
      --	 	Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',
      --		Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.FinalAssetClassAlt_Key<>1 Then Replace(convert(varchar(20),A.FinalNpaDt,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'
      --	 from tt_MetaGrid_3 A
      --	  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --	And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
      --	Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
      --	And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
      --	 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1
      --------------------------------------------- EIFS ADDED BY Mandeep Singh (26-09-2022)-------------------------------------------------------
      IF ( v_SourceType = 'EIFS' ) THEN

      BEGIN
         IF utils.object_id('TempDB..tt_ACCOUNTCAL_TAF') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_TAF ';
         END IF;
         DELETE FROM tt_ACCOUNTCAL_TAF;
         UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_TAF');

         INSERT INTO tt_ACCOUNTCAL_TAF ( 
         	SELECT CustomerEntityID ,
                 MAX(DPD_Max)  DPD_Max  
         	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         	  GROUP BY CustomerEntityID );
         IF utils.object_id('TempDB..tt_EIFS') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EIFS ';
         END IF;
         DELETE FROM tt_EIFS;
         UTILS.IDENTITY_RESET('tt_EIFS');

         INSERT INTO tt_EIFS ( 
         	SELECT RefCustomerID ,
                 FinalAssetClassAlt_Key ,
                 FinalNpaDt ,
                 SourceAssetClass ,
                 SourceNpaDate ,
                 BankAssetClass ,
                 ProductType ,
                 ClientName ,
                 ClientCustId ,
                 SystemClassification ,
                 SystemSubClassification ,
                 DPD ,
                 UserClassification ,
                 UserSubClassification ,
                 NpaDate ,
                 CurrentDate ,
                 UCIF_ID ,
                 SrcSysClassName 
         	  FROM ( SELECT A.RefCustomerID ,
                          A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                          A.SysNPA_Dt FinalNpaDt  ,
                          B.SourceAssetClass ,
                          B.SourceNpaDate ,
                          DA.AssetClassAlt_Key BankAssetClass  ,
                          DP.ProductName ProductType  ,
                          C.CustomerName ClientName  ,
                          A.RefCustomerID ClientCustId  ,
                          E.AssetClassGroup SystemClassification  ,
                          CASE 
                               WHEN E.SrcSysClassCode = 'SS' THEN 'SBSTD'
                               WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                               WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                               WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                               WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                          ELSE E.SrcSysClassCode
                             END SystemSubClassification  ,
                          AD.DPD_Max DPD  ,
                          'NPA' UserClassification  ,
                          'SBSTD' UserSubClassification  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105) NpaDate  ,
                          v_Date CurrentDate  ,
                          a.UCIF_ID ,
                          E.SrcSysClassName 
                   FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                          JOIN tt_ReverseFeedDataInsertSyn_3 RC   ON A.RefCustomerID = RC.CustomerID
                          JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                          AND B.EffectiveFromTimeKey <= v_Timekey
                          AND B.EffectiveToTimeKey >= v_Timekey
                          JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                          AND DS.EffectiveFromTimeKey <= v_Timekey
                          AND DS.EffectiveToTimeKey >= v_Timekey
                          AND DS.SourceAlt_Key = ( SELECT SourceAlt_Key 
                                                   FROM DIMSOURCEDB 
                                                    WHERE  SourceDBName = 'EIFS'
                                                             AND EffectiveToTimeKey = 49999 )
                          JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                          JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                          AND E.EffectiveFromTimeKey <= v_Timekey
                          AND E.EffectiveToTimeKey >= v_Timekey
                          JOIN DimAssetClassMapping DA   ON DA.AssetClassShortName = B.SourceAssetClass
                          AND DA.EffectiveFromTimeKey <= v_Timekey
                          AND DA.EffectiveToTimeKey >= v_Timekey
                          AND DA.SourceAlt_Key = ( SELECT SourceAlt_Key 
                                                   FROM DIMSOURCEDB 
                                                    WHERE  SourceDBName = 'EIFS'
                                                             AND EffectiveToTimeKey = 49999 )
                          AND A.SourceAlt_Key = DA.SourceAlt_Key
                          LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                          AND Z.EffectiveFromTimeKey <= v_Timekey
                          AND Z.EffectiveToTimeKey >= v_Timekey
                          LEFT JOIN tt_ACCOUNTCAL_TAF AD   ON AD.CustomerEntityID = Z.CustomerEntityID
                          JOIN DimProduct DP   ON DP.ProductAlt_Key = Z.ProductAlt_Key
                          AND DP.EffectiveFromTimeKey <= v_Timekey
                          AND DP.EffectiveToTimeKey >= v_Timekey
                          AND DP.ProductCode = 'RVF'
                    WHERE  DS.SourceName = 'EIFS'
                             AND RC.SourceName = 'EIFS' ) 
                 --Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID

                 --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')

                 --And R.ProcessDate=@PreviousDate)

                 ----And Not exists (Select 1 from ReverseFeedData B where B.CustomerID=A.RefCustomerID and DateofData=@Date )

                 --AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 

                 --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
                 A
         	  GROUP BY RefCustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,UCIF_ID,SrcSysClassName );
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( 
                     --Select CustomerID as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                     --Convert(Varchar(10),DateofData,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                     --FROM (

                     --Select 

                     --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                     --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                     --, DPD , UserClassification, UserSubClassification, NpaDate, CurrentDate,CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData

                     --from (

                     --Select A.ProductName ProductType,

                     --A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,

                     --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 

                     --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification

                     --,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,

                     --Convert(Varchar(10),A.DateofData,105)as CurrentDate,CustomerID,UCIF_ID,E.SrcSysClassName,DateofData

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='EIFS'

                     -- And A.AssetSubClass<>'STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By A.ProductName ,

                     -- A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode ,A.DPD  

                     --,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105),CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData

                     --)A

                     --)T

                     -------------Changes for npadate on 22/04/2022

                     --UNION

                     --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                     --Convert(Varchar(10),CurrentDate,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                     -- from (

                     --Select 

                     --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                     --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                     --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                     --from (

                     --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification

                     --,A.DPD as DPD,E.AssetClassGroup as UserClassification,

                     --(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60' 

                     --When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )

                     -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate,

                     -- UCIF_ID,e.SrcSysClassName

                     --  from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.AssetClassShortName

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     ----Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID

                     -- where B.SourceName='EIFS'

                     -- And A.AssetSubClass='STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By 

                     -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.AssetClassShortName 

                     --,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105),UCIF_ID,SrcSysClassName

                     --)A

                     --)T

                     -----------Added on 04/04/2022-----

                     --UNION
                     SELECT ClientCustId CustomerID  ,
                            UCIF_ID UCIC  ,
                            SystemSubClassification Asset_Code  ,
                            SrcSysClassName DESCRIPTION  ,
                            UTILS.CONVERT_TO_VARCHAR2(CurrentDate,10,p_style=>110) Asset_Code_Date  ,
                            NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>110), ' ') D2KNpaDate  
                     FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
                                   ProductType ,
                                   ClientName ,
                                   ClientCustId ,
                                   SystemClassification ,
                                   SystemSubClassification ,
                                   DPD ,
                                   UserClassification ,
                                   UserSubClassification ,
                                   NpaDate ,
                                   CurrentDate ,
                                   UCIF_ID ,
                                   SrcSysClassName 
                            FROM ( SELECT ProductType ,
                                          ClientName ,
                                          ClientCustId ,
                                          SystemClassification ,
                                          SystemSubClassification ,
                                          DPD ,
                                          UserClassification ,
                                          UserSubClassification ,
                                          NpaDate ,
                                          CurrentDate ,
                                          UCIF_ID ,
                                          SrcSysClassName 
                                   FROM tt_EIFS A ) 
                                 --where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1
                                 A ) T ) 
                   -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                   --UNION

                   --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                   --Convert(Varchar(10),CurrentDate,110) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,110),'')  as D2KNpaDate

                   -- from (

                   --Select 

                   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                   --ProductType,

                   --ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD

                   --, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --from (

                   --Select ProductType,

                   --ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD

                   --, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --  from tt_EIFS A

                   --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1

                   --And (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')  OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))

                   --)A

                   --)T

                   --Union

                   --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                   --Convert(Varchar(10),CurrentDate,110) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,110),'')  as D2KNpaDate

                   -- from (

                   --Select 

                   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --from (

                   --Select ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                   --  from tt_EIFS A

                   --  where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1

                   --)A

                   --)T
                   A
              GROUP BY CustomerID,UCIC,Asset_Code,DESCRIPTION,Asset_Code_Date,D2KNpaDate ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      ------------Calypso
      IF ( v_SourceType = 'Calypso' ) THEN

      BEGIN
         --------------Calypso
         OPEN  v_cursor FOR
            SELECT 'AMEND' Action  ,
                   CASE 
                        WHEN D.CP_EXTERNAL_REF IS NULL THEN ' '
                   ELSE D.CP_EXTERNAL_REF
                      END External_Reference  ,
                   CASE 
                        WHEN D.COUNTERPARTY_SHORTNAME IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_SHORTNAME
                      END ShortName  ,
                   CASE 
                        WHEN D.COUNTERPARTY_FULLNAME IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_FULLNAME
                      END LongName  ,
                   CASE 
                        WHEN D.COUNTERPARTY_COUNTRY IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_COUNTRY
                      END Country  ,
                   CASE 
                        WHEN D.CP_FINANCIAL IS NULL THEN ' '
                   ELSE D.CP_FINANCIAL
                      END Financial  ,
                   CASE 
                        WHEN D.CP_PARENT IS NULL THEN ' '
                   ELSE D.CP_PARENT
                      END Parent  ,
                   CASE 
                        WHEN D.CP_HOLIDAY IS NULL THEN ' '
                   ELSE D.CP_HOLIDAY
                      END HolidayCode  ,
                   CASE 
                        WHEN D.CP_COMMENT IS NULL THEN ' '
                   ELSE D.CP_COMMENT
                      END Comment_  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE1 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE1
                      END Roles_Role  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE2 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE2
                      END Roles__A11  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE3 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE3
                      END Roles__A12  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE4 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE4
                      END Roles__A13  ,
                   CASE 
                        WHEN D.COUNTERPARTY_ROLE5 IS NULL THEN ' '
                   ELSE D.COUNTERPARTY_ROLE5
                      END Roles__A14  ,
                   CASE 
                        WHEN D.CP_STATUS IS NULL THEN ' '
                   ELSE D.CP_STATUS
                      END Status  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'CIF_Id' Attribute_AttributeName  ,
                   CASE 
                        WHEN D.CIF_ID IS NULL THEN ' '
                   ELSE D.CIF_ID
                      END Attribute_AttributeValue  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'UCIC' Attribute_AttributeName  ,
                   CASE 
                        WHEN D.ucic_id IS NULL THEN ' '
                   ELSE D.ucic_id
                      END Attribute_AttributeV_A23  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_ASSET_CODE' Attribute_AttributeName  ,
                   CASE 
                        WHEN E.SrcSysClassCode IS NULL THEN ' '
                   ELSE E.SrcSysClassCode
                      END Attribute_AttributeV_A27  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_DESCRIPTION' Attribute_AttributeName  ,
                   CASE 
                        WHEN E.SrcSysClassName IS NULL THEN ' '
                   ELSE E.SrcSysClassName
                      END Attribute_AttributeV_A31  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_ASSET_CODE_DATE' Attribute_AttributeName  ,
                   CASE 
                        WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                   ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                      END Attribute_AttributeV_A35  ,
                   'ALL' Attribute_Role  ,
                   'ALL' Attribute_ProcessingOrg  ,
                   'ENPA_D2K_NPA_DATE' Attribute_AttributeName  ,
                   CASE 
                        WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                   ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                      END Attribute_AttributeV_A39  
              FROM RBL_MISDB_PROD.InvestmentFinancialDetail A
                     JOIN RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                     AND C.EffectiveFromTimeKey <= v_Timekey
                     AND C.EffectiveToTimeKey >= v_TimeKey
                     JOIN ReversefeedCalypso D   ON D.issuerId = C.IssuerID
                     AND D.EffectiveFromTimeKey <= v_Timekey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_Timekey
                     AND E.EffectiveToTimeKey >= v_TimeKey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND A.FinalAssetClassAlt_Key <> A.InitialAssetAlt_key ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   ELSE

   BEGIN
      utils.raiserror( 0, 'ACL Failed' );

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY" TO "ADF_CDR_RBL_STGDB";
