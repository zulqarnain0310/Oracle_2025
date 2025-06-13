--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELQUICKSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" 
--IF OBJECT_ID('TempDB..#tmp') IS NOT NULL

(
  v_ACID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   v_Timekey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   v_CustomerEntityID NUMBER(10,0) := 0;
   v_ExtDate VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   v_PageFrom := (v_pageSize * v_newPage) - (v_pageSize) + 1 ;
   v_PageTo := v_pageSize * v_newPage ;
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  NVL(MOC_Initialised, 'N') = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT DISTINCT ExtDate 

     INTO v_ExtDate
     FROM SysDataMatrix 
    WHERE  NVL(MOC_Initialised, 'N') = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT CustomerEntityID 

     INTO v_CustomerEntityID
     FROM CustomerBasicDetail A
    WHERE  CustomerId = v_CustomerId
             AND A.EffectiveFromTimeKey <= v_Timekey
             AND A.EffectiveToTimeKey >= v_Timekey;
   DBMS_OUTPUT.PUT_LINE('@CustomerEntityID');
   DBMS_OUTPUT.PUT_LINE(v_CustomerEntityID);
   --print @Timekey
   --DROP TABLE IF EXISTS #TEmp
   --select A.AccountID,AuthorisationStatus into #Temp from Accountlevelmoc_mod A
   --inner join(
   --select max(EntityKey) EntityKey,AccountID 
   --                                 from Accountlevelmoc_mod
   --                                 where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey
   --								 group by AccountID)B on B.EntityKey=A.EntityKey
   --Select '#TEmp', * from #TEmp
   IF ( ( v_ACID = ' '
     OR v_ACID IS NULL ) ) THEN

   BEGIN
      IF ( v_operationflag NOT IN ( 16,20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('111');
         DBMS_OUTPUT.PUT_LINE('SWAPNA');
         IF utils.object_id('TempDB..tt_tmp2_7') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp2_7 ';
         END IF;
         DELETE FROM tt_tmp2_7;
         UTILS.IDENTITY_RESET('tt_tmp2_7');

         INSERT INTO tt_tmp2_7 SELECT * 
              FROM ( SELECT DISTINCT C.CustomerACID ACID  ,
                                     T.CustomerId RefCustomerId  ,
                                     T.CustomerName ,
                                     T.UCIF_ID UCICID  ,
                                     CASE 
                                          WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                           THEN 'Pending'
                                          WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                           THEN '2nd Approval Pending'
                                          WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                           THEN 'Authorised'
                                     ELSE 'No MOC Done'
                                        END AuthorisationStatus  ,
                                     v_ExtDate MOCMonthEndDate  ,
                                     A.CustomerEntityID ,
                                     'AccountLevel' TableName  ,
                                     ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                      FROM DUAL  )  ) RowNumber  
                     FROM MOC_ChangeDetails A
                          --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                            JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                            JOIN AdvAcBasicDetail C   ON C.AccountEntityId = A.AccountEntityID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND A.AuthorisationStatus = 'A'
                               AND A.AccountEntityID NOT IN ( SELECT AccountEntityID 
                                                              FROM AccountLevelMOC_Mod 
                                                               WHERE  AuthorisationStatus IN ( 'MP','NP','1A' )

                                                                        AND EffectiveFromTimeKey <= v_Timekey
                                                                        AND EffectiveToTimeKey >= v_Timekey )

                     UNION 

                     --OR A.CustomerEntityID=@CustomerEntityID
                     SELECT A.AccountID ACID  ,
                            T.CustomerID RefCustomerId  ,
                            T.CustomerName ,
                            T.UCIF_ID UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN 'Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            0 CustomerEntityID  ,
                            'AccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM AccountLevelMOC_Mod A
                          --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                            JOIN AdvAcBasicDetail C   ON C.AccountEntityId = A.AccountEntityID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                            JOIN CustomerBasicDetail T   ON T.CustomerEntityId = C.CustomerEntityID
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey

                     --LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
                     WHERE  A.EffectiveFromTimeKey <= v_Timekey
                              AND A.EffectiveToTimeKey >= v_Timekey
                              AND A.AuthorisationStatus IN ( 'MP','NP','1A' )
                    ) E;
         --Select 'tt_tmp2_7',* from tt_tmp2_7
         IF v_CustomerEntityID <> 0 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_tmp2_7 
                WHERE  CustomerEntityID = v_CustomerEntityID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_CustomerEntityID IS NULL THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_tmp2_7  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
      END IF;
      IF ( v_OperationFlag IN ( 16 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SWAPNA 1');
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT A.AccountID ACID  ,
                            C.CustomerId RefCustomerId  ,
                            C.CustomerName ,
                            C.UCIF_ID UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN 'Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            'AccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM AccountLevelMOC_Mod A
                          --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                           --inner join Pro.customercal_hist B

                            JOIN AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityId
                            AND B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                            JOIN CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND NVL(A.AuthorisationStatus, 'A') IN ( 'MP','NP','DP','RM' )

                               AND NVL(A.ScreenFlag, 'S') NOT IN ( 'U' )
                    ) 
                   --OR C.CustomerId=@CustomerId

                   --   OR C.CustomerName like '%' + @CustomerName+ '%'

                   --   OR C.UCIF_ID=@UCICID)
                   A
             WHERE  RowNumber BETWEEN v_PageFrom AND v_PageTo
              ORDER BY RowNumber ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_OperationFlag IN ( 20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SWAPNA 2');
         OPEN  v_cursor FOR
            SELECT * 
              FROM ( SELECT A.AccountID ACID  ,
                            C.CustomerId RefCustomerId  ,
                            C.CustomerName ,
                            C.UCIF_ID UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN 'Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            'AccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM AccountLevelMOC_Mod A
                          --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                           --inner join Pro.customercal_hist B
                           --                ON C.RefCustomerID=B.Refcustomerid
                           --                AND B.EffectiveFromTimeKey <= @Timekey
                           --                AND B.EffectiveToTimeKey >= @Timekey

                            JOIN AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityId
                            AND B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                            JOIN CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                               AND NVL(A.ScreenFlag, 'S') NOT IN ( 'U' )
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

   END;
   ELSE
   DECLARE
      v_AccountEntityID NUMBER(10,0);

   BEGIN
      SELECT AccountEntityId 

        INTO v_AccountEntityID
        FROM AdvAcBasicDetail A
       WHERE  CustomerACID = v_ACID
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey;
      IF ( v_operationflag NOT IN ( 16,20 )
       )
        AND ( v_ACID <> ' '
        OR v_ACID <> NULL ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM MOC_ChangeDetails 
                             WHERE  AccountEntityID = v_AccountEntityID
                                      AND EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey
                                      AND AuthorisationStatus = 'A' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('111');
            DBMS_OUTPUT.PUT_LINE('45');
            DBMS_OUTPUT.PUT_LINE('SWAPNA 3');
            OPEN  v_cursor FOR
               SELECT DISTINCT C.CustomerACID ACID  ,
                               T.CustomerId RefCustomerId  ,
                               T.CustomerName ,
                               T.UCIF_ID UCICID  ,
                               CASE 
                                    WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                     THEN 'Pending'
                                    WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                     THEN '2nd Approval Pending'
                                    WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                     THEN 'Authorised'
                               ELSE 'No MOC Done'
                                  END AuthorisationStatus  ,
                               v_ExtDate MOCMonthEndDate  ,
                               'AccountLevel' TableName  ,
                               ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                FROM DUAL  )  ) RowNumber  
                 FROM MOC_ChangeDetails A
                      --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                        JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                        AND T.EffectiveFromTimeKey <= v_Timekey
                        AND T.EffectiveToTimeKey >= v_Timekey
                        JOIN AdvAcBasicDetail C   ON C.AccountEntityId = A.AccountEntityID
                        AND C.EffectiveFromTimeKey <= v_Timekey
                        AND C.EffectiveToTimeKey >= v_Timekey
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus = 'A'
                         AND A.AccountEntityID = v_AccountEntityID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM AccountLevelMOC_Mod 
                                WHERE  AccountEntityID = v_AccountEntityID
                                         AND EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey
                                         AND AuthorisationStatus IN ( 'MP','NP','1A' )
             );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SWAPNA 4');
               OPEN  v_cursor FOR
                  SELECT A.AccountID ACID  ,
                         C.CustomerId RefCustomerId  ,
                         C.CustomerName ,
                         C.UCIF_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN 'Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         v_ExtDate MOCMonthEndDate  ,
                         'AccountLevel' TableName  ,
                         ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) RowNumber  
                    FROM AccountLevelMOC_Mod A
                         --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                          --inner join Pro.customercal_hist B

                           JOIN AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityId
                           AND B.EffectiveFromTimeKey <= v_Timekey
                           AND B.EffectiveToTimeKey >= v_Timekey
                           JOIN CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'MP','NP','1A' )

                            AND NVL(A.ScreenFlag, 'S') NOT IN ( 'U' )

                            AND A.AccountEntityID = v_AccountEntityID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('AKSHAY3');
               OPEN  v_cursor FOR
                  SELECT DISTINCT B.CustomerACID ACID  ,
                                  C.CustomerID RefCustomerId  ,
                                  C.CustomerName ,
                                  C.UCIF_ID UCICID  ,
                                  'No MOC Done' AuthorisationStatus  ,
                                  'AccountLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM AdvAcBasicDetail B
                           JOIN CustomerBasicDetail C   ON B.CustomerEntityId = C.CustomerEntityId
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                   WHERE  B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey
                            AND B.AccountEntityId = v_AccountEntityID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
