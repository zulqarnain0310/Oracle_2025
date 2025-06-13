--------------------------------------------------------
--  DDL for Procedure CUSTOMERLEVELNPAMOCSEARCHLIST_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" 
---- exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2
 ----go
 --sp_helptext CustomerLevelNPAMOCSearchList
 -------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2
 --go
 --SELECT Top 100 * FROM [PRO].[CustomerCal_Hist]	where RefCustomerID ='95'
 --And EffectiveFromTimeKey=25992 AND EffectiveToTimeKey=25992
 --Exec [CustomerLevelNPAMOCfH.MOCSourceAltKeySearchList] @OperationFlag =, @CustomerID='161760505'		--Main screen select
 --MOCSource
 --MOCSourceAltKey
 --exec CustomerLevelNPAMOCSearchList_Backup_14052021_1 @CustomerID=N'90',@OperationFlag=2

(
  --Declare
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_CustomerID IN VARCHAR2 DEFAULT '84' ,
  iv_TimeKey IN NUMBER DEFAULT 25841 ,
  iv_SourceSystem IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_SourceSystem VARCHAR2(20) := iv_SourceSystem;
   --Select @Timekey
   v_MOCType VARCHAR2(50);
   v_MocTypeAlt_Key NUMBER(10,0);
   v_MOCSourceAltkey NUMBER(10,0);
   v_CreatedBy VARCHAR2(50);
   v_DateCreated VARCHAR2(200);
   v_ModifiedBy VARCHAR2(50);
   v_DateModified VARCHAR2(200);
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved VARCHAR2(200);
   v_AuthorisationStatus VARCHAR2(5);
   v_MocReason VARCHAR2(50);
   --Declare @SourceSystem Varchar(50)
   v_ApprovedByFirstLevel VARCHAR2(100);
   v_DateApprovedFirstLevel VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   SELECT SourceName 

     INTO v_SourceSystem
     FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
            JOIN DIMSOURCEDB B   ON A.SourceAlt_key = B.SourceAlt_Key
    WHERE  RefCustomerId = v_CustomerID;
   IF v_OperationFlag NOT IN ( 16,20 )
    THEN

   BEGIN
      SELECT MocReason ,
             MOCType ,
             MocTypeAlt_Key ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_MocReason,
             v_MOCType,
             v_MocTypeAlt_Key,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey = v_Timekey
                AND EffectiveToTimeKey = v_Timekey
                AND Entity_key IN ( SELECT MAX(Entity_key)  
                                    FROM CustomerLevelMOC_Mod 
                                     WHERE  AuthorisationStatus IN ( 'MP','1A','A' )

                                              AND CUSTOMERID = v_CustomerID
                                              AND EffectiveFromTimeKey = v_Timekey
                                              AND EffectiveToTimeKey = v_Timekey )
      ;

   END;
   END IF;
   IF v_OperationFlag = '16' THEN

   BEGIN
      SELECT MocReason ,
             MOCType ,
             MocTypeAlt_Key ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_MocReason,
             v_MOCType,
             v_MocTypeAlt_Key,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( 'MP' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey = v_Timekey
                AND EffectiveToTimeKey = v_Timekey
                AND SCREENFLAG <> ('U');

   END;
   END IF;
   IF v_OperationFlag = '20' THEN

   BEGIN
      SELECT MocReason ,
             MOCType ,
             MocTypeAlt_Key ,
             MOCSourceAltkey ,
             CreatedBy ,
             DateCreated ,
             ModifiedBy ,
             DateModified ,
             ApprovedBy ,
             DateApproved ,
             AuthorisationStatus ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_MocReason,
             v_MOCType,
             v_MocTypeAlt_Key,
             v_MOCSourceAltkey,
             v_CreatedBy,
             v_DateCreated,
             v_ModifiedBy,
             v_DateModified,
             v_ApprovedBy,
             v_DateApproved,
             v_AuthorisationStatus,
             v_ApprovedByFirstLevel,
             v_DateApprovedFirstLevel
        FROM CustomerLevelMOC_Mod 
       WHERE  AuthorisationStatus IN ( '1A' )

                AND CUSTOMERID = v_CustomerID
                AND EffectiveFromTimeKey = v_Timekey
                AND EffectiveToTimeKey = v_Timekey
                AND SCREENFLAG <> ('U');

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
   DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
   BEGIN
      DECLARE
         v_DateOfData DATE;
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

           INTO v_DateOfData
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CUST_PREMOC_7  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_CUST_PREMOC_7;
         UTILS.IDENTITY_RESET('tt_CUST_PREMOC_7');

         INSERT INTO tt_CUST_PREMOC_7 ( 
         	SELECT * 
         	  FROM ( SELECT CustomerEntityId ,
                          RefCustomerID CustomerID  ,
                          CustomerName ,
                          SysAssetClassAlt_Key AssetClassAlt_Key  ,
                          SysNPA_Dt NPADate  ,
                          AddlProvisionPer AdditionalProvision  ,
                          CurntQtrRv SecurityValue  ,
                          UCIF_ID UCICID  ,
                          ScreenFlag ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_MOCType MOCType  ,
                          v_MocReason MocReason  ,
                          v_MocTypeAlt_Key MocTypeAlt_Key  ,
                          v_MOCSourceAltkey MOCSourceAltkey  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  ,
                          v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                          v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                          v_SourceSystem SourceSystem  
                   FROM PreMoc_RBL_MISDB_PROD.CUSTOMERCAL 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey
                             AND RefCustomerID = v_CustomerID
                   UNION 
                   SELECT CustomerEntityId ,
                          RefCustomerID CustomerID  ,
                          CustomerName ,
                          SysAssetClassAlt_Key AssetClassAlt_Key  ,
                          SysNPA_Dt NPADate  ,
                          AddlProvisionPer AdditionalProvision  ,
                          CurntQtrRv SecurityValue  ,
                          UCIF_ID UCICID  ,
                          ScreenFlag ,
                          v_AuthorisationStatus AuthorisationStatus  ,
                          v_MOCType MOCType  ,
                          v_MocReason MocReason  ,
                          v_MocTypeAlt_Key MocTypeAlt_Key  ,
                          v_MOCSourceAltkey MOCSourceAltkey  ,
                          v_CreatedBy CreatedBy  ,
                          v_DateCreated DateCreated  ,
                          v_ModifiedBy ModifiedBy  ,
                          v_DateModified DateModified  ,
                          v_ApprovedBy ApprovedBy  ,
                          v_DateApproved DateApproved  ,
                          v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                          v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                          v_SourceSystem SourceSystem  
                   FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
                    WHERE  EffectiveFromTimeKey = v_TimeKey
                             AND EffectiveToTimeKey = v_TimeKey
                             AND NVL(FlgMoc, 'N') = 'N'
                             AND RefCustomerID = v_CustomerID ) X );
         ----POST 
         --Select 'tt_CUST_PREMOC_7',* from tt_CUST_PREMOC_7
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CUST_POSTMOC_7  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_CUST_POSTMOC_7;
         UTILS.IDENTITY_RESET('tt_CUST_POSTMOC_7');

         INSERT INTO tt_CUST_POSTMOC_7 ( 
         	SELECT CustomerEntityId ,
                 CustomerID ,
                 CustomerName ,
                 AssetClassAlt_Key ,
                 NPADate ,
                 AdditionalProvision ,
                 SecurityValue ,
                 UTILS.CONVERT_TO_VARCHAR2('',50) UCICID  ,
                 ScreenFlag ,
                 'a' AuthorisationStatus  ,
                 'a' MOCType  ,
                 'a' MocReason  ,
                 0 MocTypeAlt_Key  ,
                 0 MOCSourceAltkey  ,
                 'a' CreatedBy  ,
                 'a' DateCreated  ,
                 'a' ModifiedBy  ,
                 'a' DateModified  ,
                 'a' ApprovedBy  ,
                 'a' DateApproved  ,
                 'a' ApprovedByFirstLevel  ,
                 'a' DateApprovedFirstLevel  ,
                 v_SourceSystem SourceSystem  
         	  FROM CustomerLevelMOC_Mod 
         	 WHERE  AuthorisationStatus = CASE 
                                             WHEN v_OperationFlag = 20 THEN '1A'
                  ELSE 'MP'
                     END
                    AND EffectiveFromTimeKey = v_TimeKey
                    AND EffectiveToTimeKey = v_TimeKey
                    AND CUSTOMERID = v_CustomerID
                    AND SCREENFLAG NOT IN ( CASE 
                                                 WHEN v_OperationFlag IN ( 16,20 )
                                                  THEN 'U'   END )
          );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM tt_CUST_POSTMOC_7 
                                 WHERE  CUSTOMERID = v_CustomerID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_CUST_POSTMOC_7
              ( SELECT CustomerEntityId ,
                       RefCustomerID CustomerID  ,
                       CustomerName ,
                       SysAssetClassAlt_Key AssetClassAlt_Key  ,
                       SysNPA_Dt NPADate  ,
                       AddlProvisionPer AdditionalProvision  ,
                       CurntQtrRv SecurityValue  ,
                       UCIF_ID UCICID  ,
                       ScreenFlag ,
                       v_AuthorisationStatus AuthorisationStatus  ,
                       v_MOCType MOCType  ,
                       v_MocReason MocReason  ,
                       v_MocTypeAlt_Key MocTypeAlt_Key  ,
                       v_MOCSourceAltkey MOCSourceAltkey  ,
                       v_CreatedBy CreatedBy  ,
                       v_DateCreated DateCreated  ,
                       v_ModifiedBy ModifiedBy  ,
                       v_DateModified DateModified  ,
                       v_ApprovedBy ApprovedBy  ,
                       v_DateApproved DateApproved  ,
                       v_ApprovedByFirstLevel ApprovedByFirstLevel  ,
                       v_DateApprovedFirstLevel DateApprovedFirstLevel  ,
                       v_SourceSystem SourceSystem  
                FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
                 WHERE  EffectiveFromTimeKey = v_TimeKey
                          AND EffectiveToTimeKey = v_TimeKey
                          AND NVL(FlgMoc, 'N') = 'Y'
                          AND RefCustomerID = v_CustomerID );

         END;
         END IF;
         OPEN  v_cursor FOR
            SELECT A.CustomerID CustomerId  ,
                   A.CustomerName ,
                   C.AssetClassName AssetClass  ,
                   UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>103) NPADate  ,
                   A.SecurityValue ,
                   A.AdditionalProvision ,
                   D.AssetClassName AssetClass_Pos  ,
                   UTILS.CONVERT_TO_VARCHAR2(B.NPADate,10,p_style=>103) NPADate_Pos  ,
                   B.SecurityValue SecurityValue_Pos  ,
                   B.AdditionalProvision AdditionalProvision_Pos  ,
                   A.UCICID UCICID  ,
                   D.AssetClassAlt_Key AssetClassAlt_Key_Pos  ,
                   --,NULL as FraudAccountFlag
                   --,F.STATUSTYPE as FraudAccountFlag_Pos
                   --,H.FraudAccountFlagAlt_Key AS FraudAccountFlagAlt_Key
                   --,convert(varchar(20),F.STATUSDATE,103) FraudDate	
                   --,H.FraudDate as FraudDate_Pos
                   --,B.MOCType as MOCType
                   B.MOCReason ,
                   B.MOCTypeAlt_Key ,
                   --,Y.MOCTypeName as MOCSource
                   B.MOCSourceAltKey ,
                   X.TotalOSBalance ,
                   X.TotalInterestReversal ,
                   X.TotalPrincOSBalance ,
                   X.TotalInterestReceivabl ,
                   X.TotalProvision ,
                   NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                   NVL(B.DateModified, B.DateCreated) CrModDate  ,
                   NVL(B.ApprovedBy, B.CreatedBy) CrAppBy  ,
                   NVL(B.DateApproved, B.DateCreated) CrAppDate  ,
                   NVL(B.ApprovedBy, B.ModifiedBy) ModAppBy  ,
                   NVL(B.DateApproved, B.DateModified) ModAppDate  ,
                   B.ModifiedBy ,
                   B.AuthorisationStatus ,
                   B.ApprovedByFirstLevel ,
                   B.DateApprovedFirstLevel ,
                   UTILS.CONVERT_TO_VARCHAR2(v_DateOfData,20,p_style=>103) DateOfData  ,
                   A.SourceSystem 
              FROM tt_CUST_PREMOC_7 A
                     LEFT JOIN tt_CUST_POSTMOC_7 B   ON A.CustomerID = b.CustomerID
                     LEFT JOIN DimAssetClass c   ON C.AssetClassAlt_Key = a.AssetClassAlt_Key
                     AND c.EffectiveFromTimeKey <= v_TimeKey
                     AND c.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = b.AssetClassAlt_Key
                     AND D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN ( SELECT RefCustomerId ,
                                        EffectiveFromTimeKey ,
                                        EffectiveToTimeKey ,
                                        SUM(T.Balance)  TotalOSBalance  ,
                                        SUM(T.unserviedint)  TotalInterestReversal  ,
                                        0 TotalPrincOSBalance  ,
                                        0 TotalInterestReceivabl  ,
                                        SUM(T.TotalProvision)  TotalProvision  
                                 FROM PRO_RBL_MISDB_PROD.AccountCal_Hist T
                                  WHERE  RefCustomerId = v_CustomerID
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey
                                   GROUP BY T.RefCustomerId,T.EffectiveFromTimeKey,T.EffectiveToTimeKey ) X   ON X.RefCustomerId = A.CustomerID ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         IF utils.object_id('tempdb..tt_MOCAuthorisation_14') IS NOT NULL THEN

         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOCAuthorisation_14 ';

         END;
         END IF;
         DELETE FROM tt_MOCAuthorisation_14;
         UTILS.IDENTITY_RESET('tt_MOCAuthorisation_14');

         INSERT INTO tt_MOCAuthorisation_14 ( 
         	SELECT * ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
         	  FROM CustomerLevelMOC_Mod A
         	 WHERE  A.CustomerID = v_CustomerID
                    AND A.EffectiveFromTimeKey <= v_Timekey
                    AND A.EffectiveToTimeKey >= v_Timekey
                    AND CustomerId IS NOT NULL
                    AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                          FROM CustomerLevelMOC_Mod 
                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                            GROUP BY CustomerID )
          );
         --Select ' tt_MOCAuthorisation_14',* from  tt_MOCAuthorisation_14
         --where abc=1
         UPDATE tt_MOCAuthorisation_14 V
            SET ErrorMessage = CASE 
                                    WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                   END,
                ErrorinColumn = CASE 
                                     WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                   END
          WHERE  V.AuthorisationStatus IN ( 'NP','MP','DP','1A' )

           AND CustomerID = v_CustomerID
           AND v_Operationflag NOT IN ( 16,17,20 )
         ;
         MERGE INTO tt_MOCAuthorisation_14 G
         USING (SELECT G.ROWID row_id, CASE 
         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for an Account ID ' || A.AccountID || ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Author







         ization’ menu'
         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for an Account ID ' || A.AccountID || ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Authorization’ menu'
            END AS pos_2, CASE 
         WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
            END AS pos_3
         FROM AccountLevelMOC_Mod A
                JOIN AdvAcBasicDetail F   ON A.AccountID = F.CustomerACID
                JOIN CustomerBasicDetail B   ON F.CustomerEntityId = B.CustomerEntityId
                JOIN tt_MOCAuthorisation_14 G   ON F.RefCustomerId = G.CustomerID 
          WHERE A.AuthorisationStatus IN ( 'NP','MP','DP','1A','FM' )

           AND G.CustomerID = v_CustomerID
           AND v_Operationflag NOT IN ( 16,17,20 )
         ) src
         ON ( G.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                      ErrorinColumn = pos_3;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_MOCAuthorisation_14 
                             WHERE  Customerid = v_CustomerID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

          --AND ISNULL(ERRORDATA,'')<>''
         BEGIN
            DBMS_OUTPUT.PUT_LINE('ERROR');
            IF ( v_operationflag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT DISTINCT ErrorMessage ErrorinColumn  ,
                                  'Validation' TableName  
                    FROM tt_MOCAuthorisation_14  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1
      -------------------------------
      --				ADVSECURITYDETAIL
      --			select * from ADVSECURITYDETAIL --ExceptionFinalStatusType
      --select * from AdvSecurityVALUEDetail 
      -----AdvSecurityDetail

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELNPAMOCSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
