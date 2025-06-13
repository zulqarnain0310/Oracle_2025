--------------------------------------------------------
--  DDL for Procedure ADVSECURITYDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" 
AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   /*  New Customers EntityKey ID Update  */
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.tempadvsecuritydetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.tempadvsecuritydetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvSecurityDetail B
                        WHERE  B.EffectiveToTimeKey = 49999

                                 ---And B.AccountEntityId=A.AccountEntityId 
                                 AND CASE 
                                          WHEN b.SecurityType = 'P' THEN B.AccountEntityId
                               ELSE B.CustomerEntityId
                                  END = CASE 
                                             WHEN A.SecurityType = 'P' THEN A.AccountEntityId
                               ELSE A.CustomerEntityId
                                  END
                                 AND A.SecurityEntityID = B.SecurityEntityID )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   MERGE INTO RBL_MISDB_PROD.AdvSecurityDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvSecurityDetail O
          JOIN RBL_TEMPDB.tempadvsecuritydetail T   ON 
        --ON O.AccountEntityID=T.AccountEntityID
        CASE 
             WHEN o.SecurityType = 'P' THEN o.AccountEntityId
        ELSE o.CustomerEntityId
           END = CASE 
                      WHEN t.SecurityType = 'P' THEN t.AccountEntityId
        ELSE t.CustomerEntityId
           END
          AND O.SecurityEntityID = T.SecurityEntityID
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(o.CustomerEntityId, 0) <> NVL(T.CustomerEntityId, 0)
     OR NVL(o.SecurityType, 0) <> NVL(T.SecurityType, 0)
     OR NVL(o.CollateralType, 0) <> NVL(T.CollateralType, 0)
     OR NVL(o.SecurityAlt_Key, 0) <> NVL(T.SecurityAlt_Key, 0)
     OR NVL(o.Security_RefNo, 0) <> NVL(T.Security_RefNo, 0)
     OR NVL(o.SecurityNature, 0) <> NVL(T.SecurityNature, 0)
     OR NVL(o.SecurityChargeTypeAlt_Key, 0) <> NVL(T.SecurityChargeTypeAlt_Key, 0)
     OR NVL(o.CurrencyAlt_Key, 0) <> NVL(T.CurrencyAlt_Key, 0)
     OR NVL(o.EntryType, 0) <> NVL(T.EntryType, 0)
     OR NVL(o.ScrCrError, 0) <> NVL(T.ScrCrError, 0)
     OR NVL(o.InwardNo, 0) <> NVL(T.InwardNo, 0)
     OR NVL(o.Limitnode_Flag, 0) <> NVL(T.Limitnode_Flag, 0)
     OR NVL(o.RefCustomerId, 0) <> NVL(T.RefCustomerId, 0)
     OR NVL(o.RefSystemAcId, 0) <> NVL(T.RefSystemAcId, 0)
     OR NVL(o.SecurityParticular, 0) <> NVL(T.SecurityParticular, 0)
     OR NVL(o.OwnerTypeAlt_Key, 0) <> NVL(T.OwnerTypeAlt_Key, 0)
     OR NVL(o.AssetOwnerName, 0) <> NVL(T.AssetOwnerName, 0)
     OR NVL(o.ValueAtSanctionTime, 0) <> NVL(T.ValueAtSanctionTime, 0)
     OR NVL(o.BranchLastInspecDate, '1990-01-01') <> NVL(T.BranchLastInspecDate, '1990-01-01')
     OR NVL(o.SatisfactionNo, 0) <> NVL(T.SatisfactionNo, 0)
     OR NVL(o.SatisfactionDate, '1990-01-01') <> NVL(T.SatisfactionDate, '1990-01-01')
     OR NVL(o.BankShare, 0) <> NVL(T.BankShare, 0)
     OR NVL(o.ActionTakenRemark, 0) <> NVL(T.ActionTakenRemark, 0)
     OR NVL(o.SecCharge, 0) <> NVL(T.SecCharge, 0)
     OR NVL(o.Sec_Perf_Flg, 0) <> NVL(T.Sec_Perf_Flg, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.tempadvsecuritydetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.tempadvsecuritydetail A
          JOIN RBL_MISDB_PROD.AdvSecurityDetail B   ON CASE 
                                             WHEN b.SecurityType = 'P' THEN B.AccountEntityId
        ELSE B.CustomerEntityId
           END = CASE 
                      WHEN A.SecurityType = 'P' THEN A.AccountEntityId
        ELSE A.CustomerEntityId
           END
          AND A.SecurityEntityID = B.SecurityEntityID 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   ---------Expire the records
   --UPDATE AA
   --SET 
   -- EffectiveToTimeKey = @vEffectiveto,
   -- DateModified=CONVERT(DATE,GETDATE(),103),
   -- ModifiedBy='SSISUSER' 
   --FROM AdvSecurityDetail AA
   --INNER JOIN [RBL_Tempdb].dbo.TempAdvAcBasicDetail BB  
   ----ON AA.AccountEntityId = BB.ACCOUNTENTITYID
   --ON CASE WHEN AA.SecurityType='P' THEN  BB.AccountEntityId ELSE BB.CustomerEntityId END=CASE WHEN AA.SecurityType='P' THEN AA.AccountEntityId ELSE AA.CustomerEntityId END
   --WHERE AA.EffectiveToTimeKey = 49999 and BB.SourceAlt_Key IN( 1,4
   --)AND NOT EXISTS (SELECT 1 FROM RBL_TEMPDB.DBO.TempAdvSecurityDetail BB
   --    WHERE  CASE WHEN AA.SecurityType='P' THEN  BB.AccountEntityId ELSE BB.CustomerEntityId END=CASE WHEN AA.SecurityType='P' THEN AA.AccountEntityId ELSE AA.CustomerEntityId END
   --	And AA.SecurityEntityID=BB.SecurityEntityID
   --					AND AA.COLLATERALID=BB.COLLATERALID
   --    AND BB.EffectiveToTimeKey =49999
   --    )  
   -------Expire the records---change by Prashant-------01122023----optimization-------------------------------
   MERGE INTO RBL_MISDB_PROD.AdvSecurityDetail AA
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvSecurityDetail AA
        --INNER JOIN [RBL_Tempdb].dbo.TempAdvAcBasicDetail BB  

          LEFT JOIN RBL_TEMPDB.TempAdvAcBasicDetail BB --------Added By Prashant----28112024-----------
         --ON AA.AccountEntityId = BB.ACCOUNTENTITYID
           ON BB.AccountEntityId = AA.AccountEntityId
          AND BB.SourceAlt_Key IN ( 1,4 --------Added By Prashant----28112024-----------
         )

    WHERE AA.EffectiveToTimeKey = 49999
     AND AA.SecurityType = 'P'

     --and BB.SourceAlt_Key IN( 1,4)
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.tempadvsecuritydetail BB
                       WHERE  BB.AccountEntityId = AA.AccountEntityId
                                AND AA.SecurityEntityID = BB.SecurityEntityID
                                AND AA.SecurityType = 'P'
                                AND AA.COLLATERALID = BB.COLLATERALID
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   MERGE INTO RBL_MISDB_PROD.AdvSecurityDetail AA
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvSecurityDetail AA
        --INNER JOIN [RBL_Tempdb].dbo.TempAdvAcBasicDetail BB  

          LEFT JOIN RBL_TEMPDB.TempAdvAcBasicDetail BB --------Added By Prashant----28112024-----------
         --ON AA.AccountEntityId = BB.ACCOUNTENTITYID
           ON BB.CustomerEntityId = AA.CustomerEntityId
          AND BB.SourceAlt_Key IN ( 1,4 --------Added By Prashant----28112024-----------
         )

    WHERE AA.EffectiveToTimeKey = 49999
     AND AA.SecurityType <> 'P'

     --and BB.SourceAlt_Key IN( 1,4)
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.tempadvsecuritydetail BB
                       WHERE  BB.CustomerEntityId = AA.CustomerEntityId
                                AND AA.SecurityEntityID = BB.SecurityEntityID
                                AND AA.SecurityType <> 'P'
                                AND AA.COLLATERALID = BB.COLLATERALID
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvSecurityDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.tempadvsecuritydetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.tempadvsecuritydetail TEMP
          JOIN ( SELECT "TEMPADVSECURITYDETAIL".CustomerEntityId ,
                        "TEMPADVSECURITYDETAIL".AccountEntityId ,
                        "TEMPADVSECURITYDETAIL".COLLATERALID ,
                        "TEMPADVSECURITYDETAIL".SecurityEntityID ,
                        "TEMPADVSECURITYDETAIL".SecurityType ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.tempadvsecuritydetail 
                  WHERE  "TEMPADVSECURITYDETAIL".EntityKey = 0
                           OR "TEMPADVSECURITYDETAIL".EntityKey IS NULL ) ACCT   ON CASE 
                                                                                         WHEN TEMP.SecurityType = 'P' THEN TEMP.AccountEntityId
        ELSE TEMP.CustomerEntityId
           END = CASE 
                      WHEN ACCT.SecurityType = 'P' THEN ACCT.AccountEntityId
        ELSE ACCT.CustomerEntityId
           END
          AND TEMP.COLLATERALID = ACCT.COLLATERALID
          AND TEMP.SecurityEntityID = ACCT.SecurityEntityID 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   ------------------------------
   INSERT INTO RBL_MISDB_PROD.AdvSecurityDetail
     ( ENTITYKEY, AccountEntityId, CustomerEntityId, SecurityType, CollateralType, SecurityAlt_Key, SecurityEntityID, Security_RefNo, SecurityNature, SecurityChargeTypeAlt_Key, CurrencyAlt_Key, EntryType, ScrCrError, InwardNo, Limitnode_Flag, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocTypeAlt_Key, MocStatus, MocDate, SecurityParticular, OwnerTypeAlt_Key, AssetOwnerName, ValueAtSanctionTime, BranchLastInspecDate, SatisfactionNo, SatisfactionDate, BankShare, ActionTakenRemark, SecCharge, CollateralID, UCICID, CustomerName, TaggingAlt_Key, DistributionAlt_Key, CollateralCode, CollateralSubTypeAlt_Key, CollateralOwnerShipTypeAlt_Key, ChargeNatureAlt_Key, ShareAvailabletoBankAlt_Key, CollateralShareamount, IfPercentagevalue_or_Absolutevalue, CollateralValueatSanctioninRs, CollateralValueasonNPAdateinRs, ApprovedByFirstLevel, DateApprovedFirstLevel, ChangeField, Sec_Perf_Flg )
     ( SELECT ENTITYKEY ,
              AccountEntityId ,
              CustomerEntityId ,
              SecurityType ,
              CollateralType ,
              SecurityAlt_Key ,
              SecurityEntityID ,
              Security_RefNo ,
              SecurityNature ,
              SecurityChargeTypeAlt_Key ,
              CurrencyAlt_Key ,
              EntryType ,
              ScrCrError ,
              InwardNo ,
              Limitnode_Flag ,
              RefCustomerId ,
              RefSystemAcId ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              SYSDATE D2Ktimestamp  ,
              MocTypeAlt_Key ,
              MocStatus ,
              MocDate ,
              SecurityParticular ,
              OwnerTypeAlt_Key ,
              AssetOwnerName ,
              ValueAtSanctionTime ,
              BranchLastInspecDate ,
              SatisfactionNo ,
              SatisfactionDate ,
              BankShare ,
              ActionTakenRemark ,
              SecCharge ,
              CollateralID ,
              UCICID ,
              CustomerName ,
              TaggingAlt_Key ,
              DistributionAlt_Key ,
              CollateralCode ,
              CollateralSubTypeAlt_Key ,
              CollateralOwnerShipTypeAlt_Key ,
              ChargeNatureAlt_Key ,
              ShareAvailabletoBankAlt_Key ,
              CollateralShareamount ,
              IfPercentagevalue_or_Absolutevalue ,
              CollateralValueatSanctioninRs ,
              CollateralValueasonNPAdateinRs ,
              ApprovedByFirstLevel ,
              DateApprovedFirstLevel ,
              ChangeField ,
              Sec_Perf_Flg 
       FROM RBL_TEMPDB.tempadvsecuritydetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
