--------------------------------------------------------
--  DDL for Function USERLOGINHISTORYINSERT_NEW_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" 
(
  v_UserID IN VARCHAR2,
  v_IPAdress IN VARCHAR2,
  v_LoginTime IN DATE,
  v_LogoutTime IN DATE,
  iv_LoginSucceeded IN CHAR,
  v_Result OUT NUMBER/* DEFAULT -1*/,
  v_LastLoginOut OUT VARCHAR2
)
RETURN NUMBER
AS
   v_LoginSucceeded CHAR(1) := iv_LoginSucceeded;
   v_UNLOGON NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_TimeKeyCurrent NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   IF v_LoginSucceeded = 'N' THEN

   BEGIN
      v_LoginSucceeded := 'W' ;

   END;
   END IF;

   BEGIN
      SELECT TimeKey 

        INTO v_TimeKey
        FROM SysDataMatrix 
       WHERE  CurrentStatus = 'C';
      SELECT TimeKey 

        INTO v_TimeKeyCurrent
        FROM SysDayMatrix 
       WHERE  date_ = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103);
      SELECT ParameterValue 

        INTO v_UNLOGON
        FROM DimUserParameters 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND ShortNameEnum = 'UNLOGON';
      DBMS_OUTPUT.PUT_LINE(v_UNLOGON);
      DBMS_OUTPUT.PUT_LINE('@UNLOGO');
      SELECT 'You last logged in at ' || FORMAT(UTILS.CONVERT_TO_DATETIME(UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(MAX(LoginTime) ,200),5)), 'hh:mm tt') || ' on ' || UTILS.CONVERT_TO_VARCHAR2(MAX(LoginTime) ,11,p_style=>100) 

        INTO v_LastLoginOut
        FROM UserLoginHistory 
       WHERE  UserID = v_UserID;
      IF v_LastLoginOut = ' '
        OR v_LastLoginOut IS NULL THEN
       v_LastLoginOut := 'You last logged in at 00:00AM' ;
      END IF;
      IF ( v_LoginSucceeded = 'Y' ) THEN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         BEGIN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('INSERT IN UserLoginHistoryTable');
               INSERT INTO UserLoginHistory
                 ( UserID, IP_Address, LoginTime, LogoutTime, DurationMin, LoginSucceeded )
                 VALUES ( v_UserID, v_IPAdress, TO_DATE(v_LoginTime,'dd/mm/yyyy'), TO_DATE(NULL ----change (as Discussed with Amol)
               ,'dd/mm/yyyy'), NULL, v_LoginSucceeded );
               utils.commit_transaction;

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            --UPDATE UserLoginHistory SET LoginSucceeded='Y'   ---as discussed on cal with sanjay sir and mohsin sir on 24112022 (swapna,gaurav,rasika)
            --				WHERE  UserID=@UserID
            --				AND LoginSucceeded='W'
            --Update  DimUserInfo SET UserLogged=1 ,CurrentLoginDate=GETDATE() 
            --where (EffectiveFromTimeKey<=@TimeKeyCurrent AND EffectiveToTimeKey>=@TimeKeyCurrent)
            --AND   UserLoginID=@UserID
            DBMS_OUTPUT.PUT_LINE('error');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            ROLLBACK;
            utils.resetTrancount;
            v_Result := -1 ;
            RETURN -1;
            OPEN  v_cursor FOR
               SELECT -1 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;END;
         SELECT MAX(EntityKey)  

           INTO v_Result
           FROM UserLoginHistory 
          WHERE  UserID = v_UserID
                   AND IP_Address = v_IPAdress
                   AND LoginTime = v_LoginTime
                   AND LoginSucceeded = v_LoginSucceeded;

      END;
      ELSE
         IF ( v_LoginSucceeded = 'W' ) THEN
          DECLARE
            v_LastLoginKey NUMBER(10,0);

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
            BEGIN
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('INSERTING INTO UserLoginHistory For Login Succeeded W');
                  INSERT INTO UserLoginHistory
                    ( UserID, IP_Address, LoginTime, LogoutTime, DurationMin, LoginSucceeded )
                    VALUES ( v_UserID, v_IPAdress, TO_DATE(v_LoginTime,'dd/mm/yyyy'), TO_DATE(NULL,'dd/mm/yyyy'), NULL, v_LoginSucceeded );
                  DBMS_OUTPUT.PUT_LINE('Insertion Done');
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( ( SELECT COUNT(LoginSucceeded)  
                                FROM UserLoginHistory 
                                 WHERE  UserID = v_UserID
                                          AND LoginSucceeded = 'W'
                                          AND LoginSucceeded = v_LoginSucceeded ) >= v_UNLOGON );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     ---CHANGED BY sanjay sir and mohsin sir on 24112022 (swapna,gaurav,rasika)
                     --UPDATE DimUserInfo SET SuspendedUser='Y',UserLogged=0
                     --				WHERE  UserLoginID=@UserID
                     UPDATE DimUserInfo
                        SET UserLogged = 0
                      WHERE  UserLoginID = v_UserID;

                  END;
                  END IF;
                  utils.commit_transaction;

               END;
            EXCEPTION
               WHEN OTHERS THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('error');
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK;
               utils.resetTrancount;
               v_Result := -1 ;
               RETURN -1;
               OPEN  v_cursor FOR
                  SELECT -1 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;END;
            DBMS_OUTPUT.PUT_LINE('A');
            SELECT MAX(EntityKey)  

              INTO v_LastLoginKey
              FROM UserLoginHistory 
             WHERE  UserID = v_UserID
                      AND LoginSucceeded = 'Y';
            v_LastLoginKey := NVL(v_LastLoginKey, 0) ;
            SELECT ( SELECT COUNT(LoginSucceeded)  
                     FROM UserLoginHistory 
                      WHERE  UserID = v_UserID
                               AND LoginSucceeded = 'W'
                               AND EntityKey > v_LastLoginKey ) 

              INTO v_Result
              FROM DUAL ;

         END;
         ELSE

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
            BEGIN

               BEGIN
                  INSERT INTO UserLoginHistory
                    ( UserID, IP_Address, LoginTime, LogoutTime, DurationMin, LoginSucceeded )
                    VALUES ( v_UserID, v_IPAdress, TO_DATE(v_LoginTime,'dd/mm/yyyy'), TO_DATE(v_LogoutTime,'dd/mm/yyyy'), NULL, v_LoginSucceeded );
                  utils.commit_transaction;

               END;
            EXCEPTION
               WHEN OTHERS THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('error');
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK;
               utils.resetTrancount;
               v_Result := -1 ;
               RETURN -1;
               OPEN  v_cursor FOR
                  SELECT -1 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;END;
            SELECT MAX(EntityKey)  

              INTO v_Result
              FROM UserLoginHistory 
             WHERE  UserID = v_UserID
                      AND IP_Address = v_IPAdress
                      AND LoginTime = v_LoginTime
                      AND LoginSucceeded = v_LoginSucceeded;--SELECT * FROM  UserLoginHistory 

         END;
         END IF;
      END IF;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINHISTORYINSERT_NEW_04122023" TO "ADF_CDR_RBL_STGDB";
