--------------------------------------------------------
--  DDL for Function PRODUCTMASTERINUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" 
-- ========================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<01/02/2023>
 -- DESCRIPTION:			<PRODUCT MASTER TABLE INSERT/UPDATE>
 -- =========================================================

(
  iv_ProductAlt_Key IN NUMBER DEFAULT 0 ,
  v_ProductCode IN VARCHAR2 DEFAULT ' ' ,
  v_ProductName IN VARCHAR2 DEFAULT ' ' ,
  v_ProductShortName IN VARCHAR2 DEFAULT ' ' ,
  v_ProductShortNameEnum IN VARCHAR2 DEFAULT ' ' ,
  v_ProductGroup IN VARCHAR2 DEFAULT ' ' ,
  v_ProductSubGroup IN VARCHAR2 DEFAULT ' ' ,
  v_ProductSegment IN VARCHAR2 DEFAULT ' ' ,
  v_ProductValidCode IN CHAR DEFAULT ' ' ,
  v_SrcSysProductCode IN VARCHAR2 DEFAULT ' ' ,
  v_SrcSysProductName IN VARCHAR2 DEFAULT ' ' ,
  v_DestSysProductCode IN VARCHAR2 DEFAULT ' ' ,
  v_DepositType IN VARCHAR2 DEFAULT ' ' ,
  v_SourceAlt_Key IN NUMBER DEFAULT 0 ,
  v_EffectiveFromDate IN NUMBER DEFAULT 0 ,
  v_FacilityType IN VARCHAR2 DEFAULT ' ' ,
  v_NPANorms IN VARCHAR2 DEFAULT ' ' ,
  v_SchemeType IN VARCHAR2 DEFAULT ' ' ,
  v_Agrischeme IN CHAR DEFAULT ' ' ,
  v_ReviewFlag IN CHAR DEFAULT ' ' ,
  v_AssetClass IN VARCHAR2 DEFAULT ' ' ,
  v_RBL_ProductGroup IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  --,@IsMOC								CHAR(1)			= 'N'
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  --,@ScreenEntityId					INT				= null
  v_ProductMaster_changefields IN VARCHAR2 DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_ProductAlt_Key NUMBER(10,0) := iv_ProductAlt_Key;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExProductKey NUMBER(10,0) := 0;
   v_AuthLevel CHAR(1);
   v_ApprovedByFirstLevel VARCHAR2(50);
   v_DateApprovedFirstLevel DATE;
   v_cursor SYS_REFCURSOR;
--,@D2Ktimestamp						INT				= 0 OUTPUT		

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   DBMS_OUTPUT.PUT_LINE('A');
   v_AuthLevel := 'Y' ;
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
                         FROM DimProductDummy 
                          WHERE  ProductCode = v_ProductCode
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                         UNION 
                         SELECT 1 
                         FROM DimProductDummy_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND ProductCode = v_ProductCode
                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','A','1A','1D' )
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
         SELECT NVL(MAX(ProductAlt_Key) , 0) + 1 

           INTO v_ProductAlt_Key
           FROM ( SELECT ProductAlt_Key 
                  FROM DimProductDummy 
                  UNION 
                  SELECT ProductAlt_Key 
                  FROM DimProductDummy_Mod  ) A;

      END;
      END IF;

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
            GOTO ProductMaster_Insert;
            <<ProductMaster_Insert_Add>>

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
               v_DateModified := SYSDATE ;
               DBMS_OUTPUT.PUT_LINE(5);
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('EDIT');
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
                 FROM DimProductDummy 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND ProductCode = v_ProductCode;
               ---FIND CREATED BY FROM MOD TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimProductDummy_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND ProductCode = v_ProductCode
                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','A','1A','1D' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimProductDummy
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ProductCode = v_ProductCode;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Update Mod By FM');
                  UPDATE DimProductDummy_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ProductCode = v_ProductCode
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO ProductMaster_Insert;
               <<ProductMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE DimProductDummy
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ProductCode = v_ProductCode;

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimProductDummy_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedByFirstLevel = v_ApprovedBy,
                            DateApprovedFirstLevel = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND ProductCode = v_ProductCode
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimProductDummy 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND ProductCode = v_ProductCode );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimProductDummy
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND ProductCode = v_ProductCode
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  ----------- NEW ADD FOR FIRST LEVEL AUTHENTICATION -------------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y'
                       AND v_AuthLevel = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('SECOND LEVEL REJECT');
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimProductDummy_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND ProductCode = v_ProductCode
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A','1D' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DimProductDummy 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND ProductCode = v_ProductCode );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimProductDummy
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND ProductCode = v_ProductCode
                             AND AuthorisationStatus IN ( 'MP','DP','RM','1D' )
                           ;

                        END;
                        END IF;

                     END;
                     ELSE
                        IF v_OperationFlag = 18
                          AND v_AuthMode = 'Y' THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimProductDummy_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND ProductCode = v_ProductCode;

                        END;

                        -------new addd 
                        ELSE
                           IF v_OperationFlag = 16
                             AND v_AuthMode = 'Y'
                             AND v_AuthLevel = 'Y' THEN
                            DECLARE
                              v_DelStatus1 CHAR(2);
                              v_CurrRecordFromTimeKey1 NUMBER(5,0) := 0;

                           BEGIN
                              v_ApprovedByFirstLevel := v_CrModApBy ;
                              v_DateApprovedFirstLevel := SYSDATE ;
                              DBMS_OUTPUT.PUT_LINE('C');
                              DBMS_OUTPUT.PUT_LINE(v_ProductCode);
                              SELECT MAX(Product_Key)  

                                INTO v_ExProductKey
                                FROM DimProductDummy_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND ProductCode = v_ProductCode
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;
                              DBMS_OUTPUT.PUT_LINE(v_ExProductKey);
                              SELECT AuthorisationStatus ,
                                     CreatedBy ,
                                     DATECreated ,
                                     ModifiedBy ,
                                     DateModified 

                                INTO v_DelStatus1,
                                     v_CreatedBy,
                                     v_DateCreated,
                                     v_ModifiedBy,
                                     v_DateModified
                                FROM DimProductDummy_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey )
                                        AND Product_Key = v_ExProductKey;
                              DBMS_OUTPUT.PUT_LINE('DELETE FLAG');
                              DBMS_OUTPUT.PUT_LINE(v_DelStatus1);
                              IF v_DelStatus1 = 'DP' THEN

                              BEGIN
                                 UPDATE DimProductDummy_Mod
                                    SET AuthorisationStatus = '1D',
                                        ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                        DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND ProductCode = v_ProductCode
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                 ;

                              END;
                              ELSE

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('Update 1A in Mod Table for Fist Level Authentication');
                                 UPDATE DimProductDummy_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                        DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                  WHERE  ProductCode = v_ProductCode
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                 ;

                              END;
                              END IF;

                           END;
                           ELSE
                              IF ( ( v_OperationFlag = 20
                                AND v_AuthLevel = 'Y' )
                                OR ( v_OperationFlag = 16
                                AND v_AuthLevel = 'Y' )
                                OR v_AuthMode = 'N' ) THEN

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
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM DimProductDummy 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND ProductCode = v_ProductCode;
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
                                    SELECT MAX(Product_Key)  

                                      INTO v_ExProductKey
                                      FROM DimProductDummy_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND ProductCode = v_ProductCode
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A','1D' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ModifiedBy ,
                                           DateModified ,
                                           ApprovedByFirstLevel ,
                                           DateApprovedFirstLevel 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModified,
                                           v_ApprovedByFirstLevel,
                                           v_DateApprovedFirstLevel
                                      FROM DimProductDummy_Mod 
                                     WHERE  Product_Key = v_ExProductKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(Product_Key)  

                                      INTO v_ExProductKey
                                      FROM DimProductDummy_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND ProductCode = v_ProductCode
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A','1D' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimProductDummy_Mod 
                                     WHERE  Product_Key = v_ExProductKey;
                                    UPDATE DimProductDummy_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND ProductCode = v_ProductCode
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus IN ( 'DP','1D' )
                                     THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                     -- @DelStatus='DP' 
                                    BEGIN
                                       UPDATE DimProductDummy_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ProductCode = v_ProductCode
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1D' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimProductDummy 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND ProductCode = v_ProductCode );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE DimProductDummy
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND ProductCode = v_ProductCode;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE DimProductDummy_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  ProductCode = v_ProductCode
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_DelStatus NOT IN ( 'DP','1D' )

                                   OR v_AuthMode = 'N' THEN
                                  DECLARE
                                    v_IsAvailable CHAR(1) := 'N';
                                    v_IsSCD2 CHAR(1) := 'N';
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('DATA INSERT IN MAIN TABLE');
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM DimProductDummy 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND ProductCode = v_ProductCode );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       v_IsAvailable := 'Y' ;
                                       v_AuthorisationStatus := 'A' ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimProductDummy 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND ProductCode = v_ProductCode );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE DimProductDummy
                                             SET ProductAlt_Key = v_ProductAlt_Key,
                                                 ProductCode = v_ProductCode,
                                                 ProductName = v_ProductName,
                                                 ProductShortName = v_ProductShortName,
                                                 ProductShortNameEnum = v_ProductShortNameEnum,
                                                 ProductGroup = v_ProductGroup,
                                                 ProductSubGroup = v_ProductSubGroup,
                                                 ProductSegment = v_ProductSegment,
                                                 ProductValidCode = v_ProductValidCode,
                                                 SrcSysProductCode = v_SrcSysProductCode,
                                                 SrcSysProductName = v_SrcSysProductName,
                                                 DestSysProductCode = v_DestSysProductCode,
                                                 DepositType = v_DepositType,
                                                 SourceAlt_Key = v_SourceAlt_Key,
                                                 EffectiveFromDate = v_EffectiveFromDate,
                                                 FacilityType = v_FacilityType,
                                                 NPANorms = v_NPANorms,
                                                 SchemeType = v_SchemeType,
                                                 Agrischeme = v_Agrischeme,
                                                 ReviewFlag = v_ReviewFlag,
                                                 AssetClass = v_AssetClass,
                                                 RBL_ProductGroup = v_RBL_ProductGroup,
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                                 DateApprovedFirstLevel = v_DateApprovedFirstLevel,
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
                                            AND ProductCode = v_ProductCode;

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
                                       INSERT INTO DimProductDummy
                                         ( ProductAlt_Key, ProductCode, ProductName, ProductShortName, ProductShortNameEnum, ProductGroup, ProductSubGroup, ProductSegment, ProductValidCode, SrcSysProductCode, SrcSysProductName, DestSysProductCode, DepositType, SourceAlt_Key, EffectiveFromDate, FacilityType, NPANorms, SchemeType, Agrischeme, ReviewFlag, AssetClass, RBL_ProductGroup, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved )
                                         ( SELECT v_ProductAlt_Key ,
                                                  v_ProductCode ,
                                                  v_ProductName ,
                                                  v_ProductShortName ,
                                                  v_ProductShortNameEnum ,
                                                  v_ProductGroup ,
                                                  v_ProductSubGroup ,
                                                  v_ProductSegment ,
                                                  v_ProductValidCode ,
                                                  v_SrcSysProductCode ,
                                                  v_SrcSysProductName ,
                                                  v_DestSysProductCode ,
                                                  v_DepositType ,
                                                  v_SourceAlt_Key ,
                                                  v_EffectiveFromDate ,
                                                  v_FacilityType ,
                                                  v_NPANorms ,
                                                  v_SchemeType ,
                                                  v_Agrischeme ,
                                                  v_ReviewFlag ,
                                                  v_AssetClass ,
                                                  v_RBL_ProductGroup ,
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
                                                         OR v_IsAvailable = 'Y' THEN v_DateModified
                                                  ELSE NULL
                                                     END col  ,
                                                  v_ApprovedByFirstLevel ,
                                                  v_DateApprovedFirstLevel ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
                                                  ELSE NULL
                                                     END col  
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DimProductDummy
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND ProductCode = v_ProductCode
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO ProductMaster_Insert;
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
         <<ProductMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('INSERT IN MOD TABLE');
            INSERT INTO DimProductDummy_Mod
              ( ProductAlt_Key, ProductCode, ProductName, ProductShortName, ProductShortNameEnum, ProductGroup, ProductSubGroup, ProductSegment, ProductValidCode, SrcSysProductCode, SrcSysProductName, DestSysProductCode, DepositType, SourceAlt_Key, EffectiveFromDate, FacilityType, NPANorms, SchemeType, Agrischeme, ReviewFlag, AssetClass, RBL_ProductGroup, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, ChangeFields )
              VALUES ( v_ProductAlt_Key, v_ProductCode, v_ProductName, v_ProductShortName, v_ProductShortNameEnum, v_ProductGroup, v_ProductSubGroup, v_ProductSegment, v_ProductValidCode, v_SrcSysProductCode, v_SrcSysProductName, v_DestSysProductCode, v_DepositType, v_SourceAlt_Key, v_EffectiveFromDate, v_FacilityType, v_NPANorms, v_SchemeType, v_Agrischeme, v_ReviewFlag, v_AssetClass, v_RBL_ProductGroup, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               WHEN v_AuthMode = 'Y'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 OR v_IsAvailable = 'Y' THEN v_ModifiedBy
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y'
                           OR v_IsAvailable = 'Y' THEN v_DateModified
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y' THEN v_DateApproved
            ELSE NULL
               END, v_ProductMaster_changefields );
            --DECLARE @Parameter2 varchar(50)
            --DECLARE @FinalParameter2 varchar(50)
            --SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
            --									from DimProductDummy_Mod where ProductCode = @ProductCode
            --									and ISNULL(AuthorisationStatus,'A')  in ( 'A','MP')
            --									 for XML PATH('')),1,1,'') )
            --If OBJECT_ID('#A') is not null
            --drop table #A
            --select DISTINCT VALUE 
            --into #A 
            --from (
            --		ELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE
            --		FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter2,',')
            -- ) A
            -- )X
            --SET @FinalParameter2 = (select STUFF((	SELECT Distinct ',' + Value from #A  for XML PATH('')),1,1,''))
            --UPDATE		A
            --set			a.ChangeFields = @FinalParameter2							 																																	
            --from		DimProductDummy_Mod   A
            --WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
            --and	ProductCode = @ProductCode										
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO ProductMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO ProductMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         --IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
         --BEGIN
         --	PRINT 'log table'
         --	SET	@DateCreated = Getdate()
         --	IF @OperationFlag IN(16,17,18,20,21) 
         --	BEGIN 
         --		Print 'Authorised'
         --		EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
         --		@BranchCode=''   ,  ----BranchCode
         --		@MenuID=@MenuID,
         --		@ReferenceID=@ProductCode ,-- ReferenceID ,
         --		@CreatedBy=NULL,
         --		@ApprovedBy=@CrModApBy, 
         --		@CreatedCheckedDt=@DateCreated,
         --		@Remark=@Remark,
         --		@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
         --		@Flag=@OperationFlag,
         --		@AuthMode=@AuthMode
         --	END
         --	ELSE
         --	BEGIN
         --		PRINT 'UNAuthorised'
         --		-- Declare
         --		SET @CreatedBy  =@CrModApBy
         --		EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
         --			@BranchCode=''   ,  ----BranchCode
         --			@MenuID=@MenuID,
         --			@ReferenceID=@ProductCode ,-- ReferenceID ,
         --			@CreatedBy=@CrModApBy,
         --			@ApprovedBy=NULL, 						
         --			@CreatedCheckedDt=@DateCreated,
         --			@Remark=@Remark,
         --			@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
         --			@Flag=@OperationFlag,
         --			@AuthMode=@AuthMode
         --	END
         --END
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimProductDummy WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --																AND ProductCode=@ProductCode
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTMASTERINUP_15122023" TO "ADF_CDR_RBL_STGDB";
