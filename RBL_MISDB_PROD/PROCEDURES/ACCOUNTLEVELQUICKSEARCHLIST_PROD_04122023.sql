--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_ACID IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  iv_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   v_CustomerId VARCHAR2(20) := iv_CustomerId;
   v_CustomerName VARCHAR2(20) := iv_CustomerName;
   v_UCICID VARCHAR2(12) := iv_UCICID;
   v_Timekey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   v_PageFrom := (v_pageSize * v_newPage) - (v_pageSize) + 1 ;
   v_PageTo := v_pageSize * v_newPage ;
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   DECLARE
      v_AccountEntityID NUMBER(10,0) := ( SELECT AccountEntityID 
        FROM AdvAcBasicDetail 
       WHERE  CustomerACID = v_ACID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey );
      v_CustomerEntityID NUMBER(10,0);
      v_UCIFEntityID NUMBER(10,0) := ( SELECT UcifEntityID 
        FROM CustomerBasicDetail 
       WHERE  UCIF_ID = v_UCICID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey 
        FETCH FIRST 1 ROWS ONLY );

   BEGIN
      DBMS_OUTPUT.PUT_LINE(v_Timekey);
      IF ( v_CustomerId != ' ' ) THEN

      BEGIN
         SELECT CustomerEntityID 

           INTO v_CustomerEntityID
           FROM CustomerBasicDetail 
          WHERE  CustomerId = v_CustomerId
                   AND EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey;

      END;
      ELSE

      BEGIN
         SELECT CustomerEntityID 

           INTO v_CustomerEntityID
           FROM AdvAcBasicDetail 
          WHERE  CustomerACID = v_ACID
                   AND EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey;

      END;
      END IF;
      IF  --SQLDEV: NOT RECOGNIZED
      IF #TEmp  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_Temp_25;
      UTILS.IDENTITY_RESET('tt_Temp_25');

      INSERT INTO tt_Temp_25 ( 
      	SELECT A.AccountID ,
              AuthorisationStatus 
      	  FROM AccountLevelMOC_Mod A
                JOIN ( SELECT MAX(EntityKey)  EntityKey  ,
                              AccountID 
                       FROM AccountLevelMOC_Mod 
                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                 AND EffectiveToTimeKey >= v_Timekey
                         GROUP BY AccountID ) B   ON B.EntityKey = A.EntityKey );
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_ACCOUNTCAL_hIST_2  --SQLDEV: NOT RECOGNIZED
      tt_ACCOUNTCAL_hIST_2 TABLE IF  --SQLDEV: NOT RECOGNIZED
      IF #CUSTOMERCAL_hIST  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_ACCOUNTCAL_hIST_2;
      UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_hIST_2');

      INSERT INTO tt_ACCOUNTCAL_hIST_2 ( 
      	SELECT * 
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
      	 WHERE  EffectiveFromTimeKey = v_Timekey
                 AND EffectiveToTimeKey = v_Timekey
                 AND ( AccountEntityID = v_AccountEntityID
                 OR CustomerEntityID = v_CustomerEntityID
                 OR UcifEntityID = v_UCIFEntityID ) );
      DELETE FROM tt_CustomerCAL_hIST_2;
      UTILS.IDENTITY_RESET('tt_CustomerCAL_hIST_2');

      INSERT INTO tt_CustomerCAL_hIST_2 ( 
      	SELECT * 
      	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
      	 WHERE  EffectiveFromTimeKey = v_Timekey
                 AND EffectiveToTimeKey = v_Timekey
                 AND ( CustomerEntityID = v_CustomerEntityID

                 --OR B.CustomerName like '%' + @CustomerName+ '%'
                 OR UcifEntityID = v_UCIFEntityID ) );
      IF ( ( v_CustomerId = ' ' )
        AND ( v_CustomerName = ' ' )
        AND ( v_UCICID = ' ' )
        AND ( v_ACID = ' ' )
        AND ( v_operationflag NOT IN ( 16,20 )
       ) ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('111');
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT DISTINCT A.CustomerACID ACID  ,
                                     A.RefCustomerId ,
                                     B.CustomerName ,
                                     B.UCIF_ID UCICID  ,
                                     CASE 
                                          WHEN C.AuthorisationStatus IN ( 'FM','MP','NP' )
                                           THEN 'Pending'
                                          WHEN C.AuthorisationStatus IN ( 'A','R' )
                                           THEN 'Authorise'
                                     ELSE 'No MOC Done '
                                        END AuthorisationStatus  ,
                                     'AccountLevel' TableName  ,
                                     ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                      FROM DUAL  )  ) RowNumber  
                     FROM tt_ACCOUNTCAL_hIST_2 A
                            JOIN tt_CustomerCAL_hIST_2 B   ON A.CustomerEntityId = B.CustomerEntityId
                          --INNER JOIN Accountlevelmoc_mod C ON C.AccountID=A.CustomerAcID

                            LEFT JOIN tt_Temp_25 C   ON C.AccountID = A.CustomerAcID
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey ) 
                   --and C.EffectiveFromTimeKey <= @Timekey

                   --AND c.EffectiveToTimeKey >= @Timekey
                   A
             WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo
              ORDER BY RowNumber ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;

      END;
      END IF;
      IF v_CustomerId = ' ' THEN
       v_CustomerId := NULL ;
      END IF;
      IF v_CustomerName = ' ' THEN
       v_CustomerName := NULL ;
      END IF;
      IF v_UCICID = ' ' THEN
       v_UCICID := NULL ;
      END IF;
      IF ( v_OperationFlag NOT IN ( 16,20 )
       ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT A.CustomerACID ACID  ,
                   A.RefCustomerId ,
                   B.CustomerName ,
                   B.UCIF_ID UCICID  ,
                   'AccountLevel' TableName  
              FROM tt_ACCOUNTCAL_hIST_2 A
                     JOIN tt_CustomerCAL_hIST_2 B   ON A.CustomerEntityId = B.CustomerEntityId ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   IF ( v_OperationFlag IN ( 16 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT A.AccountID ACID  ,
                         B.RefCustomerId ,
                         B.CustomerName ,
                         B.UCIF_ID UCICID  ,
                         'AccountLevel' TableName  ,
                         ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) RowNumber  
                  FROM AccountLevelMOC_Mod A
                         JOIN tt_ACCOUNTCAL_hIST_2 C   ON C.CustomerAcID = A.AccountID
                         JOIN tt_CustomerCAL_hIST_2 B   ON C.RefCustomerID = B.Refcustomerid
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
                 ) 
                --AND  (A.AccountID=@ACID

                --OR B.RefCustomerId=@CustomerId

                --   OR B.CustomerName like '%' + @CustomerName+ '%'

                --   OR B.UCIF_ID=@UCICID)
                A
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo
           ORDER BY RowNumber ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT A.AccountID ACID  ,
                         B.RefCustomerId ,
                         B.CustomerName ,
                         B.UCIF_ID UCICID  ,
                         'AccountLevel' TableName  ,
                         ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) RowNumber  
                  FROM AccountLevelMOC_Mod A
                         JOIN tt_ACCOUNTCAL_hIST_2 C   ON C.CustomerAcID = A.AccountID
                         JOIN tt_CustomerCAL_hIST_2 B   ON C.RefCustomerID = B.Refcustomerid
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )
                 ) 
                --AND  (A.AccountID=@ACID

                --OR B.RefCustomerId=@CustomerId

                --   OR B.CustomerName like '%' + @CustomerName+ '%'

                --   OR B.UCIF_ID=@UCICID)
                A
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo
           ORDER BY RowNumber ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
