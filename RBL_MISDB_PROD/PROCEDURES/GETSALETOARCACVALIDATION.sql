--------------------------------------------------------
--  DDL for Procedure GETSALETOARCACVALIDATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" 
(
  v_CustomerACID IN VARCHAR2
)
AS
   v_Timekey NUMBER(10,0);
   --IF(@Flag=1)
   --BEGIN
   v_cursor SYS_REFCURSOR;
--,@Flag Int

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( 
                  --(Select	A.AccountID as CustomerACID

                  --			,A.[CustomerId]

                  --		    ,B.[CustomerName]

                  --			,ACC.SourceAlt_Key

                  --			,ds.SourceName

                  --			,' ' AS PoolID

                  --			,' ' AS PoolName

                  --			,POS

                  --			,InterestReceivable

                  --			,(Select top(1) BalanceOutstanding from SaletoARC S

                  --			where S.CustomerID=A.CustomerID and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS

                  --			,ExposureAmount

                  --			,'CustSaletoARCFlaggingDetails'as TableName

                  --from		SaletoARCACFlaggingDetail A

                  --left join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID

                  --and			ACC.EffectiveFromTimeKey<=@Timekey

                  --and			ACC.EffectiveToTimeKey>=@Timekey

                  --left Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]

                  --and			B.EffectiveFromTimeKey<=@Timekey

                  --and			B.EffectiveToTimeKey>=@Timekey	

                  --Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key

                  --where		[CustomerACID] = @CustomerACID

                  --and			A.EffectiveFromTimeKey<=@Timekey

                  --and			A.EffectiveToTimeKey>=@Timekey

                  --And IsNull(A.AuthorisationStatus,'A')='A'

                  --UNION
                  SELECT ACC.CustomerACID ,
                         A."CustomerId" ,
                         B.CustomerName ,
                         ACC.SourceAlt_Key ,
                         ds.SourceName ,
                         ' ' PoolID  ,
                         ' ' PoolName  ,
                         POS ,
                         InterestReceivable ,
                         ( SELECT BalanceOutstanding 
                           FROM SaletoARC_Mod S
                            WHERE  S.CustomerID = A.CustomerID
                                     AND S.EffectiveFromTimeKey <= v_Timekey
                                     AND S.EffectiveToTimeKey >= v_Timekey 
                             FETCH FIRST 1 ROWS ONLY ) BalanceOS  ,
                         ExposureAmount ,
                         'CustSaletoARCFlaggingDetails' TableName  
                  FROM SaletoARCACFlaggingDetail_Mod A
                         JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ACC   ON ACC.CustomerACID = A.AccountID
                         AND ACC.EffectiveFromTimeKey <= v_Timekey
                         AND ACC.EffectiveToTimeKey >= v_Timekey
                         JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON ACC.CustomerEntityId = B.CustomerEntityId
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                         JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = ACC.SourceAlt_Key
                   WHERE  CustomerACID = v_CustomerACID
                            AND A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' --)dt
                           )

                  UNION 

                  --END

                  --If(@Flag=2)

                  --BEGIN

                  --Select * from (

                  --Select	A.AccountID as CustomerACID

                  --			,A.[CustomerId]

                  --		    ,B.[CustomerName]

                  --			,ACC.SourceAlt_Key

                  --			,ds.SourceName

                  --			,PoolID

                  --			,PoolName

                  --			,POS

                  --			,InterestReceivable

                  --			,BalanceOutstanding

                  --			,0 AS ExposureAmount

                  --			--,(Select top(1) BalanceOutstanding from IBPCPoolSummary S

                  --			--where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS

                  --			,'CustSaletoARCDetails'as TableName

                  --from		SaletoARC A

                  --left join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID

                  --and			ACC.EffectiveFromTimeKey<=@Timekey

                  --and			ACC.EffectiveToTimeKey>=@Timekey

                  --left Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]

                  --and			B.EffectiveFromTimeKey<=@Timekey

                  --and			B.EffectiveToTimeKey>=@Timekey	

                  --Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key

                  --where		[CustomerACID] = @CustomerACID

                  --and			A.EffectiveFromTimeKey<=@Timekey

                  --and			A.EffectiveToTimeKey>=@Timekey

                  --And IsNull(A.AuthorisationStatus,'A')='A'

                  --UNION
                  SELECT ACC.CustomerACID ,
                         A."CustomerId" ,
                         A."CustomerName" ,
                         ACC.SourceAlt_Key ,
                         ds.SourceName ,
                         PoolID ,
                         PoolName ,
                         POS ,
                         InterestReceivable ,
                         BalanceOutstanding ,
                         0 ExposureAmount  ,
                         --,(Select top(1) BalanceOutstanding from IBPCPoolSummary_Mod S
                         --where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS
                         'CustSaletoARCDetails' TableName  
                  FROM SaletoARC_Mod A
                         JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ACC   ON ACC.CustomerACID = A.AccountID
                         AND ACC.EffectiveFromTimeKey <= v_Timekey
                         AND ACC.EffectiveToTimeKey >= v_Timekey
                         JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON ACC.CustomerEntityId = B.CustomerEntityId
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                         JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = ACC.SourceAlt_Key
                   WHERE  CustomerACID = v_CustomerACID
                            AND A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
                 ) dt ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --END
      -- UNION
      --IF(@Flag=3)
      --BEGIN
      OPEN  v_cursor FOR
         SELECT CustomerACID ,
                CustomerId ,
                CustomerName ,
                A.SourceAlt_Key ,
                ds.SourceName ,
                ' ' PoolID  ,
                ' ' PoolName  ,
                0 ,
                0 ,
                0 ,
                0 ,
                'CustDetails' TableName  
           FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                  JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerEntityId = B.CustomerEntityId
                  JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
          WHERE  CustomerACID = v_CustomerACID
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--)dt
      --END
      OPEN  v_cursor FOR
         SELECT A.AccountID CustomerACID  ,
                A."CustomerId" ,
                B.CustomerName ,
                ACC.SourceAlt_Key ,
                ds.SourceName ,
                ' ' PoolID  ,
                ' ' PoolName  ,
                POS ,
                InterestReceivable ,
                ( SELECT BalanceOutstanding 
                  FROM SaletoARC S
                   WHERE  S.CustomerID = A.CustomerID
                            AND S.EffectiveFromTimeKey <= v_Timekey
                            AND S.EffectiveToTimeKey >= v_Timekey 
                    FETCH FIRST 1 ROWS ONLY ) BalanceOS  ,
                ExposureAmount ,
                A.AccountBalance ,
                'CustSaletoARCFinalACFlagging' TableName  
           FROM SaletoARCFinalACFlagging A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ACC   ON ACC.CustomerACID = A.AccountID
                  AND ACC.EffectiveFromTimeKey <= v_Timekey
                  AND ACC.EffectiveToTimeKey >= v_Timekey
                  LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON ACC.CustomerEntityId = B.CustomerEntityId
                  AND B.EffectiveFromTimeKey <= v_Timekey
                  AND B.EffectiveToTimeKey >= v_Timekey
                  JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = ACC.SourceAlt_Key
          WHERE  CustomerACID = v_CustomerACID
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') = 'A' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSALETOARCACVALIDATION" TO "ADF_CDR_RBL_STGDB";
