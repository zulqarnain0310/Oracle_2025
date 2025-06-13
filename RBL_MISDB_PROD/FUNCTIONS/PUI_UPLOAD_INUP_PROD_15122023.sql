--------------------------------------------------------
--  DDL for Function PUI_UPLOAD_INUP_PROD_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" 
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
   v_CustomerEntityId NUMBER(10,0);
   v_CreatedBy VARCHAR2(50);
   v_DateCreated DATE;
   v_ModifiedBy VARCHAR2(50);
   v_DateModified DATE;
   v_ApprovedBy VARCHAR2(50);
   v_DateApproved DATE;
   v_AuthorisationStatus CHAR(2);
   v_ErrorHandle NUMBER(5,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_Data_Sequence NUMBER(10,0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('TEMPDB..tt_PUIDATAUPLOAD_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PUIDATAUPLOAD_3 ';
   END IF;
   DELETE FROM tt_PUIDATAUPLOAD_3;
   UTILS.IDENTITY_RESET('tt_PUIDATAUPLOAD_3');

   INSERT INTO tt_PUIDATAUPLOAD_3 ( 
   	SELECT /*TODO:SQLDEV*/ C.value('./CustomerEntityID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerEntityID  ,
           /*TODO:SQLDEV*/ C.value('./CustomerID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerID  ,
           /*TODO:SQLDEV*/ C.value('./CustomerName [1]','VARCHAR(255)') /*END:SQLDEV*/ CustomerName  ,
           /*TODO:SQLDEV*/ C.value('./AccountID [1]','VARCHAR(30)') /*END:SQLDEV*/ AccountID  ,
           /*TODO:SQLDEV*/ C.value('./OriginalEnvisagCompletionDt [1]','VARCHAR(20)') /*END:SQLDEV*/ OriginalEnvisagCompletionDt  ,
           /*TODO:SQLDEV*/ C.value('./RevisedCompletionDt [1]','VARCHAR(20)') /*END:SQLDEV*/ RevisedCompletionDt  ,
           /*TODO:SQLDEV*/ C.value('./ActualCompletionDt [1]','VARCHAR(20)') /*END:SQLDEV*/ ActualCompletionDt  ,
           /*TODO:SQLDEV*/ C.value('./ProjectCat [1]','VARCHAR(50)') /*END:SQLDEV*/ ProjectCat  ,
           /*TODO:SQLDEV*/ C.value('./ProjectDelReason [1]','VARCHAR(50)') /*END:SQLDEV*/ ProjectDelReason  ,
           /*TODO:SQLDEV*/ C.value('./StandardRestruct [1]','VARCHAR(20)') /*END:SQLDEV*/ StandardRestruct  
   	  FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/DataSet/Gridrow') AS t(c) /*END:SQLDEV*/)  );
   --select * from tt_PUIDATAUPLOAD_3
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
                         FROM AdvAcProjectDetail_Upload_Mod D
                                JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
         FROM D ,AdvAcProjectDetail_Upload_Mod D
                JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                         FROM AdvAcProjectDetail_Upload_Mod D
                                JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                                       FROM tt_PUIDATAUPLOAD_3 t2 ), 1, 1, ' ') 

           INTO v_ErrorMsg
           FROM AdvAcProjectDetail_Upload_Mod D
                  JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                  FROM AdvAcProjectDetail 
                  UNION 
                  SELECT MAX(Entitykey)  CustomerEntityId  
                  FROM AdvAcProjectDetail_Upload_Mod  ) A;
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
              FROM AdvAcProjectDetail D
                     JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID
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
                 FROM AdvAcProjectDetail_Upload_Mod D
                        JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID
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
               FROM D ,AdvAcProjectDetail D
                      JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID 
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
               FROM D ,AdvAcProjectDetail_Upload_Mod D
                      JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID 
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
               FROM D ,AdvAcProjectDetail D
                      JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID 
                WHERE ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )) src
               ON ( D.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET D.ModifiedBy = v_Modifiedby,
                                            D.DateModified = v_DateModified,
                                            D.EffectiveToTimeKey = pos_4;
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
                  FROM D ,AdvAcProjectDetail_Upload_Mod D
                         JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID 
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
                                     FROM AdvAcProjectDetail D
                                            JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                     FROM D ,AdvAcProjectDetail D
                            JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID 
                      WHERE ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND D.AuthorisationStatus IN ( 'MP','DP','RM' )
                     ) src
                     ON ( D.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET D.AuthorisationStatus = 'A';

                  END;
                  END IF;

               END;

               ---------------------Two level Auth. changes.---------------
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
                     FROM D ,AdvAcProjectDetail_Upload_Mod D
                            JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID 
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
                                        FROM AdvAcProjectDetail D
                                               JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                        FROM D ,AdvAcProjectDetail D
                               JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID 
                         WHERE ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND D.AuthorisationStatus IN ( 'MP','DP','RM' )
                        ) src
                        ON ( D.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET D.AuthorisationStatus = 'A';

                     END;
                     END IF;

                  END;

                  ------------------------------------------------------------------
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
                        FROM D ,AdvAcProjectDetail_Upload_Mod D
                               JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID 
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
                           FROM D ,AdvAcProjectDetail_Upload_Mod D
                                  JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerID = GD.CustomerID 
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
                                      FROM AdvAcProjectDetail D
                                             JOIN tt_PUIDATAUPLOAD_3 GD   ON D.CustomerId = GD.CustomerID
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
                                   FROM AdvAcProjectDetail_Upload_Mod A
                                          JOIN tt_PUIDATAUPLOAD_3 C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
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
                                   FROM AdvAcProjectDetail_Upload_Mod A
                                          JOIN tt_PUIDATAUPLOAD_3 C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey )
                                          AND A.CustomerID = C.CustomerID
                                  WHERE  Entitykey = v_ExEntityKey;
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 SELECT MIN(Entitykey)  

                                   INTO v_ExEntityKey
                                   FROM AdvAcProjectDetail_Upload_Mod A
                                          JOIN tt_PUIDATAUPLOAD_3 C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey )
                                          AND A.CustomerID = C.CustomerID
                                  WHERE  a.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                 ;
                                 SELECT A.EffectiveFromTimeKey 

                                   INTO v_CurrRecordFromTimeKey
                                   FROM AdvAcProjectDetail_Upload_Mod A
                                          JOIN tt_PUIDATAUPLOAD_3 C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey )
                                          AND A.CustomerID = C.CustomerID
                                          AND Entitykey = v_ExEntityKey;
                                 MERGE INTO A 
                                 USING (SELECT A.ROWID row_id, v_CurrRecordFromTimeKey - 1 AS EffectiveToTimeKey
                                 FROM A ,AdvAcProjectDetail_Upload_Mod A
                                        JOIN tt_PUIDATAUPLOAD_3 C   ON ( A.EffectiveFromTimeKey <= v_TimeKey
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
                                    FROM G ,AdvAcProjectDetail_Upload_Mod G
                                           JOIN tt_PUIDATAUPLOAD_3 GD   ON G.CustomerID = GD.CustomerID
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
                                                       FROM AdvAcProjectDetail G
                                                              JOIN tt_PUIDATAUPLOAD_3 GD   ON G.CustomerID = GD.CustomerID
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
                                       FROM G ,AdvAcProjectDetail G
                                              JOIN tt_PUIDATAUPLOAD_3 GD   ON G.CustomerId = GD.CustomerID 
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
                                    FROM G ,AdvAcProjectDetail_Upload_Mod G
                                           JOIN tt_PUIDATAUPLOAD_3 GD   ON G.CustomerID = GD.CustomerID 
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
                                   FROM AdvAcProjectDetail G
                                          JOIN tt_PUIDATAUPLOAD_3 GD   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                                          AND G.EffectiveToTimeKey >= v_TimeKey )
                                          AND G.CustomerID = GD.CustomerID,
                                        G
                                  WHERE  G.EffectiveFromTimeKey = v_EffectiveFromTimeKey );--and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
                                 DBMS_OUTPUT.PUT_LINE('ROW deleted' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,10) || 'Deleted');
                                 MERGE INTO G 
                                 USING (SELECT G.ROWID row_id, v_EffectiveFromTimeKey - 1 AS pos_2, 'A' --ADDED ON 12 FEB 2018

                                 FROM G ,AdvAcProjectDetail G
                                        JOIN tt_PUIDATAUPLOAD_3 GD   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                                        AND G.EffectiveToTimeKey >= v_TimeKey )
                                        AND G.CustomerId = GD.CustomerID 
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
                                 --	(SELECT MAX(Entitykey) CustomerEntityId FROM advacprojectdetail
                                 --	 UNION 
                                 --	 SELECT MAX(Entitykey) CustomerEntityId FROM  AdvAcProjectDetail_Upload_Mod
                                 --	)A
                                 --SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)
                                 --------------------------Added on 11-01-2021  Main Table Authorize Data to be Expired If Again Uploading after Authorized Data
                                 DBMS_OUTPUT.PUT_LINE('SUNIL1');
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM AdvAcProjectDetail D
                                                           JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
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
                                    FROM D ,AdvAcProjectDetail D
                                           JOIN tt_PUIDATAUPLOAD_3 GD   ON ( EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey )
                                           AND D.CustomerId = GD.CustomerID 
                                     WHERE D.AuthorisationStatus IN ( 'A' )
                                    ) src
                                    ON ( D.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET D.EffectiveToTimeKey = src.EffectiveToTimeKey;

                                 END;
                                 END IF;
                                 --------------------------------------------------------------------
                                 INSERT INTO AdvAcProjectDetail
                                   ( CustomerEntityID, RefAccountEntityId, CustomerID, CustomerName, AccountId, OriginalEnvisagCompletionDt, RevisedCompletionDt, ActualCompletionDt, ProjectCatgAlt_Key, ProjectDelReason_AltKey, StandardRestruct_AltKey, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                   ( SELECT CustomerEntityID ,
                                            'NULL' ,
                                            CustomerID ,
                                            CustomerName ,
                                            AccountID ,
                                            UTILS.CONVERT_TO_VARCHAR2(OriginalEnvisagCompletionDt,200,p_style=>103) OriginalEnvisagCompletionDt  ,
                                            UTILS.CONVERT_TO_VARCHAR2(RevisedCompletionDt,200,p_style=>103) RevisedCompletionDt  ,
                                            UTILS.CONVERT_TO_VARCHAR2(ActualCompletionDt,200,p_style=>103) ActualCompletionDt  ,
                                            PC.ParameterAlt_Key ,
                                            PDR.ParameterAlt_Key ,
                                            STD.ParameterAlt_Key ,
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
                                     FROM tt_PUIDATAUPLOAD_3 S
                                            JOIN ( SELECT ParameterAlt_Key ,
                                                          ParameterName 
                                                   FROM DimParameter 
                                                    WHERE  DimparameterName = 'ProjectCategory'
                                                             AND EffectiveFromTimeKey <= v_TimeKey
                                     AND EffectiveToTimeKey >= v_TimeKey ) PC   ON PC.ParameterName = S.ProjectCat
                                            JOIN ( SELECT ParameterAlt_Key ,
                                                          ParameterName 
                                                   FROM DimParameter 
                                                    WHERE  DimparameterName = 'ProdectDelReson'
                                                             AND EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey ) PDR   ON PDR.ParameterName = S.ProjectDelReason
                                            JOIN ( SELECT ParameterAlt_Key ,
                                                          ParameterName 
                                                   FROM DimParameter 
                                                    WHERE  DimparameterName = 'DimYesNo'
                                                             AND EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey ) STD   ON STD.ParameterName = S.StandardRestruct );

                              END;
                              END IF;
                              -----------------------------------------------------Calculated Columns Update Added on 08-01-2021 ------------
                              -------------Portfolio Main
                              --Select * 
                              ----------------------------------------------------------------------------------------
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
            --end
            IF v_OperationFlag IN ( 17,21 )

              AND v_Remark IS NULL THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('@ErrorHandle');
               INSERT INTO AdvAcProjectDetail_Upload_Mod
                 ( CustomerEntityID, CustomerID, CustomerName, AccountID, OriginalEnvisagCompletionDt, RevisedCompletionDt, ActualCompletionDt, ProjectCat, ProjectDelReason, StandardRestruct, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 ( SELECT CustomerEntityID ,
                          CustomerID ,
                          CustomerName ,
                          AccountID ,
                          UTILS.CONVERT_TO_VARCHAR2(OriginalEnvisagCompletionDt,200,p_style=>103) OriginalEnvisagCompletionDt  ,
                          UTILS.CONVERT_TO_VARCHAR2(RevisedCompletionDt,200,p_style=>103) RevisedCompletionDt  ,
                          UTILS.CONVERT_TO_VARCHAR2(ActualCompletionDt,200,p_style=>103) ActualCompletionDt  ,
                          ProjectCat ,
                          ProjectDelReason ,
                          StandardRestruct ,
                          v_EffectiveFromTimeKey ,
                          v_EffectiveToTimeKey ,
                          'NP' ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                          ELSE NULL
                             END col  ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_DateApproved
                          ELSE NULL
                             END col  ,
                          v_CreatedBy ,
                          v_DateCreated ,
                          v_ModifiedBy ,
                          v_DateModified 
                   FROM tt_PUIDATAUPLOAD_3 S );

            END;
            END IF;

         END;
         END IF;
         v_ErrorHandle := 1 ;
         <<BusinessMatrix_Insert>>
         DBMS_OUTPUT.PUT_LINE('A');
         --SELECT  @ErrorHandle
         IF v_ErrorHandle = 0 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('insert into  AdvAcProjectDetail_Upload_Mod');
            DBMS_OUTPUT.PUT_LINE('@ErrorHandle');
            INSERT INTO AdvAcProjectDetail_Upload_Mod
              ( CustomerEntityID, CustomerID, CustomerName, AccountID, OriginalEnvisagCompletionDt, RevisedCompletionDt, ActualCompletionDt, ProjectCat, ProjectDelReason, StandardRestruct, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
              SELECT v_CustomerEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                           FROM DUAL  )  ) ,
                     CustomerID ,
                     CustomerName ,
                     AccountID ,
                     UTILS.CONVERT_TO_VARCHAR2(OriginalEnvisagCompletionDt,200,p_style=>103) OriginalEnvisagCompletionDt  ,
                     UTILS.CONVERT_TO_VARCHAR2(RevisedCompletionDt,200,p_style=>103) RevisedCompletionDt  ,
                     UTILS.CONVERT_TO_VARCHAR2(ActualCompletionDt,200,p_style=>103) ActualCompletionDt  ,
                     ProjectCat ,
                     ProjectDelReason ,
                     StandardRestruct ,
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
                FROM tt_PUIDATAUPLOAD_3 S;
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
            --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM  AdvAcProjectDetail_Upload_Mod D
            --					--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
            --					WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
            --UPDATE A SET CustomerName=B.CustomerName 		FROM  advacprojectdetail A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.CustomerName IS NULL
            --UPDATE A SET CustomerName=B.CustomerName		FROM   AdvAcProjectDetail_Upload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.CustomerName IS NULL					
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
      OPEN  v_cursor FOR
         SELECT SQLERRM ERRORDESC  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ROLLBACK;
      utils.resetTrancount;
      v_RESULT := -1 ;
      RETURN v_RESULT;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_UPLOAD_INUP_PROD_15122023" TO "ADF_CDR_RBL_STGDB";
