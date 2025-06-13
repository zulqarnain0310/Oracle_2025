--------------------------------------------------------
--  DDL for Function IBPCDATAUPLOAD_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" 
-- =============================================
 -- Author:		<shailesh naik>
 -- Create date: <16 jan 2019 kikrant>
 -- Description:	<RBI pan insert update>
 -- =============================================

(
  v_XMLDocument IN CLOB DEFAULT u'' ,
  v_ScreenName IN VARCHAR2 DEFAULT 'IBPCDataUpload' ,
  v_SheetNames IN VARCHAR2 DEFAULT ' ' ,
  v_DateOfData IN VARCHAR2 DEFAULT ' ' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_TimeKey IN NUMBER DEFAULT 24957 ,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_D2KTimeStamp OUT NUMBER/* DEFAULT 0*/,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuId IN NUMBER DEFAULT 118 
)
RETURN NUMBER
AS
   v_OperationFlag NUMBER(10,0) := iv_OperationFlag;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_EntityId NUMBER(10,0);
   v_CreatedBy VARCHAR2(50);
   v_DateCreated DATE;
   v_ModifiedBy VARCHAR2(50);
   v_DateModified DATE;
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved DATE;
   v_AuthorisationStatus CHAR(2);
   v_ErrorHandle NUMBER(5,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_Data_Sequence NUMBER(10,0) := 0;
   v_cursor SYS_REFCURSOR;
   v_checkDate NUMBER(10,0);

BEGIN

   --SET @EffectiveFromTimeKey=@TimeKey
   IF utils.object_id('Tempdb..tt_MiscIBPC_Detail_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiscIBPC_Detail_2 ';
   END IF;
   DELETE FROM tt_MiscIBPC_Detail_2;
   UTILS.IDENTITY_RESET('tt_MiscIBPC_Detail_2');

   INSERT INTO tt_MiscIBPC_Detail_2 ( 
   	SELECT /*TODO:SQLDEV*/ C.value('./Soldto				[1]','VARCHAR(50)'	) /*END:SQLDEV*/ ParticipatingBank  ,
           /*TODO:SQLDEV*/ C.value('./CustID				[1]','VARCHAR(20)'	) /*END:SQLDEV*/ CustomerId  ,
           /*TODO:SQLDEV*/ C.value('./AccountNumber					[1]','VARCHAR(30)'	) /*END:SQLDEV*/ CustomerACID  ,
           /*TODO:SQLDEV*/ C.value('./Segment				[1]','VARCHAR(100)'	) /*END:SQLDEV*/ REMARK  ,
           /*TODO:SQLDEV*/ C.value('./Customer				[1]','VARCHAR(100)'	) /*END:SQLDEV*/ CUSTOMERNAME  ,
           /*TODO:SQLDEV*/ C.value('./IBPCSep19					[1]','VARCHAR(30)'	) /*END:SQLDEV*/ IBPC_Amount  

   	  --FROM @XMLDocument.nodes('/DataSet/BondsUploadEntry') AS t(c)
   	  FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/Root/Sheet1') AS t(c) /*END:SQLDEV*/)  );
   -----
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_MiscIBPC_Detail_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --select * from #BondsUploadEntry
   DBMS_OUTPUT.PUT_LINE('revert');
   v_OperationFlag := 1 ;
   SELECT TimeKey 

     INTO v_checkDate
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(v_DateOfData,200);
   DBMS_OUTPUT.PUT_LINE(v_checkDate);
   v_EffectiveFromTimeKey := v_checkDate ;
   v_EffectiveToTimeKey := v_checkDate ;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         IF v_OperationFlag = 1
           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            DBMS_OUTPUT.PUT_LINE('op1');
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_AuthorisationStatus := 'NP' ;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT * 
                               FROM MiscIBPC_Detail 
                                WHERE  EffectiveFromTimeKey <= v_checkDate
                                         AND EffectiveToTimeKey >= v_checkDate );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DELETE MiscIBPC_Detail

             WHERE  EffectiveFromTimeKey <= v_checkDate
                      AND EffectiveToTimeKey >= v_checkDate;
            END IF;
            DBMS_OUTPUT.PUT_LINE('DELETE');
            GOTO BSCodeStructure_Insert;
            <<BSCodeStruct_Insert_Add>>

         END;
         END IF;
         v_ErrorHandle := 1 ;
         DBMS_OUTPUT.PUT_LINE(v_ErrorHandle);
         <<BSCodeStructure_Insert>>
         DBMS_OUTPUT.PUT_LINE('A');
         IF v_ErrorHandle = 0 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Insert into MiscIBPC_Detail_MOD');
            DBMS_OUTPUT.PUT_LINE('@ErrorHandle');
            INSERT INTO MiscIBPC_Detail_MOD
              ( BranchCode, IBPC_Nature
            --,IBPC_Type
            , CustomerId, CustomerName, SystemACID, CustomerACID, ParticipatingBank, CurrencyAlt_key, IBPC_AmountInCurrency, IBPC_Amount, Remark, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
              ( SELECT 'HO' ,
                       'Sale' ,
                       CustomerId ,
                       CustomerName ,
                       CustomerACID ,
                       CustomerACID ,
                       ParticipatingBank ,
                       62 ,--CurrencyAlt_key

                       IBPC_Amount ,
                       IBPC_Amount ,
                       Remark ,
                       v_AuthorisationStatus ,
                       v_EffectiveFromTimeKey ,
                       v_EffectiveToTimeKey ,
                       v_CreatedBy ,
                       v_DateCreated 
                FROM tt_MiscIBPC_Detail_2  );
            DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,30) || 'INSERTED into mod');
            DBMS_OUTPUT.PUT_LINE('Insert into MiscIBPC_Detail');
            --Select *from MiscIBPC_Detail
            DBMS_OUTPUT.PUT_LINE('@ErrorHandle');
            INSERT INTO MiscIBPC_Detail
              ( BranchCode, IBPC_Nature
            --,IBPC_Type
            , CustomerId, CustomerName, SystemACID, CustomerACID, ParticipatingBank, CurrencyAlt_key, IBPC_AmountInCurrency, IBPC_Amount, Remark, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
              ( SELECT 'HO' ,
                       'Sale' ,
                       CustomerId ,
                       CustomerName ,
                       CustomerACID ,
                       CustomerACID ,
                       ParticipatingBank ,
                       62 ,--CurrencyAlt_key

                       IBPC_Amount ,
                       IBPC_Amount ,
                       Remark ,
                       v_AuthorisationStatus ,
                       v_EffectiveFromTimeKey ,
                       v_EffectiveToTimeKey ,
                       v_CreatedBy ,
                       v_DateCreated 
                FROM tt_MiscIBPC_Detail_2  );
            DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,30) || 'INSERTED');
            IF v_OperationFlag = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO BSCodeStruct_Insert_Add;

            END;
            END IF;

         END;
         END IF;
         utils.commit_transaction;
         IF v_OperationFlag <> 3 THEN

         BEGIN
            v_D2Ktimestamp := '090934' ;
            v_RESULT := 1 ;
            RETURN v_RESULT;

         END;

         --RETURN @D2Ktimestamp
         ELSE

         BEGIN
            v_Result := 0 ;
            RETURN v_RESULT;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT SQLERRM ERRORDESC  ,
                utils.error_line LineNum  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ROLLBACK;
      utils.resetTrancount;
      v_RESULT := -1 ;
      RETURN v_RESULT;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
