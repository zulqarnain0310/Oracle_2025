--------------------------------------------------------
--  DDL for Procedure TRESHOLD_SHOW_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" 
-- =============================================
 -- Author:		<HAMID>
 -- Create date: <09 MAY 2019>
 -- Description:	<TO GET A  LIST OF SHOW DETAIL DATA>
 -- =============================================

(
  --DECLARE 
  v_Location IN CHAR DEFAULT 'HO' ,
  v_LocationCode IN VARCHAR2 DEFAULT '2' ,
  v_MasterNameAlt_Key IN NUMBER DEFAULT 2 ,
  v_MasterAlt_Key IN NUMBER DEFAULT 90 ,
  v_Timekey IN NUMBER DEFAULT 25292 ,
  v_Result OUT NUMBER,
  v_SQLQuery OUT VARCHAR2
)
AS
   v_SQL VARCHAR2(4000) := ' ';

BEGIN

   v_SQL := 'SELECT	  ABD.BranchCode

   					, CBD.CustomerId
   					, CBD.CustomerName
   					, CBD.ConstitutionAlt_Key
   					, CONS.ConstitutionName
   					, ABD.CustomerACID
   					, ABD.GLAlt_Key
   					,GL.GLName
   					,SUB.SubSector_Key
   					,SUB.SubSectorName
   					,ACT.ActivityAlt_Key
   					,ACT.ActivityName
   					,BAL.Balance

   			FROM CurDat.CustomerBasicDetail CBD

   			INNER JOIN DimConstitution CONS
   				ON CBD.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND CBD.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || 'AND CONS.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND CONS.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || 'AND CBD.ConstitutionAlt_Key = CASE	WHEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,5) || ' = 1 
   														THEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || '
   													ELSE CBD.ConstitutionAlt_Key
   											 END
   					AND CBD.ConstitutionAlt_Key = CONS.ConstitutionAlt_Key


   			LEFT OUTER JOIN CurDat.AdvCustOtherDetail COD
   					ON  COD.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND COD.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   					AND CBD.CustomerEntityId = COD.CustomerEntityId

   			INNER JOIN CurDat.AdvAcBasicDetail ABD
   					ON  ABD.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND ABD.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   					AND CBD.CustomerEntityId = ABD.CustomerEntityId

   				INNER JOIN DimBranch BR
   					ON BR.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND BR.EffectiveToTimeKey>= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' 
   					AND BR.BranchCode =ABD.BranchCode

   					AND  (CASE  WHEN ''' || v_Location || ''' = ''HO'' THEN 1
   								WHEN ''' || v_Location || ''' = ''ZO'' AND BR.BranchZoneAlt_Key		= ''' || v_LocationCode || ''' AND BR.BranchCode = ABD.BranchCode THEN 1
   								WHEN ''' || v_Location || ''' = ''RO'' AND BR.BranchRegionAlt_Key		= ''' || v_LocationCode || ''' AND BR.BranchCode = ABD.BranchCode THEN 1
   								WHEN ''' || v_Location || ''' = ''BO'' AND BR.BranchCode				= ''' || v_LocationCode || ''' AND BR.BranchCode = ABD.BranchCode THEN 1

   								ELSE 0 END
   						  )=1

   			INNER JOIN CurDat.AdvAcBalanceDetail BAL
   					ON BAL.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND BAL.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   					AND ABD.AccountEntityId = BAL.AccountEntityId

   			LEFT OUTER JOIN CurDat.AdvACOtherDetail AOD
   					ON  AOD.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND AOD.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   					AND AOD.AccountEntityId = ABD.AccountEntityId

   			LEFT OUTER JOIN Curdat.AdvAcFinancialDetail AFD
   					ON  AFD.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND AFD.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   					AND AFD.AccountEntityId = ABD.AccountEntityId



   			INNER JOIN DimGL	GL
   				ON GL.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND GL.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   				AND GL.GLAlt_Key = CASE WHEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,5) || ' = 7
   										THEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || '
   										ELSE GL.GLAlt_Key
   									END
   				AND GL.GLAlt_Key = ABD.GLAlt_Key

   			INNER JOIN DimSubSector	 SUB
   				ON SUB.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND SUB.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   				AND SUB.SubSectorAlt_Key= CASE	WHEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,5) || ' = 9
   												THEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || '
   												ELSE SUB.SubSectorAlt_Key
   											END
   				AND SUB.SubSectorAlt_Key = ABD.SubSectorAlt_Key

   			INNER JOIN DimActivity	ACT
   				ON ACT.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND ACT.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   				AND ACT.ActivityAlt_Key= CASE	WHEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,5) || ' = 10
   												THEN ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || '
   												ELSE ACT.ActivityAlt_Key
   											END
   				AND ACT.ActivityAlt_Key = ABD.ActivityAlt_Key' ;
   IF v_MasterNameAlt_Key NOT IN ( 1,7,9,10 )
    THEN
    DECLARE
      v_TableName VARCHAR2(100);
      v_MstTablColAlt_key VARCHAR2(30);
      v_MstTablColName VARCHAR2(30);
      v_FactTableName VARCHAR2(50);
      --FOR ADDING ADDITIONAL COLUMN
      v_SQLBeforeFrom VARCHAR2(4000);
      v_SQLAfterFrom VARCHAR2(4000);
      v_BeforBal VARCHAR2(4000);
      v_AfterBal VARCHAR2(4000);

   BEGIN
      SELECT MasterName ,
             MstTablColAlt_key ,
             MstTablColName ,
             FactTableName 

        INTO v_TableName,
             v_MstTablColAlt_key,
             v_MstTablColName,
             v_FactTableName
        FROM ALERT_RBL_MISDB_PROD.DImMasterName 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey
                AND MasterNameAlt_Key = v_MasterNameAlt_Key;
      v_SQL := v_SQL || CHR(10) || CHR(10) || ' INNER JOIN' || LPAD(' ', 1, ' ') || v_TableName || LPAD(' ', 1, ' ') || CHR(10) || +LPAD(' ', 10, ' ') || ' ON ' || v_TableName || '.EffectiveFromTimeKey <=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND ' || v_TableName || '.EffectiveToTimeKey >=' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || LPAD(' ', 1, ' ') || ' 

      										AND ' || CASE 
                              WHEN v_FactTableName = 'CustomerBasicDetail' THEN 'CBD'
                              WHEN v_FactTableName = 'AdvCustOtherDetail' THEN 'COALESCE(COD'
                              WHEN v_FactTableName = 'AdvACOtherDetail' THEN 'COALESCE(AOD'
                              WHEN v_FactTableName = 'AdvAcBasicDetail' THEN 'ABD'
                              WHEN v_FactTableName = 'AdvAcBalanceDetail' THEN 'BAL'
                              WHEN v_FactTableName = 'AdvAcFinancialDetail' THEN 'AFD'
      ELSE ' '
         END || '.' || CASE 
                            WHEN v_FactTableName IN ( 'AdvCustOtherDetail','AdvACOtherDetail' )
                             THEN 'SplCatg1Alt_Key ,SplCatg2Alt_Key ,SplCatg3Alt_Key ,SplCatg4Alt_Key)'
      ELSE +v_MstTablColAlt_key
         END || LPAD(' ', 1, ' ') || '= ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || '
      											AND ' || CASE 
                               WHEN v_FactTableName = 'CustomerBasicDetail' THEN 'CBD'
                               WHEN v_FactTableName = 'AdvCustOtherDetail' THEN 'COALESCE(COD'
                               WHEN v_FactTableName = 'AdvACOtherDetail' THEN 'COALESCE(AOD'
                               WHEN v_FactTableName = 'AdvAcBasicDetail' THEN 'ABD'
                               WHEN v_FactTableName = 'AdvAcBalanceDetail' THEN 'BAL'
                               WHEN v_FactTableName = 'AdvAcFinancialDetail' THEN 'AFD'
      ELSE ' '
         END || '.' || CASE 
                            WHEN v_FactTableName IN ( 'AdvCustOtherDetail','AdvACOtherDetail' )
                             THEN 'SplCatg1Alt_Key ,SplCatg2Alt_Key ,SplCatg3Alt_Key ,SplCatg4Alt_Key)'
      ELSE +v_MstTablColAlt_key
         END || LPAD(' ', 1, ' ') || +'=' || LPAD(' ', 1, ' ') || v_TableName || '.' || v_MstTablColAlt_key ;
      --SELECT CHARINDEX('FROM CURDAT.',@SQL)
      v_SQLBeforeFrom := SUBSTR(v_SQL, 1, INSTR(v_SQL, 'FROM CURDAT.') - 1) ;
      v_SQLAfterFrom := SUBSTR(v_SQL, INSTR(v_SQL, 'FROM CURDAT.'), LENGTH(v_SQL)) ;
      --FOR ADDING A MASTER COLUMN ALTKEY AND COLUMN NAME
      v_SQL := NVL(v_SQLBeforeFrom, ' ') || LPAD(' ', 1, ' ') || NVL(v_SQLAfterFrom, ' ') ;
      v_BeforBal := SUBSTR(v_SQL, 1, INSTR(v_SQL, ',BAL.Balance') - 1) ;
      v_AfterBal := SUBSTR(v_SQL, INSTR(v_SQL, ',BAL.Balance'), LENGTH(v_SQL)) ;
      --SELECT @BeforBal,@AfterBal
      v_SQL := NVL(v_BeforBal, ' ') || LPAD(' ', 1, ' ') || ',' || v_TableName || '.' || v_MstTablColAlt_key || +CHR(10) || LPAD(' ', 1, ' ') || ',' || LPAD(' ', 1, ' ') || v_MstTablColName || LPAD(' ', 1, ' ') || v_AfterBal ;

   END;
   END IF;
   --SELECT @SQL
   DBMS_OUTPUT.PUT_LINE(v_SQL);
   --SELECT LEN(@SQL)-LEN(REPLACE(@SQL, ',',''))
   --EXEC(@SQL)
   v_SQLQuery := v_Sql ;
   v_Result := 1 ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_SHOW_SELECT" TO "ADF_CDR_RBL_STGDB";
