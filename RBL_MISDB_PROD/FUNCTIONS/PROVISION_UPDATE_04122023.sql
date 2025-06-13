--------------------------------------------------------
--  DDL for Function PROVISION_UPDATE_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" 
-- =============================================
 -- Author:		<Author Triloki Kuamr>
 -- Create date: <Create Date 03/04/2020>
 -- Description:	<Description,,>
 -- =============================================

(
  v_ProvisionAlt_Key IN NUMBER,
  v_Expression IN VARCHAR2 DEFAULT ' ' ,
  v_FinalExpression IN VARCHAR2 DEFAULT ' ' ,
  --,@D2kTimestamp				INT	OUTPUT
  v_Result OUT NUMBER,
  v_UserId IN VARCHAR2,
  v_OperationFlag IN NUMBER
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0);
   v_EffectiveFromTimeKey NUMBER(10,0);
   v_EffectiveToTimeKey NUMBER(10,0);

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         IF ( v_OperationFlag = 1 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT EXISTS ( SELECT 1 
                                   FROM DimProvision_SegStd_Mod 
                                    WHERE  BankCategoryID = v_ProvisionAlt_Key
                                             AND AuthorisationStatus IN ( 'NP','MP' )
             );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               INSERT INTO DimProvision_SegStd_Mod
                 ( Provision_Key, ProvisionAlt_Key, Segment, ProvisionRule, SecurityApplicable, ProductAlt_Key, BankCategoryID, ProvisionName, CategoryTypeAlt_Key, ProvisionShortNameEnum, ProvisionSecured, ProvisionUnSecured, LowerDPD, UpperDPD, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, DB1_PROV, DB2_PROV, ProvProductCat, RBIProvisionSecured, RBIProvisionUnSecured, EffectiveFromDate, AdditionalBanksProvision, AdditionalprovisionRBINORMS, BusinessRuleAlt_Key, Expression, SystemFinalExpression, UserFinalExpression )
                 ( SELECT Provision_Key ,
                          ProvisionAlt_Key ,
                          Segment ,
                          ProvisionRule ,
                          SecurityApplicable ,
                          ProductAlt_Key ,
                          BankCategoryID ,
                          ProvisionName ,
                          CategoryTypeAlt_Key ,
                          ProvisionShortNameEnum ,
                          ProvisionSecured ,
                          ProvisionUnSecured ,
                          LowerDPD ,
                          UpperDPD ,
                          'MP' ,
                          v_Timekey EffectiveFromTimeKey  ,
                          49999 EffectiveToTimeKey  ,
                          v_UserId CreatedBy  ,
                          SYSDATE ,
                          --DateCreated
                          NULL ModifiedBy  ,
                          NULL DateModified  ,
                          NULL ApprovedBy  ,
                          NULL DateApproved  ,
                          DB1_PROV ,
                          DB2_PROV ,
                          ProvProductCat ,
                          RBIProvisionSecured ,
                          RBIProvisionUnSecured ,
                          EffectiveFromDate ,
                          AdditionalBanksProvision ,
                          AdditionalprovisionRBINORMS ,
                          BusinessRuleAlt_Key ,
                          v_Expression Expression  ,
                          v_FinalExpression SystemFinalExpression  ,
                          UserFinalExpression 
                   FROM DimProvision_SegStd 
                    WHERE  EffectiveFromTimeKey <= v_Timekey
                             AND EffectiveToTimeKey >= v_TimeKey
                             AND BankCategoryID = v_ProvisionAlt_Key );
               UPDATE DimProvision_SegStd
                  SET AuthorisationStatus = 'MP'
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_TimeKey
                 AND BankCategoryID = v_ProvisionAlt_Key;

            END;
            ELSE

            BEGIN
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_Expression, v_FinalExpression
               FROM A ,DimProvision_SegStd_Mod A 
                WHERE A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND A.BankCategoryID = v_ProvisionAlt_Key

                 --AND B.AuthorisationStatus='NP'
                 AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                      FROM DimProvision_SegStd_Mod 
                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey
                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','A','RM' )

                                        GROUP BY BankCategoryID )
               ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.Expression = v_Expression,
                                            A.SystemFinalExpression = v_FinalExpression;

            END;
            END IF;

         END;
         END IF;
         IF ( v_OperationFlag = 16 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            --IF EXISTS (SELECT 1 FROM DimProvision_SegStd WHERE EffectiveToTimeKey=49999 and BankCategoryID=@ProvisionAlt_Key)
            --					BEGIN
            --						Update DimProvision_SegStd Set EffectiveToTimeKey=@TimeKey-1
            --														,ModifiedBy				=@UserId
            --														,DateModified			=GETDATE()
            --								WHERE EffectiveToTimeKey=49999 and BankCategoryID=@ProvisionAlt_Key
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM DimProvision_SegStd 
                                WHERE  BankCategoryID = v_ProvisionAlt_Key
                                         AND AuthorisationStatus IN ( 'NP','MP','A' )
             );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               UPDATE DimProvision_SegStd
                  SET EffectiveToTimeKey = v_TimeKey - 1,
                      ModifiedBy = v_UserId,
                      DateModified = SYSDATE,
                      AuthorisationStatus = 'A'
                WHERE  EffectiveToTimeKey = 49999
                 AND BankCategoryID = v_ProvisionAlt_Key;
               INSERT INTO DimProvision_SegStd
                 ( Provision_Key, ProvisionAlt_Key, Segment, ProvisionRule, SecurityApplicable, ProductAlt_Key, BankCategoryID, ProvisionName, CategoryTypeAlt_Key, ProvisionShortNameEnum, ProvisionSecured, ProvisionUnSecured, LowerDPD, UpperDPD, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, DB1_PROV, DB2_PROV, ProvProductCat, RBIProvisionSecured, RBIProvisionUnSecured, EffectiveFromDate, AdditionalBanksProvision, AdditionalprovisionRBINORMS, BusinessRuleAlt_Key, Expression, SystemFinalExpression, UserFinalExpression )
                 ( SELECT Provision_Key ,
                          ProvisionAlt_Key ,
                          Segment ,
                          ProvisionRule ,
                          SecurityApplicable ,
                          ProductAlt_Key ,
                          BankCategoryID ,
                          ProvisionName ,
                          CategoryTypeAlt_Key ,
                          ProvisionShortNameEnum ,
                          ProvisionSecured ,
                          ProvisionUnSecured ,
                          LowerDPD ,
                          UpperDPD ,
                          'A' AuthorisationStatus  ,
                          v_TimeKey EffectiveFromTimeKey  ,
                          49999 EffectiveToTimeKey  ,
                          v_UserId CreatedBy  ,
                          SYSDATE DateCreated  ,
                          NULL ModifiedBy  ,
                          NULL DateModified  ,
                          NULL ApprovedBy  ,
                          NULL DateApproved  ,
                          DB1_PROV ,
                          DB2_PROV ,
                          ProvProductCat ,
                          RBIProvisionSecured ,
                          RBIProvisionUnSecured ,
                          EffectiveFromDate ,
                          AdditionalBanksProvision ,
                          AdditionalprovisionRBINORMS ,
                          BusinessRuleAlt_Key ,
                          Expression ,
                          SystemFinalExpression ,
                          UserFinalExpression 
                   FROM DimProvision_SegStd_Mod 
                    WHERE  EffectiveFromTimeKey <= v_Timekey
                             AND EffectiveToTimeKey >= v_TimeKey
                             AND BankCategoryID = v_ProvisionAlt_Key
                             AND AuthorisationStatus IN ( 'MP','NP' )
                  );
               UPDATE DimProvision_SegStd_Mod
                  SET AuthorisationStatus = 'A'
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_TimeKey
                 AND BankCategoryID = v_ProvisionAlt_Key
                 AND AuthorisationStatus IN ( 'MP','NP' )
               ;

            END;
            END IF;

         END;
         END IF;
         utils.commit_transaction;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --ELSE
      --BEGIN
      --					--Select * 
      --					Update A set A.Expression=B.Expression,A.SystemFinalExpression=B.SystemFinalExpression
      --					from DimProvision_SegStd A
      --					Inner JOIN DimProvision_SegStd_Mod B ON A.BankCategoryID=B.BankCategoryID
      --					AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@TimeKey
      --					Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@TimeKey
      --					And A.BankCategoryID=@ProvisionAlt_Key 
      --					--AND B.AuthorisationStatus='NP'
      --					AND A.EntityKey IN
      --                     (
      --                         SELECT MAX(EntityKey)
      --                         FROM DimProvision_SegStd_Mod
      --                         WHERE EffectiveFromTimeKey <= @TimeKey
      --                               AND EffectiveToTimeKey >= @TimeKey
      --                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP','A' ,'RM')
      --                         GROUP BY BankCategoryID
      --                     )
      --								--------------------
      --								--Update DimProvision_SegStd_Mod Set AuthorisationStatus='A'
      --								--WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey and BankCategoryID=@ProvisionAlt_Key
      --								--AND AuthorisationStatus='NP'
      --						--END 
      --		END
      v_Result := -1 ;
      RETURN v_Result;
      ROLLBACK;
      utils.resetTrancount;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISION_UPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
