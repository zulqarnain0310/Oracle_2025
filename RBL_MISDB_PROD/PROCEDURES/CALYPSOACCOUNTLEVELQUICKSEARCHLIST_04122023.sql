--------------------------------------------------------
--  DDL for Procedure CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" 
--IF OBJECT_ID('TempDB..#tmp') IS NOT NULL

(
  v_ACID IN VARCHAR2 DEFAULT '20517' ,
  v_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   v_Timekey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   v_InvestmentCustomerEntityID NUMBER(10,0) := 0;
   v_DerivativeCustomerEntityID NUMBER(10,0) := 0;
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
   SELECT IssuerEntityId 

     INTO v_InvestmentCustomerEntityID
     FROM InvestmentBasicDetail A
    WHERE  RefIssuerID = v_CustomerId
             AND A.EffectiveFromTimeKey <= v_Timekey
             AND A.EffectiveToTimeKey >= v_Timekey;
   DBMS_OUTPUT.PUT_LINE('@InvestmentCustomerEntityID');
   DBMS_OUTPUT.PUT_LINE(v_InvestmentCustomerEntityID);
   SELECT DerivativeEntityID 

     INTO v_DerivativeCustomerEntityID
     FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
    WHERE  DerivativeRefNo = v_CustomerId
             AND A.EffectiveFromTimeKey <= v_Timekey
             AND A.EffectiveToTimeKey >= v_Timekey;
   DBMS_OUTPUT.PUT_LINE('@DerivativeCustomerEntityID');
   DBMS_OUTPUT.PUT_LINE(v_DerivativeCustomerEntityID);
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
         IF utils.object_id('TempDB..tt_tmp2_12') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp2_12 ';
         END IF;
         DELETE FROM tt_tmp2_12;
         UTILS.IDENTITY_RESET('tt_tmp2_12');

         INSERT INTO tt_tmp2_12 SELECT * 
              FROM ( SELECT C.InvID ACID  ,
                            T.IssuerID RefCustomerId  ,
                            T.IssuerName CustomerName  ,
                            T.UcifId UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN '1st Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            A.CustomerEntityID ,
                            'CalypsoAccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM CalypsoInvMOC_ChangeDetails A
                          --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                            JOIN InvestmentIssuerDetail T   ON T.IssuerEntityID = A.CustomerEntityID
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                            JOIN InvestmentBasicDetail C   ON C.InvEntityId = A.AccountEntityID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND A.AuthorisationStatus = 'A'
                     UNION 

                     --AND  A.AccountEntityID NOT IN (SELECT AccountEntityID FROM CalypsoAccountLevelMOC_Mod 

                     --                         WHERE AuthorisationStatus IN ('MP','NP','1A')

                     -- AND EffectiveFromTimeKey<=@Timekey

                     --                         AND EffectiveToTimeKey >= @Timekey )

                     --OR A.CustomerEntityID=@CustomerEntityID

                     --and c.INVID=@ACID
                     SELECT T.DerivativeRefNo ACID  ,
                            T.CustomerID RefCustomerId  ,
                            T.CustomerName ,
                            T.UCIC_ID UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN '1st Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            0 CustomerEntityID  ,
                            'CalypsoAccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM CalypsoDervMOC_ChangeDetails A
                            JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON A.AccountEntityID = T.DerivativeEntityID
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND A.AuthorisationStatus = 'A'
                     UNION 

                     --AND  A.AccountEntityID NOT IN (SELECT AccountEntityID FROM CalypsoAccountLevelMOC_Mod 

                     --                         WHERE AuthorisationStatus IN ('MP','NP','1A')

                     -- AND EffectiveFromTimeKey<=@Timekey

                     --                         AND EffectiveToTimeKey >= @Timekey )

                     -- and T.DerivativeRefNo=@ACID
                     SELECT C.InvID ACID  ,
                            T.IssuerID RefCustomerId  ,
                            T.IssuerName CustomerName  ,
                            T.UcifId UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN '1st Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            0 CustomerEntityID  ,
                            'CalypsoAccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM CalypsoAccountLevelMOC_Mod A
                          --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                            JOIN InvestmentBasicDetail C   ON C.InvEntityId = A.AccountEntityID
                            AND A.AccountID = C.InvID
                            AND C.EffectiveFromTimeKey <= v_Timekey
                            AND C.EffectiveToTimeKey >= v_Timekey
                            JOIN InvestmentIssuerDetail T   ON T.IssuerEntityID = C.IssuerEntityId
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                               AND A.ScreenFlag <> 'U'
                     UNION 

                     --OR A.CustomerEntityID=@CustomerEntityID

                     --	and c.INVID=@ACID
                     SELECT T.DerivativeRefNo ACID  ,
                            T.CustomerID RefCustomerId  ,
                            T.CustomerName ,
                            T.UCIC_ID UCICID  ,
                            CASE 
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                  THEN '1st Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                                  THEN '2nd Approval Pending'
                                 WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                                  THEN 'Authorised'
                            ELSE 'No MOC Done'
                               END AuthorisationStatus  ,
                            v_ExtDate MOCMonthEndDate  ,
                            0 CustomerEntityID  ,
                            'CalypsoAccountLevel' TableName  ,
                            ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                             FROM DUAL  )  ) RowNumber  
                     FROM CalypsoAccountLevelMOC_Mod A
                            JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON A.AccountEntityID = T.DerivativeEntityID
                            AND T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                            AND A.AccountID = T.DerivativeRefNo
                      WHERE  A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                               AND A.ScreenFlag <> 'U' ) 
                   -- and T.DerivativeRefNo=@ACID
                   E;
         --Select 'tt_tmp2_12',* from tt_tmp2_12
         IF v_InvestmentCustomerEntityID <> 0 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_tmp2_12 
                WHERE  CustomerEntityID = v_InvestmentCustomerEntityID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF v_DerivativeCustomerEntityID <> 0 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM tt_tmp2_12 
                   WHERE  CustomerEntityID = v_DerivativeCustomerEntityID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         IF ( v_InvestmentCustomerEntityID IS NULL
           AND v_DerivativeCustomerEntityID IS NULL ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_tmp2_12  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
      END IF;
      IF ( v_OperationFlag IN ( 16 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SWAPNA 1');
         --select * from (
         OPEN  v_cursor FOR
            SELECT A.AccountID ACID  ,
                   C.IssuerID RefCustomerId  ,
                   C.IssuerName CustomerName  ,
                   C.UcifId UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN '1st Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoAccountLevel' TableName  ,
                   ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                    FROM DUAL  )  ) RowNumber  
              FROM CalypsoAccountLevelMOC_Mod A
                     JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvId
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_Timekey
                     JOIN InvestmentIssuerDetail C   ON B.IssuerEntityid = C.IssuerEntityid
                     AND C.EffectiveFromTimeKey <= v_Timekey
                     AND C.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','DP','RM' )

                      AND A.ScreenFlag <> 'U'
                      AND A.MOC_TypeFlag = 'ACCT'
            UNION 

            --and A.AccountID=@ACID
            SELECT A.AccountID ACID  ,
                   B.CustomerId RefCustomerId  ,
                   B.CustomerName ,
                   B.UCIC_ID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN '1st Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoAccountLevel' TableName  ,
                   ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                    FROM DUAL  )  ) RowNumber  
              FROM CalypsoAccountLevelMOC_Mod A
                   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                    --inner join Pro.customercal_hist B

                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountID = B.DerivativeRefNo
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','DP','RM' )

                      AND A.ScreenFlag <> 'U' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --and A.AccountID=@ACID
      --OR C.CustomerId=@CustomerId
      --   OR C.CustomerName like '%' + @CustomerName+ '%'
      --   OR C.UCIF_ID=@UCICID)
      -- ) A
      IF ( v_OperationFlag IN ( 20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SWAPNA 2');
         --select * from (
         OPEN  v_cursor FOR
            SELECT A.AccountID ACID  ,
                   C.IssuerID RefCustomerId  ,
                   C.IssuerName CustomerName  ,
                   C.UcifId UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN '1st Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoAccountLevel' TableName  ,
                   ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                    FROM DUAL  )  ) RowNumber  
              FROM CalypsoAccountLevelMOC_Mod A
                     JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvId
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_Timekey
                     JOIN InvestmentIssuerDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                     AND C.EffectiveFromTimeKey <= v_Timekey
                     AND C.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( '1A' )

                      AND A.ScreenFlag <> 'U'
                      AND A.MOC_TypeFlag = 'ACCT'
            UNION 

            --and A.AccountID=@ACID
            SELECT A.AccountID ACID  ,
                   C.CustomerId RefCustomerId  ,
                   C.CustomerName ,
                   C.UCIC_ID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN '1st Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoAccountLevel' TableName  ,
                   ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                    FROM DUAL  )  ) RowNumber  
              FROM CalypsoAccountLevelMOC_Mod A
                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail C   ON A.AccountID = C.DerivativeRefNo
                     AND C.EffectiveFromTimeKey <= v_Timekey
                     AND C.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( '1A' )

                      AND A.ScreenFlag <> 'U' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;

   --and A.AccountID=@ACID

   --AND  (A.AccountID=@ACID

   --OR B.RefCustomerId=@CustomerId

   --   OR B.CustomerName like '%' + @CustomerName+ '%'

   --   OR B.UCIF_ID=@UCICID)

   -- ) A

   --  and RowNumber BETWEEN @PageFrom AND @PageTo

   --order by 	RowNumber
   ELSE
   DECLARE
      v_InvestmentAccountEntityID NUMBER(10,0);
      v_DerivativeAccountEntityID NUMBER(10,0);

   BEGIN
      SELECT invEntityid 

        INTO v_InvestmentAccountEntityID
        FROM InvestmentBasicDetail A
       WHERE  InvID = v_ACID
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey;
      SELECT DerivativeEntityID 

        INTO v_DerivativeAccountEntityID
        FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
       WHERE  DerivativeRefNO = v_ACID
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
                            FROM CalypsoInvMOC_ChangeDetails 
                             WHERE  AccountEntityID = v_InvestmentAccountEntityID
                                      AND EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey
                                      AND AuthorisationStatus = 'A'
                            UNION 
                            SELECT 1 
                            FROM CalypsoDervMOC_ChangeDetails 
                             WHERE  AccountEntityID = v_DerivativeAccountEntityID
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
               SELECT C.InvID ACID  ,
                      T.IssuerID RefCustomerId  ,
                      T.IssuerName CustomerName  ,
                      T.UcifId UCICID  ,
                      CASE 
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                            THEN '1st Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                            THEN '2nd Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                            THEN 'Authorised'
                      ELSE 'No MOC Done'
                         END AuthorisationStatus  ,
                      v_ExtDate MOCMonthEndDate  ,
                      'CalypsoAccountLevel' TableName  ,
                      ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                       FROM DUAL  )  ) RowNumber  
                 FROM CalypsoInvMOC_ChangeDetails A
                      --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                        JOIN InvestmentIssuerDetail T   ON T.IssuerEntityId = A.CustomerEntityID
                        AND T.EffectiveFromTimeKey <= v_Timekey
                        AND T.EffectiveToTimeKey >= v_Timekey
                        JOIN InvestmentBasicDetail C   ON C.InvEntityId = A.AccountEntityID
                        AND C.EffectiveFromTimeKey <= v_Timekey
                        AND C.EffectiveToTimeKey >= v_Timekey
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus = 'A'
                         AND A.AccountEntityID = v_InvestmentAccountEntityID
                         AND C.iNVID = v_ACID
               UNION 
               SELECT C.DerivativeRefNo ACID  ,
                      C.CustomerId RefCustomerId  ,
                      C.CustomerName ,
                      C.UCIC_ID UCICID  ,
                      CASE 
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                            THEN '1st Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                            THEN '2nd Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                            THEN 'Authorised'
                      ELSE 'No MOC Done'
                         END AuthorisationStatus  ,
                      v_ExtDate MOCMonthEndDate  ,
                      'CalypsoAccountLevel' TableName  ,
                      ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                       FROM DUAL  )  ) RowNumber  
                 FROM CalypsoDervMOC_ChangeDetails A
                        JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail C   ON C.DerivativeEntityID = A.AccountEntityID
                        AND C.EffectiveFromTimeKey <= v_Timekey
                        AND C.EffectiveToTimeKey >= v_Timekey
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus = 'A'
                         AND A.AccountEntityID = v_DerivativeAccountEntityID
                         AND C.DerivativeRefNo = v_ACID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CalypsoAccountLevelMOC_Mod 
                                WHERE  AccountEntityID = v_InvestmentAccountEntityID
                                         AND EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey
                                         AND AuthorisationStatus IN ( 'MP','NP','1A' )

                               UNION 
                               SELECT 1 
                               FROM CalypsoAccountLevelMOC_Mod 
                                WHERE  AccountEntityID = v_DerivativeAccountEntityID
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
                         C.IssuerID RefCustomerId  ,
                         C.IssuerName CustomerName  ,
                         C.UcifId UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         v_ExtDate MOCMonthEndDate  ,
                         'CalypsoAccountLevel' TableName  ,
                         ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) RowNumber  
                    FROM CalypsoAccountLevelMOC_Mod A
                         --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                          --inner join Pro.customercal_hist B

                           JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvId
                           AND B.EffectiveFromTimeKey <= v_Timekey
                           AND B.EffectiveToTimeKey >= v_Timekey
                           JOIN InvestmentIssuerDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'MP','NP','1A' )

                            AND NVL(A.ScreenFlag, 'S') NOT IN ( 'U' )

                            AND A.AccountEntityID = v_InvestmentAccountEntityID
                            AND A.AccountID = v_ACID
                  UNION 
                  SELECT A.AccountID ACID  ,
                         B.CustomerId RefCustomerId  ,
                         B.CustomerName ,
                         B.UCIC_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         v_ExtDate MOCMonthEndDate  ,
                         'CalypsoAccountLevel' TableName  ,
                         ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) RowNumber  
                    FROM CalypsoAccountLevelMOC_Mod A
                         --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
                          --inner join Pro.customercal_hist B

                           JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountID = B.DerivativeRefNo
                           AND B.EffectiveFromTimeKey <= v_Timekey
                           AND B.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND NVL(A.AuthorisationStatus, 'A') IN ( 'MP','NP','1A' )

                            AND NVL(A.ScreenFlag, 'S') NOT IN ( 'U' )

                            AND A.AccountEntityID = v_DerivativeAccountEntityID
                            AND A.AccountID = v_ACID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('AKSHAY3');
               OPEN  v_cursor FOR
                  SELECT DISTINCT B.InvID ACID  ,
                                  C.IssuerID RefCustomerId  ,
                                  C.IssuerName CustomerName  ,
                                  C.UcifId UCICID  ,
                                  --  ,'No MOC Done' AuthorisationStatus 
                                  CASE 
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                        THEN '1st Approval Pending'
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'A' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CalypsoAccountLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM InvestmentBasicDetail B
                           JOIN InvestmentIssuerDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey
                   WHERE  B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey

                            --AND    B.InvEntityId=@AccountEntityID
                            AND b.InvID = v_ACID
                  UNION 
                  SELECT DISTINCT B.DerivativeRefNo ACID  ,
                                  B.CustomerID RefCustomerId  ,
                                  B.CustomerName ,
                                  B.UCIC_ID UCICID  ,
                                  --,'No MOC Done' AuthorisationStatus 
                                  CASE 
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                        THEN '1st Approval Pending'
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'A' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CalypsoAccountLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM CurDat_RBL_MISDB_PROD.DerivativeDetail B
                   WHERE  B.EffectiveFromTimeKey <= v_Timekey
                            AND B.EffectiveToTimeKey >= v_Timekey

                            --AND    B.DerivativeEntityID=@AccountEntityID
                            AND B.DerivativeRefNo = v_ACID ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
