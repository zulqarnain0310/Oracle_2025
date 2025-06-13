--------------------------------------------------------
--  DDL for Procedure DUPLICATE_VERIFICATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" 
(
  v_UserId IN VARCHAR2 DEFAULT ' ' ,
  v_TimeKey IN NUMBER DEFAULT 49999 ,
  v_CheckFor IN VARCHAR2 DEFAULT 'MobileNo' ,
  v_Value IN VARCHAR2 DEFAULT ' ' ,
  v_NextValue IN VARCHAR2 DEFAULT ' ' ,
  v_ThirdValue IN VARCHAR2 DEFAULT ' ' ,
  v_FourthValue IN VARCHAR2 DEFAULT ' ' ,
  v_BranchCode IN VARCHAR2 DEFAULT 0 ,
  v_BaseColumnValue IN VARCHAR2 DEFAULT ' ' ,
  v_ParentColumnValue IN VARCHAR2 DEFAULT ' ' ,
  v_HyperCubeId IN NUMBER DEFAULT ' ' ,
  v_CustomerACID IN NUMBER DEFAULT ' ' 
)
AS
   v_cursor SYS_REFCURSOR;
--DECLARE 
--@UserId varchar(20) =''
--	,@TimeKey INT = 49999
--	,@CheckFor varchar(30)='ContactpersonName'
--	,@Value	varchar(30)='ada213'
--	,@NextValue varchar(300)=''
--	,@ThirdValue varchar(300)=''
--	,@FourthValue varchar(300)=''
--	,@BranchCode VARCHAR(MAX) = 'sh123'
--	,@BaseColumnValue varchar(30)='72'
--	,@ParentColumnValue  varchar(30)=''
--	,@HyperCubeId INT=''
--	,@CustomerACID INT = ''

BEGIN

   --   Select @TimeKey=Case when ISNULL(@TimeKey,0)=0 THEN TimeKey else @TimeKey end
   --from SysDayMatrix where cast(GetDate() as date)=cast([date] as date)
   --Select @Timekey=Max(Timekey) from SysProcessingCycle
   -- where Extracted='Y' and ProcessType='Full' --and PreMOC_CycleFrozenDate IS NULL
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   IF ( v_CheckFor = 'MobileNo' ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM DimUserInfo 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )

                                   --AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')

                                   --AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
                                   AND NVL(MobileNo, ' ') <> ' '
                                   AND SUBSTR(MobileNo, 1, 10) = v_Value
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                         UNION 
                         SELECT 1 
                         FROM DimUserInfo_mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )

                                   --AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')

                                   --AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
                                   AND NVL(MobileNo, ' ') <> ' '
                                   AND SUBSTR(MobileNo, 1, 10) = v_Value
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT '1' CODE  ,
                   'Data Exist' STATUS  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT '0' CODE  ,
                   'Data Not Exist' STATUS  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   ELSE
      IF ( v_CheckFor = 'ExtensionNo' ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM DimUserInfo 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )

                                      --AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')

                                      --AND (SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) LIKE CASE WHEN @Value <> '' Then '%' + @Value +'%' ELSE SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) END ) AND UserLoginID<>isnull(@UserId,'')
                                      AND SUBSTR(NVL(MobileNo, ' '), 12, LENGTH(NVL(MobileNo, ' '))) = v_Value

                                      --AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT 1 
                            FROM DimUserInfo_mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )

                                      --AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')

                                      --AND (SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) LIKE CASE WHEN @Value <> '' Then '%' + @Value +'%' ELSE SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) END ) AND UserLoginID<>isnull(@UserId,'')
                                      AND SUBSTR(NVL(MobileNo, ' '), 12, LENGTH(NVL(MobileNo, ' '))) = v_Value

                                      --AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT '1' CODE  ,
                      'Data Exist' STATUS  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE

         BEGIN
            OPEN  v_cursor FOR
               SELECT '0' CODE  ,
                      'Data Not Exist' STATUS  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
      ELSE
         IF ( v_CheckFor = 'UserId' ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM DimUserInfo 
                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND UserLoginID = v_Value --AND UserLoginID<>isnull(@UserId,'')

                                         AND NVL(AuthorisationStatus, 'A') = 'A'
                               UNION 
                               SELECT 1 
                               FROM DimUserInfo_mod 
                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND UserLoginID = v_Value --AND UserLoginID<>isnull(@UserId,'')

                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
             );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT '1' CODE  ,
                         'Data Exist' STATUS  
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE

            BEGIN
               OPEN  v_cursor FOR
                  SELECT '0' CODE  ,
                         'Data Not Exist' STATUS  
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;
         ELSE
            IF ( v_CheckFor = 'EmailId' ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               IF utils.object_id('Tempdb..tt_Email') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Email ';
               END IF;
               DELETE FROM tt_Email;
               UTILS.IDENTITY_RESET('tt_Email');

               INSERT INTO tt_Email ( 
               	SELECT Email_ID 
               	  FROM ( SELECT a_SPLIT.VALUE('.', 'VARCHAR(8000)') Email_ID  
                         FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Email_ID, ',', '</M><M>') || '</M>') Email  
                                FROM DimUserInfo 
                                 WHERE  EffectiveFromTimeKey <= v_Timekey
                                          AND EffectiveToTimeKey >= v_Timekey
                                          AND NVL(Email_ID, ' ') <> ' '
                                          AND UserLoginID <> v_UserId ) A
                                 /*TODO:SQLDEV*/ CROSS APPLY Email.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) B
               	 WHERE  NVL(Email_ID, ' ') <> ' ' );
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT * 
                                  FROM tt_Email 
                                   WHERE  Email_ID = v_Value );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT '1' CODE  ,
                            'Data Exist' STATUS  
                       FROM DUAL  ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT '0' CODE  ,
                            'Data Not Exist' STATUS  
                       FROM DUAL  ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;

            END;

            --ELSE IF(@CheckFor = 'GLCode')

            --BEGIN

            --PRINT 'IN GL CODE'

            --	IF EXISTS( SELECT  1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

            --								GLCode=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )

            --								AND ISNULL( AuthorisationStatus,'A' ) ='A'

            --				 UNION

            --				 SELECT  1 FROM DimGL_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

            --								GLCode=@Value AND  GLAlt_Key<>isnull(@BaseColumnValue,'') )

            --								AND AuthorisationStatus in('NP','MP','DP','RM')

            --			)

            --	BEGIN

            --		SELECT '1' CODE, 'Data Exist' Status

            --	END

            --	ELSE

            --	BEGIN

            --		SELECT '0' CODE, 'Data Not Exist' Status

            --	END

            --END
            ELSE
               IF ( v_CheckFor = 'ChildBSCode' ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('ChildBSCode');
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM BS_RBL_MISDB_PROD.DimBSCodeStructure 
                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_TimeKey
                                               AND BS_Code = v_Value
                                               AND NVL(AuthorisationStatus, 'A') = 'A' )
                                     UNION 
                                     SELECT 1 
                                     FROM BS_RBL_MISDB_PROD.DimBSCodeStructure_Mod 
                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_TimeKey
                                               AND BS_Code = v_Value
                                               AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                              ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT '1' CODE  ,
                               'Data Exist' STATUS  
                          FROM DUAL  ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  ELSE

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT '0' CODE  ,
                               'Data Not Exist' STATUS  
                          FROM DUAL  ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;

               END;
               ELSE
                  IF ( v_CheckFor = 'CAFirmName' ) THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM BS_RBL_MISDB_PROD.DimAuditors 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                  AND CAFirmName = v_Value
                                                  AND CAFirmAlt_Key <> NVL(v_BaseColumnValue, ' ')
                                                  AND NVL(AuthorisationStatus, 'A') = 'A' )
                                        UNION 
                                        SELECT 1 
                                        FROM BS_RBL_MISDB_PROD.DimAuditors_Mod 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                  AND CAFirmName = v_Value
                                                  AND CAFirmAlt_Key <> NVL(v_BaseColumnValue, ' ') )
                                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                      );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT '1' CODE  ,
                                  'Data Exist' STATUS  
                             FROM DUAL  ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     ELSE

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT '0' CODE  ,
                                  'Data Not Exist' STATUS  
                             FROM DUAL  ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     END IF;

                  END;

                  --ELSE IF(@CheckFor = 'GLName')

                  --BEGIN

                  --PRINT 'IN GL Name'

                  ----IF EXISTS( SELECT  1 FROM DimGL WHERE (--EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

                  ----								GLName=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )

                  ----				 UNION

                  ----				 SELECT  1 FROM DimGL_Mod WHERE (--EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

                  ----								GLName=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )

                  ----			)

                  ----				BEGIN

                  ----		SELECT '1' CODE, 'Data Exist' Status

                  ----	END

                  ----	ELSE

                  ----	BEGIN

                  ----		SELECT '0' CODE, 'Data Not Exist' Status

                  ----	END

                  --	IF EXISTS( SELECT  1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

                  --	 GLName=@Value AND GLAlt_Key<>isnull(@BaseColumnValue,'') AND ISNULL( AuthorisationStatus,'A' ) ='A')

                  --	 UNION 

                  --				SELECT  1 FROM DimGL_Mod WHERE 

                  --								 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND

                  --	 GLName=@Value AND GLAlt_Key<>isnull(@BaseColumnValue,'')) AND AuthorisationStatus in('NP','MP','DP','RM'))

                  --	BEGIN

                  --		SELECT '1' CODE, 'Data Exist' Status

                  --	END

                  --	ELSE

                  --	BEGIN

                  --		SELECT '0' CODE, 'Data Not Exist' Status

                  --	END

                  --END
                  ELSE
                     IF ( v_CheckFor = 'OffeceAcCd' ) THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('IN OffeceAcCd');
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM BS_RBL_MISDB_PROD.DimOfficeAccount 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND OffeceAcCd = v_Value
                                                     AND OfficeAccountAlt_key <> NVL(v_BaseColumnValue, ' ')
                                                     AND NVL(AuthorisationStatus, 'A') = 'A' )
                                           UNION 
                                           SELECT 1 
                                           FROM BS_RBL_MISDB_PROD.DimOfficeAccount_Mod 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND OffeceAcCd = v_Value
                                                     AND OfficeAccountAlt_key <> NVL(v_BaseColumnValue, ' ') )
                                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                         );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           OPEN  v_cursor FOR
                              SELECT '1' CODE  ,
                                     'Data Exist' STATUS  
                                FROM DUAL  ;
                              DBMS_SQL.RETURN_RESULT(v_cursor);

                        END;
                        ELSE

                        BEGIN
                           OPEN  v_cursor FOR
                              SELECT '0' CODE  ,
                                     'Data Not Exist' STATUS  
                                FROM DUAL  ;
                              DBMS_SQL.RETURN_RESULT(v_cursor);

                        END;
                        END IF;

                     END;
                     ELSE
                        IF ( v_CheckFor = 'OfficeAccountDescription' ) THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE('IN OfficeAccountDescription');
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM BS_RBL_MISDB_PROD.DimOfficeAccount 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND OfficeAccountDescription = v_Value
                                                        AND OfficeAccountAlt_key <> NVL(v_BaseColumnValue, ' ')
                                                        AND NVL(AuthorisationStatus, 'A') = 'A' )
                                              UNION 
                                              SELECT 1 
                                              FROM BS_RBL_MISDB_PROD.DimOfficeAccount_Mod 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND OfficeAccountDescription = v_Value
                                                        AND OfficeAccountAlt_key <> NVL(v_BaseColumnValue, ' ') )
                                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                            );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              OPEN  v_cursor FOR
                                 SELECT '1' CODE  ,
                                        'Data Exist' STATUS  
                                   FROM DUAL  ;
                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                           END;
                           ELSE

                           BEGIN
                              OPEN  v_cursor FOR
                                 SELECT '0' CODE  ,
                                        'Data Not Exist' STATUS  
                                   FROM DUAL  ;
                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                           END;
                           END IF;

                        END;
                        ELSE
                           IF ( v_CheckFor = 'AccountNoBorrLiabilitiesStmt' ) THEN
                            DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              --select * from BorrLiabilitiesStmt
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM BorrLiabilitiesStmt 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND AccountNo LIKE ' ' || v_Value || ' '
                                                           AND EntityID <> NVL(v_BaseColumnValue, ' ')
                                                           AND NVL(AuthorisationStatus, 'A') = 'A'
                                                 UNION 
                                                 SELECT 1 
                                                 FROM BorrLiabilitiesStmt_Mod 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND AccountNo LIKE ' ' || v_Value || ' '
                                                           AND EntityID <> NVL(v_BaseColumnValue, ' ')
                                                           AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                               );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN

                              BEGIN
                                 OPEN  v_cursor FOR
                                    SELECT '1' CODE  ,
                                           'Data Exist' STATUS  
                                      FROM DUAL  ;
                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                              END;
                              ELSE

                              BEGIN
                                 OPEN  v_cursor FOR
                                    SELECT '0' CODE  ,
                                           'Data Not Exist' STATUS  
                                      FROM DUAL  ;
                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                              END;
                              END IF;

                           END;
                           ELSE
                              IF ( v_CheckFor = 'MobileNoFinLiteracyCenter' ) THEN
                               DECLARE
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM FinLiteracyCenter 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND MobileNo LIKE '%' || v_Value || '%'
                                                              AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                              AND NVL(AuthorisationStatus, 'A') = 'A'
                                                    UNION 
                                                    SELECT 1 
                                                    FROM FinLiteracyCenter_Mod 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND MobileNo LIKE '%' || v_Value || '%'
                                                              AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                  );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    OPEN  v_cursor FOR
                                       SELECT '1' CODE  ,
                                              'Data Exist' STATUS  
                                         FROM DUAL  ;
                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                 END;
                                 ELSE

                                 BEGIN
                                    OPEN  v_cursor FOR
                                       SELECT '0' CODE  ,
                                              'Data Not Exist' STATUS  
                                         FROM DUAL  ;
                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                 END;
                                 END IF;

                              END;
                              ELSE
                                 IF ( v_CheckFor = 'EmailFinLiteracyCenter' ) THEN
                                  DECLARE
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM FinLiteracyCenter 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND Email LIKE ' ' || v_Value || ' '
                                                                 AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                 AND NVL(AuthorisationStatus, 'A') = 'A'
                                                       UNION 
                                                       SELECT 1 
                                                       FROM FinLiteracyCenter_Mod 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND Email LIKE ' ' || v_Value || ' '
                                                                 AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                     );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       OPEN  v_cursor FOR
                                          SELECT '1' CODE  ,
                                                 'Data Exist' STATUS  
                                            FROM DUAL  ;
                                          DBMS_SQL.RETURN_RESULT(v_cursor);

                                    END;
                                    ELSE

                                    BEGIN
                                       OPEN  v_cursor FOR
                                          SELECT '0' CODE  ,
                                                 'Data Not Exist' STATUS  
                                            FROM DUAL  ;
                                          DBMS_SQL.RETURN_RESULT(v_cursor);

                                    END;
                                    END IF;

                                 END;
                                 ELSE
                                    IF ( v_CheckFor = 'FLC_CodeFinLiteracyCenter' ) THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM FinLiteracyCenter 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND FLC_Code LIKE ' ' || v_Value || ' '
                                                                    AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                    AND NVL(AuthorisationStatus, 'A') = 'A'
                                                          UNION 
                                                          SELECT 1 
                                                          FROM FinLiteracyCenter_Mod 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND FLC_Code LIKE ' ' || v_Value || ' '
                                                                    AND FinLitEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                        );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          OPEN  v_cursor FOR
                                             SELECT '1' CODE  ,
                                                    'Data Exist' STATUS  
                                               FROM DUAL  ;
                                             DBMS_SQL.RETURN_RESULT(v_cursor);

                                       END;
                                       ELSE

                                       BEGIN
                                          OPEN  v_cursor FOR
                                             SELECT '0' CODE  ,
                                                    'Data Not Exist' STATUS  
                                               FROM DUAL  ;
                                             DBMS_SQL.RETURN_RESULT(v_cursor);

                                       END;
                                       END IF;

                                    END;
                                    ELSE
                                       IF ( v_CheckFor = 'NABARD_Code' ) THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM FarmersClubDtls 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND NABARD_Code LIKE ' ' || v_Value || ' '
                                                                       AND ClubEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                       AND NVL(AuthorisationStatus, 'A') = 'A'
                                                             UNION 
                                                             SELECT 1 
                                                             FROM FarmersClubDtls_Mod 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND NABARD_Code LIKE ' ' || v_Value || ' '
                                                                       AND ClubEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                           );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             OPEN  v_cursor FOR
                                                SELECT '1' CODE  ,
                                                       'Data Exist' STATUS  
                                                  FROM DUAL  ;
                                                DBMS_SQL.RETURN_RESULT(v_cursor);

                                          END;
                                          ELSE

                                          BEGIN
                                             OPEN  v_cursor FOR
                                                SELECT '0' CODE  ,
                                                       'Data Not Exist' STATUS  
                                                  FROM DUAL  ;
                                                DBMS_SQL.RETURN_RESULT(v_cursor);

                                          END;
                                          END IF;

                                       END;
                                       ELSE
                                          IF ( v_CheckFor = 'Designation_Profile' ) THEN
                                           DECLARE
                                             v_temp NUMBER(1, 0) := 0;

                                          BEGIN
                                             BEGIN
                                                SELECT 1 INTO v_temp
                                                  FROM DUAL
                                                 WHERE EXISTS ( SELECT 1 
                                                                FROM RBL_MISDB_PROD.TopManagementProfile 
                                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                          AND EffectiveToTimeKey >= v_TimeKey )
                                                                          AND DesignationAlt_Key = 1
                                                                          AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                          AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                UNION 
                                                                SELECT 1 
                                                                FROM RBL_MISDB_PROD.TopManagementProfile_Mod 
                                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                          AND EffectiveToTimeKey >= v_TimeKey )
                                                                          AND DesignationAlt_Key = 1
                                                                          AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                              );
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   NULL;
                                             END;

                                             IF v_temp = 1 THEN

                                             BEGIN
                                                OPEN  v_cursor FOR
                                                   SELECT '1' CODE  ,
                                                          'Data Exist' STATUS  
                                                     FROM DUAL  ;
                                                   DBMS_SQL.RETURN_RESULT(v_cursor);

                                             END;
                                             ELSE

                                             BEGIN
                                                OPEN  v_cursor FOR
                                                   SELECT '0' CODE  ,
                                                          'Data Not Exist' STATUS  
                                                     FROM DUAL  ;
                                                   DBMS_SQL.RETURN_RESULT(v_cursor);

                                             END;
                                             END IF;

                                          END;
                                          ELSE
                                             IF ( v_CheckFor = 'Email_Profile' ) THEN
                                              DECLARE
                                                v_temp NUMBER(1, 0) := 0;

                                             BEGIN
                                                BEGIN
                                                   SELECT 1 INTO v_temp
                                                     FROM DUAL
                                                    WHERE EXISTS ( SELECT 1 
                                                                   FROM RBL_MISDB_PROD.TopManagementProfile 
                                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                                             AND Email LIKE ' ' || v_Value || ' '
                                                                             AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                             AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                   UNION 
                                                                   SELECT 1 
                                                                   FROM RBL_MISDB_PROD.TopManagementProfile_Mod 
                                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                                             AND Email LIKE ' ' || v_Value || ' '
                                                                             AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                 );
                                                EXCEPTION
                                                   WHEN OTHERS THEN
                                                      NULL;
                                                END;

                                                IF v_temp = 1 THEN

                                                BEGIN
                                                   OPEN  v_cursor FOR
                                                      SELECT '1' CODE  ,
                                                             'Data Exist' STATUS  
                                                        FROM DUAL  ;
                                                      DBMS_SQL.RETURN_RESULT(v_cursor);

                                                END;
                                                ELSE

                                                BEGIN
                                                   OPEN  v_cursor FOR
                                                      SELECT '0' CODE  ,
                                                             'Data Not Exist' STATUS  
                                                        FROM DUAL  ;
                                                      DBMS_SQL.RETURN_RESULT(v_cursor);

                                                END;
                                                END IF;

                                             END;
                                             ELSE
                                                IF ( v_CheckFor = 'EmailId_Board' ) THEN
                                                 DECLARE
                                                   v_temp NUMBER(1, 0) := 0;

                                                BEGIN
                                                   BEGIN
                                                      SELECT 1 INTO v_temp
                                                        FROM DUAL
                                                       WHERE EXISTS ( SELECT 1 
                                                                      FROM RBL_MISDB_PROD.BoardMemberstProfile 
                                                                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                AND EffectiveToTimeKey >= v_TimeKey )
                                                                                AND Email LIKE ' ' || v_Value || ' '
                                                                                AND MemProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                      UNION 
                                                                      SELECT 1 
                                                                      FROM RBL_MISDB_PROD.BoardMemberstProfile_Mod 
                                                                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                AND EffectiveToTimeKey >= v_TimeKey )
                                                                                AND Email LIKE ' ' || v_Value || ' '
                                                                                AND MemProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                    );
                                                   EXCEPTION
                                                      WHEN OTHERS THEN
                                                         NULL;
                                                   END;

                                                   IF v_temp = 1 THEN

                                                   BEGIN
                                                      OPEN  v_cursor FOR
                                                         SELECT '1' CODE  ,
                                                                'Data Exist' STATUS  
                                                           FROM DUAL  ;
                                                         DBMS_SQL.RETURN_RESULT(v_cursor);

                                                   END;
                                                   ELSE

                                                   BEGIN
                                                      OPEN  v_cursor FOR
                                                         SELECT '0' CODE  ,
                                                                'Data Not Exist' STATUS  
                                                           FROM DUAL  ;
                                                         DBMS_SQL.RETURN_RESULT(v_cursor);

                                                   END;
                                                   END IF;

                                                END;
                                                ELSE
                                                   IF ( v_CheckFor = 'MobileNo_Board' ) THEN
                                                    DECLARE
                                                      v_temp NUMBER(1, 0) := 0;

                                                   BEGIN
                                                      BEGIN
                                                         SELECT 1 INTO v_temp
                                                           FROM DUAL
                                                          WHERE EXISTS ( SELECT 1 
                                                                         FROM RBL_MISDB_PROD.BoardMemberstProfile 
                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                   AND MobileNo LIKE '%' || v_Value || '%'
                                                                                   AND MemProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                         UNION 
                                                                         SELECT 1 
                                                                         FROM RBL_MISDB_PROD.BoardMemberstProfile_Mod 
                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                   AND MobileNo LIKE '%' || v_Value || '%'
                                                                                   AND MemProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                       );
                                                      EXCEPTION
                                                         WHEN OTHERS THEN
                                                            NULL;
                                                      END;

                                                      IF v_temp = 1 THEN

                                                      BEGIN
                                                         OPEN  v_cursor FOR
                                                            SELECT '1' CODE  ,
                                                                   'Data Exist' STATUS  
                                                              FROM DUAL  ;
                                                            DBMS_SQL.RETURN_RESULT(v_cursor);

                                                      END;
                                                      ELSE

                                                      BEGIN
                                                         OPEN  v_cursor FOR
                                                            SELECT '0' CODE  ,
                                                                   'Data Not Exist' STATUS  
                                                              FROM DUAL  ;
                                                            DBMS_SQL.RETURN_RESULT(v_cursor);

                                                      END;
                                                      END IF;

                                                   END;
                                                   ELSE
                                                      IF ( v_CheckFor = 'Date' ) THEN
                                                       DECLARE
                                                         v_temp NUMBER(1, 0) := 0;

                                                      BEGIN
                                                         BEGIN
                                                            SELECT 1 INTO v_temp
                                                              FROM DUAL
                                                             WHERE EXISTS ( SELECT 1 
                                                                            FROM RBL_MISDB_PROD.CrimeDetails 
                                                                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                      AND EffectiveToTimeKey >= v_TimeKey )

                                                                                      --AND CrimeEntityId<>isnull(@BaseColumnValue,'')
                                                                                      AND UTILS.CONVERT_TO_VARCHAR2(OccurrenceDateTime,10,p_style=>103) = v_Value
                                                                                      AND BranchCode = v_BranchCode
                                                                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                            UNION 
                                                                            SELECT 1 
                                                                            FROM RBL_MISDB_PROD.CrimeDetails_Mod 
                                                                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                      AND EffectiveToTimeKey >= v_TimeKey )

                                                                                      --AND CrimeEntityId<>isnull(@BaseColumnValue,'')
                                                                                      AND UTILS.CONVERT_TO_VARCHAR2(OccurrenceDateTime,10,p_style=>103) = v_Value
                                                                                      AND BranchCode = v_BranchCode
                                                                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                          );
                                                         EXCEPTION
                                                            WHEN OTHERS THEN
                                                               NULL;
                                                         END;

                                                         IF v_temp = 1 THEN

                                                         BEGIN
                                                            OPEN  v_cursor FOR
                                                               SELECT '1' CODE  ,
                                                                      'Data Exist' STATUS  
                                                                 FROM DUAL  ;
                                                               DBMS_SQL.RETURN_RESULT(v_cursor);

                                                         END;
                                                         ELSE

                                                         BEGIN
                                                            OPEN  v_cursor FOR
                                                               SELECT '0' CODE  ,
                                                                      'Data Not Exist' STATUS  
                                                                 FROM DUAL  ;
                                                               DBMS_SQL.RETURN_RESULT(v_cursor);

                                                         END;
                                                         END IF;

                                                      END;
                                                      ELSE
                                                         IF ( v_CheckFor = 'IssuerID' ) THEN
                                                          DECLARE
                                                            v_temp NUMBER(1, 0) := 0;

                                                         BEGIN
                                                            BEGIN
                                                               SELECT 1 INTO v_temp
                                                                 FROM DUAL
                                                                WHERE EXISTS ( SELECT 1 
                                                                               FROM RBL_MISDB_PROD.InvestmentIssuerDetail 
                                                                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                         AND EffectiveToTimeKey >= v_TimeKey )
                                                                                         AND IssuerEntityID <> NVL(v_BaseColumnValue, ' ')
                                                                                         AND IssuerID = v_Value

                                                                                         -- AND BranchCode = @BranchCode
                                                                                         AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                               UNION 
                                                                               SELECT 1 
                                                                               FROM RBL_MISDB_PROD.InvestmentIssuerDetail_Mod 
                                                                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                         AND EffectiveToTimeKey >= v_TimeKey )
                                                                                         AND IssuerEntityID <> NVL(v_BaseColumnValue, ' ')
                                                                                         AND IssuerID = v_Value

                                                                                         --AND BranchCode = @BranchCode
                                                                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                             );
                                                            EXCEPTION
                                                               WHEN OTHERS THEN
                                                                  NULL;
                                                            END;

                                                            IF v_temp = 1 THEN

                                                            BEGIN
                                                               OPEN  v_cursor FOR
                                                                  SELECT '1' CODE  ,
                                                                         'Data Exist' STATUS  
                                                                    FROM DUAL  ;
                                                                  DBMS_SQL.RETURN_RESULT(v_cursor);

                                                            END;
                                                            ELSE

                                                            BEGIN
                                                               OPEN  v_cursor FOR
                                                                  SELECT '0' CODE  ,
                                                                         'Data Not Exist' STATUS  
                                                                    FROM DUAL  ;
                                                                  DBMS_SQL.RETURN_RESULT(v_cursor);

                                                            END;
                                                            END IF;

                                                         END;
                                                         ELSE
                                                            IF ( v_CheckFor = 'FMS_Nuumber' ) THEN
                                                             DECLARE
                                                               v_temp NUMBER(1, 0) := 0;

                                                            BEGIN
                                                               BEGIN
                                                                  SELECT 1 INTO v_temp
                                                                    FROM DUAL
                                                                   WHERE EXISTS ( SELECT 1 
                                                                                  FROM RBL_MISDB_PROD.FraudDetail 
                                                                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                            AND EffectiveToTimeKey >= v_TimeKey )
                                                                                            AND FraudEntityId <> NVL(v_BaseColumnValue, ' ')

                                                                                            --AND FMS_Nuumber = @Value

                                                                                            -- AND BranchCode = @BranchCode
                                                                                            AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                  UNION 
                                                                                  SELECT 1 
                                                                                  FROM RBL_MISDB_PROD.FraudDetail_Mod 
                                                                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                            AND EffectiveToTimeKey >= v_TimeKey )
                                                                                            AND FraudEntityId <> NVL(v_BaseColumnValue, ' ')

                                                                                            --AND FMS_Nuumber = @Value

                                                                                            --AND BranchCode = @BranchCode
                                                                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                );
                                                               EXCEPTION
                                                                  WHEN OTHERS THEN
                                                                     NULL;
                                                               END;

                                                               IF v_temp = 1 THEN

                                                               BEGIN
                                                                  OPEN  v_cursor FOR
                                                                     SELECT '1' CODE  ,
                                                                            'Data Exist' STATUS  
                                                                       FROM DUAL  ;
                                                                     DBMS_SQL.RETURN_RESULT(v_cursor);

                                                               END;
                                                               ELSE

                                                               BEGIN
                                                                  OPEN  v_cursor FOR
                                                                     SELECT '0' CODE  ,
                                                                            'Data Not Exist' STATUS  
                                                                       FROM DUAL  ;
                                                                     DBMS_SQL.RETURN_RESULT(v_cursor);

                                                               END;
                                                               END IF;

                                                            END;
                                                            ELSE
                                                               IF ( v_CheckFor = 'LCBGNo' ) THEN
                                                                DECLARE
                                                                  v_temp NUMBER(1, 0) := 0;

                                                               BEGIN
                                                                  BEGIN
                                                                     SELECT 1 INTO v_temp
                                                                       FROM DUAL
                                                                      WHERE EXISTS ( SELECT 1 
                                                                                     FROM RBL_MISDB_PROD.AdvFacNFDetail 
                                                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                               AND EffectiveToTimeKey >= v_TimeKey )

                                                                                               --AND FraudEntityId<>isnull(@BaseColumnValue,'')
                                                                                               AND LCBGNo = v_Value

                                                                                               -- AND BranchCode = @BranchCode
                                                                                               AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                     UNION 
                                                                                     SELECT 1 
                                                                                     FROM RBL_MISDB_PROD.AdvFacNFDetail_Mod 
                                                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                               AND EffectiveToTimeKey >= v_TimeKey )

                                                                                               --AND FraudEntityId<>isnull(@BaseColumnValue,'')
                                                                                               AND LCBGNo = v_Value

                                                                                               --AND BranchCode = @BranchCode
                                                                                               AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                   );
                                                                  EXCEPTION
                                                                     WHEN OTHERS THEN
                                                                        NULL;
                                                                  END;

                                                                  IF v_temp = 1 THEN

                                                                  BEGIN
                                                                     OPEN  v_cursor FOR
                                                                        SELECT '1' CODE  ,
                                                                               'Data Exist' STATUS  
                                                                          FROM DUAL  ;
                                                                        DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                  END;
                                                                  ELSE

                                                                  BEGIN
                                                                     OPEN  v_cursor FOR
                                                                        SELECT '0' CODE  ,
                                                                               'Data Not Exist' STATUS  
                                                                          FROM DUAL  ;
                                                                        DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                  END;
                                                                  END IF;

                                                               END;
                                                               ELSE
                                                                  IF ( v_CheckFor = 'IssuerName' ) THEN
                                                                   DECLARE
                                                                     v_temp NUMBER(1, 0) := 0;

                                                                  BEGIN
                                                                     BEGIN
                                                                        SELECT 1 INTO v_temp
                                                                          FROM DUAL
                                                                         WHERE EXISTS ( SELECT 1 
                                                                                        FROM RBL_MISDB_PROD.InvestmentIssuerDetail 
                                                                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                  AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                  AND IssuerEntityID <> NVL(v_BaseColumnValue, ' ')
                                                                                                  AND IssuerName = v_Value
                                                                                                  AND BranchCode = v_BranchCode
                                                                                                  AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                        UNION 
                                                                                        SELECT 1 
                                                                                        FROM RBL_MISDB_PROD.InvestmentIssuerDetail_Mod 
                                                                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                  AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                  AND IssuerEntityID <> NVL(v_BaseColumnValue, ' ')
                                                                                                  AND IssuerName = v_Value
                                                                                                  AND BranchCode = v_BranchCode
                                                                                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                      );
                                                                     EXCEPTION
                                                                        WHEN OTHERS THEN
                                                                           NULL;
                                                                     END;

                                                                     IF v_temp = 1 THEN

                                                                     BEGIN
                                                                        OPEN  v_cursor FOR
                                                                           SELECT '1' CODE  ,
                                                                                  'Data Exist' STATUS  
                                                                             FROM DUAL  ;
                                                                           DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                     END;
                                                                     ELSE

                                                                     BEGIN
                                                                        OPEN  v_cursor FOR
                                                                           SELECT '0' CODE  ,
                                                                                  'Data Not Exist' STATUS  
                                                                             FROM DUAL  ;
                                                                           DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                     END;
                                                                     END IF;

                                                                  END;
                                                                  ELSE
                                                                     IF ( v_CheckFor = 'ReportId' ) THEN
                                                                      DECLARE
                                                                        v_temp NUMBER(1, 0) := 0;

                                                                     BEGIN
                                                                        BEGIN
                                                                           SELECT 1 INTO v_temp
                                                                             FROM DUAL
                                                                            WHERE EXISTS ( SELECT 1 
                                                                                           FROM xbrl.DimXBRL_Properties 
                                                                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                     AND ReportId = v_Value
                                                                                           UNION 

                                                                                           --AND ISNULL( AuthorisationStatus,'A' ) ='A'
                                                                                           SELECT 1 
                                                                                           FROM xbrl.DimXBRL_Properties_mod 
                                                                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                                                                                     AND ReportId = v_Value );
                                                                        EXCEPTION
                                                                           WHEN OTHERS THEN
                                                                              NULL;
                                                                        END;

                                                                        IF v_temp = 1 THEN

                                                                        BEGIN
                                                                           OPEN  v_cursor FOR
                                                                              SELECT '1' CODE  ,
                                                                                     'Data Exist' STATUS  
                                                                                FROM DUAL  ;
                                                                              DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                        END;
                                                                        ELSE

                                                                        BEGIN
                                                                           OPEN  v_cursor FOR
                                                                              SELECT '0' CODE  ,
                                                                                     'Data Not Exist' STATUS  
                                                                                FROM DUAL  ;
                                                                              DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                        END;
                                                                        END IF;

                                                                     END;
                                                                     ELSE
                                                                        IF ( v_CheckFor = 'MobileNo_Profile' ) THEN
                                                                         DECLARE
                                                                           v_temp NUMBER(1, 0) := 0;

                                                                        BEGIN
                                                                           BEGIN
                                                                              SELECT 1 INTO v_temp
                                                                                FROM DUAL
                                                                               WHERE EXISTS ( SELECT 1 
                                                                                              FROM RBL_MISDB_PROD.TopManagementProfile 
                                                                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                        AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                        AND MobileNo LIKE '%' || v_Value || '%'
                                                                                                        AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                                        AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                              UNION 
                                                                                              SELECT 1 
                                                                                              FROM RBL_MISDB_PROD.TopManagementProfile_Mod 
                                                                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                        AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                        AND MobileNo LIKE '%' || v_Value || '%'
                                                                                                        AND MgmtProfileEntityId <> NVL(v_BaseColumnValue, ' ') );
                                                                           EXCEPTION
                                                                              WHEN OTHERS THEN
                                                                                 NULL;
                                                                           END;

                                                                           IF v_temp = 1 THEN

                                                                           BEGIN
                                                                              OPEN  v_cursor FOR
                                                                                 SELECT '1' CODE  ,
                                                                                        'Data Exist' STATUS  
                                                                                   FROM DUAL  ;
                                                                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                           END;
                                                                           ELSE

                                                                           BEGIN
                                                                              OPEN  v_cursor FOR
                                                                                 SELECT '0' CODE  ,
                                                                                        'Data Not Exist' STATUS  
                                                                                   FROM DUAL  ;
                                                                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                           END;
                                                                           END IF;

                                                                        END;
                                                                        ELSE
                                                                           IF ( v_CheckFor = 'SuitRefNo' ) THEN
                                                                            DECLARE
                                                                              v_temp NUMBER(1, 0) := 0;

                                                                           BEGIN
                                                                              BEGIN
                                                                                 SELECT 1 INTO v_temp
                                                                                   FROM DUAL
                                                                                  WHERE EXISTS ( SELECT 1 
                                                                                                 FROM RBL_MISDB_PROD.AdvCustStressedAssetDetail 
                                                                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                           AND SuitRefNo LIKE '%' || v_Value || '%'
                                                                                                           AND LitigationEntityId <> NVL(v_BaseColumnValue, ' ')
                                                                                                           AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                 UNION 
                                                                                                 SELECT 1 
                                                                                                 FROM RBL_MISDB_PROD.AdvCustStressedAssetDetail_Mod 
                                                                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                           AND SuitRefNo LIKE '%' || v_Value || '%'
                                                                                                           AND LitigationEntityId <> NVL(v_BaseColumnValue, ' ') );
                                                                              EXCEPTION
                                                                                 WHEN OTHERS THEN
                                                                                    NULL;
                                                                              END;

                                                                              IF v_temp = 1 THEN

                                                                              BEGIN
                                                                                 OPEN  v_cursor FOR
                                                                                    SELECT '1' CODE  ,
                                                                                           'Data Exist' STATUS  
                                                                                      FROM DUAL  ;
                                                                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                              END;
                                                                              ELSE

                                                                              BEGIN
                                                                                 OPEN  v_cursor FOR
                                                                                    SELECT '0' CODE  ,
                                                                                           'Data Not Exist' STATUS  
                                                                                      FROM DUAL  ;
                                                                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                              END;
                                                                              END IF;

                                                                           END;
                                                                           ELSE
                                                                              IF ( v_CheckFor = 'MobileNo_Application' ) THEN
                                                                               DECLARE
                                                                                 v_temp NUMBER(1, 0) := 0;

                                                                              BEGIN
                                                                                 BEGIN
                                                                                    SELECT 1 INTO v_temp
                                                                                      FROM DUAL
                                                                                     WHERE EXISTS ( SELECT 1 
                                                                                                    FROM RBL_MISDB_PROD.Inward 
                                                                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                              AND MobileNo LIKE '%' || v_Value || '%'
                                                                                                              AND InwardNo <> NVL(v_BaseColumnValue, ' ')
                                                                                                              AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                    UNION 
                                                                                                    SELECT 1 
                                                                                                    FROM RBL_MISDB_PROD.Inward_Mod 
                                                                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                              AND MobileNo LIKE '%' || v_Value || '%'
                                                                                                              AND InwardNo <> NVL(v_BaseColumnValue, ' ') );
                                                                                 EXCEPTION
                                                                                    WHEN OTHERS THEN
                                                                                       NULL;
                                                                                 END;

                                                                                 IF v_temp = 1 THEN

                                                                                 BEGIN
                                                                                    OPEN  v_cursor FOR
                                                                                       SELECT '1' CODE  ,
                                                                                              'Data Exist' STATUS  
                                                                                         FROM DUAL  ;
                                                                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                 END;
                                                                                 ELSE

                                                                                 BEGIN
                                                                                    OPEN  v_cursor FOR
                                                                                       SELECT '0' CODE  ,
                                                                                              'Data Not Exist' STATUS  
                                                                                         FROM DUAL  ;
                                                                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                 END;
                                                                                 END IF;

                                                                              END;
                                                                              ELSE
                                                                                 IF ( v_CheckFor = 'CustomerId' ) THEN
                                                                                  DECLARE
                                                                                    v_temp NUMBER(1, 0) := 0;

                                                                                 BEGIN
                                                                                    DBMS_OUTPUT.PUT_LINE('Customer ID');
                                                                                    BEGIN
                                                                                       SELECT 1 INTO v_temp
                                                                                         FROM DUAL
                                                                                        WHERE EXISTS ( SELECT 1 
                                                                                                       FROM SHG_DirectMembersDetail 
                                                                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                                                                 AND CustomerId = v_Value
                                                                                                                 AND SHGEntityId <> NVL(v_BaseColumnValue, ' ') )
                                                                                                                 AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                       UNION 
                                                                                                       SELECT 1 
                                                                                                       FROM SHG_DirectMembersDetail_Mod 
                                                                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                                                                 AND CustomerId = v_Value
                                                                                                                 AND SHGEntityId <> NVL(v_BaseColumnValue, ' ') )
                                                                                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                     );
                                                                                    EXCEPTION
                                                                                       WHEN OTHERS THEN
                                                                                          NULL;
                                                                                    END;

                                                                                    IF v_temp = 1 THEN

                                                                                    BEGIN
                                                                                       OPEN  v_cursor FOR
                                                                                          SELECT '1' CODE  ,
                                                                                                 'Data Exist' STATUS  
                                                                                            FROM DUAL  ;
                                                                                          DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                    END;
                                                                                    ELSE

                                                                                    BEGIN
                                                                                       OPEN  v_cursor FOR
                                                                                          SELECT '0' CODE  ,
                                                                                                 'Data Not Exist' STATUS  
                                                                                            FROM DUAL  ;
                                                                                          DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                    END;
                                                                                    END IF;

                                                                                 END;
                                                                                 ELSE
                                                                                    IF ( v_CheckFor = 'BGCustomerId' ) THEN
                                                                                     DECLARE
                                                                                       v_temp NUMBER(1, 0) := 0;

                                                                                    BEGIN
                                                                                       BEGIN
                                                                                          SELECT 1 INTO v_temp
                                                                                            FROM DUAL
                                                                                           WHERE EXISTS ( SELECT 1 
                                                                                                          FROM RBL_MISDB_PROD.AdvNFAcBasicDetail 
                                                                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                    AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                    --AND FraudEntityId<>isnull(@BaseColumnValue,'')
                                                                                                                    AND CustomerId = v_Value

                                                                                                                    -- AND BranchCode = @BranchCode
                                                                                                                    AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                          UNION 
                                                                                                          SELECT 1 
                                                                                                          FROM RBL_MISDB_PROD.AdvNFAcBasicDetail_mod 
                                                                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                    AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                    --AND FraudEntityId<>isnull(@BaseColumnValue,'')
                                                                                                                    AND CustomerId = v_Value

                                                                                                                    --AND BranchCode = @BranchCode
                                                                                                                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                        );
                                                                                       EXCEPTION
                                                                                          WHEN OTHERS THEN
                                                                                             NULL;
                                                                                       END;

                                                                                       IF v_temp = 1 THEN

                                                                                       BEGIN
                                                                                          OPEN  v_cursor FOR
                                                                                             SELECT '1' CODE  ,
                                                                                                    'Data Exist' STATUS  
                                                                                               FROM DUAL  ;
                                                                                             DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                       END;
                                                                                       ELSE

                                                                                       BEGIN
                                                                                          OPEN  v_cursor FOR
                                                                                             SELECT '0' CODE  ,
                                                                                                    'Data Not Exist' STATUS  
                                                                                               FROM DUAL  ;
                                                                                             DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                       END;
                                                                                       END IF;

                                                                                    END;
                                                                                    ELSE
                                                                                       IF ( v_CheckFor = 'SheetName' ) THEN
                                                                                        DECLARE
                                                                                          v_temp NUMBER(1, 0) := 0;

                                                                                       BEGIN
                                                                                          BEGIN
                                                                                             SELECT 1 INTO v_temp
                                                                                               FROM DUAL
                                                                                              WHERE EXISTS ( SELECT 1 
                                                                                                             FROM RBL_MISDB_PROD.ExcelUtility_DataMapping 
                                                                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                       AND ReportEntityId = v_BaseColumnValue
                                                                                                                       AND SheetName = v_Value
                                                                                                                       AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                             UNION 
                                                                                                             SELECT 1 
                                                                                                             FROM RBL_MISDB_PROD.ExcelUtility_DataMapping_Mod 
                                                                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                       AND ReportEntityId = v_BaseColumnValue
                                                                                                                       AND SheetName = v_Value
                                                                                                                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                           );
                                                                                          EXCEPTION
                                                                                             WHEN OTHERS THEN
                                                                                                NULL;
                                                                                          END;

                                                                                          IF v_temp = 1 THEN

                                                                                          BEGIN
                                                                                             OPEN  v_cursor FOR
                                                                                                SELECT '1' CODE  ,
                                                                                                       'Data Exist' STATUS  
                                                                                                  FROM DUAL  ;
                                                                                                DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                          END;
                                                                                          ELSE

                                                                                          BEGIN
                                                                                             OPEN  v_cursor FOR
                                                                                                SELECT '0' CODE  ,
                                                                                                       'Data Not Exist' STATUS  
                                                                                                  FROM DUAL  ;
                                                                                                DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                          END;
                                                                                          END IF;

                                                                                       END;
                                                                                       ELSE
                                                                                          IF ( v_CheckFor = 'BusinessSegEnumartion' ) THEN
                                                                                           DECLARE
                                                                                             v_temp NUMBER(1, 0) := 0;

                                                                                          BEGIN
                                                                                             BEGIN
                                                                                                SELECT 1 INTO v_temp
                                                                                                  FROM DUAL
                                                                                                 WHERE EXISTS ( SELECT 1 
                                                                                                                FROM RBL_MISDB_PROD.DimTargetMaster 
                                                                                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                          AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                          -- AND TargetAlt_Key=@BaseColumnValue
                                                                                                                          AND BusinessSegEnumartion = v_Value
                                                                                                                          AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                UNION 
                                                                                                                SELECT 1 
                                                                                                                FROM RBL_MISDB_PROD.DimTargetMaster_Mod 
                                                                                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                          AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                          --   AND TargetAlt_Key=@BaseColumnValue
                                                                                                                          AND BusinessSegEnumartion = v_Value
                                                                                                                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                              );
                                                                                             EXCEPTION
                                                                                                WHEN OTHERS THEN
                                                                                                   NULL;
                                                                                             END;

                                                                                             IF v_temp = 1 THEN

                                                                                             BEGIN
                                                                                                OPEN  v_cursor FOR
                                                                                                   SELECT '1' CODE  ,
                                                                                                          'Data Exist' STATUS  
                                                                                                     FROM DUAL  ;
                                                                                                   DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                             END;
                                                                                             ELSE

                                                                                             BEGIN
                                                                                                OPEN  v_cursor FOR
                                                                                                   SELECT '0' CODE  ,
                                                                                                          'Data Not Exist' STATUS  
                                                                                                     FROM DUAL  ;
                                                                                                   DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                             END;
                                                                                             END IF;

                                                                                          END;
                                                                                          ELSE
                                                                                             IF ( v_CheckFor = 'BGOriginalLimitRefNo' ) THEN
                                                                                              DECLARE
                                                                                                v_AccountId NUMBER(10,0);
                                                                                                v_temp NUMBER(1, 0) := 0;

                                                                                             BEGIN
                                                                                                SELECT MAX(CustomerACID)  

                                                                                                  INTO v_AccountId
                                                                                                  FROM ( SELECT MAX(CustomerACID)  CustomerACID  
                                                                                                         FROM RBL_MISDB_PROD.AdvNFAcBasicDetail 
                                                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                   AND BranchCode = v_BranchCode
                                                                                                                   AND OriginalLimitRefNo = v_Value

                                                                                                                   --AND AccountEntityId=@BaseColumnValue

                                                                                                                   --and CustomerACID = @CustomerACID
                                                                                                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                         UNION 
                                                                                                         SELECT MAX(CustomerACID)  CustomerACID  
                                                                                                         FROM RBL_MISDB_PROD.AdvNFAcBasicDetail_mod 
                                                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                   AND BranchCode = v_BranchCode
                                                                                                                   AND OriginalLimitRefNo = v_Value

                                                                                                                   --AND AccountEntityId=@BaseColumnValue

                                                                                                                   --and CustomerACID = @CustomerACID
                                                                                                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                        ) A;
                                                                                                BEGIN
                                                                                                   SELECT 1 INTO v_temp
                                                                                                     FROM DUAL
                                                                                                    WHERE EXISTS ( SELECT 1 
                                                                                                                   FROM RBL_MISDB_PROD.AdvNFAcBasicDetail 
                                                                                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                             AND BranchCode = v_BranchCode
                                                                                                                             AND OriginalLimitRefNo = v_Value

                                                                                                                             --AND AccountEntityId=@BaseColumnValue

                                                                                                                             --and CustomerACID = @CustomerACID

                                                                                                                             --AND @CustomerACID = @AccountId
                                                                                                                             AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                   UNION 
                                                                                                                   SELECT 1 
                                                                                                                   FROM RBL_MISDB_PROD.AdvNFAcBasicDetail_mod 
                                                                                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                             AND BranchCode = v_BranchCode
                                                                                                                             AND OriginalLimitRefNo = v_Value

                                                                                                                             --AND AccountEntityId=@BaseColumnValue

                                                                                                                             --and CustomerACID = @CustomerACID
                                                                                                                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                 );
                                                                                                EXCEPTION
                                                                                                   WHEN OTHERS THEN
                                                                                                      NULL;
                                                                                                END;

                                                                                                IF v_temp = 1 THEN

                                                                                                BEGIN
                                                                                                   OPEN  v_cursor FOR
                                                                                                      SELECT CASE 
                                                                                                                  WHEN v_CustomerACID = v_AccountId THEN '0'
                                                                                                             ELSE '1'
                                                                                                                END CODE  ,
                                                                                                             CASE 
                                                                                                                  WHEN v_CustomerACID = v_AccountId THEN 'Data Not Exist'
                                                                                                             ELSE 'Data Exist'
                                                                                                                END STATUS  
                                                                                                        FROM DUAL  ;
                                                                                                      DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                END;
                                                                                                ELSE

                                                                                                BEGIN
                                                                                                   OPEN  v_cursor FOR
                                                                                                      SELECT '0' CODE  ,
                                                                                                             'Data Not Exist' STATUS  
                                                                                                        FROM DUAL  ;
                                                                                                      DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                END;
                                                                                                END IF;

                                                                                             END;

                                                                                             --commented by Mohsin	
                                                                                             ELSE
                                                                                                IF ( v_CheckFor = 'BranchCode' ) THEN
                                                                                                 DECLARE
                                                                                                   v_temp NUMBER(1, 0) := 0;

                                                                                                BEGIN
                                                                                                   BEGIN
                                                                                                      SELECT 1 INTO v_temp
                                                                                                        FROM DUAL
                                                                                                       WHERE EXISTS ( SELECT 1 
                                                                                                                      FROM RBL_MISDB_PROD.DimBranch 
                                                                                                                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                AND BranchCode = v_Value

                                                                                                                                --AND BusinessSegEnumartion=@Value
                                                                                                                                AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                      UNION 
                                                                                                                      SELECT 1 
                                                                                                                      FROM RBL_MISDB_PROD.DimBranch_Mod 
                                                                                                                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                AND BranchCode = v_Value

                                                                                                                                --   AND TargetAlt_Key=@BaseColumnValue

                                                                                                                                --AND BusinessSegEnumartion=@Value
                                                                                                                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                    );
                                                                                                   EXCEPTION
                                                                                                      WHEN OTHERS THEN
                                                                                                         NULL;
                                                                                                   END;

                                                                                                   IF v_temp = 1 THEN

                                                                                                   BEGIN
                                                                                                      OPEN  v_cursor FOR
                                                                                                         SELECT '1' CODE  ,
                                                                                                                'Data Exist' STATUS  
                                                                                                           FROM DUAL  ;
                                                                                                         DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                   END;
                                                                                                   ELSE

                                                                                                   BEGIN
                                                                                                      OPEN  v_cursor FOR
                                                                                                         SELECT '0' CODE  ,
                                                                                                                'Data Not Exist' STATUS  
                                                                                                           FROM DUAL  ;
                                                                                                         DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                   END;
                                                                                                   END IF;

                                                                                                END;
                                                                                                ELSE
                                                                                                   IF ( v_CheckFor = 'BranchName' ) THEN
                                                                                                    DECLARE
                                                                                                      v_temp NUMBER(1, 0) := 0;

                                                                                                   BEGIN
                                                                                                      BEGIN
                                                                                                         SELECT 1 INTO v_temp
                                                                                                           FROM DUAL
                                                                                                          WHERE EXISTS ( SELECT 1 
                                                                                                                         FROM RBL_MISDB_PROD.DimBranch 
                                                                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                   AND BranchName = v_Value

                                                                                                                                   --AND BusinessSegEnumartion=@Value
                                                                                                                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                         UNION 
                                                                                                                         SELECT 1 
                                                                                                                         FROM RBL_MISDB_PROD.DimBranch_Mod 
                                                                                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                   AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                   AND BranchName = v_Value

                                                                                                                                   --   AND TargetAlt_Key=@BaseColumnValue

                                                                                                                                   --AND BusinessSegEnumartion=@Value
                                                                                                                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                       );
                                                                                                      EXCEPTION
                                                                                                         WHEN OTHERS THEN
                                                                                                            NULL;
                                                                                                      END;

                                                                                                      IF v_temp = 1 THEN

                                                                                                      BEGIN
                                                                                                         OPEN  v_cursor FOR
                                                                                                            SELECT '1' CODE  ,
                                                                                                                   'Data Exist' STATUS  
                                                                                                              FROM DUAL  ;
                                                                                                            DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                      END;
                                                                                                      ELSE

                                                                                                      BEGIN
                                                                                                         OPEN  v_cursor FOR
                                                                                                            SELECT '0' CODE  ,
                                                                                                                   'Data Not Exist' STATUS  
                                                                                                              FROM DUAL  ;
                                                                                                            DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                      END;
                                                                                                      END IF;

                                                                                                   END;
                                                                                                   ELSE
                                                                                                      IF ( v_CheckFor = 'GLCode' ) THEN
                                                                                                       DECLARE
                                                                                                         v_temp NUMBER(1, 0) := 0;

                                                                                                      BEGIN
                                                                                                         BEGIN
                                                                                                            SELECT 1 INTO v_temp
                                                                                                              FROM DUAL
                                                                                                             WHERE EXISTS ( SELECT 1 
                                                                                                                            FROM RBL_MISDB_PROD.DimGL 
                                                                                                                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                      AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                                      --AND TerritoryAlt_Key = @NextValue
                                                                                                                                      AND GLAlt_Key = v_Value
                                                                                                                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                            UNION 
                                                                                                                            SELECT 1 
                                                                                                                            FROM RBL_MISDB_PROD.DimGL_Mod 
                                                                                                                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                      AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                                      --AND TerritoryAlt_Key = @NextValue
                                                                                                                                      AND GLAlt_Key = v_Value
                                                                                                                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                          );
                                                                                                         EXCEPTION
                                                                                                            WHEN OTHERS THEN
                                                                                                               NULL;
                                                                                                         END;

                                                                                                         IF v_temp = 1 THEN

                                                                                                         BEGIN
                                                                                                            OPEN  v_cursor FOR
                                                                                                               SELECT '1' CODE  ,
                                                                                                                      'Data Exist' STATUS  
                                                                                                                 FROM DUAL  ;
                                                                                                               DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                         END;
                                                                                                         ELSE

                                                                                                         BEGIN
                                                                                                            OPEN  v_cursor FOR
                                                                                                               SELECT '0' CODE  ,
                                                                                                                      'Data Not Exist' STATUS  
                                                                                                                 FROM DUAL  ;
                                                                                                               DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                         END;
                                                                                                         END IF;

                                                                                                      END;
                                                                                                      ELSE
                                                                                                         IF ( v_CheckFor = 'GLName' ) THEN
                                                                                                          DECLARE
                                                                                                            v_temp NUMBER(1, 0) := 0;

                                                                                                         BEGIN
                                                                                                            BEGIN
                                                                                                               SELECT 1 INTO v_temp
                                                                                                                 FROM DUAL
                                                                                                                WHERE EXISTS ( SELECT 1 
                                                                                                                               FROM RBL_MISDB_PROD.DimGL 
                                                                                                                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                         AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                                         --AND TerritoryAlt_Key = @NextValue
                                                                                                                                         AND GLName = v_Value
                                                                                                                                         AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                               UNION 
                                                                                                                               SELECT 1 
                                                                                                                               FROM RBL_MISDB_PROD.DimGL_Mod 
                                                                                                                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                         AND EffectiveToTimeKey >= v_TimeKey )

                                                                                                                                         --AND TerritoryAlt_Key = @NextValue
                                                                                                                                         AND GLName = v_Value
                                                                                                                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                             );
                                                                                                            EXCEPTION
                                                                                                               WHEN OTHERS THEN
                                                                                                                  NULL;
                                                                                                            END;

                                                                                                            IF v_temp = 1 THEN

                                                                                                            BEGIN
                                                                                                               OPEN  v_cursor FOR
                                                                                                                  SELECT '1' CODE  ,
                                                                                                                         'Data Exist' STATUS  
                                                                                                                    FROM DUAL  ;
                                                                                                                  DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                            END;
                                                                                                            ELSE

                                                                                                            BEGIN
                                                                                                               OPEN  v_cursor FOR
                                                                                                                  SELECT '0' CODE  ,
                                                                                                                         'Data Not Exist' STATUS  
                                                                                                                    FROM DUAL  ;
                                                                                                                  DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                            END;
                                                                                                            END IF;

                                                                                                         END;
                                                                                                         ELSE
                                                                                                            IF ( v_CheckFor = 'BACID' ) THEN
                                                                                                             DECLARE
                                                                                                               v_temp NUMBER(1, 0) := 0;

                                                                                                            BEGIN
                                                                                                               BEGIN
                                                                                                                  SELECT 1 INTO v_temp
                                                                                                                    FROM DUAL
                                                                                                                   WHERE EXISTS ( SELECT 1 
                                                                                                                                  FROM RBL_MISDB_PROD.DimOfficeAccountBACID 
                                                                                                                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                            AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                            AND TerritoryAlt_Key = v_NextValue
                                                                                                                                            AND CurrencyAlt_Key = v_ThirdValue
                                                                                                                                            AND BACID = v_Value
                                                                                                                                            AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                  UNION 
                                                                                                                                  SELECT 1 
                                                                                                                                  FROM RBL_MISDB_PROD.DimOfficeAccountBACID_mod 
                                                                                                                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                            AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                            AND TerritoryAlt_Key = v_NextValue
                                                                                                                                            AND CurrencyAlt_Key = v_ThirdValue
                                                                                                                                            AND BACID = v_Value
                                                                                                                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                );
                                                                                                               EXCEPTION
                                                                                                                  WHEN OTHERS THEN
                                                                                                                     NULL;
                                                                                                               END;

                                                                                                               IF v_temp = 1 THEN

                                                                                                               BEGIN
                                                                                                                  OPEN  v_cursor FOR
                                                                                                                     SELECT '1' CODE  ,
                                                                                                                            'Data Exist' STATUS  
                                                                                                                       FROM DUAL  ;
                                                                                                                     DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                               END;
                                                                                                               ELSE

                                                                                                               BEGIN
                                                                                                                  OPEN  v_cursor FOR
                                                                                                                     SELECT '0' CODE  ,
                                                                                                                            'Data Not Exist' STATUS  
                                                                                                                       FROM DUAL  ;
                                                                                                                     DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                               END;
                                                                                                               END IF;

                                                                                                            END;
                                                                                                            ELSE
                                                                                                               IF ( v_CheckFor = 'DepartmentCode' ) THEN
                                                                                                                DECLARE
                                                                                                                  v_temp NUMBER(1, 0) := 0;

                                                                                                               BEGIN
                                                                                                                  BEGIN
                                                                                                                     SELECT 1 INTO v_temp
                                                                                                                       FROM DUAL
                                                                                                                      WHERE EXISTS ( SELECT 1 
                                                                                                                                     FROM RBL_MISDB_PROD.dimdepartment 
                                                                                                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                               AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                               AND DepartmentCode = v_Value
                                                                                                                                               AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                     UNION 
                                                                                                                                     SELECT 1 
                                                                                                                                     FROM RBL_MISDB_PROD.DimDepartment_Mod 
                                                                                                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                               AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                               AND DepartmentCode = v_Value
                                                                                                                                               AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                   );
                                                                                                                  EXCEPTION
                                                                                                                     WHEN OTHERS THEN
                                                                                                                        NULL;
                                                                                                                  END;

                                                                                                                  IF v_temp = 1 THEN

                                                                                                                  BEGIN
                                                                                                                     OPEN  v_cursor FOR
                                                                                                                        SELECT '1' CODE  ,
                                                                                                                               'Data Exist' STATUS  
                                                                                                                          FROM DUAL  ;
                                                                                                                        DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                  END;
                                                                                                                  ELSE

                                                                                                                  BEGIN
                                                                                                                     OPEN  v_cursor FOR
                                                                                                                        SELECT '0' CODE  ,
                                                                                                                               'Data Not Exist' STATUS  
                                                                                                                          FROM DUAL  ;
                                                                                                                        DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                  END;
                                                                                                                  END IF;

                                                                                                               END;
                                                                                                               ELSE
                                                                                                                  IF ( v_CheckFor = 'DepartmentShortName' ) THEN
                                                                                                                   DECLARE
                                                                                                                     v_temp NUMBER(1, 0) := 0;

                                                                                                                  BEGIN
                                                                                                                     BEGIN
                                                                                                                        SELECT 1 INTO v_temp
                                                                                                                          FROM DUAL
                                                                                                                         WHERE EXISTS ( SELECT 1 
                                                                                                                                        FROM RBL_MISDB_PROD.dimdepartment 
                                                                                                                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                  AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                  AND DepartmentShortName = v_Value
                                                                                                                                                  AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                        UNION 
                                                                                                                                        SELECT 1 
                                                                                                                                        FROM RBL_MISDB_PROD.DimDepartment_Mod 
                                                                                                                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                  AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                  AND DepartmentShortName = v_Value
                                                                                                                                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                      );
                                                                                                                     EXCEPTION
                                                                                                                        WHEN OTHERS THEN
                                                                                                                           NULL;
                                                                                                                     END;

                                                                                                                     IF v_temp = 1 THEN

                                                                                                                     BEGIN
                                                                                                                        OPEN  v_cursor FOR
                                                                                                                           SELECT '1' CODE  ,
                                                                                                                                  'Data Exist' STATUS  
                                                                                                                             FROM DUAL  ;
                                                                                                                           DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                     END;
                                                                                                                     ELSE

                                                                                                                     BEGIN
                                                                                                                        OPEN  v_cursor FOR
                                                                                                                           SELECT '0' CODE  ,
                                                                                                                                  'Data Not Exist' STATUS  
                                                                                                                             FROM DUAL  ;
                                                                                                                           DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                     END;
                                                                                                                     END IF;

                                                                                                                  END;
                                                                                                                  ELSE
                                                                                                                     IF ( v_CheckFor = 'BACIDDept' ) THEN
                                                                                                                      DECLARE
                                                                                                                        v_temp NUMBER(1, 0) := 0;

                                                                                                                     BEGIN
                                                                                                                        BEGIN
                                                                                                                           SELECT 1 INTO v_temp
                                                                                                                             FROM DUAL
                                                                                                                            WHERE EXISTS ( SELECT 1 
                                                                                                                                           FROM RBL_MISDB_PROD.DimDepartmentBACID 
                                                                                                                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                     AND TerritoryAlt_Key = v_NextValue
                                                                                                                                                     AND BACID = v_ThirdValue
                                                                                                                                                     AND BranchCode = v_FourthValue
                                                                                                                                                     AND DepartmentAlt_Key = v_Value
                                                                                                                                                     AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                           UNION 
                                                                                                                                           SELECT 1 
                                                                                                                                           FROM RBL_MISDB_PROD.DimDepartmentBACID_mod 
                                                                                                                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                     AND TerritoryAlt_Key = v_NextValue
                                                                                                                                                     AND BACID = v_ThirdValue
                                                                                                                                                     AND BranchCode = v_FourthValue
                                                                                                                                                     AND DepartmentAlt_Key = v_Value
                                                                                                                                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                         );
                                                                                                                        EXCEPTION
                                                                                                                           WHEN OTHERS THEN
                                                                                                                              NULL;
                                                                                                                        END;

                                                                                                                        IF v_temp = 1 THEN

                                                                                                                        BEGIN
                                                                                                                           OPEN  v_cursor FOR
                                                                                                                              SELECT '1' CODE  ,
                                                                                                                                     'Data Exist' STATUS  
                                                                                                                                FROM DUAL  ;
                                                                                                                              DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                        END;
                                                                                                                        ELSE

                                                                                                                        BEGIN
                                                                                                                           OPEN  v_cursor FOR
                                                                                                                              SELECT '0' CODE  ,
                                                                                                                                     'Data Not Exist' STATUS  
                                                                                                                                FROM DUAL  ;
                                                                                                                              DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                        END;
                                                                                                                        END IF;

                                                                                                                     END;
                                                                                                                     ELSE
                                                                                                                        IF ( v_CheckFor = 'ContactPersonid' ) THEN
                                                                                                                         DECLARE
                                                                                                                           v_temp NUMBER(1, 0) := 0;

                                                                                                                        BEGIN
                                                                                                                           BEGIN
                                                                                                                              SELECT 1 INTO v_temp
                                                                                                                                FROM DUAL
                                                                                                                               WHERE EXISTS ( SELECT 1 
                                                                                                                                              FROM RBL_MISDB_PROD.DimDepartmentContactPersonsAgeing 
                                                                                                                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                        AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                        AND DepartmentAlt_Key = v_NextValue
                                                                                                                                                        AND ContactPersonid = v_Value
                                                                                                                                                        AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                              UNION 
                                                                                                                                              SELECT 1 
                                                                                                                                              FROM RBL_MISDB_PROD.DimDepartmentContactPersonsAgeing_Mod 
                                                                                                                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                        AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                        AND DepartmentAlt_Key = v_NextValue
                                                                                                                                                        AND ContactPersonid = v_Value
                                                                                                                                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                            );
                                                                                                                           EXCEPTION
                                                                                                                              WHEN OTHERS THEN
                                                                                                                                 NULL;
                                                                                                                           END;

                                                                                                                           IF v_temp = 1 THEN

                                                                                                                           BEGIN
                                                                                                                              OPEN  v_cursor FOR
                                                                                                                                 SELECT '1' CODE  ,
                                                                                                                                        'Data Exist' STATUS  
                                                                                                                                   FROM DUAL  ;
                                                                                                                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                           END;
                                                                                                                           ELSE

                                                                                                                           BEGIN
                                                                                                                              OPEN  v_cursor FOR
                                                                                                                                 SELECT '0' CODE  ,
                                                                                                                                        'Data Not Exist' STATUS  
                                                                                                                                   FROM DUAL  ;
                                                                                                                                 DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                           END;
                                                                                                                           END IF;

                                                                                                                        END;
                                                                                                                        ELSE
                                                                                                                           IF ( v_CheckFor = 'ContactpersonName' ) THEN
                                                                                                                            DECLARE
                                                                                                                              v_temp NUMBER(1, 0) := 0;

                                                                                                                           BEGIN
                                                                                                                              BEGIN
                                                                                                                                 SELECT 1 INTO v_temp
                                                                                                                                   FROM DUAL
                                                                                                                                  WHERE EXISTS ( SELECT 1 
                                                                                                                                                 FROM RBL_MISDB_PROD.DimBranchContactPerson 
                                                                                                                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                           AND BranchCode = v_BranchCode
                                                                                                                                                           AND ContactpersonName = v_Value
                                                                                                                                                           AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                                 UNION 
                                                                                                                                                 SELECT 1 
                                                                                                                                                 FROM RBL_MISDB_PROD.DimBranchContactPerson_Mod 
                                                                                                                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                           AND BranchCode = v_BranchCode
                                                                                                                                                           AND ContactpersonName = v_Value
                                                                                                                                                           AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                               );
                                                                                                                              EXCEPTION
                                                                                                                                 WHEN OTHERS THEN
                                                                                                                                    NULL;
                                                                                                                              END;

                                                                                                                              IF v_temp = 1 THEN

                                                                                                                              BEGIN
                                                                                                                                 OPEN  v_cursor FOR
                                                                                                                                    SELECT '1' CODE  ,
                                                                                                                                           'Data Exist' STATUS  
                                                                                                                                      FROM DUAL  ;
                                                                                                                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                              END;
                                                                                                                              ELSE

                                                                                                                              BEGIN
                                                                                                                                 OPEN  v_cursor FOR
                                                                                                                                    SELECT '0' CODE  ,
                                                                                                                                           'Data Not Exist' STATUS  
                                                                                                                                      FROM DUAL  ;
                                                                                                                                    DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                              END;
                                                                                                                              END IF;

                                                                                                                           END;
                                                                                                                           ELSE
                                                                                                                              IF ( v_CheckFor = 'EmployeeID' ) THEN
                                                                                                                               DECLARE
                                                                                                                                 v_temp NUMBER(1, 0) := 0;

                                                                                                                              BEGIN
                                                                                                                                 BEGIN
                                                                                                                                    SELECT 1 INTO v_temp
                                                                                                                                      FROM DUAL
                                                                                                                                     WHERE EXISTS ( SELECT 1 
                                                                                                                                                    FROM RBL_MISDB_PROD.DimBranchContactPerson 
                                                                                                                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                              AND BranchCode = v_BranchCode
                                                                                                                                                              AND EmployeeID = v_Value
                                                                                                                                                              AND NVL(AuthorisationStatus, 'A') = 'A'
                                                                                                                                                    UNION 
                                                                                                                                                    SELECT 1 
                                                                                                                                                    FROM RBL_MISDB_PROD.DimBranchContactPerson_Mod 
                                                                                                                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                                                              AND BranchCode = v_BranchCode
                                                                                                                                                              AND EmployeeID = v_Value
                                                                                                                                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                                                                                                                  );
                                                                                                                                 EXCEPTION
                                                                                                                                    WHEN OTHERS THEN
                                                                                                                                       NULL;
                                                                                                                                 END;

                                                                                                                                 IF v_temp = 1 THEN

                                                                                                                                 BEGIN
                                                                                                                                    OPEN  v_cursor FOR
                                                                                                                                       SELECT '1' CODE  ,
                                                                                                                                              'Data Exist' STATUS  
                                                                                                                                         FROM DUAL  ;
                                                                                                                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                                 END;
                                                                                                                                 ELSE

                                                                                                                                 BEGIN
                                                                                                                                    OPEN  v_cursor FOR
                                                                                                                                       SELECT '0' CODE  ,
                                                                                                                                              'Data Not Exist' STATUS  
                                                                                                                                         FROM DUAL  ;
                                                                                                                                       DBMS_SQL.RETURN_RESULT(v_cursor);

                                                                                                                                 END;
                                                                                                                                 END IF;

                                                                                                                              END;
                                                                                                                              END IF;
                                                                                                                           END IF;
                                                                                                                        END IF;
                                                                                                                     END IF;
                                                                                                                  END IF;
                                                                                                               END IF;
                                                                                                            END IF;
                                                                                                         END IF;
                                                                                                      END IF;
                                                                                                   END IF;
                                                                                                END IF;
                                                                                             END IF;
                                                                                          END IF;
                                                                                       END IF;
                                                                                    END IF;
                                                                                 END IF;
                                                                              END IF;
                                                                           END IF;
                                                                        END IF;
                                                                     END IF;
                                                                  END IF;
                                                               END IF;
                                                            END IF;
                                                         END IF;
                                                      END IF;
                                                   END IF;
                                                END IF;
                                             END IF;
                                          END IF;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DUPLICATE_VERIFICATION" TO "ADF_CDR_RBL_STGDB";
