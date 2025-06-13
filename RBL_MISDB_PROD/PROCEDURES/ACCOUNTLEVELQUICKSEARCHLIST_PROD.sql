--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELQUICKSEARCHLIST_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" 
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
      v_AccountEntityID NUMBER(10,0) ;
      v_CustomerEntityID NUMBER(10,0);
      v_UCIFEntityID NUMBER(10,0) ;

   BEGIN

      SELECT AccountEntityID INTO v_AccountEntityID
        FROM AdvAcBasicDetail 
       WHERE  CustomerACID = v_ACID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;

      SELECT UcifEntityID INTO v_UCIFEntityID 
        FROM CustomerBasicDetail 
       WHERE  UCIF_ID = v_UCICID
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey 
        FETCH FIRST 1 ROWS ONLY ;


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
      
      INSERT INTO GTT_Temp_24 ( 
      	SELECT A.AccountID ,
              AuthorisationStatus 
      	  FROM AccountLevelMOC_Mod A
                JOIN ( SELECT MAX(EntityKey)  EntityKey  ,
                              AccountID 
                       FROM AccountLevelMOC_Mod 
                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                 AND EffectiveToTimeKey >= v_Timekey
                         GROUP BY AccountID ) B   ON B.EntityKey = A.EntityKey );
      
      DELETE FROM GTT_ACCOUNTCAL_hIST;
      UTILS.IDENTITY_RESET('GTT_ACCOUNTCAL_hIST');

      INSERT INTO GTT_ACCOUNTCAL_hIST ( 
      	SELECT * 
      	  FROM MAIN_PRO.AccountCal_Hist 
      	 WHERE  EffectiveFromTimeKey = v_Timekey
                 AND EffectiveToTimeKey = v_Timekey
                 AND ( AccountEntityID = v_AccountEntityID
                 OR CustomerEntityID = v_CustomerEntityID
                 OR UcifEntityID = v_UCIFEntityID ) );
      DELETE FROM GTT_CustomerCAL_hIST;
      UTILS.IDENTITY_RESET('GTT_CustomerCAL_hIST');

      INSERT INTO GTT_CustomerCAL_hIST ( 
      	SELECT * 
      	  FROM MAIN_PRO.CustomerCal_Hist 
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
                     FROM GTT_ACCOUNTCAL_hIST A
                            JOIN GTT_CustomerCAL_hIST B   ON A.CustomerEntityId = B.CustomerEntityId
                          --INNER JOIN Accountlevelmoc_mod C ON C.AccountID=A.CustomerAcID

                            LEFT JOIN GTT_Temp_24 C   ON C.AccountID = A.CustomerAcID
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
              FROM GTT_ACCOUNTCAL_hIST A
                     JOIN GTT_CustomerCAL_hIST B   ON A.CustomerEntityId = B.CustomerEntityId ;
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
                         JOIN GTT_ACCOUNTCAL_hIST C   ON C.CustomerAcID = A.AccountID
                         JOIN GTT_CustomerCAL_hIST B   ON C.RefCustomerID = B.Refcustomerid
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
                         JOIN GTT_ACCOUNTCAL_hIST C   ON C.CustomerAcID = A.AccountID
                         JOIN GTT_CustomerCAL_hIST B   ON C.RefCustomerID = B.Refcustomerid
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
