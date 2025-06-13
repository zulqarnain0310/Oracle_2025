--------------------------------------------------------
--  DDL for Function DIMASSETCLASSMASTER_INUP_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" 
(
  iv_AssetClassMappingAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_SrcSysAssetClassCode IN VARCHAR2 DEFAULT ' ' ,---SourceSysCRRCode
  v_SrcSysAssetClassName IN VARCHAR2 DEFAULT ' ' ,------Sourcesysassetclass
  v_AssetClassName IN VARCHAR2 DEFAULT ' ' ,------
  v_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  v_DPD_LowerValue IN NUMBER DEFAULT 0 ,
  v_DPD_HigherValue IN NUMBER DEFAULT 0 ,
  v_DimAssetClassMaster_changeFields IN VARCHAR2,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AssetClassMappingAlt_Key NUMBER(10,0) := iv_AssetClassMappingAlt_Key;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModifie DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'AssetClassMaster' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
   DBMS_OUTPUT.PUT_LINE('A');
   SELECT ParameterValue 

     INTO v_AppAvail
     FROM SysSolutionParameter 
    WHERE  Parameter_Key = 6;
   IF ( v_AppAvail = 'N' ) THEN

   BEGIN
      v_Result := -11 ;
      RETURN v_Result;

   END;
   END IF;
   -------------------------------------------------
   IF utils.object_id('Tempdb..tt_Temp_50') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_50 ';
   END IF;
   IF utils.object_id('Tempdb..tt_final_27') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_final_27 ';
   END IF;
   DELETE FROM tt_Temp_50;
   INSERT INTO tt_Temp_50
     VALUES ( v_AssetClassAlt_Key, v_SourceAlt_Key, v_AssetClassName );
   DELETE FROM tt_final_27;
   UTILS.IDENTITY_RESET('tt_final_27');

   INSERT INTO tt_final_27 ( 
   	SELECT A.Businesscolvalues1 SourceAlt_Key  ,
           AssetClassName ,
           AssetClassAlt_Key 
   	  FROM ( SELECT AssetClassName ,
                    AssetClassAlt_Key ,
                    a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
             FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(SourceAlt_Key, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                           AssetClassName ,
                           AssetClassAlt_Key 
                    FROM tt_Temp_50  ) A
                     /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_final_27 
      ADD ( AssetClassMAPPINGALT_KEY NUMBER(10,0)  ) ';
   /*
   	select * Into DimAssetclassMapping_Mod  from DimAssetclassMapping where 1=2


   	Alter Table DimAssetclassMapping
   	add SourceAlt_Key int

   	*/
   IF v_OperationFlag = 1 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

    --- add
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      -----CHECK DUPLICATE
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM DimAssetClassMapping 
                          WHERE  SourceAlt_Key IN ( SELECT * 
                                                    FROM TABLE(SPLIT(v_SourceAlt_Key, ','))  )

                                   AND SrcSysClassCode = v_SrcSysAssetClassCode
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM DimAssetclassMapping_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND SourceAlt_Key IN ( SELECT * 
                                                          FROM TABLE(SPLIT(v_SourceAlt_Key, ','))  )

                                   AND SrcSysClassCode = v_SrcSysAssetClassCode
                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE(2);
         v_Result := -4 ;
         RETURN v_Result;-- USER ALEADY EXISTS

      END;
      ELSE

      BEGIN
         DBMS_OUTPUT.PUT_LINE(3);
         SELECT NVL(MAX(AssetClassMappingAlt_Key) , 0) + 1 

           INTO v_AssetClassMappingAlt_Key
           FROM ( SELECT AssetClassMappingAlt_Key 
                  FROM DimAssetClassMapping 
                  UNION 
                  SELECT AssetClassMappingAlt_Key 
                  FROM DimAssetclassMapping_Mod  ) A;
         IF v_OperationFlag = 1 THEN

         BEGIN
            MERGE INTO TEMP 
            USING (SELECT TEMP.ROWID row_id, ACCT.AssetClassMappingAlt_Key
            FROM TEMP ,tt_final_27 TEMP
                   JOIN ( SELECT tt_final_27.SourceAlt_Key ,
                                 (v_AssetClassMappingAlt_Key + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
              FROM DUAL  )  )) AssetClassMappingAlt_Key  
                          FROM tt_final_27 
                           WHERE  tt_final_27.AssetClassMappingAlt_Key = 0
                                    OR tt_final_27.AssetClassMappingAlt_Key IS NULL ) ACCT   ON TEMP.SourceAlt_Key = ACCT.SourceAlt_Key ) src
            ON ( TEMP.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET TEMP.AssetClassMappingAlt_Key = src.AssetClassMappingAlt_Key;

         END;
         END IF;

      END;
      END IF;

   END;
   END IF;
   IF v_OperationFlag = 2 THEN

   BEGIN
      MERGE INTO TEMP 
      USING (SELECT TEMP.ROWID row_id, v_AssetClassMappingAlt_Key
      FROM TEMP ,tt_final_27 TEMP ) src
      ON ( TEMP.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET TEMP.AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -----
         DBMS_OUTPUT.PUT_LINE(3);
         --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
         IF v_OperationFlag = 1
           AND v_AuthMode = 'Y' THEN

          -- ADD
         BEGIN
            DBMS_OUTPUT.PUT_LINE('Add');
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_AuthorisationStatus := 'NP' ;
            --SET @AssetClassMappingAlt_Key = (Select ISNULL(Max(AssetClassMappingAlt_Key),0)+1 from 
            --						(Select AssetClassMappingAlt_Key from DimAssetClassMapping
            --						 UNION 
            --						 Select AssetClassMappingAlt_Key from DimAssetClassMapping_Mod
            --						)A)
            GOTO AssetClassMaster_Insert;
            <<AssetClassMaster_Insert_Add>>

         END;
         ELSE
            IF ( v_OperationFlag = 2
              OR v_OperationFlag = 3 )
              AND v_AuthMode = 'Y' THEN

             --EDIT AND DELETE
            BEGIN
               DBMS_OUTPUT.PUT_LINE(4);
               v_CreatedBy := v_CrModApBy ;
               v_DateCreated := SYSDATE ;
               v_Modifiedby := v_CrModApBy ;
               v_DateModifie := SYSDATE ;
               DBMS_OUTPUT.PUT_LINE(5);
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Edit');
                  v_AuthorisationStatus := 'MP' ;

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('DELETE');
                  v_AuthorisationStatus := 'DP' ;

               END;
               END IF;
               ---FIND CREATED BY FROM MAIN TABLE
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM DimAssetClassMapping 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimAssetclassMapping_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimAssetClassMapping
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimAssetclassMapping_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModifie = v_DateModifie
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key

                    --AND SourceAlt_Key = @SourceAlt_Key
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO AssetClassMaster_Insert;
               <<AssetClassMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModifie := SYSDATE ;
                  UPDATE DimAssetClassMapping
                     SET ModifiedBy = v_Modifiedby,
                         DateModifie = v_DateModifie,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

               END;

               ---------------------------------------------First lvl Authorise----------
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimAssetclassMapping_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimAssetClassMapping 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimAssetClassMapping
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -------------------------------------------------------
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimAssetclassMapping_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('Sunil');
                        --		DECLARE @EntityKey as Int 
                        --		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                        --							 FROM DimBankRP_Mod 
                        --								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                        --									AND BankRPAlt_Key=@BankRPAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                        --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                        --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DimAssetClassMapping 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimAssetClassMapping
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;
                     ELSE
                        IF v_OperationFlag = 18 THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimAssetclassMapping_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

                        END;

                        ---------------------new add
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimAssetclassMapping_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;

                           ----------------------------------------------------------
                           ELSE
                              IF v_OperationFlag = 20
                                OR v_AuthMode = 'N' THEN

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('Authorise');
                                 -------set parameter for  maker checker disabled
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
                                       v_DateModifie := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM DimAssetClassMapping 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 ---set parameters and UPDATE mod table in case maker checker enabled
                                 IF v_AuthMode = 'Y' THEN
                                  DECLARE
                                    v_DelStatus CHAR(2) := ' ';
                                    v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                                    v_CurEntityKey NUMBER(10,0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('B');
                                    DBMS_OUTPUT.PUT_LINE('C');
                                    SELECT MAX(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimAssetclassMapping_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifiedBy ,
                                           DateModifie 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModifie
                                      FROM DimAssetclassMapping_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimAssetclassMapping_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimAssetclassMapping_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE DimAssetclassMapping_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE DimAssetclassMapping_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimAssetClassMapping 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE DimAssetClassMapping
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModifie = v_DateModifie,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE DimAssetclassMapping_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_DelStatus <> 'DP'
                                   OR v_AuthMode = 'N' THEN
                                  DECLARE
                                    v_IsAvailable CHAR(1) := 'N';
                                    v_IsSCD2 CHAR(1) := 'N';
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM DimAssetClassMapping 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       v_IsAvailable := 'Y' ;
                                       --SET @AuthorisationStatus='A'
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimAssetClassMapping 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE DimAssetClassMapping
                                             SET AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key,
                                                 SourceAlt_Key = v_SourceAlt_Key -----source	 
                                                 ,
                                                 SrcSysClassCode = v_SrcSysAssetClassCode ---sourcesysCRRCode
                                                 ,
                                                 SrcSysClassName = v_SrcSysAssetClassName ----sourcesysclassname 
                                                 ,
                                                 AssetClassName = v_AssetClassName ------CrismacAssetclass			 
                                                 ,
                                                 AssetClassAlt_Key = v_AssetClassAlt_Key -----Crismacode
                                                 ,
                                                 DPD_LowerValue = v_DPD_LowerValue,
                                                 DPD_HigherValue = v_DPD_HigherValue,
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModifie = v_DateModifie,
                                                 ApprovedBy = CASE 
                                                                   WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                 ELSE NULL
                                                    END,
                                                 DateApproved = CASE 
                                                                     WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                 ELSE NULL
                                                    END,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AuthMode = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key;

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
                                       INSERT INTO DimAssetClassMapping
                                         ( AssetClassMappingAlt_Key, SourceAlt_Key, SrcSysClassCode, SrcSysClassName, AssetClassName, AssetClassAlt_Key, DPD_LowerValue, DPD_HigherValue, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModifie, ApprovedBy, DateApproved )
                                         ( SELECT v_AssetClassMappingAlt_Key ,
                                                  SourceAlt_Key ,
                                                  v_SrcSysAssetClassCode ,
                                                  v_SrcSysAssetClassName ,
                                                  AssetClassName ,
                                                  v_AssetClassAlt_Key ,
                                                  v_DPD_LowerValue ,
                                                  v_DPD_HigherValue ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
                                                  ELSE NULL
                                                     END col  ,
                                                  v_EffectiveFromTimeKey ,
                                                  v_EffectiveToTimeKey ,
                                                  v_CreatedBy ,
                                                  v_DateCreated ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y'
                                                         OR v_IsAvailable = 'Y' THEN v_ModifiedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y'
                                                         OR v_IsAvailable = 'Y' THEN v_DateModifie
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
                                                  ELSE NULL
                                                     END col  
                                           FROM tt_Temp_50  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DimAssetClassMapping
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND AssetClassMappingAlt_Key = v_AssetClassMappingAlt_Key
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO AssetClassMaster_Insert;
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
         END IF;
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<AssetClassMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            -----------------------------------------------------------
            --	IF Object_id('Tempdb..tt_Temp_50') Is Not Null
            --Drop Table tt_Temp_50
            --	IF Object_id('Tempdb..tt_final_27') Is Not Null
            --Drop Table tt_final_27
            --Create table tt_Temp_50
            --(AssetClassAlt_Key int
            --,SourceAlt_Key Varchar(20)
            --,AssetClassName	varchar(100)
            --)
            --Insert into tt_Temp_50 values(@AssetClassAlt_Key,@SourceAlt_Key,@AssetClassName)
            --Select A.Businesscolvalues1 as SourceAlt_Key,AssetClassName,AssetClassAlt_Key  into tt_final_27 From (
            --SELECT AssetClassName,AssetClassAlt_Key,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
            --                            FROM  (SELECT 
            --                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
            --											AssetClassName,AssetClassAlt_Key
            --                                            from tt_Temp_50
            --                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
            --)A 
            --ALTER TABLE #FINAL ADD AssetClassMAPPINGALT_KEY INT
            --IF @OperationFlag=1 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.AssetClassMappingAlt_Key=ACCT.AssetClassMappingAlt_Key
            -- FROM tt_final_27 TEMP
            --INNER JOIN (SELECT SourceAlt_Key,(@AssetClassMappingAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) AssetClassMappingAlt_Key
            --			FROM tt_final_27
            --			WHERE AssetClassMappingAlt_Key=0 OR AssetClassMappingAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
            --END
            --IF @OperationFlag=2 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
            -- FROM tt_final_27 TEMP
            --END
            --------------------------------------------------
            INSERT INTO DimAssetclassMapping_Mod
              ( AssetClassMappingAlt_Key, SourceAlt_Key, SrcSysClassCode, SrcSysClassName, AssetClassName, AssetClassAlt_Key, DPD_LowerValue, DPD_HigherValue, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModifie, ApprovedBy, DateApproved )
              ( SELECT
                --@AssetClassMappingAlt_Key
                 AssetClassMappingAlt_Key ,
                 SourceAlt_Key ,
                 v_SrcSysAssetClassCode ,
                 v_SrcSysAssetClassName ,
                 AssetClassName ,
                 AssetClassAlt_Key ,
                 v_DPD_LowerValue ,
                 v_DPD_HigherValue ,
                 v_AuthorisationStatus ,
                 v_EffectiveFromTimeKey ,
                 v_EffectiveToTimeKey ,
                 v_CreatedBy ,
                 v_DateCreated ,
                 CASE 
                      WHEN v_AuthMode = 'Y'
                        OR v_IsAvailable = 'Y' THEN v_ModifiedBy
                 ELSE NULL
                    END col  ,
                 CASE 
                      WHEN v_AuthMode = 'Y'
                        OR v_IsAvailable = 'Y' THEN v_DateModifie
                 ELSE NULL
                    END col  ,
                 CASE 
                      WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                 ELSE NULL
                    END col  ,
                 CASE 
                      WHEN v_AuthMode = 'Y' THEN v_DateApproved
                 ELSE NULL
                    END col  
                FROM tt_final_27  );
            --(   
            --		 @AssetClassMappingAlt_Key	
            --		,@SourceAlt_Key			
            --		,@SrcSysAssetClassCode		
            --		,@SrcSysAssetClassName		
            --		,@AssetClassName			
            --		,@AssetClassAlt_Key
            --		,@AuthorisationStatus
            --		,@EffectiveFromTimeKey
            --		,@EffectiveToTimeKey 
            --		,@CreatedBy
            --		,@DateCreated
            --		,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
            --		,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModifie ELSE NULL END
            --		,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
            --		,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
            --		
            --)
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO AssetClassMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO AssetClassMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------------------------Attendance Log----------------------------	
         IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_DateCreated1 DATE;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            v_DateCreated1 := SYSDATE ;
            --declare @ReferenceID1 varchar(max)
            --set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @SourceAlt_Key else @SourceAlt_Key end)
            IF v_OperationFlag IN ( 16,17,18,20,21 )
             THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Authorised');
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_SrcSysAssetClassCode -- ReferenceID ,
                ,
                v_CreatedBy => NULL,
                v_ApprovedBy => v_CrModApBy,
                iv_CreatedCheckedDt => v_DateCreated1,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('UNAuthorised');
               -- Declare
               -- set @CreatedBy  =@UserLoginID
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_SrcSysAssetClassCode -- ReferenceID ,
                ,
                v_CreatedBy => v_CrModApBy,
                v_ApprovedBy => NULL,
                iv_CreatedCheckedDt => v_DateCreated1,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            END IF;

         END;
         END IF;
         ---------------------------------------------------------------------------------------
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimBankRP WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND BankRPAlt_Key=@BankRPAlt_Key
         IF v_OperationFlag = 3 THEN

         BEGIN
            v_Result := 0 ;

         END;
         ELSE

         BEGIN
            v_Result := 1 ;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
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
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;---------

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMASSETCLASSMASTER_INUP_04122023" TO "ADF_CDR_RBL_STGDB";
