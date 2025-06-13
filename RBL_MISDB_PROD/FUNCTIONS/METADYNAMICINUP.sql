--------------------------------------------------------
--  DDL for Function METADYNAMICINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."METADYNAMICINUP" 
-- ====================================================================================================================
 -- Author:			<Amar>
 -- Create Date:		<30-11-2014>
 -- Loading Master Data for Common Master Screen>
 -- ====================================================================================================================

(
  v_ColName IN VARCHAR2 DEFAULT ' ' ,
  iv_DataVal IN VARCHAR2 DEFAULT ' ' ,
  v_DataValAuth IN VARCHAR2 DEFAULT ' ' ,
  iv_ColName_DataVal IN VARCHAR2 DEFAULT ' ' ,
  iv_BaseColumnValue IN VARCHAR2 DEFAULT '0' ,
  v_ParentColumnValue IN VARCHAR2 DEFAULT '0' ,
  v_SourceTableName IN VARCHAR2,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 3500 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 9999 ,
  v_CreateModifyApprovedBy IN VARCHAR2 DEFAULT 'D2KAMAR' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_TimeKey IN NUMBER DEFAULT 9999 ,
  v_AuthMode IN CHAR DEFAULT 'Y' ,
  v_MenuID IN NUMBER DEFAULT 120 ,
  v_TabID IN NUMBER,
  v_Remark IN VARCHAR2 DEFAULT NULL ,
  v_ChangeField IN VARCHAR2 DEFAULT NULL ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 1*/
)
RETURN NUMBER
AS
   v_DataVal VARCHAR2(4000) := iv_DataVal;
   v_ColName_DataVal VARCHAR2(4000) := iv_ColName_DataVal;
   v_BaseColumnValue VARCHAR2(50) := iv_BaseColumnValue;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
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

   BEGIN
      DECLARE
         v_AuthorisationStatus CHAR(2) := NULL;
         v_CreatedBy VARCHAR2(20) := NULL;
         v_DateCreated DATE := NULL;
         v_Modifiedby VARCHAR2(20) := NULL;
         v_DateModified DATE := NULL;
         v_ExEntityKey NUMBER(10,0) := 0;
         v_ErrorHandle NUMBER(10,0) := 0;
         v_TableWithSchema VARCHAR2(50);
         v_TableWithSchema_Mod VARCHAR2(50);
         v_SQL VARCHAR2(4000) := ' ';
         --,@SourceTableName VARCHAR(50)
         --,@BaseColumnValue VARCHAR(50)
         v_EntityKey VARCHAR2(50);
         v_ApprovedBy VARCHAR2(20);
         v_TempSQL VARCHAR2(4000) := ' ';
         v_DateApproved DATE;
         v_BaseColumn VARCHAR2(50);
         v_ParentColumn VARCHAR2(50);

      BEGIN
         /* SET PARAMATER VALUE FOR USABLE*/
         --SET @DataVal=REPLACE(@DataVal,',',''',''')
         v_DataVal := REPLACE(v_DataVal, '''NULL''', 'NULL') ;
         --SET @DataVal=''''+@DataVal+''''
         v_DataVal := REPLACE(v_DataVal, '''''', 'NULL') ;
         v_DataVal := REPLACE(v_DataVal, '''null''', 'NULL') ;
         v_DataVal := REPLACE(v_DataVal, '''null', 'NULL') ;
         v_ColName_DataVal := REPLACE(v_ColName_DataVal, '''NULL''', 'NULL') ;
         --SET @DataVal=''''+@DataVal+''''
         v_ColName_DataVal := REPLACE(v_ColName_DataVal, '''''', 'NULL') ;
         v_ColName_DataVal := REPLACE(v_ColName_DataVal, '''null''', 'NULL') ;
         v_ColName_DataVal := REPLACE(v_ColName_DataVal, '''null', 'NULL') ;
         --SET @ColName_DataVal=@ColName_DataVal+''''
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,',',''',')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'=','=''')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''NULL''','NULL')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''''','NULL')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null''','NULL')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null','NULL')
         --SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''NULL','NULL')
         v_DataVal := REPLACE(v_DataVal, '''y''', '''Y''') ;
         v_DataVal := REPLACE(v_DataVal, '''n''', '''N''') ;
         v_DataVal := REPLACE(v_DataVal, '_AND_', '&') ;
         DBMS_OUTPUT.PUT_LINE('A1 ' || v_ColName_DataVal);
         v_ColName_DataVal := REPLACE(v_ColName_DataVal, '_AND_', '&') ;
         DBMS_OUTPUT.PUT_LINE('A2- ' || v_ColName_DataVal);
         /* Generate Alt Key and Key Column Naame*/
         SELECT NAME 

           INTO v_EntityKey
           FROM SYS.COLUMNS_ 
          WHERE  /*TODO:SQLDEV*/ OBJECT_NAME(OBJECT_ID) /*END:SQLDEV*/ = v_SourceTableName
                   AND IS_identity = 1;
         /* FIND THE SCHEMA NAME FOR MASTER TABKE*/
         SELECT /*TODO:SQLDEV*/ SCHEMA_NAME(SCHEMA_ID) /*END:SQLDEV*/ || '.' || v_SourceTableName 

           INTO v_TableWithSchema
           FROM SYS.OBJECTS 
          WHERE  NAME = v_SourceTableName
                   AND TYPE = 'U';
         SELECT /*TODO:SQLDEV*/ SCHEMA_NAME(SCHEMA_ID) /*END:SQLDEV*/ || '.' || v_SourceTableName || '_Mod' 

           INTO v_TableWithSchema_Mod
           FROM SYS.OBJECTS 
          WHERE  NAME = v_SourceTableName || '_Mod'
                   AND TYPE = 'U';
         /* FIND THE TABLE NAME */
         SELECT SourceColumn 

           INTO v_BaseColumn
           FROM MetaDynamicScreenField 
          WHERE  MenuId = v_MenuID
                   AND NVL(ParentcontrolID, 0) = CASE 
                                                      WHEN v_TabID > 0 THEN v_TabID
                 ELSE NVL(ParentcontrolID, 0)
                    END
                   AND BaseColumnType = 'BASE'
                   AND SourceTable = v_SourceTableName
                   AND ValidCode = 'Y';
         SELECT SourceColumn 

           INTO v_ParentColumn
           FROM MetaDynamicScreenField 
          WHERE  MenuId = v_MenuID
                   AND NVL(ParentcontrolID, 0) = CASE 
                                                      WHEN v_TabID > 0 THEN v_TabID
                 ELSE NVL(ParentcontrolID, 0)
                    END
                   AND BaseColumnType = 'PARENT'
                   AND SourceTable = v_SourceTableName
                   AND ValidCode = 'Y';
         /* CREATE TEMP TABLE FOR INSERT DATA DYNAMICALLY */
         IF utils.object_id('Tempdb..tt_MasterInfo') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
         END IF;
         DELETE FROM tt_MasterInfo;
         IF v_ParentColumn IS NULL THEN
          v_ParentColumn := ' ' ;
         END IF;
         /* GENERATING BASE VALE IN ADD MODE FOR MAIN TABLE, FOR ASSOCIATE TABLES USE THAT BASE VALUE */
         IF v_OperationFlag = 1
           AND v_BaseColumnValue IN ( '0',' ' )
          THEN
          DECLARE
            v_temp TT_MASTERINFO%ROWTYPE;
            cv_ins SYS_REFCURSOR;

          -- FOR FIND ALT_KEY DYNAMICALLY FROM TABLE 
         BEGIN
            EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
            /* FOR GENERATE CODE (ALT_KEY) */
            v_SQL := ' SELECT MAX(CODE)+1 AS CODE FROM ' || ' (SELECT  MAX(' || v_BaseColumn || ') AS CODE FROM ' || v_TableWithSchema || ' UNION SELECT  MAX(' || v_BaseColumn || ') AS CODE FROM ' || v_TableWithSchema_Mod || ') A' ;
            cv_ins := OPEN cv_5 FOR
            v_SQL;
            LOOP
               FETCH cv_ins INTO v_temp;
               EXIT WHEN cv_ins%NOTFOUND;
               INSERT INTO tt_MasterInfo VALUES v_temp;
            END LOOP;
            CLOSE cv_ins;
            SELECT EntityKey 

              INTO v_BaseColumnValue
              FROM tt_MasterInfo ;
            IF NVL(v_BaseColumnValue, 0) = 0 THEN

            BEGIN
               v_BaseColumnValue := 1 ;

            END;
            END IF;

         END;
         END IF;
         BEGIN

            BEGIN
               --SQL Server BEGIN TRANSACTION;
               utils.incrementTrancount;
               --RETURN 1
               --select @BaseColumnValue as BaseColumnValue
               /* <<<<<<<<<<< START OF TRANSACTIONS WITHIN ERROR HANDLING >>>>>>>>>>>	*/
               -----
               /* OPERATTION MODE ADD AND MAKER CHECKER */
               IF v_OperationFlag = 1
                 AND v_AuthMode = 'Y' THEN

               BEGIN
                  v_CreatedBy := v_CreateModifyApprovedBy ;
                  v_DateCreated := SYSDATE ;
                  v_AuthorisationStatus := 'NP' ;
                  /* JUMP POINTER TO INSDERT DATA IN MOD TABLE*/
                  GOTO CommonMaster_Insert;
                  <<CommonMaster_Insert_Add>>

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp TT_MASTERINFO%ROWTYPE;
                     cv_ins SYS_REFCURSOR;

                  BEGIN
                     v_Modifiedby := v_CreateModifyApprovedBy ;
                     v_DateModified := SYSDATE ;
                     IF v_OperationFlag = 2 THEN

                     BEGIN
                        v_AuthorisationStatus := 'MP' ;

                     END;
                     ELSE

                     BEGIN
                        v_AuthorisationStatus := 'DP' ;

                     END;
                     END IF;
                     /* FIND CREADED BY FROM MAIN TABLE	*/
                     v_SQL := ' ' ;
                     v_SQL := 'SELECT TOP(1) CreatedBy,DateCreated FROM ' || v_TableWithSchema || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                     v_SQL := v_SQL || CASE 
                                            WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                     ELSE ' '
                        END ;
                     v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                     cv_ins := EXECUTE IMMEDIATE v_SQL;
                     LOOP
                        FETCH cv_ins INTO v_temp;
                        EXIT WHEN cv_ins%NOTFOUND;
                        INSERT INTO tt_MasterInfo VALUES v_temp;
                     END LOOP;
                     CLOSE cv_ins;
                     /* FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE	*/
                     IF NOT EXISTS ( SELECT 1 
                                     FROM tt_MasterInfo  ) THEN
                      DECLARE
                        v_temp TT_MASTERINFO%ROWTYPE;
                        cv_ins SYS_REFCURSOR;

                     BEGIN
                        v_SQL := REPLACE(v_SQL, v_TableWithSchema, v_TableWithSchema_Mod) ;
                        v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')' ;
                        EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                        cv_ins := EXECUTE IMMEDIATE v_SQL;
                        LOOP
                           FETCH cv_ins INTO v_temp;
                           EXIT WHEN cv_ins%NOTFOUND;
                           INSERT INTO tt_MasterInfo VALUES v_temp;
                        END LOOP;
                        CLOSE cv_ins;

                     END;
                     ELSE

                      /*---IF DATA IS AVAILABLE IN MAIN TABLE		*/
                     BEGIN
                        /*--UPDATE FLAG IN MAIN TABLES AS MP	*/
                        v_SQL := ' ' ;
                        v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET AuthorisationStatus=' || '''' || v_AuthorisationStatus || '''' ;
                        v_SQL := v_SQL || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                        v_SQL := v_SQL || CASE 
                                               WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                        ELSE ' '
                           END ;
                        v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                        EXECUTE IMMEDIATE v_SQL;

                     END;
                     END IF;
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM tt_MasterInfo ;
                     /*UPDATE AUTHORISATIONSTATUS AS FM IN MOD TABLE IF RECORD IS ALREADY EXISTS*/
                     IF v_OperationFlag = 2 THEN

                     BEGIN
                        v_SQL := ' ' ;
                        v_SQL := 'UPDATE ' || v_TableWithSchema_Mod || ' SET AuthorisationStatus=''FM''' ;
                        v_SQL := v_SQL || ', ModifiedBy=' || '''' || v_Modifiedby || '''' || ', DateModified=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateModified,19) || +'''' ;
                        v_SQL := v_SQL || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                        v_SQL := v_SQL || CASE 
                                               WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                        ELSE ' '
                           END ;
                        v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                        v_SQL := v_SQL || ' AND AuthorisationStatus IN(''NP'',''MP'')' ;
                        EXECUTE IMMEDIATE v_SQL;

                     END;
                     END IF;
                     /* JUMP POINTER TO INSDERT DATA IN MOD TABLE*/
                     GOTO CommonMaster_Insert;
                     <<CommonMaster_Edit_Delete>>

                  END;
                  ELSE
                     IF v_OperationFlag = 3
                       AND v_AuthMode = 'N' THEN

                     BEGIN
                        /*-- DELETE RECORD IN CASE OF SCREEN IS RUNNING IN NON-MAKER CHECKER	*/
                        v_Modifiedby := v_CreateModifyApprovedBy ;
                        v_DateModified := SYSDATE ;
                        v_SQL := ' ' ;
                        v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET ' ;
                        v_SQL := v_SQL || ' ModifiedBy=' || '''' || v_Modifiedby || '''' || ', DateModified=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateModified,19) || +'''' ;
                        v_SQL := v_SQL || ' ,EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;
                        v_SQL := v_SQL || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                        v_SQL := v_SQL || CASE 
                                               WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                        ELSE ' '
                           END ;
                        v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                        EXECUTE IMMEDIATE v_SQL;

                     END;
                     ELSE
                        IF v_OperationFlag = 17
                          AND v_AuthMode = 'Y' THEN

                        BEGIN
                           /*  REJECT THE RECORD IN MAKER CHECKER */
                           v_ApprovedBy := v_CreateModifyApprovedBy ;
                           v_DateApproved := SYSDATE ;
                           v_SQL := ' ' ;
                           v_SQL := 'UPDATE ' || v_TableWithSchema_Mod || ' SET' ;
                           v_SQL := v_SQL || ' ApprovedBy=' || '''' || v_ApprovedBy || '''' || ', DateApproved=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,19) || '''' || ', AuthorisationStatus=''R''' ;
                           v_SQL := v_SQL || ', EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;
                           v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                           v_SQL := v_SQL || CASE 
                                                  WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                           ELSE ' '
                              END ;
                           v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                           v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')' ;
                           EXECUTE IMMEDIATE v_SQL;
                           /*  MARK THE AUTHORISATION STATUS 'A' IN CASE OF REJECT THE RECORD*/
                           v_SQL := ' ' ;
                           v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET' ;
                           v_SQL := v_SQL || ' AuthorisationStatus=''A''' ;
                           v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                           v_SQL := v_SQL || CASE 
                                                  WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                           ELSE ' '
                              END ;
                           v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                           v_SQL := v_SQL || ' AND AuthorisationStatus in(''MP'',''DP'')' ;
                           EXECUTE IMMEDIATE v_SQL;

                        END;
                        ELSE
                           IF v_OperationFlag = 16
                             OR v_AuthMode = 'N' THEN

                           BEGIN
                              /*  AUTHORISE DATA IN MAKER CHECKER MODE OR ADD/EDIT IN NON-MAKER CHECKER */
                              IF v_AuthMode = 'N' THEN

                              BEGIN
                                 IF v_OperationFlag = 1 THEN

                                 BEGIN
                                    v_CreatedBy := v_CreateModifyApprovedBy ;
                                    v_DateCreated := SYSDATE ;

                                 END;
                                 ELSE
                                 DECLARE
                                    v_temp TT_MASTERINFO%ROWTYPE;
                                    cv_ins SYS_REFCURSOR;

                                 BEGIN
                                    v_ModifiedBy := v_CreateModifyApprovedBy ;
                                    v_DateModified := SYSDATE ;
                                    v_SQL := ' ' ;
                                    /*-----FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE	*/
                                    v_SQL := 'SELECT CreatedBy,DateCreated FROM ' || v_TableWithSchema || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    --PRINT 'OP 2'+@SQL
                                    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                    cv_ins := EXECUTE IMMEDIATE v_SQL;
                                    LOOP
                                       FETCH cv_ins INTO v_temp;
                                       EXIT WHEN cv_ins%NOTFOUND;
                                       INSERT INTO tt_MasterInfo VALUES v_temp;
                                    END LOOP;
                                    CLOSE cv_ins;
                                    /* UPDATING CREATEDBY AND DATECREATED FROM MOD OR MAIN TABLE AS RECORD IS AVAILABLE AS PER ABOVE SCRIPT */
                                    SELECT CreatedBy ,
                                           DateCreated 

                                      INTO v_CreatedBy,
                                           v_DateCreated
                                      FROM tt_MasterInfo ;
                                    v_ApprovedBy := v_ApprovedBy ;
                                    v_DateApproved := SYSDATE ;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              -------------
                              /*--SET PARAMETERS AND UPDATE MOD TABLEIN CASE MAKER CHECKER ENABLED	*/
                              IF v_AuthMode = 'Y' THEN
                               DECLARE
                                 v_DelStatus CHAR(2);
                                 v_CurrRecordFromTimeKey NUMBER(10,0) := 0;
                                 v_temp TT_MASTERINFO%ROWTYPE;
                                 cv_ins SYS_REFCURSOR;
                                 v_temp_1 INSERT%ROWTYPE;
                                 cv_ins_1 SYS_REFCURSOR;
                                 v_CurEntityKey NUMBER(10,0) := 0;
                                 v_temp_2 INSERT%ROWTYPE;
                                 cv_ins_2 SYS_REFCURSOR;
                                 v_MinEntityKey NUMBER(10,0) := 0;
                                 v_temp_3 INSERT%ROWTYPE;
                                 cv_ins_3 SYS_REFCURSOR;

                              BEGIN
                                 v_SQL := 'SELECT MAX(' || v_EntityKey || ') EntityKey FROM ' || v_TableWithSchema_Mod || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                 v_SQL := v_SQL || CASE 
                                                        WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                 ELSE ' '
                                    END ;
                                 v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                 v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')' ;
                                 EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                 cv_ins := EXECUTE IMMEDIATE v_SQL;
                                 LOOP
                                    FETCH cv_ins INTO v_temp;
                                    EXIT WHEN cv_ins%NOTFOUND;
                                    INSERT INTO tt_MasterInfo VALUES v_temp;
                                 END LOOP;
                                 CLOSE cv_ins;
                                 SELECT EntityKey 

                                   INTO v_ExEntityKey
                                   FROM tt_MasterInfo ;
                                 v_SQL := 'SELECT AuthorisationStatus,CreatedBy,DateCreated,ModifiedBy, DateModified FROM ' || v_TableWithSchema_Mod || ' WHERE ' || v_EntityKey || '=' || UTILS.CONVERT_TO_VARCHAR2(v_ExEntityKey,10) ;
                                 EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                 cv_ins := OPEN cv_5 FOR
                                 v_SQL;
                                 LOOP
                                    FETCH cv_ins INTO v_temp;
                                    EXIT WHEN cv_ins%NOTFOUND;
                                    INSERT INTO tt_MasterInfo VALUES v_temp;
                                 END LOOP;
                                 CLOSE cv_ins;
                                 SELECT AuthorisationStatus ,
                                        CreatedBy ,
                                        DateCreated ,
                                        ModifiedBy ,
                                        DateModified 

                                   INTO v_DelStatus,
                                        v_CreatedBy,
                                        v_DateCreated,
                                        v_ModifiedBy,
                                        v_DateModified
                                   FROM tt_MasterInfo ;
                                 v_ApprovedBy := v_CreateModifyApprovedBy ;
                                 v_DateApproved := SYSDATE ;
                                 v_SQL := 'SELECT MIN(' || v_EntityKey || ') EntityKey FROM ' || v_TableWithSchema_Mod || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                 v_SQL := v_SQL || CASE 
                                                        WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                 ELSE ' '
                                    END ;
                                 v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                 v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')' ;
                                 EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                 cv_ins := EXECUTE IMMEDIATE v_SQL;
                                 LOOP
                                    FETCH cv_ins INTO v_temp;
                                    EXIT WHEN cv_ins%NOTFOUND;
                                    INSERT INTO tt_MasterInfo VALUES v_temp;
                                 END LOOP;
                                 CLOSE cv_ins;
                                 SELECT EntityKey 

                                   INTO v_MinEntityKey
                                   FROM tt_MasterInfo ;
                                 v_SQL := 'SELECT EffectiveFromTimeKey FROM ' || v_TableWithSchema_Mod || ' WHERE ' || v_EntityKey || '=' || UTILS.CONVERT_TO_VARCHAR2(v_MinEntityKey,10) ;
                                 EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                 cv_ins := OPEN cv_6 FOR
                                 v_SQL;
                                 LOOP
                                    FETCH cv_ins INTO v_temp;
                                    EXIT WHEN cv_ins%NOTFOUND;
                                    INSERT INTO tt_MasterInfo VALUES v_temp;
                                 END LOOP;
                                 CLOSE cv_ins;
                                 SELECT EffectiveFromTimeKey 

                                   INTO v_CurrRecordFromTimeKey
                                   FROM tt_MasterInfo ;
                                 v_SQL := ' ' ;
                                 v_SQL := 'UPDATE ' || v_TableWithSchema_Mod || ' SET' ;
                                 v_SQL := v_SQL || ' EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;-- TEMPORARY USING CURRENT TIMEKEY 
                                 --SET @SQL=@SQL+' EffectiveToTimeKey='+CAST(@CurrRecordFromTimeKey-1 AS VARCHAR(5))
                                 v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                 v_SQL := v_SQL || CASE 
                                                        WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                 ELSE ' '
                                    END ;
                                 v_SQL := v_SQL || ' AND ' || v_BaseColumnValue || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                 v_SQL := v_SQL || ' AND AuthorisationStatus=''A''' ;
                                 EXECUTE IMMEDIATE v_SQL;
                                 IF v_DelStatus = 'DP' THEN

                                 BEGIN
                                    /* DELETE REORD AND AUTHORISE IN MAKER CHECKER */
                                    v_SQL := ' ' ;
                                    v_SQL := 'UPDATE ' || v_TableWithSchema_Mod || ' SET' ;
                                    v_SQL := v_SQL || ' ApprovedBy=' || '''' || v_ApprovedBy || '''' || ', DateApproved=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,19) || '''' || ', AuthorisationStatus=''A''' ;
                                    v_SQL := v_SQL || ', EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;
                                    v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')' ;
                                    EXECUTE IMMEDIATE v_SQL;
                                    v_SQL := ' ' ;
                                    v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET' ;
                                    v_SQL := v_SQL || ' ApprovedBy=' || '''' || v_ApprovedBy || '''' || ', DateApproved=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,19) || '''' || ', AuthorisationStatus=''A''' ;
                                    v_SQL := v_SQL || ' ,ModifiedBy=' || '''' || v_ModifiedBy || '''' || ', DateModified=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateModified,19) || '''' ;
                                    v_SQL := v_SQL || ' ,EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;
                                    v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    EXECUTE IMMEDIATE v_SQL;

                                 END;
                                  -- END OF DELETE BLOCK
                                 ELSE

                                  -- OTHER THAN DELETE STATUS
                                 BEGIN
                                    v_SQL := ' ' ;
                                    v_SQL := 'UPDATE ' || v_TableWithSchema_Mod || ' SET' ;
                                    v_SQL := v_SQL || ' ApprovedBy=' || '''' || v_ApprovedBy || '''' || ', DateApproved=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,19) || '''' || ', AuthorisationStatus=''A''' ;
                                    v_SQL := v_SQL || '  WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    v_SQL := v_SQL || ' AND AuthorisationStatus in(''NP'',''MP'')' ;
                                    EXECUTE IMMEDIATE v_SQL;
                                    DBMS_OUTPUT.PUT_LINE(v_SQL);

                                 END;
                                 END IF;

                              END;
                              END IF;
                              IF NVL(v_DelStatus, ' ') <> 'DP'
                                OR v_AuthMode = 'N' THEN
                               DECLARE
                                 v_IsAvailable CHAR(1) := 'N';
                                 v_IsSCD2 CHAR(1) := 'N';
                                 v_temp TT_MASTERINFO%ROWTYPE;
                                 cv_ins SYS_REFCURSOR;

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('tri');
                                 /* GENERATING QUERY FOR RECORD IS EXISTING OR NOT */
                                 v_SQL := 'SELECT 1 EntityKey FROM ' || v_TableWithSchema || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                 v_SQL := v_SQL || CASE 
                                                        WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                 ELSE ' '
                                    END ;
                                 v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                 EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                 OPEN  v_cursor FOR
                                    SELECT 'AB' ,
                                           v_SQL 
                                      FROM DUAL  ;
                                    DBMS_SQL.RETURN_RESULT(v_cursor);
                                 cv_ins := EXECUTE IMMEDIATE v_SQL;
                                 LOOP
                                    FETCH cv_ins INTO v_temp;
                                    EXIT WHEN cv_ins%NOTFOUND;
                                    INSERT INTO tt_MasterInfo VALUES v_temp;
                                 END LOOP;
                                 CLOSE cv_ins;
                                 IF EXISTS ( SELECT 1 
                                             FROM tt_MasterInfo  ) THEN
                                  DECLARE
                                    v_temp TT_MASTERINFO%ROWTYPE;
                                    cv_ins SYS_REFCURSOR;

                                 BEGIN
                                    /* GENERATING QUERY FOR RECORD IS EXISTING ON SAME TIMEKEY OR PREV. TIMEKEY */
                                    v_IsAvailable := 'Y' ;
                                    v_AuthorisationStatus := 'A' ;
                                    v_SQL := 'SELECT 1 EntityKey FROM ' || v_TableWithSchema || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || 'AND EffectiveFromTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey,5) ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    DBMS_OUTPUT.PUT_LINE(v_sql);
                                    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MasterInfo ';
                                    cv_ins := EXECUTE IMMEDIATE v_SQL;
                                    LOOP
                                       FETCH cv_ins INTO v_temp;
                                       EXIT WHEN cv_ins%NOTFOUND;
                                       INSERT INTO tt_MasterInfo VALUES v_temp;
                                    END LOOP;
                                    CLOSE cv_ins;
                                    OPEN  v_cursor FOR
                                       SELECT * 
                                         FROM tt_MasterInfo  ;
                                       DBMS_SQL.RETURN_RESULT(v_cursor);
                                    DBMS_OUTPUT.PUT_LINE('12344556');
                                    IF EXISTS ( SELECT 1 
                                                FROM tt_MasterInfo  ) THEN

                                    BEGIN
                                       /* UPDATING RECORD IN CASE OF AVAILABLE ON SAME TIMEKEY*/
                                       v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET ' ;
                                       v_SQL := v_SQL || v_ColName_DataVal ;
                                       v_SQL := v_SQL || ',ModifiedBy =' || '''' || v_ModifiedBy || '''' ;
                                       v_SQL := v_SQL || ',DateModified=' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateModified,19) || '''' ;
                                       v_SQL := v_SQL || ',ApprovedBy=CASE WHEN ''' || v_AUTHMODE || '''= ''Y'' THEN ' || '''' || NVL(v_ApprovedBy, ' ') || '''' || 'ELSE NULL END' ;
                                       v_SQL := v_SQL || ',DateApproved =CASE WHEN ''' || v_AUTHMODE || '''= ''Y'' THEN ' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,19) || '''' || 'ELSE NULL END' ;
                                       v_SQL := v_SQL || ',AuthorisationStatus= CASE WHEN ''' || v_AUTHMODE || '''= ''Y'' THEN ''A'' ELSE NULL END' ;
                                       v_SQL := v_SQL || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                       v_SQL := v_SQL || CASE 
                                                              WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                       ELSE ' '
                                          END ;
                                       v_SQL := v_SQL || 'AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                       DBMS_OUTPUT.PUT_LINE(v_SQL);
                                       DBMS_OUTPUT.PUT_LINE('GGGGGGGGGG');
                                       EXECUTE IMMEDIATE v_SQL;
                                       v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET AuthorisationStatus=''A'' WHERE  (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ') AND ISNULL(AuthorisationStatus,''A'')=''A''AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                       OPEN  v_cursor FOR
                                          SELECT v_SQL 
                                            FROM DUAL  ;
                                          DBMS_SQL.RETURN_RESULT(v_cursor);
                                       DBMS_OUTPUT.PUT_LINE('SSSSSSSSSSS');
                                       EXECUTE IMMEDIATE v_SQL;

                                    END;
                                    ELSE

                                    BEGIN
                                       v_IsSCD2 := 'Y' ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_IsAvailable = 'N'
                                   OR v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('AUTH');
                                    DBMS_OUTPUT.PUT_LINE(v_IsAvailable);
                                    /* INSERT DATA IN MAIN TABLE EITHER ADDING THE RECORD AND BEING SCD2*/
                                    DBMS_OUTPUT.PUT_LINE(v_BaseColumn);
                                    v_SQL := ' INSERT INTO ' || v_TableWithSchema || ' (' || v_BaseColumn || ',' || v_ColName ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ',' || v_ParentColumn
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || ',AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved)' ;
                                    v_SQL := v_SQL || ' SELECT ' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || ',' || v_DataVal ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ',' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    OPEN  v_cursor FOR
                                       SELECT v_SQL 
                                         FROM DUAL  ;
                                       DBMS_SQL.RETURN_RESULT(v_cursor);
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_AUTHMODE = 'Y' THEN ',''' || NVL(v_AuthorisationStatus, 'NULL') || ''''
                                    ELSE ',NULL'
                                       END ;
                                    v_SQL := v_SQL || ',' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey,5) || '''' ;
                                    v_SQL := v_SQL || ',' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveToTimeKey,5) || '''' ;
                                    v_SQL := v_SQL || ',''' || NVL(v_CreatedBy, ' ') || '''' || ',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateCreated, 'NULL'),19) || '''' ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_IsAvailable = 'Y' THEN ',''' || NVL(v_ModifiedBy, ' ') || ''''
                                    ELSE ',NULL'
                                       END ;
                                    v_SQL := v_SQL + CASE 
                                                          WHEN v_IsAvailable = 'Y' THEN +',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateModified, ' '),19) || ''''
                                    ELSE ',NULL'
                                       END ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_AUTHMODE = 'Y' THEN ',''' || NVL(v_ApprovedBy, ' ') || ''''
                                    ELSE ',NULL'
                                       END ;
                                    v_SQL := v_SQL + CASE 
                                                          WHEN v_AUTHMODE = 'Y' THEN +',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateApproved, ' '),19) || ''''
                                    ELSE ',NULL'
                                       END ;
                                    v_SQL := REPLACE(v_SQL, '''NULL''', 'NULL') ;
                                    DBMS_OUTPUT.PUT_LINE('AUTH ' || v_SQL);
                                    OPEN  v_cursor FOR
                                       SELECT v_SQL 
                                         FROM DUAL  ;
                                       DBMS_SQL.RETURN_RESULT(v_cursor);
                                    EXECUTE IMMEDIATE v_SQL;
                                    v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET AuthorisationStatus=null WHERE  (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')  and ISNULL(AuthorisationStatus,'''')=''NU''AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    EXECUTE IMMEDIATE v_SQL;

                                 END;
                                 END IF;
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    /* EXPIRED THE RECORD IN MAIN TABLE FOR SCD2 */
                                    v_SQL := 'UPDATE ' || v_TableWithSchema || ' SET' ;
                                    v_SQL := v_SQL || ' AuthorisationStatus=CASE WHEN ''' || v_AUTHMODE || '''=''Y'' THEN  ''A'' ELSE NULL END' ;
                                    v_SQL := v_SQL || ', EffectiveToTimeKey=' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey - 1,5) ;
                                    v_SQL := v_SQL || ' WHERE (EffectiveFromTimeKey<=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ' AND EffectiveToTimeKey>=' || UTILS.CONVERT_TO_VARCHAR2(v_TimeKey,5) || ')' ;
                                    v_SQL := v_SQL || ' AND EffectiveFromTimeKey<' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey,5) ;
                                    v_SQL := v_SQL || CASE 
                                                           WHEN v_ParentColumn <> ' ' THEN ' AND ' || v_ParentColumn || '= ' || v_ParentColumnValue
                                    ELSE ' '
                                       END ;
                                    v_SQL := v_SQL || ' AND ' || v_BaseColumn || '=''' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) || '''' ;
                                    EXECUTE IMMEDIATE v_SQL;
                                    DBMS_OUTPUT.PUT_LINE('update');
                                    DBMS_OUTPUT.PUT_LINE(v_SQL);

                                 END;
                                 END IF;

                              END;
                              END IF;
                              /*To be enable for maintain history	*/
                              ---GOTO CommonMaster_Insert
                              IF v_AuthMode = 'N' THEN

                              BEGIN
                                 v_AuthorisationStatus := 'A' ;
                                 GOTO CommonMaster_Insert;
                                 <<HistoryRecordInsert>>

                              END;
                              END IF;

                           END;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
               -------------END---------- 
               ---------call log 
               IF v_OperationFlag IN ( 1,2,3,16,17,18 )
                THEN
                DECLARE
                  v_ReferenceID VARCHAR2(10);
                  v_ScreenEntityId NUMBER(10,0) := 0;

               BEGIN
                  /* EXECUTING LOG ATTENDANCE PART IN BOTHE MAKER CHECKER OR NON-MAKER CHECKER MODE */
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     v_CreatedBy := v_ModifiedBy ;

                  END;
                  END IF;
                  IF v_OperationFlag NOT IN ( 16,17 )
                   THEN

                  BEGIN
                     v_ApprovedBy := NULL ;

                  END;
                  END IF;
                  v_DateCreated := SYSDATE ;
                  v_ReferenceID := UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) ;
                  v_ScreenEntityId := v_MenuID ;
                  --PRINT 'INSERT LOG'
                  /* CALLING OF LOG ATTANDENDE SP*/
                  DBMS_OUTPUT.PUT_LINE('aaaUUUUUUUUUU');
                  utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
                  (0 -- BranchCode 
                   ,
                   v_MenuID,
                   v_ReferenceID --  ,
                   ,
                   v_CreatedBy,
                   v_ApprovedBy -- @ApproveBy 
                   ,
                   v_DateCreated,
                   v_Remark,
                   v_ScreenEntityId -- for FXT060 screen
                   ,
                   v_OperationFlag,
                   v_AuthMode) ;

               END;
               END IF;
               --INT 'END LOG'
               --------------------------
               v_ErrorHandle := 1 ;
               <<CommonMaster_Insert>>
               IF v_ErrorHandle = 0 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('UUUUUUUUUU');
                  /* INSERT DATA INTO MOD TABLE*/
                  v_SQL := ' INSERT INTO ' || v_TableWithSchema_Mod || ' (' || v_BaseColumn ;
                  v_SQL := v_SQL || CASE 
                                         WHEN v_ParentColumn <> ' ' THEN ',' || v_ParentColumn
                  ELSE ' '
                     END ;
                  v_SQL := v_SQL || ',' || v_ColName ;
                  v_SQL := v_SQL || ',AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved,ChangeFields)' ;
                  v_SQL := v_SQL || ' SELECT ' || UTILS.CONVERT_TO_VARCHAR2(v_BaseColumnValue,20) ;
                  v_SQL := v_SQL || CASE 
                                         WHEN v_ParentColumn <> ' ' THEN ',' || v_ParentColumnValue
                  ELSE ' '
                     END ;
                  v_SQL := v_SQL || ',' || v_DataVal ;
                  v_SQL := v_SQL || ',''' || NVL(v_AuthorisationStatus, ' ') || '''' || ',''' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveFromTimeKey,5) || '''' || ',''' || UTILS.CONVERT_TO_VARCHAR2(v_EffectiveToTimeKey,5) || '''' ;
                  v_SQL := v_SQL || ',''' || NVL(v_CreatedBy, ' ') || '''' || ',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateCreated, ' '),19) || '''' ;
                  v_SQL := v_SQL || CASE 
                                         WHEN v_ModifiedBy <> ' ' THEN ',''' || NVL(v_ModifiedBy, ' ') || ''''
                  ELSE ',NULL'
                     END ;
                  v_SQL := v_SQL + CASE 
                                        WHEN v_ModifiedBy <> ' ' THEN +',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateModified, ' '),19) || ''''
                  ELSE ',NULL'
                     END ;
                  v_SQL := v_SQL || CASE 
                                         WHEN v_ApprovedBy <> ' ' THEN ',''' || NVL(v_ApprovedBy, ' ') || ''''
                  ELSE ',NULL'
                     END ;
                  v_SQL := v_SQL + CASE 
                                        WHEN v_ApprovedBy <> ' ' THEN +',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_DateApproved, ' '),19) || ''''
                  ELSE ',NULL'
                     END ;
                  v_SQL := v_SQL + CASE 
                                        WHEN v_ChangeField <> ' ' THEN +',''' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_ChangeField, ' '),19) || ''''
                  ELSE ',NULL'
                     END ;
                  v_SQL := REPLACE(v_SQL, '''NULL''', 'NULL') ;
                  EXECUTE IMMEDIATE v_SQL;
                  /* REALLOCATE THE POINTER TO THE POSITION FROM WHERE CALLED THIS BLOCK */
                  IF v_OperationFlag = 1
                    AND v_AuthMode = 'Y' THEN

                  BEGIN
                     GOTO CommonMaster_Insert_Add;

                  END;
                  ELSE
                     IF ( v_OperationFlag = 2
                       OR v_OperationFlag = 3 )
                       AND v_AuthMode = 'Y' THEN

                     BEGIN
                        GOTO CommonMaster_Edit_Delete;

                     END;
                     ELSE
                        IF v_AuthMode = 'N' THEN

                        BEGIN
                           GOTO HistoryRecordInsert;

                        END;
                        END IF;
                     END IF;
                  END IF;

               END;
               END IF;
               utils.commit_transaction;
               /* RETURN THE RESULT AFTER SAVING THE DATA */
               v_Result := UTILS.CONVERT_TO_NUMBER(v_BaseColumnValue,10,0) ;
               RETURN v_Result;

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            /* ROLLING BACK TRANSACTION IN CASE OF ERRONR IN EXECUTION ABOVE SCRIPTS*/
            OPEN  v_cursor FOR
               SELECT SQLERRM 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            ROLLBACK;
            utils.resetTrancount;
            v_Result := -1 ;
            RETURN v_Result;/*  END OF EXECUTION */

         END;END;

      END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUP" TO "ADF_CDR_RBL_STGDB";
