--------------------------------------------------------
--  DDL for Procedure CUSTOMERLEVELQUICKSEARCHLIST_04012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --USE [USFB_ENPADB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --DROP PROCEDURE [dbo].[CustomerLevelQuickSearchList]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 --exec CustomerLevelQuickSearchList @CustomerId=N'22552793',@CustomerName=N'',@UCICID=N'',@OperationFlag=2,@newPage=1,@pageSize=1000
 --go
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --declare
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
   v_ExtDate VARCHAR2(200);
   -- AND ISNULL(ScreenFlag,'U') NOT IN('U','')
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
   IF ( v_CustomerId = ' '
     OR v_CustomerId IS NULL ) THEN

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
            SELECT DISTINCT T.CustomerID CustomerId  ,
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
                            'CustomerLevel' TableName  
              FROM MOC_ChangeDetails A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.MOCType_Flag = 'CUST'
                      AND A.AuthorisationStatus = 'A'
                      AND A.CustomerEntityID NOT IN ( SELECT CustomerEntityId 
                                                      FROM CustomerLevelMOC_Mod 
                                                       WHERE  AuthorisationStatus IN ( 'MP','NP','1A' )

                                                                AND EffectiveFromTimeKey <= v_Timekey
                                                                AND EffectiveToTimeKey >= v_Timekey )

            UNION 
            SELECT T.CustomerID CustomerId  ,
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
                   'CustomerLevel' TableName  
              FROM CustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey

            --LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
            WHERE  A.EffectiveFromTimeKey <= v_Timekey
                     AND A.EffectiveToTimeKey >= v_Timekey
                     AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                     AND A.MOCType_Flag = 'CUST' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
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
         OPEN  v_cursor FOR
            SELECT T.CustomerID CustomerId  ,
                   T.CustomerName ,
                   T.UCIF_ID UCICID  ,
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
                   'CustomerLevel' TableName  
              FROM CustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( 'MP','NP','DP','RM' )

                      AND A.MOCType_Flag = 'CUST' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_OperationFlag IN ( 20 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('114');
         OPEN  v_cursor FOR
            SELECT T.CustomerID CustomerId  ,
                   T.CustomerName ,
                   T.UCIF_ID UCICID  ,
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
                   'CustomerLevel' TableName  
              FROM CustomerLevelMOC_Mod A
                   --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                     JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                     AND T.EffectiveFromTimeKey <= v_Timekey
                     AND T.EffectiveToTimeKey >= v_Timekey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND A.AuthorisationStatus IN ( '1A' )

                      AND A.MOCType_Flag = 'CUST' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   ELSE
   DECLARE
      v_CustomerEntityID NUMBER(10,0);

   BEGIN
      SELECT CustomerEntityID 

        INTO v_CustomerEntityID
        FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail A
       WHERE  CustomerId = v_CustomerId
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey;
      DBMS_OUTPUT.PUT_LINE('Sac1');
      IF ( v_operationflag NOT IN ( 16,20 )
       )
        AND ( v_CustomerId <> ' '
        OR v_CustomerId <> NULL ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM MOC_ChangeDetails 
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
               SELECT DISTINCT T.CustomerID CustomerId  ,
                               T.CustomerName ,
                               T.UCIF_ID UCICID  ,
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
                               'CustomerLevel' TableName  
                 FROM MOC_ChangeDetails A
                      --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                        JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                        AND T.EffectiveFromTimeKey <= v_Timekey
                        AND T.EffectiveToTimeKey >= v_Timekey
                WHERE  A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey
                         AND A.AuthorisationStatus = 'A'
                         AND A.MOCType_Flag = 'CUST'
                         AND T.CustomerId = v_CustomerId ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
         ELSE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CustomerLevelMOC_Mod 
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
                  SELECT T.CustomerID CustomerId  ,
                         T.CustomerName ,
                         T.UCIF_ID UCICID  ,
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
                         'CustomerLevel' TableName  
                    FROM CustomerLevelMOC_Mod A
                         --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID

                           JOIN CustomerBasicDetail T   ON T.CustomerEntityId = A.CustomerEntityID
                           AND T.EffectiveFromTimeKey <= v_Timekey
                           AND T.EffectiveToTimeKey >= v_Timekey
                   WHERE  A.EffectiveFromTimeKey <= v_Timekey
                            AND A.EffectiveToTimeKey >= v_Timekey
                            AND A.AuthorisationStatus IN ( 'MP','NP','1A' )

                            AND A.MOCType_Flag = 'CUST'
                            AND A.CustomerID = v_CustomerId ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Sac3');
               OPEN  v_cursor FOR
                  SELECT DISTINCT T.CustomerID CustomerId  ,
                                  T.CustomerName ,
                                  T.UCIF_ID UCICID  ,
                                  'No MOC Done' AuthorisationStatus  ,
                                  'CustomerLevel' TableName  ,
                                  v_ExtDate MOCMonthEndDate  
                    FROM CustomerBasicDetail T
                   WHERE  T.EffectiveFromTimeKey <= v_Timekey
                            AND T.EffectiveToTimeKey >= v_Timekey
                            AND T.CustomerId = v_CustomerId ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELQUICKSEARCHLIST_04012024" TO "ADF_CDR_RBL_STGDB";
