--------------------------------------------------------
--  DDL for Procedure USERPARAMETERSINSERTUPDATE_BACKUP_11022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" 
(
  v_CreatedBy IN VARCHAR2,
  v_CreatedDate IN DATE,
  v_NONUSE IN NUMBER,
  v_PWDCHNG IN NUMBER,
  v_PWDLEN IN NUMBER,
  v_PWDNUM IN NUMBER,
  v_PWDREUSE IN NUMBER,
  v_UNLOGON IN NUMBER,
  v_USERIDALP IN NUMBER,
  v_USERIDLEN IN NUMBER,
  v_USERIDLENMAX IN NUMBER,
  v_PWDLENMAX IN NUMBER,
  v_PWDALPHAMIN IN NUMBER,
  v_USERSHOMAX IN NUMBER,
  v_USERSROMAX IN NUMBER,
  v_USERSBOMAX IN NUMBER,
  v_Remark IN VARCHAR2,
  v_EffectiveFromTimeKey IN NUMBER,
  v_EffectiveToTimeKey IN NUMBER,
  v_Flag IN VARCHAR2,
  iv_AuthMode IN CHAR DEFAULT NULL ,
  v_TimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT -1*/
)
AS
   v_AuthMode CHAR(2) := iv_AuthMode;
   v_AuthorisationStatus CHAR(2) := NULL;
   v_CreateModifyApprovedBy VARCHAR2(20) := NULL;
   v_DateCreatedModifiedApproved DATE := NULL;
   v_Modifiedby VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_CurrentLoginDate VARCHAR2(200);--- added by shailesh naik on 10/06/2014
   * INTO ##temp2 FROM ( SELECT * FROM ( SELECT * FROM tt_temp1_78 ) T UNPIVOT (  --SQLDEV: NOT RECOGNIZED
   v_cursor SYS_REFCURSOR;

 -- NITIN : 21 DEC 2010
BEGIN

   v_AuthMode := CASE 
                      WHEN v_AuthMode IN ( 'S','H','A' )
                       THEN 'Y'
   ELSE 'N'
      END ;
   SELECT CurrentLoginDate 

     INTO v_CurrentLoginDate
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_CreatedBy;
   --IF DATEDIFF(DAY,@CurrentLoginDate,GetDate()) <> 0
   --BEGIN
   --   return -12 --- User Login Date is prior. Data will not be Saved. Please Close the Application.
   --END
   IF v_Flag = 2
     AND v_AuthMode = 'Y' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('A');
      IF utils.object_id('Tempdb..tt_temp1_78') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_78 ';
      END IF;
      DELETE FROM tt_temp1_78;
      INSERT INTO tt_temp1_78
        ( NONUSE, PWDCHNG, PWDLEN, PWDNUM, PWDREUSE, UNLOGON, USERIDALP, USERIDLEN, USERIDLENMAX, PWDLENMAX, PWDALPHAMIN, USERSHOMAX, USERSROMAX, USERSBOMAX )
        ( SELECT v_NONUSE ,
                 v_PWDCHNG ,
                 v_PWDLEN ,
                 v_PWDNUM ,
                 v_PWDREUSE ,
                 v_UNLOGON ,
                 v_USERIDALP ,
                 v_USERIDLEN ,
                 v_USERIDLENMAX ,
                 v_PWDLENMAX ,
                 v_PWDALPHAMIN ,
                 v_USERSHOMAX ,
                 v_USERSROMAX ,
                 v_USERSBOMAX 
            FROM DUAL  );
      IF utils.object_id('Tempdb..##temp2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_51 ';
      END IF;
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT * 
                  FROM tt_temp1_78  ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --select * from ##temp2
      ( FOR ParameterName IN ( NONUSE , PWDCHNG , PWDLEN , PWDNUM , PWDREUSE , UNLOGON , USERIDALP , USERIDLEN , USERIDLENMAX , PWDLENMAX , PWDALPHAMIN , USERSHOMAX , USERSROMAX , USERSBOMAX ) ) P ) A  --SQLDEV: NOT RECOGNIZED
      DBMS_OUTPUT.PUT_LINE('ABC');
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM RBL_MISDB_PROD.DimUserParameters_mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         UPDATE RBL_MISDB_PROD.DimUserParameters_mod
            SET AuthorisationStatus = 'FM',
                ModifyBy = v_CreatedBy,
                DateModified = v_CreatedDate
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
           AND EffectiveToTimeKey >= v_TimeKey )
           AND AuthorisationStatus IN ( 'NP','MP','RM' )
         ;

      END;
      END IF;
      INSERT INTO DimUserParameters_mod
        ( ShortNameEnum, ParameterType, ParameterValue, SeqNo, MinValue, MaxValue, AuthorisationStatus, DateCreated, CreatedBy, EffectiveFromTimeKey, EffectiveToTimeKey, ModifyBy, DateModified, Remark )
        ( SELECT ShortNameEnum ,
                 ParameterType ,
                 B.ParameterValue ,
                 SeqNo ,
                 MinValue ,
                 MaxValue ,
                 'MP' ,
                 DateCreated ,
                 CreatedBy ,
                 v_EffectiveFromTimeKey ,
                 v_EffectiveToTimeKey ,
                 v_CreatedBy ,
                 SYSDATE ,
                 v_Remark 
          FROM DimUserParameters A
                 LEFT JOIN tt_temp2_51 B   ON B.ParameterName = A.ShortNameEnum
           WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey );
      UPDATE DimUserParameters
         SET AuthorisationStatus = 'MP'
       WHERE  EffectiveFromTimeKey <= v_TimeKey
        AND EffectiveToTimeKey >= v_TimeKey;

   END;
   ELSE
      IF v_Flag = 16
        AND v_AuthMode = 'Y' THEN

      BEGIN
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.ParameterValue, v_CreatedBy, v_CreatedDate, CASE 
         WHEN v_AuthMode = 'Y' THEN v_CreatedBy
         ELSE NULL
            END AS pos_5, CASE 
         WHEN v_AuthMode = 'Y' THEN v_CreatedDate
         ELSE NULL
            END AS pos_6, CASE 
         WHEN v_AuthMode = 'Y' THEN 'A'
         ELSE NULL
            END AS pos_7
         FROM A ,DimUserParameters A
                JOIN DimUserParameters_mod B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND B.AuthorisationStatus IN ( 'NP','MP','RM' )

                AND A.ShortNameEnum = B.ShortNameEnum 
          WHERE A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey
           AND A.AuthorisationStatus = 'MP') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ParameterValue = src.ParameterValue,
                                      A.ModifyBy = v_CreatedBy,
                                      A.DateModified = v_CreatedDate,
                                      A.ApprovedBy = pos_5,
                                      A.DateApproved = pos_6,
                                      A.AuthorisationStatus = pos_7;
         UPDATE DimUserParameters_mod
            SET AuthorisationStatus = 'A',
                ApprovedBy = v_CreatedBy,
                DateApproved = v_CreatedDate
          WHERE  ( EffectiveFromTimekey <= v_TimeKey
           AND EffectiveToTimekey >= v_TimeKey )
           AND AuthorisationStatus IN ( 'NP','MP','RM' )
         ;

      END;
      ELSE
         IF v_Flag = 17
           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            v_ApprovedBy := v_CreatedBy ;
            v_DateApproved := SYSDATE ;
            UPDATE RBL_MISDB_PROD.DimUserParameters_mod
               SET AuthorisationStatus = 'R',
                   ApprovedBy = v_ApprovedBy,
                   DateApproved = v_DateApproved,
                   EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                   Remark = v_Remark
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey )
              AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
            ;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RBL_MISDB_PROD.DimUserParameters 
                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_Timekey ) );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               UPDATE DimUserParameters
                  SET AuthorisationStatus = 'A'
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND AuthorisationStatus IN ( 'MP','DP','RM' )
               ;

            END;
            END IF;

         END;
         ELSE
            IF v_Flag = 18
              AND v_AuthMode = 'Y' THEN

            BEGIN
               v_ApprovedBy := v_CreateModifyApprovedBy ;
               v_DateApproved := SYSDATE ;
               UPDATE DimUserParameters_mod
                  SET AuthorisationStatus = 'RM',
                      Remark = v_Remark
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
               ;

            END;
            END IF;
         END IF;
      END IF;
   END IF;
   IF v_AuthMode = 'N' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('N mode');
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE v_EffectiveFromTimeKey = ( SELECT EffectiveFromTimeKey 
                                           FROM DimUserParameters 
                                            WHERE  ShortNameEnum = 'NONUSE'
                                                     AND ( EffectiveToTimeKey >= v_EffectiveFromTimeKey
                                                     AND EffectiveFromTimeKey <= v_EffectiveFromTimeKey ) );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('same');
         UPDATE DimUserParameters
            SET ParameterValue = v_NONUSE,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'NONUSE';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDCHNG,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDCHNG';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDLEN,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDLEN';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDNUM,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDNUM';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDREUSE,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDREUSE';
         UPDATE DimUserParameters
            SET ParameterValue = v_UNLOGON,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'UNLOGON';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDALP,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDALP';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDLEN,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDLEN';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDLENMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDLENMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDLENMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDLENMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDALPHAMIN,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDALPHAMIN';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSHOMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSHOMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSROMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSROMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSBOMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSBOMAX';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSHOMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  UserLocation = 'HO'
           AND MaxUserCustom = 'N';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSROMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  UserLocation = 'RO'
           AND MaxUserCustom = 'N';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSBOMAX,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  UserLocation = 'BO'
           AND MaxUserCustom = 'N';
         UPDATE DimUserParameters
            SET EffectiveToTimeKey = v_EffectiveFromTimeKey,
                ModifyBy = v_CreatedBy,
                DateModified = SYSDATE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey > v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey < v_TimeKey )
           AND ShortNameEnum = 'NONUSE';

      END;

      --UPDATE DimUserParameters 

      --	SET 

      --WHERE  (DimUserParameters.EffectiveFromTimekey>@TimeKey AND DimUserParameters.EffectiveToTimekey<@TimeKey) 
      ELSE

      BEGIN
         DBMS_OUTPUT.PUT_LINE('diffrent');
         UPDATE DimUserParameters
            SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                ModifyBy = v_CreatedBy,
                DateModified = v_CreatedDate
          WHERE  EffectiveToTimeKey = v_EffectiveToTimeKey;
         DBMS_OUTPUT.PUT_LINE('1');
         INSERT INTO DimUserParameters
           ( ShortNameEnum, ParameterType, ParameterValue, SeqNo, MinValue, MaxValue, DateCreated, CreatedBy, EffectiveFromTimeKey, EffectiveToTimeKey, ModifyBy, DateModified )
           ( SELECT ShortNameEnum ,
                    ParameterType ,
                    ParameterValue ,
                    SeqNo ,
                    MinValue ,
                    MaxValue ,
                    DateCreated ,
                    CreatedBy ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    v_CreatedBy ,
                    SYSDATE 
             FROM DimUserParameters 
              WHERE  ( DimUserParameters.EffectiveToTimeKey = v_EffectiveFromTimeKey - 1 ) );
         UPDATE DimUserParameters
            SET ParameterValue = v_NONUSE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'NONUSE';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDCHNG
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDCHNG';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDLEN
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDLEN';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDNUM
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDNUM';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDREUSE
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDREUSE';
         UPDATE DimUserParameters
            SET ParameterValue = v_UNLOGON
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'UNLOGON';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDALP
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDALP';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDLEN
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDLEN';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERIDLENMAX
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERIDLENMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDLENMAX
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDLENMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_PWDALPHAMIN
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'PWDALPHAMIN';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSHOMAX
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSHOMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSROMAX
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSROMAX';
         UPDATE DimUserParameters
            SET ParameterValue = v_USERSBOMAX
          WHERE  ( DimUserParameters.EffectiveFromTimeKey <= v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey >= v_TimeKey )
           AND ShortNameEnum = 'USERSBOMAX';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSHOMAX
          WHERE  UserLocation = 'HO'
           AND MaxUserCustom = 'N';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSROMAX
          WHERE  UserLocation = 'RO'
           AND MaxUserCustom = 'N';
         UPDATE DimMaxLoginAllow
            SET MaxUserLogin = v_USERSBOMAX
          WHERE  UserLocation = 'BO'
           AND MaxUserCustom = 'N';
         UPDATE DimUserParameters
            SET EffectiveToTimeKey = v_EffectiveFromTimeKey
          WHERE  ( DimUserParameters.EffectiveFromTimeKey > v_TimeKey
           AND DimUserParameters.EffectiveToTimeKey < v_TimeKey )
           AND ShortNameEnum = 'NONUSE';

      END;
      END IF;

   END;
   END IF;
   v_Result := 1 ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
