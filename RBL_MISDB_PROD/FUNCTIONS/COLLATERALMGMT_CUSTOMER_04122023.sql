--------------------------------------------------------
--  DDL for Function COLLATERALMGMT_CUSTOMER_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --exec CollateralMgmt_Customer @SearchType=N'4',@Cust_Ucic_Acid=N'22562119'
 --go
 --sp_helptext CollateralMgmt_Customer
 -------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  exec CollateralMgmt_Customer @CustomerId=N'19987800'
 --go
 --sp_helptext CollateralMgmt_Customer
 --Select Top 10 REfcustomerID, * from [CurDat].[AdvAcBasicDetail]
 --[CurDat].[CustomerBasicDetail
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --- Script Date: 3/26/2021 2:00:55 PM *****(Farahnaaz)

(
  v_SearchType IN NUMBER,
  v_Cust_Ucic_Acid IN VARCHAR2 DEFAULT ' ' ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --IF OBJECT_ID('TempDB..#temp') IS NOT NULL
   --             DROP TABLE  #temp;
   v_RowsRetrurn NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_LatestColletralSum NUMBER(18,2);
   v_LatestColletralCount NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF ( v_SearchType = 1 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      IF utils.object_id('TempDB..tt_tmp_8') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_8 ';
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT M.AccountID ,
                                    M.CustomerId ,
                                    M.CustomerName ,
                                    M.EffectiveFromTimeKey ,
                                    M.EffectiveToTimeKey ,
                                    'CustomerDetails' TableName  
                             FROM ( SELECT A.CustomerACID AccountID  ,
                                           C.CustomerId ,
                                           C.CustomerName ,
                                           A.EffectiveFromTimeKey ,
                                           A.EffectiveToTimeKey 
                                    FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                                           JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
                              WHERE  M.CustomerId = v_Cust_Ucic_Acid );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT ' ' AccountID  ,
                   ' ' CustomerId  ,
                   ' ' CustomerName  ,
                   ' ' EffectiveFromTimeKey  ,
                   ' ' EffectiveToTimeKey  ,
                   'CustomerDetails' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT M.AccountID ,
                   M.CustomerId ,
                   M.CustomerName ,
                   M.EffectiveFromTimeKey ,
                   M.EffectiveToTimeKey ,
                   'CustomerDetails' TableName  
              FROM ( SELECT A.CustomerACID AccountID  ,
                            C.CustomerId ,
                            C.CustomerName ,
                            A.EffectiveFromTimeKey ,
                            A.EffectiveToTimeKey 
                     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                            JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
             WHERE  M.CustomerId = v_Cust_Ucic_Acid ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      DELETE FROM tt_tmp_8;
      UTILS.IDENTITY_RESET('tt_tmp_8');

      INSERT INTO tt_tmp_8 ( 
      	SELECT CollateralID 
      	  FROM CollateralMgmt 
      	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey
                 AND CustomerID = v_Cust_Ucic_Acid );
      SELECT SUM(TotalCollateralvalueatcustomerlevel)  

        INTO v_LatestColletralSum
        FROM ( SELECT (NVL(LatestCollateralValueinRs, 0)) TotalCollateralvalueatcustomerlevel  
               FROM CollateralValueDetails A
                      JOIN CollateralMgmt B   ON A.CollateralID = B.CollateralID
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND A.CollateralID IN ( SELECT CollateralID 
                                                 FROM tt_tmp_8  )

                         AND B.CustomerID = v_Cust_Ucic_Acid ) X;
      SELECT COUNT(*)  

        INTO v_LatestColletralCount
        FROM tt_tmp_8 ;
      OPEN  v_cursor FOR
         SELECT v_LatestColletralSum LatestColletralSum  ,
                v_LatestColletralCount LatestColletralCount  ,
                'TotalSumColletral' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_RowsRetrurn := SQL%ROWCOUNT ;
      IF ( v_RowsRetrurn <= 0 ) THEN

      BEGIN
         v_Result := -1 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;
   IF ( v_SearchType = 4 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('aaa');
      IF utils.object_id('TempDB..tt_tmp_82') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp2_15 ';
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT M.UCIF_ID ,
                                    'UCICDetails' TableName  ,
                                    M.CustomerName 
                             FROM ( SELECT C.UCIF_ID ,
                                           C.CustomerName 
                                    FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                                           JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
                              WHERE  M.UCIF_ID = v_Cust_Ucic_Acid );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT 'NULL' UCIC_ID  ,
                   'UCICDetails' TableName  ,
                   ' ' CustomerName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT M.UCIF_ID ,
                   'UCICDetails' TableName  ,
                   M.CustomerName 
              FROM ( SELECT C.UCIF_ID ,
                            C.CustomerName 
                     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                            JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
             WHERE  M.UCIF_ID = v_Cust_Ucic_Acid ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      DELETE FROM tt_tmp2_15;
      UTILS.IDENTITY_RESET('tt_tmp2_15');

      INSERT INTO tt_tmp2_15 ( 
      	SELECT CollateralID 
      	  FROM CollateralMgmt 
      	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey
                 AND UCICID = v_Cust_Ucic_Acid );
      SELECT SUM(TotalCollateralvalueatcustomerlevel)  

        INTO v_LatestColletralSum
        FROM ( SELECT (NVL(LatestCollateralValueinRs, 0)) TotalCollateralvalueatcustomerlevel  
               FROM CollateralValueDetails A
                      JOIN CollateralMgmt B   ON A.CollateralID = B.CollateralID
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND A.CollateralID IN ( SELECT CollateralID 
                                                 FROM tt_tmp2_15  )

                         AND B.UCICID = v_Cust_Ucic_Acid ) X;
      SELECT COUNT(*)  

        INTO v_LatestColletralCount
        FROM tt_tmp2_15 ;
      OPEN  v_cursor FOR
         SELECT v_LatestColletralSum LatestColletralSum  ,
                v_LatestColletralCount LatestColletralCount  ,
                'ColletralDetails2' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_RowsRetrurn := SQL%ROWCOUNT ;
      IF ( v_RowsRetrurn <= 0 ) THEN

      BEGIN
         v_Result := -4 ;

      END;
      END IF;

   END;
   END IF;
   --RETURN @Result;
   --Select @Result As result
   IF ( v_SearchType = 2 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      IF utils.object_id('TempDB..tt_tmp_81') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp1_6 ';
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT M.AccountID ,
                                    M.CustomerId ,
                                    M.CustomerName ,
                                    'AccountDetails' TableName  
                             FROM ( SELECT A.CustomerACID AccountID  ,
                                           C.CustomerId ,
                                           C.CustomerName 
                                    FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                                           JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
                              WHERE  M.AccountID = v_Cust_Ucic_Acid );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT ' ' AccountID  ,
                   ' ' CustomerId  ,
                   ' ' CustomerName  ,
                   'AccountDetails' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT M.AccountID ,
                   M.CustomerId ,
                   M.CustomerName ,
                   'AccountDetails' TableName  
              FROM ( SELECT A.CustomerACID AccountID  ,
                            C.CustomerId ,
                            C.CustomerName 
                     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                            JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail C   ON A.REfcustomerID = C.CustomerID ) M
             WHERE  M.AccountID = v_Cust_Ucic_Acid ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      DELETE FROM tt_tmp1_6;
      UTILS.IDENTITY_RESET('tt_tmp1_6');

      INSERT INTO tt_tmp1_6 ( 
      	SELECT CollateralID 
      	  FROM CollateralMgmt 
      	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey
                 AND AccountID = v_Cust_Ucic_Acid );
      SELECT SUM(TotalCollateralvalueatcustomerlevel)  

        INTO v_LatestColletralSum
        FROM ( SELECT (NVL(LatestCollateralValueinRs, 0)) TotalCollateralvalueatcustomerlevel  
               FROM CollateralValueDetails A
                      JOIN CollateralMgmt B   ON A.CollateralID = B.CollateralID
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND A.CollateralID IN ( SELECT CollateralID 
                                                 FROM tt_tmp1_6  )

                         AND B.AccountID = v_Cust_Ucic_Acid ) X;
      SELECT COUNT(*)  

        INTO v_LatestColletralCount
        FROM tt_tmp1_6 ;
      OPEN  v_cursor FOR
         SELECT v_LatestColletralSum LatestColletralSum  ,
                v_LatestColletralCount LatestColletralCount  ,
                'ColletralDetails2' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_RowsRetrurn := SQL%ROWCOUNT ;
      IF ( v_RowsRetrurn <= 0 ) THEN

      BEGIN
         v_Result := -2 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMT_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
