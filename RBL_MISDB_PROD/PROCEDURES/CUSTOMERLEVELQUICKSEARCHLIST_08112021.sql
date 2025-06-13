--------------------------------------------------------
--  DDL for Procedure CUSTOMERLEVELQUICKSEARCHLIST_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --declare
  iv_CustomerId IN VARCHAR2 DEFAULT '60' ,
  iv_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  iv_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   v_CustomerId VARCHAR2(20) := iv_CustomerId;
   v_CustomerName VARCHAR2(100) := iv_CustomerName;
   v_UCICID VARCHAR2(12) := iv_UCICID;
   v_Timekey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   v_PageFrom := (v_pageSize * v_newPage) - (v_pageSize) + 1 ;
   v_PageTo := v_pageSize * v_newPage ;
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   ---select customerid and auth status
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_45  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_Temp_45;
   UTILS.IDENTITY_RESET('tt_Temp_45');

   INSERT INTO tt_Temp_45 ( 
   	SELECT A.CustomerID ,
           AuthorisationStatus 
   	  FROM CustomerLevelMOC_Mod A
             JOIN ( SELECT MAX(Entity_Key)  Entity_Key  ,
                           CustomerID 
                    FROM CustomerLevelMOC_Mod 
                     WHERE  EffectiveFromTimeKey <= v_Timekey
                              AND EffectiveToTimeKey >= v_Timekey --AND ISNULL(ScreenFlag,'U') NOT IN('U','')

                      GROUP BY CustomerID ) B   ON B.Entity_Key = A.Entity_Key );
   IF ( ( v_CustomerId = ' ' )
     AND ( v_CustomerName = ' ' )
     AND ( v_UCICID = ' ' )
     AND ( v_operationflag NOT IN ( 16,20 )
    ) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('111');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_12  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp_12;
      UTILS.IDENTITY_RESET('tt_tmp_12');

      INSERT INTO tt_tmp_12 SELECT ROW_NUMBER() OVER ( ORDER BY MOC_Dt DESC  ) RowNumber  ,
                                   * 
           FROM ( SELECT DISTINCT A.RefCustomerID CustomerId  ,
                                  A.CustomerName ,
                                  A.UCIF_ID UCICID  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  ,
                                  A.MOC_Dt 
                  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                       --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                         LEFT JOIN tt_Temp_45 T   ON T.CustomerID = A.RefCustomerID
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey ) 
                --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
                X
           ORDER BY X.MOC_Dt DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp_12 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
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
   DBMS_OUTPUT.PUT_LINE('1');
   IF ( v_OperationFlag NOT IN ( 16,20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('112');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_121  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp1_10;
      UTILS.IDENTITY_RESET('tt_tmp1_10');

      INSERT INTO tt_tmp1_10 SELECT ROW_NUMBER() OVER ( ORDER BY MOC_Dt DESC  ) RowNumber  ,
                                    * 
           FROM ( SELECT DISTINCT A.RefCustomerID CustomerId  ,
                                  A.CustomerName ,
                                  A.UCIF_ID UCICID  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, ' ') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  ,
                                  A.MOC_Dt 
                  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                       --Left join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                         LEFT JOIN tt_Temp_45 T   ON T.CustomerID = A.RefCustomerID
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey

                            --AND ISNULL(A.ScreenFlag,'U') NOT IN('U','')
                            AND ( A.RefCustomerID = v_CustomerId )
                            OR ( A.CustomerName LIKE '%' || v_CustomerName || '%' )
                            OR ( A.UCIF_ID = v_UCICID ) ) R
           ORDER BY MOC_Dt DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp1_10 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 16 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('113');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_122  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp2_19;
      UTILS.IDENTITY_RESET('tt_tmp2_19');

      INSERT INTO tt_tmp2_19 SELECT ROW_NUMBER() OVER ( ORDER BY MOCDate DESC  ) RowNumber  ,
                                    * 
           FROM ( SELECT A.CustomerID ,
                         A.CustomerName ,
                         B.UCIF_ID UCICID  ,
                         AuthorisationStatus ,
                         'CustomerLevel' TableName  ,
                         A.MOCDate 
                  FROM CustomerLevelMOC_Mod A
                         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerID = B.RefCustomerID
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                            AND NVL(A.ScreenFlag, 'G') NOT IN ( 'U' )
                 ) 
                --AND  (A.CustomerId=@CustomerId)

                --OR (A.CustomerName like '%' + @CustomerName+ '%')

                --OR (B.UCIF_ID=@UCICID)
                R
           ORDER BY MOCDate DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp2_19 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('114');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_123  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp3_4;
      UTILS.IDENTITY_RESET('tt_tmp3_4');

      INSERT INTO tt_tmp3_4 SELECT ROW_NUMBER() OVER ( ORDER BY MOCDate DESC  ) RowNumber  ,
                                   * 
           FROM ( SELECT A.CustomerID ,
                         A.CustomerName ,
                         B.UCIF_ID UCICID  ,
                         AuthorisationStatus ,
                         'CustomerLevel' TableName  ,
                         A.MOCDate 
                  FROM CustomerLevelMOC_Mod A
                         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerID = B.RefCustomerID
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                            AND NVL(A.ScreenFlag, 'G') NOT IN ( 'U' )
                 ) 
                --AND  (A.CustomerId=@CustomerId)

                --OR (A.CustomerName like '%' + @CustomerName+ '%')

                --OR (B.UCIF_ID=@UCICID)
                R
           ORDER BY MOCDate DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp3_4 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_08112021" TO "ADF_CDR_RBL_STGDB";
