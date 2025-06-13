--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELQUICKSEARCHLIST_17082021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_ACID IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  iv_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER,
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

   BEGIN
      DBMS_OUTPUT.PUT_LINE(v_Timekey);
      IF  --SQLDEV: NOT RECOGNIZED
      IF #TEmp  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_Temp_22;
      UTILS.IDENTITY_RESET('tt_Temp_22');

      INSERT INTO tt_Temp_22 ( 
      	SELECT A.AccountID ,
              AuthorisationStatus 
      	  FROM AccountLevelMOC_Mod A
                JOIN ( SELECT MAX(EntityKey)  EntityKey  ,
                              AccountID 
                       FROM AccountLevelMOC_Mod 
                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                 AND EffectiveToTimeKey >= v_Timekey
                         GROUP BY AccountID ) B   ON B.EntityKey = A.EntityKey );
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
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerEntityId = B.CustomerEntityId
                            AND B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                          --INNER JOIN Accountlevelmoc_mod C ON C.AccountID=A.CustomerAcID

                            LEFT JOIN tt_Temp_22 C   ON C.AccountID = A.CustomerAcID
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
              FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                     JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerEntityId = B.CustomerEntityId
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey

                      --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                      AND ( A.CustomerACID = v_ACID
                      OR A.RefCustomerId = v_CustomerId
                      OR B.CustomerName LIKE '%' || v_CustomerName || '%'
                      OR B.UCIF_ID = v_UCICID ) ;
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
                         JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON C.CustomerAcID = A.AccountID
                         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON C.RefCustomerID = B.Refcustomerid
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
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
                         JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON C.CustomerAcID = A.AccountID
                         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON C.RefCustomerID = B.Refcustomerid
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_17082021" TO "ADF_CDR_RBL_STGDB";
