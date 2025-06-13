--------------------------------------------------------
--  DDL for Procedure CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --USE [USFB_ENPADB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CalypsoCustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --DROP PROCEDURE [dbo].[CalypsoCustomerLevelQuickSearchList]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CalypsoCustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 --exec CalypsoCustomerLevelQuickSearchList @CustomerId=N'22552793',@CustomerName=N'',@UCICID=N'',@OperationFlag=2,@newPage=1,@pageSize=1000
 --go
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --declare--@UCICID VARCHAR(20)=''
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
   v_ExtDate VARCHAR2(200);
   --AND  A.UCICID NOT IN (SELECT UcifId FROM CalypsoCustomerLevelMOC_Mod 
   --                                WHERE AuthorisationStatus IN ('MP','NP','1A')
   --					   AND EffectiveFromTimeKey<=@Timekey
   --                                AND EffectiveToTimeKey >= @Timekey  )
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
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   ---select customerid and auth status
   --	Drop Table  IF Exists #Temp
   --	select A.CustomerID,AuthorisationStatus into #Temp 
   --	from Customerlevelmoc_mod  A
   --	inner join(
   --SELECT MAX(Entity_Key) Entity_Key,CustomerID
   --                                        FROM Customerlevelmoc_mod
   --                                         WHERE EffectiveFromTimeKey <= @Timekey
   --                                             AND EffectiveToTimeKey >= @Timekey --AND ISNULL(ScreenFlag,'U') NOT IN('U','')
   --                                     GROUP BY CustomerID) B on B.Entity_Key=A.Entity_Key 
   ----Select '#Temp',* from #Temp
   IF ( v_UCICID = ' '
     OR v_UCICID IS NULL ) THEN

   BEGIN
      IF ( v_operationflag NOT IN ( 16,20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('111');
         DBMS_OUTPUT.PUT_LINE('54');
         --		DROP TABLE IF EXISTS #TEmp
         --select A.CustomerEntityID,AuthorisationStatus into #Temp from CustomerLevelMOC_Mod A
         --inner join(
         --select max(Entity_Key) EntityKey,CustomerEntityID 
         --                                 from CustomerLevelMOC_Mod
         --                                 where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey
         --								 group by CustomerEntityID)B on B.EntityKey=A.Entity_Key
         OPEN  v_cursor FOR
            SELECT T.UcifId UCICID  ,
                   T.IssuerName CustomerName  ,
                   T.UcifId UCI_A3  ,
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
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoInvMOC_ChangeDetails A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN InvestmentIssuerDetail T
                   -- T.IssuerEntityID=A.CustomerEntityid
                    --- T.UcifId=@UCICID
                      ON T.UcifId = A.UCICID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.MOCType_Flag = 'CUST'
                      AND A.AuthorisationStatus = 'A'
            UNION 
            SELECT T.UCIC_ID UCICID  ,
                   T.CustomerName CustomerName  ,
                   T.UCIC_ID UCI_A3  ,
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
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoDervMOC_ChangeDetails A
                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.UCIC_ID = A.UCICID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.MOCType_Flag = 'CUST'
                      AND A.AuthorisationStatus = 'A'
            UNION 

            ----AND  A.UCICID NOT IN (SELECT A.UCICID FROM CalypsoCustomerLevelMOC_Mod 

            ----                                WHERE AuthorisationStatus IN ('MP','NP','1A')

            ----					   AND EffectiveFromTimeKey<=@Timekey

            ----                                AND EffectiveToTimeKey >= @Timekey  )

            --AND ISNULL(ScreenFlag,'U') NOT IN('U','')

            --and t.IssuerId=@customerid 

            --and t.UcifId=@UCICID 

            --AND t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' 

            --and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
            SELECT T.IssuerID ,
                   T.IssuerName ,
                   T.UcifId UCICID  ,
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
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN InvestmentIssuerDetail T   ON T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
                     AND T.UcifId = A.UCIFID
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                      AND A.ScreenFlag <> 'U'
            UNION 

            --and t.customerid=@CustomerId 

            --and t.UcifId=@UCICID 
            SELECT T.CustomerId ,
                   T.CustomerName ,
                   T.UCIC_ID UCICID  ,
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
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
                     AND T.UCIC_ID = A.UCIFID
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                      AND A.ScreenFlag <> 'U' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --and t.customerid=@CustomerId 
      --and t.UCIC_ID=@UCICID 
      --AND t.CustomerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.CustomerId ELSE @CustomerId END+'%' 
      --and t.Ucic_Id LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.Ucic_Id ELSE @UCICID  END+'%' 
      --	select * from (
      --select distinct 
      --		   B.CustomerId
      --		   ,B.CustomerName
      --		   ,B.UCIF_ID as UCICID
      --		    ,case when C.AuthorisationStatus IN ('FM','MP','NP')
      --		         then 'Pending'
      --				 when C.AuthorisationStatus IN ('A','R')
      --				 Then 'Authorise'
      --				 else 'No MOC Done ' End As AuthorisationStatus 
      --		   ,'CustomerLevel' as TableName
      --		   ,Row_Number()over (order by (select 1)) RowNumber 
      --	 from MOC_ChangeDetails A
      --			 --inner join Pro.customercal_hist B ON A.CustomerEntityId=B.CustomerEntityId 
      --			 inner join CURDAT.CustomerBasicDetail B ON A.CustomerEntityId=B.CustomerEntityId 
      --			 AND B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey
      --			 --INNER JOIN Accountlevelmoc_mod C ON C.AccountID=A.CustomerAcID
      --			 LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
      --	 Where A.EffectiveFromTimeKey <= @Timekey
      --		   AND A.EffectiveToTimeKey >= @Timekey
      --		   --and C.EffectiveFromTimeKey <= @Timekey
      --		   --AND c.EffectiveToTimeKey >= @Timekey
      --		   ) A
      IF ( v_OperationFlag IN ( 16 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('113');
         DBMS_OUTPUT.PUT_LINE('SA');
         OPEN  v_cursor FOR
            SELECT T.IssuerID CustomerId  ,
                   T.IssuerName CustomerName  ,
                   T.UCIFID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN 'Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN InvestmentIssuerDetail T   ON T.UcifId = A.UCIfID

                     --T.IssuerEntityID=A.CustomerEntityID 
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','DP','RM' )

                      AND A.ScreenFlag <> 'U'
                      AND A.MOCType_Flag = 'CUST'
            UNION 

            --and t.IssuerId=@customerid

            -- and t.UcifId=@UCICID 

            --AND t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' 

            --and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
            SELECT T.CustomerId ,
                   T.CustomerName ,
                   T.UCIC_ID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN 'Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
                     AND T.UCIC_ID = A.UcifID
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','DP','RM' )

                      AND A.ScreenFlag <> 'U' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      ---and t.customerid=@customerid 
      --and t.Ucic_Id=@UCICID 
      --AND t.CustomerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.CustomerId ELSE @CustomerId END+'%' 
      -- and t.Ucic_Id LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.Ucic_Id ELSE @UCICID  END+'%' 
      IF ( v_OperationFlag IN ( 20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('114');
         OPEN  v_cursor FOR
            SELECT T.IssuerID CustomerId  ,
                   T.IssuerName CustomerName  ,
                   T.UCIFID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN 'Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN InvestmentIssuerDetail T   ON T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
                     AND T.UcifId = A.UcifID
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( '1A' )

                      AND A.ScreenFlag <> 'U'
                      AND A.MOCType_Flag = 'CUST'
            UNION 

            --and IssuerId=@customerid 

            ---- and t.UcifId=@UCICID 

            --AND t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' 

            -- and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
            SELECT T.CustomerId ,
                   T.CustomerName ,
                   T.UCIC_ID UCICID  ,
                   CASE 
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                         THEN 'Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                         THEN '2nd Approval Pending'
                        WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                         THEN 'Authorised'
                   ELSE 'No MOC Done'
                      END AuthorisationStatus  ,
                   v_ExtDate MOCMonthEndDate  ,
                   'CalypsoCustomerLevel' TableName  
              FROM CalypsoCustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
                     AND T.UCIC_ID = A.UcifID
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( '1A' )

                      AND A.ScreenFlag <> 'U' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;

   --and t.customerid=@customerid  

   ---	and t.Ucic_Id=@UCICID 

   --AND t.CustomerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.CustomerId ELSE @CustomerId END+'%' 

   -- and t.Ucic_Id LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.Ucic_Id ELSE @UCICID  END+'%' 
   ELSE
   DECLARE
      v_CustomerEntityID NUMBER(10,0);


   ---aaaa
   BEGIN
      SELECT IssuerEntityID 

        INTO v_CustomerEntityID
        FROM InvestmentIssuerDetail A
       WHERE  A.UcifId = v_UCICID
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey;
      DBMS_OUTPUT.PUT_LINE('Sac1');
      IF ( v_operationflag NOT IN ( 16,20 )
       )
        AND ( v_UCICID <> ' '
        OR v_UCICID <> NULL ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM CalypsoInvMOC_ChangeDetails 
                             WHERE  CustomerEntityID = v_CustomerEntityID
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
            OPEN  v_cursor FOR
               SELECT T.IssuerID CustomerId  ,
                      T.IssuerName CustomerName  ,
                      T.UCIFID UCICID  ,
                      CASE 
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                            THEN 'Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                            THEN '2nd Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                            THEN 'Authorised'
                      ELSE 'No MOC Done'
                         END AuthorisationStatus  ,
                      v_ExtDate MOCMonthEndDate  ,
                      'CalypsoCustomerLevel' TableName  
                 FROM CalypsoInvMOC_ChangeDetails A
                      --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                        JOIN InvestmentIssuerDetail T   ON T.UcifId = v_UCICID
                        AND T.EffectiveFromTimeKey <= v_Timekey
                        AND T.EffectiveToTimeKey >= v_Timekey
                        AND T.UcifId = v_UCICID
                        AND T.UcifId = A.UCICID
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus = 'A'
                         AND A.MOCType_Flag = 'CUST'
                         AND T.UcifId = v_UCICID

                         --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')

                         -- and IssuerId=@customerid
                         AND t.UcifId = v_UCICID
               UNION 

               --AND t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' 

               -- and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
               SELECT T.CustomerId ,
                      T.CustomerName ,
                      T.UCIC_ID UCICID  ,
                      CASE 
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                            THEN 'Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                            THEN '2nd Approval Pending'
                           WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                            THEN 'Authorised'
                      ELSE 'No MOC Done'
                         END AuthorisationStatus  ,
                      v_ExtDate MOCMonthEndDate  ,
                      'CalypsoCustomerLevel' TableName  
                 FROM CalypsoCustomerLevelMOC_Mod A
                      --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                        JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.UCIC_ID = v_UCICID
                        AND T.EffectiveFromTimeKey <= v_Timekey
                        AND T.EffectiveToTimeKey >= v_Timekey
                        AND T.UCIC_ID = A.UcifID
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus IN ( 'A' )


                         --and t.CustomerID =@CustomerId 
                         AND t.Ucic_Id = v_UCICID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --AND t.CustomerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.CustomerId ELSE @CustomerId END+'%' 

         -- and t.Ucic_Id LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.Ucic_Id ELSE @UCICID  END+'%' 
         ELSE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CalypsoCustomerLevelMOC_Mod 
                                WHERE  CustomerEntityID = v_CustomerEntityID
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
               DBMS_OUTPUT.PUT_LINE('Sac2');
               OPEN  v_cursor FOR
                  SELECT T.IssuerID CustomerId  ,
                         T.IssuerName CustomerName  ,
                         T.UCIFID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                               THEN 'Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         v_ExtDate MOCMonthEndDate  ,
                         'CalypsoCustomerLevel' TableName  
                    FROM CalypsoCustomerLevelMOC_Mod A
                         --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                           JOIN InvestmentIssuerDetail T   ON T.UcifId = v_UCICID
                           AND T.EffectiveFromTimeKey <= v_Timekey
                           AND T.EffectiveToTimeKey >= v_Timekey
                           AND T.UcifId = A.UcifID
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                            AND A.ScreenFlag <> 'U'
                            AND A.MOCType_Flag = 'CUST'

                            --AND A.CustomerId=@CustomerId
                            AND t.UcifId = v_UCICID
                  UNION 

                  --AND t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' 

                  -- and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
                  SELECT T.CustomerId ,
                         T.CustomerName ,
                         T.UCIC_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'FM','MP','NP' )
                               THEN 'Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A','R' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         v_ExtDate MOCMonthEndDate  ,
                         'CalypsoCustomerLevel' TableName  
                    FROM CalypsoCustomerLevelMOC_Mod A
                         --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                           JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail T   ON T.UCIC_ID = v_UCICID
                           AND T.EffectiveFromTimeKey <= v_Timekey
                           AND T.EffectiveToTimeKey >= v_Timekey
                           AND T.UCIC_ID = A.UcifID
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                            AND A.ScreenFlag <> 'U'

                            --and t.customerid=@customerid 
                            AND t.Ucic_Id = v_UCICID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --AND t.CustomerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.CustomerId ELSE @CustomerId END+'%' 

            --and t.Ucic_Id LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.Ucic_Id ELSE @UCICID  END+'%'  
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Sac3');
               OPEN  v_cursor FOR
                  SELECT DISTINCT C.IssuerID CustomerId  ,
                                  C.IssuerName CustomerName  ,
                                  C.UCIFID UCICID  ,
                                  --  ,'No MOC Done' AuthorisationStatus 
                                  CASE 
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                        THEN '1st Approval Pending'
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( 'A' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CalypsoCustomerLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM InvestmentBasicDetail B
                           JOIN InvestmentIssuerDetail C   ON B.IssuerEntityId = C.IssuerEntityId
                           AND C.EffectiveFromTimeKey <= v_Timekey
                           AND C.EffectiveToTimeKey >= v_Timekey

                  --inner join CalypsoCustomerlevelmoc_mod T ON T.UCIFID=c.ucifid

                  --AND T.EffectiveFromTimeKey<=@Timekey

                  --  AND T.EffectiveToTimeKey >= @Timekey 
                  WHERE  B.EffectiveFromTimeKey <= v_Timekey
                           AND B.EffectiveToTimeKey >= v_Timekey

                           --AND    B.InvEntityId=@AccountEntityID

                           -- AND t.AuthorisationStatus IN ('MP','NP','1A','A')
                           AND c.UCIFID = v_UCICID
                  UNION 
                  SELECT DISTINCT B.CustomerID CustomerId  ,
                                  B.CustomerName CustomerName  ,
                                  B.UCIC_ID UCICID  ,
                                  --,'No MOC Done' AuthorisationStatus 
                                  CASE 
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                                        THEN '1st Approval Pending'
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( '1A' )
                                        THEN '2nd Approval Pending'
                                       WHEN NVL(b.AuthorisationStatus, ' ') IN ( 'A' )
                                        THEN 'Authorised'
                                  ELSE 'No MOC Done'
                                     END AuthorisationStatus  ,
                                  'CalypsoCustomerLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM CurDat_RBL_MISDB_PROD.DerivativeDetail B

                  --inner join CalypsoCustomerlevelmoc_mod T ON T.UCIFID=b.ucic_id

                  --	AND T.EffectiveFromTimeKey<=@Timekey

                  --   AND T.EffectiveToTimeKey >= @Timekey 
                  WHERE  B.EffectiveFromTimeKey <= v_Timekey
                           AND B.EffectiveToTimeKey >= v_Timekey

                           --AND    B.DerivativeEntityID=@AccountEntityID

                           -- AND t.AuthorisationStatus IN ('MP','NP','1A','A')
                           AND B.UCIC_ID = v_UCICID ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);--select distinct T.IssuerID CustomerId
               --					   ,T.IssuerName CustomerName
               --					,T.UCIFID as UCICID
               --					   ,'No' AuthorisationStatus 
               --					   	   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate 
               --						   ,'CalypsoCustomerLevel' as TableName
               --				 from InvestmentbASICDetail T  
               --				 where (T.EffectiveFromTimeKey<=@Timekey
               --					   AND T.EffectiveToTimeKey >= @Timekey )
               --				--AND  (t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' )
               --					-- and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
               --					and t.UcifId=@UCICID
               --					UNION
               --					select distinct T.CustomerID CustomerId
               --					   ,T.CustomerName CustomerName
               --					,T.UCIC_ID as UCICID
               --					   ,'No ' AuthorisationStatus 
               --					   	   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate 
               --						   ,'CalypsoCustomerLevel' as TableName
               --				 from CurDat.DerivativeDetail T  
               --				 where (T.EffectiveFromTimeKey<=@Timekey
               --					   AND T.EffectiveToTimeKey >= @Timekey )
               --				--AND  (t.IssuerId LIKE '%'+CASE WHEN ISNULL(@CustomerId,'')='' THEN t.IssuerId ELSE @CustomerId END+'%' )
               --					-- and t.UcifId LIKE '%'+CASE WHEN ISNULL(@UCICID ,'')='' THEN t.UcifId ELSE @UCICID  END+'%' 
               --					and t.UCIC_ID=@UCICID

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
