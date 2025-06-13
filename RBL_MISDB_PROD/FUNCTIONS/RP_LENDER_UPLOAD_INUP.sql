--------------------------------------------------------
--  DDL for Function RP_LENDER_UPLOAD_INUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" 
(
  v_XMLDocument IN CLOB DEFAULT ' ' ,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_D2KTimeStamp OUT NUMBER/* DEFAULT 0*/,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuId IN NUMBER DEFAULT 6100 ,
  v_ErrorMsg OUT VARCHAR2/* DEFAULT ' '*/
)
RETURN NUMBER
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM ACLProcessInProgressStatus 
                       WHERE  STATUS = 'RUNNING'
                                AND StatusFlag = 'N'
                                AND TimeKey IN ( SELECT MAX(Timekey)  
                                                 FROM ACLProcessInProgressStatus  )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process is In Progress');

   END;

   --IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )

   --BEGIN

   --	PRINT 'ACL Process Completed'
   ELSE
   DECLARE
      v_CustomerEntityId NUMBER(10,0);
      v_CreatedBy VARCHAR2(50);
      v_DateCreated DATE;
      v_ModifiedBy VARCHAR2(50);
      v_DateModified DATE;
      v_ApprovedBy VARCHAR2(50);
      v_DateApproved DATE;
      v_AuthorisationStatus VARCHAR2(5);
      v_ErrorHandle NUMBER(5,0) := 0;
      v_ExEntityKey NUMBER(10,0) := 0;
      v_Data_Sequence NUMBER(10,0) := 0;

   BEGIN
      IF utils.object_id('TEMPDB..tt_LENDERDATAUPLOAD') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LENDERDATAUPLOAD ';
      END IF;
      DELETE FROM tt_LENDERDATAUPLOAD;
      UTILS.IDENTITY_RESET('tt_LENDERDATAUPLOAD');

      INSERT INTO tt_LENDERDATAUPLOAD ( 
      	SELECT /*TODO:SQLDEV*/ C.value('./UCIC_ID[1]','VARCHAR(30)') /*END:SQLDEV*/ UCIC_ID  ,
              /*TODO:SQLDEV*/ C.value('./CustomerID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerID  ,
              /*TODO:SQLDEV*/ C.value('./PAN_No [1]','VARCHAR(20)') /*END:SQLDEV*/ Pan_No  ,
              /*TODO:SQLDEV*/ C.value('./CustomerName [1]','VARCHAR(255)') /*END:SQLDEV*/ CustomerName  ,
              /*TODO:SQLDEV*/ C.value('./LenderName [1]','VARCHAR(100)') /*END:SQLDEV*/ LenderName  ,
              /*TODO:SQLDEV*/ C.value('./InDefaultDate [1]','VARCHAR(20)') /*END:SQLDEV*/ InDefaultDate  ,
              /*TODO:SQLDEV*/ C.value('./OutOfDefaultDate [1]','VARCHAR(20)') /*END:SQLDEV*/ OutOfDefaultDate  
      	  FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/DataSet/Gridrow') AS t(c) /*END:SQLDEV*/)  );
      --select * from tt_LENDERDATAUPLOAD
      --return
      IF v_OperationFlag = 1 THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         --------------------------Added on 11-01-2021  Mod Table Authorize Data to be Expired If Again Uploading after Authorized Data
         DBMS_OUTPUT.PUT_LINE('SUNIL');
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RP_Lender_Upload_Mod D
                                   JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND D.CustomerID = GD.CustomerID
                             WHERE  D.AuthorisationStatus IN ( 'A' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('EXISTS');
            MERGE INTO D 
            USING (SELECT D.ROWID row_id, v_EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
            FROM D ,RP_Lender_Upload_Mod D
                   JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND D.CustomerID = GD.CustomerID 
             WHERE D.AuthorisationStatus IN ( 'A' )
            ) src
            ON ( D.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET D.EffectiveToTimeKey = src.EffectiveToTimeKey;

         END;
         END IF;
         --------------------------------------------------------------------
         DBMS_OUTPUT.PUT_LINE('1');
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RP_Lender_Upload_Mod D
                                   JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND D.CustomerID = GD.CustomerID
                             WHERE  D.AuthorisationStatus IN ( 'MP','NP','DP','RM' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('EXISTS');
            v_Result := -4 ;
            SELECT DISTINCT utils.stuff(( SELECT DISTINCT ', ' || UTILS.CONVERT_TO_VARCHAR2(CustomerID,4000) 
                                          FROM tt_LENDERDATAUPLOAD t2 ), 1, 1, ' ') 

              INTO v_ErrorMsg
              FROM RP_Lender_Upload_Mod D
                     JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                     AND EffectiveToTimeKey >= v_TimeKey )
                     AND D.CustomerID = GD.CustomerID
             WHERE  D.AuthorisationStatus IN ( 'MP','NP','DP','RM' )
            ;
            v_ErrorMsg := 'Authorization Pending for Customer id ' || UTILS.CONVERT_TO_VARCHAR2(v_ErrorMsg,4000) || ' Please Authorize first' ;
            RETURN v_Result;

         END;
         END IF;
         --ELSE 

         BEGIN
            --SET @CustomerEntityId = 
            SELECT MAX(CustomerEntityId)  

              INTO v_CustomerEntityId
              FROM ( SELECT MAX(Entitykey)  CustomerEntityId  
                     FROM RP_Lender_Details 
                     UNION 
                     SELECT MAX(Entitykey)  CustomerEntityId  
                     FROM RP_Lender_Upload_Mod  ) A;
            v_CustomerEntityId := NVL(v_CustomerEntityId, 0) ;

         END;

      END;
      END IF;
      BEGIN

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
            --SELECT @CustomerEntityId
            IF v_OperationFlag = 1
              AND v_AuthMode = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(2);
               v_CreatedBy := v_CrModApBy ;
               v_DateCreated := SYSDATE ;
               v_AuthorisationStatus := 'NP' ;
               GOTO BusinessMatrix_Insert;
               <<BusinessMatrix_Insert_Add>>

            END;
            END IF;
            --SET @Result=1
            --ELSE
            IF ( v_OperationFlag = 3
              OR v_OperationFlag = 2 )
              AND v_AuthMode = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(2);
               v_CreatedBy := v_CrModApBy ;
               v_DateCreated := SYSDATE ;
               v_Modifiedby := v_CrModApBy ;
               v_DateModified := SYSDATE ;
               DBMS_OUTPUT.PUT_LINE(22);
               IF v_OperationFlag = 3 THEN

               BEGIN
                  v_AuthorisationStatus := 'DP' ;

               END;
               ELSE

               BEGIN
                  v_AuthorisationStatus := 'MP' ;

               END;
               END IF;
               ---FIND CREADED BY FROM MAIN TABLE 
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RP_Lender_Details D
                        JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey );
               DBMS_OUTPUT.PUT_LINE(v_CreatedBy);
               DBMS_OUTPUT.PUT_LINE(v_DateCreated);
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(44);
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM RP_Lender_Upload_Mod D
                           JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND D.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('OperationFlag');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  MERGE INTO D 
                  USING (SELECT D.ROWID row_id, v_AuthorisationStatus
                  FROM D ,RP_Lender_Details D
                         JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                   WHERE ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )) src
                  ON ( D.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET D.AuthorisationStatus = v_AuthorisationStatus;

               END;
               END IF;
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('FM');
                  MERGE INTO D 
                  USING (SELECT D.ROWID row_id, 'FM', v_Modifiedby, v_DateModified
                  FROM D ,RP_Lender_Upload_Mod D
                         JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                   WHERE ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND D.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                  ) src
                  ON ( D.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET D.AuthorisationStatus = 'FM',
                                               D.ModifiedBy = v_Modifiedby,
                                               D.DateModified = v_DateModified;

               END;
               END IF;
               GOTO BusinessMatrix_Insert;
               <<BusinessMatrix_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  --SELECT * FROM ##DimBSCodeStructure
                  -- DELETE WITHOUT MAKER CHECKER
                  DBMS_OUTPUT.PUT_LINE('DELETE');
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  MERGE INTO D 
                  USING (SELECT D.ROWID row_id, v_Modifiedby, v_DateModified, v_EffectiveFromTimeKey - 1 AS pos_4
                  FROM D ,RP_Lender_Details D
                         JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                   WHERE ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )) src
                  ON ( D.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET ModifiedBy = v_Modifiedby,
                                               DateModified = v_DateModified,
                                               EffectiveToTimeKey = pos_4;
                  DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,2) || LPAD(' ', 1, ' ') || 'ROW DELETED');
                  v_RESULT := v_CustomerEntityId ;

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('REJECT');
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     MERGE INTO D 
                     USING (SELECT D.ROWID row_id, 'R', v_ApprovedBy, v_DateApproved, v_EffectiveFromTimeKey - 1 AS pos_5
                     FROM D ,RP_Lender_Upload_Mod D
                            JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                      WHERE ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND D.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ) src
                     ON ( D.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'R',
                                                  ApprovedBy = v_ApprovedBy,
                                                  DateApproved = v_DateApproved,
                                                  EffectiveToTimeKey = pos_5;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM RP_Lender_Details D
                                               JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_TimeKey )
                                               AND D.CustomerID = GD.CustomerID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        MERGE INTO D 
                        USING (SELECT D.ROWID row_id, 'A'
                        FROM D ,RP_Lender_Details D
                               JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                         WHERE ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND D.AuthorisationStatus IN ( 'MP','DP','RM' )
                        ) src
                        ON ( D.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'A';

                     END;
                     END IF;

                  END;

                  ----------------Two level Auth. changes---------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('REJECT');
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        MERGE INTO D 
                        USING (SELECT D.ROWID row_id, 'R', v_ApprovedBy, v_DateApproved, v_EffectiveFromTimeKey - 1 AS pos_5
                        FROM D ,RP_Lender_Upload_Mod D
                               JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                         WHERE ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND D.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ) src
                        ON ( D.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'R',
                                                     ApprovedBy = v_ApprovedBy,
                                                     DateApproved = v_DateApproved,
                                                     EffectiveToTimeKey = pos_5;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM RP_Lender_Details D
                                                  JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_TimeKey )
                                                  AND D.CustomerID = GD.CustomerID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           MERGE INTO D 
                           USING (SELECT D.ROWID row_id, 'A'
                           FROM D ,RP_Lender_Details D
                                  JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                            WHERE ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND D.AuthorisationStatus IN ( 'MP','DP','RM' )
                           ) src
                           ON ( D.ROWID = src.row_id )
                           WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'A';

                        END;
                        END IF;

                     END;

                     --------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 18
                          AND v_AuthMode = 'Y' THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE('remarks');
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           --SET @FactTargetEntityId=(select FactTargetEntityId from #FactTarget)
                           --select @GroupAlt_Key
                           MERGE INTO D 
                           USING (SELECT D.ROWID row_id, 'RM', v_ApprovedBy, v_DateApproved
                           FROM D ,RP_Lender_Upload_Mod D
                                  JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                            WHERE ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND D.AuthorisationStatus IN ( 'NP','MP','DP' )
                           ) src
                           ON ( D.ROWID = src.row_id )
                           WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'RM',
                                                        ApprovedBy = v_ApprovedBy,
                                                        DateApproved = v_DateApproved;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              MERGE INTO D 
                              USING (SELECT D.ROWID row_id, '1A', v_ApprovedBy, v_DateApproved
                              FROM D ,RP_Lender_Upload_Mod D
                                     JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID 
                               WHERE ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND D.AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ) src
                              ON ( D.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET AuthorisationStatus = '1A',
                                                           ApprovedBy = v_ApprovedBy,
                                                           DateApproved = v_DateApproved;

                           END;
                           ELSE
                              IF v_OperationFlag = 20
                                OR v_AuthMode = 'N' THEN

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('a1');
                                 IF v_AuthMode = 'N' THEN

                                 BEGIN
                                    IF v_OperationFlag = 1 THEN

                                    BEGIN
                                       v_CreatedBy := v_CrModApBy ;
                                       v_DateCreated := SYSDATE ;

                                    END;
                                    ELSE

                                    BEGIN
                                       v_ModifiedBy := v_CrModApBy ;
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM RP_Lender_Details D
                                                JOIN tt_LENDERDATAUPLOAD GD   ON D.CustomerID = GD.CustomerID
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey );
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AuthMode = 'Y' THEN
                                  DECLARE
                                    v_DelStatus CHAR(2) := ' ';
                                    v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                                    v_CurEntityKey NUMBER(10,0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('B');
                                    --SELECT  * FROM ##DimBSCodeStructure
                                    DBMS_OUTPUT.PUT_LINE('C');
                                    SELECT MAX(Entitykey)  

                                      INTO v_ExEntityKey
                                      FROM RP_Lender_Upload_Mod A
                                             JOIN tt_LENDERDATAUPLOAD C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey )
                                             AND A.CustomerID = C.CustomerID
                                     WHERE  a.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                                    SELECT a.AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifiedBy ,
                                           DateModified 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModified
                                      FROM RP_Lender_Upload_Mod A
                                             JOIN tt_LENDERDATAUPLOAD C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey )
                                             AND A.CustomerID = C.CustomerID
                                     WHERE  Entitykey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(Entitykey)  

                                      INTO v_ExEntityKey
                                      FROM RP_Lender_Upload_Mod A
                                             JOIN tt_LENDERDATAUPLOAD C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey )
                                             AND A.CustomerID = C.CustomerID
                                     WHERE  a.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT A.EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM RP_Lender_Upload_Mod A
                                             JOIN tt_LENDERDATAUPLOAD C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey )
                                             AND A.CustomerID = C.CustomerID
                                             AND Entitykey = v_ExEntityKey;
                                    MERGE INTO A 
                                    USING (SELECT A.ROWID row_id, v_CurrRecordFromTimeKey - 1 AS EffectiveToTimeKey
                                    FROM A ,RP_Lender_Upload_Mod A
                                           JOIN tt_LENDERDATAUPLOAD C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                           AND A.EffectiveToTimeKey >= v_TimeKey )
                                           AND A.CustomerID = C.CustomerID 
                                     WHERE a.AuthorisationStatus = 'A') src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                                    DBMS_OUTPUT.PUT_LINE('A');
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('Delete Authorise');
                                       MERGE INTO G 
                                       USING (SELECT G.ROWID row_id, 'A', v_ApprovedBy, v_DateApproved, v_EffectiveFromTimeKey - 1 AS pos_5
                                       FROM G ,RP_Lender_Upload_Mod G
                                              JOIN tt_LENDERDATAUPLOAD GD   ON G.CustomerID = GD.CustomerID
                                            --AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode

                                        WHERE G.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ) src
                                       ON ( G.ROWID = src.row_id )
                                       WHEN MATCHED THEN UPDATE SET G.AuthorisationStatus = 'A',
                                                                    ApprovedBy = v_ApprovedBy,
                                                                    DateApproved = v_DateApproved,
                                                                    EffectiveToTimeKey = pos_5;
                                       DBMS_OUTPUT.PUT_LINE('BE');
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM RP_Lender_Details G
                                                                 JOIN tt_LENDERDATAUPLOAD GD   ON G.CustomerID = GD.CustomerID
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey ) );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('EXPIRE');
                                          MERGE INTO G 
                                          USING (SELECT G.ROWID row_id, 'A', v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, v_EffectiveFromTimeKey - 1 AS pos_7
                                          FROM G ,RP_Lender_Details G
                                                 JOIN tt_LENDERDATAUPLOAD GD   ON G.CustomerID = GD.CustomerID 
                                           WHERE ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )) src
                                          ON ( G.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'A',
                                                                       ModifiedBy = v_ModifiedBy,
                                                                       DateModified = v_DateModified,
                                                                       ApprovedBy = v_ApprovedBy,
                                                                       DateApproved = v_DateApproved,
                                                                       EffectiveToTimeKey = pos_7;

                                       END;
                                       END IF;

                                    END;
                                    ELSE

                                    BEGIN
                                       MERGE INTO G 
                                       USING (SELECT G.ROWID row_id, 'A', v_ApprovedBy, v_DateApproved
                                       FROM G ,RP_Lender_Upload_Mod G
                                              JOIN tt_LENDERDATAUPLOAD GD   ON G.CustomerID = GD.CustomerID 
                                        WHERE G.AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ) src
                                       ON ( G.ROWID = src.row_id )
                                       WHEN MATCHED THEN UPDATE SET AuthorisationStatus = 'A',
                                                                    ApprovedBy = v_ApprovedBy,
                                                                    DateApproved = v_DateApproved;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF NVL(v_DelStatus, 'A') <> 'DP'
                                   OR v_AuthMode = 'N' THEN
                                  DECLARE
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus || 'AuthorisationStatus');
                                    DBMS_OUTPUT.PUT_LINE(v_AUTHMODE || 'Authmode');
                                    v_AuthorisationStatus := 'A' ;
                                    DELETE G
                                     WHERE ROWID IN 
                                    ( SELECT G.ROWID
                                      FROM RP_Lender_Details G
                                             JOIN tt_LENDERDATAUPLOAD GD   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                                             AND G.EffectiveToTimeKey >= v_TimeKey )
                                             AND G.CustomerID = GD.CustomerID,
                                           G
                                     WHERE  G.EffectiveFromTimeKey = v_EffectiveFromTimeKey );--and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
                                    DBMS_OUTPUT.PUT_LINE('ROW deleted' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,10) || 'Deleted');
                                    MERGE INTO G 
                                    USING (SELECT G.ROWID row_id, v_EffectiveFromTimeKey - 1 AS pos_2, 'A' --ADDED ON 12 FEB 2018

                                    FROM G ,RP_Lender_Details G
                                           JOIN tt_LENDERDATAUPLOAD GD   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                                           AND G.EffectiveToTimeKey >= v_TimeKey )
                                           AND G.CustomerID = GD.CustomerID 
                                     WHERE G.EffectiveFromTimeKey < v_EffectiveFromTimeKey) src
                                    ON ( G.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET G.EffectiveTOTimeKey = pos_2,
                                                                 G.AuthorisationStatus = 'A';--and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
                                    DBMS_OUTPUT.PUT_LINE('ROW deleted' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,10));
                                    IF v_AuthMode = 'N' THEN

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;

                                    END;
                                    END IF;
                                    -- SELECT @CustomerEntityId= MAX(CustomerEntityId)  FROM  
                                    --	(SELECT MAX(Entitykey) CustomerEntityId FROM RP_Lender_Details
                                    --	 UNION 
                                    --	 SELECT MAX(Entitykey) CustomerEntityId FROM  RP_Lender_Upload_Mod
                                    --	)A
                                    --SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)
                                    --------------------------Added on 11-01-2021  Main Table Authorize Data to be Expired If Again Uploading after Authorized Data
                                    DBMS_OUTPUT.PUT_LINE('SUNIL1');
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM RP_Lender_Details D
                                                              JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND D.CustomerID = GD.CustomerID
                                                        WHERE  D.AuthorisationStatus IN ( 'A' )
                                     );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('EXISTS');
                                       MERGE INTO D 
                                       USING (SELECT D.ROWID row_id, v_EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
                                       FROM D ,RP_Lender_Details D
                                              JOIN tt_LENDERDATAUPLOAD GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey )
                                              AND D.CustomerID = GD.CustomerID 
                                        WHERE D.AuthorisationStatus IN ( 'A' )
                                       ) src
                                       ON ( D.ROWID = src.row_id )
                                       WHEN MATCHED THEN UPDATE SET D.EffectiveToTimeKey = src.EffectiveToTimeKey;

                                    END;
                                    END IF;
                                    --------------------------------------------------------------------
                                    INSERT INTO RP_Lender_Details
                                      ( CustomerID, ReportingLenderAlt_Key, InDefaultDate, OutOfDefaultDate, DefaultStatus, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                      ( SELECT DISTINCT
                                        --UCIC_ID
                                         CustomerID ,
                                         --,PAN_No
                                         --,CustomerName
                                         D.BankRPAlt_Key LenderAlt_Key  ,
                                         --,(Case when convert(DATE,InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
                                         --,(Case when convert(DATE,OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate
                                         (CASE 
                                               WHEN UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,20) = ' ' THEN NULL
                                         ELSE UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,200,p_style=>103)
                                            END) InDefaultDate  ,
                                         (CASE 
                                               WHEN UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,20) = ' ' THEN NULL
                                         ELSE UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,200,p_style=>103)
                                            END) OutOfDefaultDate  ,
                                         (CASE 
                                               WHEN NVL(OutOfDefaultDate, ' ') <> ' ' THEN 'Out Default'
                                         ELSE 'In Default'
                                            END) DefaultStatus  ,
                                         CASE 
                                              WHEN v_AuthMode = 'Y' THEN v_AuthorisationStatus
                                         ELSE NULL
                                            END col  ,
                                         v_EffectiveFromTimeKey ,
                                         v_EffectiveToTimeKey ,
                                         v_CreatedBy ,
                                         v_DateCreated ,
                                         v_ModifiedBy ,
                                         v_DateModified ,
                                         CASE 
                                              WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                         ELSE NULL
                                            END col  ,
                                         CASE 
                                              WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                         ELSE NULL
                                            END col  
                                        FROM tt_LENDERDATAUPLOAD S
                                               JOIN DimBankRP D   ON S.LenderName = D.BankName
                                               AND D.EffectiveFromTimeKey <= v_TimeKey
                                               AND D.EffectiveToTimeKey >= v_TimeKey );
                                    ----------------------------------------------------------------- From Lender Details Update Calculation for Portfolio Columns Added On 08-01-2021 -------
                                    IF utils.object_id('TempDB..tt_PortfolioCustomer') IS NOT NULL THEN
                                     EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PortfolioCustomer ';
                                    END IF;
                                    DELETE FROM tt_PortfolioCustomer;
                                    UTILS.IDENTITY_RESET('tt_PortfolioCustomer');

                                    INSERT INTO tt_PortfolioCustomer ( 
                                    	SELECT A.* 
                                    	  FROM RP_Portfolio_Details A
                                              JOIN DimExposureBucket DE   ON DE.ExposureBucketAlt_Key = A.ExposureBucketAlt_Key
                                              AND DE.EffectiveFromTimeKey <= v_TimeKey
                                              AND DE.EffectiveToTimeKey >= v_TimeKey
                                    	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                               AND A.EffectiveToTimeKey >= v_TimeKey
                                               AND DE.BucketName NOT IN ( '1500 Crs To 2000 Crs','Greater Than 2000 Crs' )
                                     );
                                    IF utils.object_id('TempDB..tt_LenderCustomer') IS NOT NULL THEN
                                     EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LenderCustomer ';
                                    END IF;
                                    DELETE FROM tt_LenderCustomer;
                                    UTILS.IDENTITY_RESET('tt_LenderCustomer');

                                    INSERT INTO tt_LenderCustomer ( 
                                    	SELECT CustomerID ,
                                            MIN(InDefaultDate)  DefaultDate  
                                    	  FROM RP_Lender_Details 
                                    	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_TimeKey
                                               AND CustomerID IN ( SELECT CustomerID 
                                                                   FROM tt_PortfolioCustomer  )

                                    	  GROUP BY CustomerID );
                                    --Select *
                                    MERGE INTO P 
                                    USING (SELECT P.ROWID row_id, L.DefaultDate, L.DefaultDate, utils.dateadd('D', 30, L.DefaultDate) AS pos_4, utils.dateadd('D', 210, L.DefaultDate) AS pos_5, utils.dateadd('D', 180, P.RP_OutOfDateAllBanksDeadline) AS pos_6, utils.dateadd('D', 75, L.DefaultDate) AS pos_7
                                    FROM P ,tt_PortfolioCustomer P
                                           JOIN tt_LenderCustomer L   ON P.CustomerID = L.CustomerID ) src
                                    ON ( P.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET P.BorrowerDefaultDate = src.DefaultDate,
                                                                 P.ReferenceDate = src.DefaultDate,
                                                                 P.ReviewExpiryDate = pos_4,
                                                                 P.RP_ExpiryDate = pos_5,
                                                                 P.Revised_RP_Expiry_Date = pos_6,
                                                                 P.RiskReviewExpiryDate = pos_7;
                                    ---------UpDate in Main Table----
                                    --Select *
                                    MERGE INTO A 
                                    USING (SELECT A.ROWID row_id, P.BorrowerDefaultDate, P.ReferenceDate, P.ReviewExpiryDate, P.RP_ExpiryDate, P.Revised_RP_Expiry_Date, P.RiskReviewExpiryDate
                                    FROM A ,RP_Portfolio_Details A
                                           JOIN tt_PortfolioCustomer P   ON A.CustomerID = P.CustomerID 
                                     WHERE A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey) src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET A.BorrowerDefaultDate = src.BorrowerDefaultDate,
                                                                 A.ReferenceDate = src.ReferenceDate,
                                                                 A.ReviewExpiryDate = src.ReviewExpiryDate,
                                                                 A.RP_ExpiryDate = src.RP_ExpiryDate,
                                                                 A.Revised_RP_Expiry_Date = src.Revised_RP_Expiry_Date,
                                                                 A.RiskReviewExpiryDate = src.RiskReviewExpiryDate;
                                    ----------------------------------------Borrower Default for exposure busket >1500crs
                                    IF utils.object_id('TempDB..tt_LenderCustomer1') IS NOT NULL THEN
                                     EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_LenderCustomer1 ';
                                    END IF;
                                    DELETE FROM tt_LenderCustomer1;
                                    UTILS.IDENTITY_RESET('tt_LenderCustomer1');

                                    INSERT INTO tt_LenderCustomer1 ( 
                                    	SELECT CustomerID ,
                                            MIN(InDefaultDate)  DefaultDate  
                                    	  FROM RP_Lender_Details 
                                    	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_TimeKey
                                               AND CustomerID NOT IN ( SELECT CustomerID 
                                                                       FROM tt_PortfolioCustomer  )

                                    	  GROUP BY CustomerID );
                                    MERGE INTO A 
                                    USING (SELECT A.ROWID row_id, P.DefaultDate
                                    FROM A ,RP_Portfolio_Details A
                                           JOIN tt_LenderCustomer1 P   ON A.CustomerID = P.CustomerID 
                                     WHERE A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey) src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET A.BorrowerDefaultDate = src.DefaultDate;
                                    -----------Added on 22nd Jan 2021----------------
                                    MERGE INTO RP_Portfolio_Details A
                                    USING (SELECT A.ROWID row_id, B.CustomerName
                                    FROM RP_Portfolio_Details A
                                           JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.CustomerID = B.RefCustomerID 
                                     WHERE A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey) src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET CustomerName = src.CustomerName;
                                    ------------------------------------------------------------------------------------
                                    -------Added on 14-04-2021
                                    IF utils.object_id('TempDB..tt_DefaultStatus') IS NOT NULL THEN
                                     EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DefaultStatus ';
                                    END IF;
                                    DELETE FROM tt_DefaultStatus;
                                    UTILS.IDENTITY_RESET('tt_DefaultStatus');

                                    INSERT INTO tt_DefaultStatus ( 
                                    	SELECT CustomerID ,
                                            DefaultStatus ,
                                            DefaultStatusAlt_key 
                                    	  FROM ( SELECT CustomerID ,
                                                     (CASE 
                                                           WHEN NVL(OutOfDefaultDate, ' ') <> ' ' THEN 'Out Default'
                                                     ELSE 'In Default'
                                                        END) DefaultStatus  ,
                                                     (CASE 
                                                           WHEN NVL(OutOfDefaultDate, ' ') <> ' ' THEN 2
                                                     ELSE 1
                                                        END) DefaultStatusAlt_key  
                                              FROM RP_Lender_Details A
                                               WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                                        AND A.EffectiveToTimeKey >= v_TimeKey
                                                        AND A.CustomerID IN ( SELECT DISTINCT CustomerID 
                                                                              FROM tt_LENDERDATAUPLOAD  )
                                             ) A
                                    	  GROUP BY CustomerID,DefaultStatus,DefaultStatusAlt_key );
                                    ----------Insert into Main With Expire
                                    --Select * 
                                    MERGE INTO A 
                                    USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
                                    FROM A ,RP_Portfolio_Details A
                                           JOIN ( SELECT tt_DefaultStatus.CustomerID ,
                                                         MIN(tt_DefaultStatus.DefaultStatusAlt_key)  DefaultStatusAlt_key  
                                                  FROM tt_DefaultStatus 
                                                    GROUP BY tt_DefaultStatus.CustomerID ) B   ON A.CustomerID = B.CustomerID 
                                     WHERE A.DefaultStatusAlt_Key <> B.DefaultStatusAlt_key) src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                                    INSERT INTO RP_Portfolio_Details
                                      ( PAN_No, UCIC_ID, CustomerID, CustomerName, BankingArrangementAlt_Key, BorrowerDefaultDate, LeadBankAlt_Key, DefaultStatusAlt_Key, ExposureBucketAlt_Key, ReferenceDate, ReviewExpiryDate, RP_ApprovalDate, RPNatureAlt_Key, If_Other, RP_ExpiryDate, RP_ImplDate, RP_ImplStatusAlt_Key, RP_failed, Revised_RP_Expiry_Date, Actual_Impl_Date, RP_OutOfDateAllBanksDeadline, IsBankExposure, AssetClassAlt_Key, RiskReviewExpiryDate, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                      ( SELECT PAN_No ,
                                               UCIC_ID ,
                                               A.CustomerID ,
                                               CustomerName ,
                                               BankingArrangementAlt_Key ,
                                               BorrowerDefaultDate ,
                                               LeadBankAlt_Key ,
                                               B.DefaultStatusAlt_key ,
                                               ExposureBucketAlt_Key ,
                                               ReferenceDate ,
                                               ReviewExpiryDate ,
                                               RP_ApprovalDate ,
                                               RPNatureAlt_Key ,
                                               If_Other ,
                                               RP_ExpiryDate ,
                                               RP_ImplDate ,
                                               (CASE 
                                                     WHEN B.DefaultStatusAlt_key = 2 THEN 1
                                                     WHEN B.DefaultStatusAlt_key = 1 THEN 2   END) RP_ImplStatusAlt_Key  ,
                                               RP_failed ,
                                               Revised_RP_Expiry_Date ,
                                               Actual_Impl_Date ,
                                               RP_OutOfDateAllBanksDeadline ,
                                               IsBankExposure ,
                                               AssetClassAlt_Key ,
                                               RiskReviewExpiryDate ,
                                               v_timekey EffectiveFromTimeKey  ,
                                               49999 EffectiveToTimeKey  ,
                                               AuthorisationStatus ,
                                               CreatedBy ,
                                               DateCreated ,
                                               ModifiedBy ,
                                               DateModified ,
                                               ApprovedBy ,
                                               DateApproved 
                                        FROM RP_Portfolio_Details A
                                               JOIN ( SELECT CustomerID ,
                                                             MIN(DefaultStatusAlt_key)  DefaultStatusAlt_key  
                                                      FROM tt_DefaultStatus 
                                                        GROUP BY CustomerID ) B   ON A.CustomerID = B.CustomerID
                                         WHERE  A.EffectiveToTimeKey = v_TimeKey - 1 );

                                 END;
                                 END IF;
                                 -----------------------------------------------------------------------------------------
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO BusinessMatrix_Insert;
                                    <<HistoryRecordInUp>>

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
            IF ( v_OperationFlag IN ( 1,2,3,16,20,17,21,18 )

              AND v_AuthMode = 'Y' ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(5);
               IF v_OperationFlag = 2 THEN

               BEGIN
                  v_CreatedBy := v_ModifiedBy ;

               END;
               END IF;

            END;
            END IF;
            --end
            --IF @OperationFlag IN(16,17) 
            --	BEGIN 
            --		SET @DateCreated= GETDATE()
            --			EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
            --				'' ,
            --				@MenuID,
            --				@CustomerEntityId,-- ReferenceID ,
            --				@CreatedBy,
            --				@ApprovedBy,-- @ApproveBy 
            --				@DateCreated,
            --				@Remark,
            --				@MenuID, -- for FXT060 screen
            --				@OperationFlag,
            --				@AuthMode
            --	END
            --ELSE
            --	BEGIN
            --	--Print @Sc
            --		EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
            --			'' ,
            --			@MenuID,
            --			@CustomerEntityId ,-- ReferenceID ,
            --			@CreatedBy,
            --			NULL,-- @ApproveBy 
            --			@DateCreated,
            --			@Remark,
            --			@MenuID, -- for FXT060 screen
            --			@OperationFlag,
            --			@AuthMode
            --	END
            v_ErrorHandle := 1 ;
            <<BusinessMatrix_Insert>>
            DBMS_OUTPUT.PUT_LINE('A');
            --SELECT  @ErrorHandle
            IF v_ErrorHandle = 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('insert into  RP_Lender_Upload_Mod');
               DBMS_OUTPUT.PUT_LINE('@ErrorHandle');
               INSERT INTO RP_Lender_Upload_Mod
                 ( CustomerEntityID, UCIC_ID, CustomerID, PAN_No, CustomerName, LenderName, InDefaultDate, OutOfDefaultDate, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 SELECT v_CustomerEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  ) ,
                        UCIC_ID ,
                        CustomerID ,
                        PAN_No ,
                        CustomerName ,
                        LenderName ,
                        --,(Case when convert(DATE,InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
                        --,(Case when convert(DATE,OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate
                        (CASE 
                              WHEN UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,20) = ' ' THEN NULL
                        ELSE UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,200,p_style=>103)
                           END) InDefaultDate  ,
                        (CASE 
                              WHEN UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,20) = ' ' THEN NULL
                        ELSE UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,200,p_style=>103)
                           END) OutOfDefaultDate  ,
                        v_EffectiveFromTimeKey ,
                        v_EffectiveToTimeKey ,
                        CASE 
                             WHEN v_AuthMode = 'Y' THEN v_AuthorisationStatus
                        ELSE NULL
                           END col  ,
                        v_CreatedBy ,
                        v_DateCreated ,
                        v_ModifiedBy ,
                        v_DateModified ,
                        CASE 
                             WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                        ELSE NULL
                           END col  ,
                        CASE 
                             WHEN v_AuthMode = 'Y' THEN v_DateApproved
                        ELSE NULL
                           END col  
                   FROM tt_LENDERDATAUPLOAD S;
               --WHERE Amount<>0
               DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,30) || 'INSERTED');
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO BusinessMatrix_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO BusinessMatrix_Insert_Edit_Delete;

                  END;
                  END IF;
               END IF;

            END;
            END IF;
            utils.commit_transaction;
            IF v_OperationFlag <> 3 THEN

            BEGIN
               --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM  RP_Lender_Upload_Mod D
               --					--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
               --					WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
               --UPDATE A SET CustomerName=B.CustomerName 		FROM  RP_Lender_Details A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.CustomerName IS NULL
               --UPDATE A SET CustomerName=B.CustomerName		FROM   RP_Lender_Upload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.CustomerName IS NULL					
               v_RESULT := 1 ;
               RETURN v_RESULT;

            END;

            --RETURN @D2Ktimestamp
            ELSE

            BEGIN
               v_Result := 0 ;
               RETURN v_RESULT;

            END;
            END IF;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         INSERT INTO RBL_MISDB_PROD.Error_Log
           ( SELECT utils.error_line ErrorLine  ,
                    SQLERRM ErrorMessage  ,
                    SQLCODE ErrorNumber  ,
                    utils.error_procedure ErrorProcedure  ,
                    utils.error_severity ErrorSeverity  ,
                    utils.error_state ErrorState  ,
                    SYSDATE 
               FROM DUAL  );
         OPEN  v_cursor FOR
            SELECT SQLERRM ERRORDESC  ,
                   utils.error_line ErrorLine  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         ROLLBACK;
         utils.resetTrancount;
         v_RESULT := -1 ;
         RETURN v_RESULT;

      END;END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDER_UPLOAD_INUP" TO "ADF_CDR_RBL_STGDB";
