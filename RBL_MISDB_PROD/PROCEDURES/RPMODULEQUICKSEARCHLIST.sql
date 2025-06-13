--------------------------------------------------------
--  DDL for Procedure RPMODULEQUICKSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" 
--[RPModuleQuickSearchList]  'AP00007193','',2,1,1000

(
  iv_CustomerId IN VARCHAR2 DEFAULT '60' ,
  iv_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   --declare
   v_CustomerId VARCHAR2(20) := iv_CustomerId;
   --,@CustomerName VARCHAR(100)=''
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
   --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
   IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
      ACLProcessStatusCheck() ;

   END;
   END IF;
   ---select customerid and auth status
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_107  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_Temp_107;
   UTILS.IDENTITY_RESET('tt_Temp_107');

   INSERT INTO tt_Temp_107 ( 
   	SELECT A.CustomerID ,
           AuthorisationStatus 
   	  FROM RP_Portfolio_Details_Mod A
             JOIN ( SELECT MAX(EntityKey)  Entity_Key  ,
                           CustomerID 
                    FROM RP_Portfolio_Details_Mod 
                     WHERE  EffectiveFromTimeKey <= v_Timekey
                              AND EffectiveToTimeKey >= v_Timekey --AND ISNULL(ScreenFlag,'U') NOT IN('U','')

                              AND AuthorisationStatus IN ( 'NP','MP','1A' )

                      GROUP BY CustomerID ) B   ON B.Entity_Key = A.EntityKey );
   --AND  (@CustomerName='')
   IF ( ( NVL(v_CustomerId, ' ') = ' ' )
     AND ( NVL(v_UCICID, ' ') = ' ' )
     AND ( v_operationflag NOT IN ( 16,20 )
    ) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('111');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_16  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp_16;
      UTILS.IDENTITY_RESET('tt_tmp_16');

      INSERT INTO tt_tmp_16 SELECT ROW_NUMBER() OVER ( ORDER BY CustomerId DESC  ) RowNumber  ,
                                   * 
           FROM ( SELECT DISTINCT A.CustomerID ,
                                  B.CustomerName ,
                                  B.UCIF_ID UCICID  ,
                                  A.ExposureBucketAlt_Key ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN A.ReferenceDate
                                  ELSE NULL
                                     END ReferenceDate  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No RP Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details A
                         LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerID = B.CustomerId
                       --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key

                         LEFT JOIN tt_Temp_107 T   ON T.CustomerID = A.CustomerID

                  --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId

                  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
                  WHERE  A.EffectiveFromTimeKey <= v_Timekey
                           AND A.EffectiveToTimeKey >= v_Timekey
                           AND NVL(T.AuthorisationStatus, 'A') = 'A'
                           AND NVL(IsActive, 'N') = 'Y'
                  UNION 
                  SELECT DISTINCT A.CustomerID ,
                                  B.CustomerName ,
                                  B.UCIF_ID UCICID  ,
                                  A.ExposureBucketAlt_Key ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN A.ReferenceDate
                                  ELSE NULL
                                     END ReferenceDate  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No RP Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details_Mod A
                         LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerID = B.CustomerId
                       --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key

                         LEFT JOIN tt_Temp_107 T   ON T.CustomerID = A.CustomerID

                  --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId

                  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
                  WHERE  A.EffectiveFromTimeKey <= v_Timekey
                           AND A.EffectiveToTimeKey >= v_Timekey
                           AND NVL(T.AuthorisationStatus, 'A') IN ( 'MP','NP','1A' )

                           AND NVL(IsActive, 'N') = 'Y' ) 
                --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
                X
           ORDER BY X.CustomerId DESC;
      OPEN  v_cursor FOR
         SELECT 'tt_tmp_16' ,
                * 
           FROM tt_tmp_16  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --Select * from tt_tmp_16
      --WHERE RowNumber BETWEEN @PageFrom AND @PageTo
      DBMS_OUTPUT.PUT_LINE('sac1');
      RETURN;
      DBMS_OUTPUT.PUT_LINE('sac2');

   END;
   END IF;
   IF v_CustomerId = ' ' THEN
    v_CustomerId := NULL ;
   END IF;
   IF v_UCICID = ' ' THEN
    v_UCICID := NULL ;
   END IF;
   DBMS_OUTPUT.PUT_LINE('1');
   IF ( v_OperationFlag NOT IN ( 16,20 )
    ) THEN
    DECLARE
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_164  --SQLDEV: NOT RECOGNIZED
      v_RecordCount NUMBER(10,0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('112');
      DELETE FROM tt_tmp4;
      UTILS.IDENTITY_RESET('tt_tmp4');

      INSERT INTO tt_tmp4 SELECT ROW_NUMBER() OVER ( ORDER BY CustomerId DESC  ) RowNumber  ,
                                 * 
           FROM ( SELECT DISTINCT A.CustomerID ,
                                  A.CustomerName ,
                                  A.UCIC_ID UCICID  ,
                                  A.ExposureBucketAlt_Key ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN A.ReferenceDate
                                  ELSE NULL
                                     END ReferenceDate  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No RP Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details A
                       --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key

                         LEFT JOIN tt_Temp_107 T   ON T.CustomerID = A.CustomerID

                  --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId

                  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
                  WHERE  A.EffectiveFromTimeKey <= v_Timekey
                           AND A.EffectiveToTimeKey >= v_Timekey
                           AND NVL(IsActive, 'N') = 'Y'
                           AND ( A.CustomerID = v_CustomerId )
                           OR ( A.UCIC_ID = v_UCICID )
                  UNION 
                  SELECT DISTINCT A.CustomerID ,
                                  A.CustomerName ,
                                  A.UCIC_ID UCICID  ,
                                  A.ExposureBucketAlt_Key ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN A.ReferenceDate
                                  ELSE NULL
                                     END ReferenceDate  ,
                                  CASE 
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'FM','MP','NP' )
                                        THEN 'Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(T.AuthorisationStatus, 'A') IN ( 'A','R' )
                                        THEN 'Authorised'
                                  ELSE 'No RP Done'
                                     END AuthorisationStatus  ,
                                  'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details_Mod A
                       --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key

                         LEFT JOIN tt_Temp_107 T   ON T.CustomerID = A.CustomerID

                  --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId

                  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
                  WHERE  A.EffectiveFromTimeKey <= v_Timekey
                           AND A.EffectiveToTimeKey >= v_Timekey
                           AND NVL(IsActive, 'N') = 'Y'
                           AND ( A.CustomerID = v_CustomerId )
                           OR ( A.UCIC_ID = v_UCICID ) ) 
                --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
                X
           ORDER BY X.CustomerId DESC;
      SELECT COUNT(*)  

        INTO v_RecordCount
        FROM tt_tmp4 ;
      IF v_RecordCount > 0 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('@RecordCountGreater');
         DBMS_OUTPUT.PUT_LINE(v_RecordCount);
         OPEN  v_cursor FOR
            SELECT * 
              FROM tt_tmp4 
             WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_RecordCount <= 0 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('@RecordCountLess');
         DBMS_OUTPUT.PUT_LINE(v_RecordCount);
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_tmp_161  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_tmp1_14;
         UTILS.IDENTITY_RESET('tt_tmp1_14');

         INSERT INTO tt_tmp1_14 SELECT ROW_NUMBER() OVER ( ORDER BY CustomerId DESC  ) RowNumber  ,
                                       * 
              FROM ( SELECT DISTINCT A.CustomerId CustomerID  ,
                                     A.CustomerName ,
                                     A.UCIF_ID UCICID  ,
                                     NULL ExposureBucketAlt_Key  ,
                                     'CustomerLevel' TableName  
                     FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail A
                            LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerId = B.RefCustomerId

                     --Left join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
                     WHERE  A.EffectiveFromTimeKey <= v_Timekey
                              AND A.EffectiveToTimeKey >= v_Timekey

                              --AND ISNULL(A.ScreenFlag,'U') NOT IN('U','')
                              AND ( A.CustomerID = v_CustomerId )

                              --OR ( B.CustomerName like '%' + @CustomerName+ '%')
                              OR ( A.UCIF_ID = v_UCICID ) ) R
              ORDER BY CustomerId DESC;
         DBMS_OUTPUT.PUT_LINE('RPModule');
         --Select '#tt_tmp_161', * from tt_tmp_161
         OPEN  v_cursor FOR
            SELECT * 
              FROM tt_tmp1_14 
             WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   IF ( v_OperationFlag IN ( 16 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('113');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_162  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp2_23;
      UTILS.IDENTITY_RESET('tt_tmp2_23');

      INSERT INTO tt_tmp2_23 SELECT ROW_NUMBER() OVER ( ORDER BY CustomerId DESC  ) RowNumber  ,
                                    * 
           FROM ( SELECT A.CustomerID ,
                         A.CustomerName ,
                         A.UCIC_ID UCICID  ,
                         AuthorisationStatus ,
                         'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details_Mod A
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                            AND NVL(IsActive, 'N') = 'Y' ) 
                --AND  (A.CustomerId=@CustomerId)

                --OR (A.CustomerName like '%' + @CustomerName+ '%')

                --OR (B.UCIF_ID=@UCICID)
                R
           ORDER BY CustomerId DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp2_23 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('114');
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_tmp_163  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_tmp3_8;
      UTILS.IDENTITY_RESET('tt_tmp3_8');

      INSERT INTO tt_tmp3_8 SELECT ROW_NUMBER() OVER ( ORDER BY CustomerId DESC  ) RowNumber  ,
                                   * 
           FROM ( SELECT A.CustomerID ,
                         A.CustomerName ,
                         A.UCIC_ID UCICID  ,
                         AuthorisationStatus ,
                         'CustomerLevel' TableName  
                  FROM RP_Portfolio_Details_Mod A
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                            AND NVL(IsActive, 'N') = 'Y' ) 
                --AND  (A.CustomerId=@CustomerId)

                --OR (A.CustomerName like '%' + @CustomerName+ '%')

                --OR (B.UCIF_ID=@UCICID)
                R
           ORDER BY CustomerId DESC;
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp3_8 
          WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPMODULEQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
