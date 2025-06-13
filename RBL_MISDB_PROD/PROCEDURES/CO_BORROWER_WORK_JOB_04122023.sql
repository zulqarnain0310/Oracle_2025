--------------------------------------------------------
--  DDL for Procedure CO_BORROWER_WORK_JOB_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" CREATE PROC "dbo" . "CO_BORROWER_WORK_JOB_04122023" AS DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   v_CustCnt NUMBER(10,0) := ( SELECT MAX(rid)  
     FROM tt_CUSTid_4  );
   v_Counter NUMBER(10,0) := 1;
   v_Acct_Cust_Code NUMBER(10,0) := 1;
   v_CustID CHAR(20);
   v_Acct_Cust_CodeExisting NUMBER(10,0) := 0;

BEGIN

   IF tt_CUSTid_4  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CUSTid_4;
   UTILS.IDENTITY_RESET('tt_CUSTid_4');

   INSERT INTO tt_CUSTid_4 SELECT CUSTID ,
                                  ROW_NUMBER() OVER ( ORDER BY CUSTID  ) RID  
        FROM ( SELECT DISTINCT CUSTID 
               FROM CO_BORROWER_DATA_UAT 
                WHERE  customer_type = 'MAIN' -- AND CUSTID='1050612'
              ) A;
   WHILE v_Counter <= v_CustCnt 
   LOOP 

      BEGIN
         SELECT CUSTID 

           INTO v_CustID
           FROM tt_CUSTid_4 
          WHERE  RID = v_Counter;
         ----PRINT @CustID
         SELECT Acct_Cust_Code 

           INTO v_Acct_Cust_CodeExisting
           FROM CO_BORROWER_DATA_UAT 
          WHERE  CUSTID = v_CustID
                   AND Acct_Cust_Code IS NOT NULL 
           FETCH FIRST 1 ROWS ONLY;
         UPDATE CO_BORROWER_DATA_UAT
            SET Acct_Cust_Code = CASE 
                                      WHEN NVL(v_Acct_Cust_CodeExisting, 0) > 0 THEN v_Acct_Cust_CodeExisting
                ELSE v_Acct_Cust_Code
                   END
          WHERE  CUSTID = v_CustID;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, CASE 
         WHEN NVL(v_Acct_Cust_CodeExisting, 0) > 0 THEN v_Acct_Cust_CodeExisting
         ELSE A.Acct_Cust_Code
            END AS Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no 
          WHERE a.CUSTID = v_CustID
           AND B.Acct_Cust_Code IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no --a.CUSTID=@CustID --AND 

          WHERE B.Acct_Cust_Code IS NULL
           AND A.Acct_Cust_Code IS NOT NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.CUSTID = b.CUSTID 
          WHERE A.Acct_Cust_Code IS NOT NULL
           AND B.Acct_Cust_Code IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no --a.CUSTID=@CustID --AND 

          WHERE B.Acct_Cust_Code IS NULL
           AND A.Acct_Cust_Code IS NOT NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.CUSTID = b.CUSTID 
          WHERE A.Acct_Cust_Code IS NOT NULL
           AND B.Acct_Cust_Code IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no --a.CUSTID=@CustID --AND 

          WHERE B.Acct_Cust_Code IS NULL
           AND A.Acct_Cust_Code IS NOT NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         --/* LEVEL 5*/
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.CUSTID = b.CUSTID 
          WHERE A.Acct_Cust_Code IS NOT NULL
           AND B.Acct_Cust_Code IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no --a.CUSTID=@CustID --AND 

          WHERE B.Acct_Cust_Code IS NULL
           AND A.Acct_Cust_Code IS NOT NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         --/* LEVEL 6*/
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.CUSTID = b.CUSTID 
          WHERE A.Acct_Cust_Code IS NOT NULL
           AND B.Acct_Cust_Code IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, A.Acct_Cust_Code
         FROM B ,CO_BORROWER_DATA_UAT a
                JOIN CO_BORROWER_DATA_UAT b   ON a.account_no = b.account_no --a.CUSTID=@CustID --AND 

          WHERE B.Acct_Cust_Code IS NULL
           AND A.Acct_Cust_Code IS NOT NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.Acct_Cust_Code = src.Acct_Cust_Code;
         IF NVL(v_Acct_Cust_CodeExisting, 0) = 0 THEN

         BEGIN
            v_Acct_Cust_Code := v_Acct_Cust_Code + 1 ;

         END;
         END IF;
         v_Acct_Cust_CodeExisting := 0 ;
         DBMS_OUTPUT.PUT_LINE(v_Counter);
         v_Counter := v_Counter + 1 ;

      END;
   END LOOP;
   ----SELECT * FROM CO_BORROWER_DATA_UAT WHERE Acct_Cust_Code='1' IS NOT NULL ORDER BY Acct_Cust_Code
   UPDATE CO_BORROWER_DATA_UAT
      SET CoBorr_CustID = custid
    WHERE  customer_type = 'CO_OBLIGANT';
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.Balance, b.PrincOutStd, b.TotalProvision, b.FinalAssetClassAlt_Key
   FROM A ,CO_BORROWER_DATA_UAT a
          JOIN PRO_RBL_MISDB_PROD.AccountCal_Main b   ON a.account_no = b.customeracid ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Balance = src.Balance,
                                a.Principal_OS = src.PrincOutStd,
                                a.TotalProv = src.TotalProvision,
                                a.AcAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
   WITH cte_Acct_Cust_Code_ACL AS ( SELECT Acct_Cust_Code ,
                                           MAX(AcAssetClassAlt_Key)  AcAssetClassAlt_Key  
     FROM CO_BORROWER_DATA_UAT 
     GROUP BY Acct_Cust_Code ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, b.AcAssetClassAlt_Key
      FROM A ,CO_BORROWER_DATA_UAT a
             JOIN cte_Acct_Cust_Code_ACL b   ON A.Acct_Cust_Code = b.Acct_Cust_Code ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET Acct_Cust_Code_AssetClassAlt_Key = src.AcAssetClassAlt_Key
      ;
   WITH CTE_COBORR_ACL AS ( SELECT CoBorr_CustID ,
                                   MAX(AcAssetClassAlt_Key)  AcAssetClassAlt_Key  
     FROM CO_BORROWER_DATA_UAT 
    WHERE  customer_type = 'CO_OBLIGANT'
     GROUP BY CoBorr_CustID ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, b.AcAssetClassAlt_Key
      FROM A ,CO_BORROWER_DATA_UAT a
             JOIN cte_coborr_ACL b   ON A.CUSTID = b.CoBorr_CustID 
       WHERE A.customer_type = 'MAIN') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET CoBorr_AcAssetClassAlt_Key
                                   --select  CoBorr_AcAssetClassAlt_Key, b.AcAssetClassAlt_Key
                                    = src.AcAssetClassAlt_Key
      ;--select customer_code,Acct_Cust_Code 
   --from CO_BORROWER_DATA_UAT --WHERE SourceName = 'VISIONPLUS' 
   --order by customer_code

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CO_BORROWER_WORK_JOB_04122023" TO "ADF_CDR_RBL_STGDB";
