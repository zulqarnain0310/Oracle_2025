--------------------------------------------------------
--  DDL for Procedure GETIBPCACCOUNTVALIDATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" 
(
  v_CustomerACID IN VARCHAR2
)
AS
   v_Timekey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--,@Flag Int

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))

   BEGIN
      --IF(@Flag=1)
      --BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( 
                  --Select	A.AccountID as CustomerACID

                  --			,A.[CustomerId]

                  --		    ,B.[CustomerName]

                  --			,ACC.SourceAlt_Key

                  --			,ds.SourceName

                  --			,PoolID

                  --			,PoolName

                  --			,POS

                  --			,InterestReceivable

                  --			,(Select top(1) BalanceOutstanding from IBPCPoolSummary S

                  --			where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS

                  --			,'CustIBPCFlaggingDetails'as TableName

                  --from		IBPCACFlaggingDetail A

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
                         PoolID ,
                         PoolName ,
                         POS ,
                         InterestReceivable ,
                         AccountBalance ,
                         ExposureAmount ,
                         ( SELECT BalanceOutstanding 
                           FROM IBPCPoolSummary_Mod S
                            WHERE  S.PoolID = A.PoolId
                                     AND S.EffectiveFromTimeKey <= v_Timekey
                                     AND S.EffectiveToTimeKey >= v_Timekey 
                             FETCH FIRST 1 ROWS ONLY ) BalanceOS  ,
                         'CustIBPCFlaggingDetails' TableName  
                  FROM IBPCACFlaggingDetail_Mod A
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

                  --   union

                  ----If(@Flag=2)

                  ----BEGIN

                  --	--Select * from (

                  --	Select	A.AccountID as CustomerACID

                  --				,A.[CustomerId]

                  --			    ,B.[CustomerName]

                  --				,ACC.SourceAlt_Key

                  --				,ds.SourceName

                  --				,PoolID

                  --				,PoolName

                  --				,POS

                  --				,InterestReceivable

                  --				,(Select top(1) BalanceOutstanding from IBPCPoolSummary S

                  --				where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS

                  --				,'CustIBPCPoolDetails'as TableName

                  --	from		IBPCPoolDetail A

                  --	left join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID

                  --	and			ACC.EffectiveFromTimeKey<=@Timekey

                  --	and			ACC.EffectiveToTimeKey>=@Timekey

                  --	left Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]

                  --	and			B.EffectiveFromTimeKey<=@Timekey

                  --	and			B.EffectiveToTimeKey>=@Timekey	

                  --	Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key

                  --	where		[CustomerACID] = @CustomerACID

                  --	and			A.EffectiveFromTimeKey<=@Timekey

                  --	and			A.EffectiveToTimeKey>=@Timekey

                  --	And IsNull(A.AuthorisationStatus,'A')='A'
                  SELECT ACC.CustomerACID ,
                         A."CustomerId" ,
                         CustomerName ,
                         ACC.SourceAlt_Key ,
                         ds.SourceName ,
                         PoolID ,
                         PoolName ,
                         POS ,
                         InterestReceivable ,
                         POS AccountBalance  ,
                         IBPCExposureAmt ,
                         ( SELECT BalanceOutstanding 
                           FROM IBPCPoolSummary_Mod S
                            WHERE  S.PoolID = A.PoolId
                                     AND S.EffectiveFromTimeKey <= v_Timekey
                                     AND S.EffectiveToTimeKey >= v_Timekey 
                             FETCH FIRST 1 ROWS ONLY ) BalanceOS  ,
                         'CustIBPCPoolDetails' TableName  
                  FROM IBPCPoolDetail_MOD A
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
      --IF(@Flag=3)
      --BEGIN
      OPEN  v_cursor FOR
         SELECT CustomerACID ,
                CustomerId ,
                CustomerName ,
                A.SourceAlt_Key ,
                ds.SourceName ,
                'CustDetails' TableName  
           FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                  JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerEntityId = B.CustomerEntityId
                  JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
          WHERE  CustomerACID = v_CustomerACID
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--END

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETIBPCACCOUNTVALIDATION" TO "ADF_CDR_RBL_STGDB";
