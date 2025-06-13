--------------------------------------------------------
--  DDL for Function ACCEPROVISIONMASTER_INUP_18112023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  iv_AcceleratedProvisionEntityID IN NUMBER DEFAULT 0 ,
  iv_CustomerId IN VARCHAR2 DEFAULT NULL ,
  iv_AccountId IN VARCHAR2 DEFAULT NULL ,
  iv_UCICID IN VARCHAR2 DEFAULT NULL ,
  v_AcceProDuration IN NUMBER DEFAULT 0 ,
  v_EffectiveDate IN VARCHAR2 DEFAULT ' ' ,
  v_SegmentNameAlt_key IN VARCHAR2 DEFAULT NULL ,
  v_AssetClassNameAlt_key IN NUMBER DEFAULT 0 ,
  v_CurrentProvisionPer IN NUMBER DEFAULT 0 ,
  v_Secured_Unsecured IN VARCHAR2 DEFAULT ' ' ,
  v_AdditionalProvision IN NUMBER DEFAULT 0 ,
  v_AdditionalProvACCT IN NUMBER DEFAULT 0 ,
  v_AcceleratedProvisionMaster_changeFields IN VARCHAR2 DEFAULT NULL ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
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
   v_CustomerId VARCHAR2(50) := iv_CustomerId;
   v_AccountId VARCHAR2(50) := iv_AccountId;
   v_UCICID VARCHAR2(50) := iv_UCICID;
   v_AcceleratedProvisionEntityID NUMBER(10,0) := iv_AcceleratedProvisionEntityID;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExAcceleratedProvisionEntityID NUMBER(10,0) := 0;
   --,@AcceleratedProvisionEntityID                Int       =0
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_AccountCount NUMBER(10,0) := 0;
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'AcceleratedProvisionMaster' ;
   -------------------------------------------------------------
   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
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
   SELECT COUNT(1)  

     INTO v_AccountCount
     FROM RBL_MISDB_PROD.AdvAcBasicDetail A
            JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerEntityId = B.CustomerEntityId
            AND B.EffectiveFromTimeKey <= v_TimeKey
            AND B.EffectiveToTimeKey >= v_TimeKey
            LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail C   ON A.CustomerEntityId = C.CustomerEntityId
            AND c.EffectiveFromTimeKey <= v_TimeKey
            AND c.EffectiveToTimeKey >= v_TimeKey
            JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
            AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key

   --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey
   WHERE  ( ( B.CustomerId = v_CustomerId )
            OR ( B.UCIF_ID = v_UCICID ) )

            --AND A.segmentcode=Convert(Varchar(10),@SegmentNameAlt_key)

            --AND A.segmentcode in (SELECT AcBuSegmentCode FROM DimAcBuSegment 

            --where AcBuRevisedSegmentCode=Convert(Varchar(100),@SegmentNameAlt_key))
            AND C.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
            AND A.FlgSecured = CASE 
                                    WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                    WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
            AND A.EffectiveFromTimeKey <= v_TimeKey
            AND A.EffectiveToTimeKey >= v_TimeKey;
   IF ( v_AccountCount = 0
     AND v_AccountId = ' '
     AND v_OperationFlag IN ( 1 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('SAC1');
      v_Result := 13 ;
      RETURN v_Result;

   END;
   END IF;
   IF ( NVL(v_EffectiveDate, ' ') <> UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('D', -1, utils.dateadd('M', utils.datediff('M', 0, UTILS.CONVERT_TO_VARCHAR2(v_EffectiveDate,200,p_style=>103)) + 1, 0)),10,p_style=>103) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('SAC1');
      v_Result := 12 ;
      RETURN v_Result;

   END;
   END IF;
   IF v_OperationFlag = 1 THEN

    --- add
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      -----CHECK DUPLICATE
      IF ( v_CustomerId <> ' ' ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM AcceleratedProvision 
                             WHERE  CustomerId = v_CustomerId
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM AcceleratedProvision_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND CustomerId = v_CustomerId
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            v_Result := 5 ;
            RETURN v_Result;-- USER ALEADY EXISTS

         END;
         END IF;

      END;
      END IF;
      IF ( v_AccountId <> ' ' ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM AcceleratedProvision 
                             WHERE  AccountId = v_AccountId
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM AcceleratedProvision_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND AccountId = v_AccountId
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            v_Result := 6 ;
            RETURN v_Result;-- USER ALEADY EXISTS

         END;
         END IF;

      END;
      END IF;
      IF ( v_UCICID <> ' ' ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM AcceleratedProvision 
                             WHERE  UCICID = v_UCICID
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM AcceleratedProvision_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND UCICID = v_UCICID
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            v_Result := 7 ;
            RETURN v_Result;-- USER ALEADY EXISTS

         END;
         END IF;

      END;
      END IF;

   END;
   END IF;
   IF NVL(v_CustomerId, ' ') = ' ' THEN

   BEGIN
      v_CustomerId := NULL ;

   END;
   END IF;
   IF NVL(v_AccountId, ' ') = ' ' THEN

   BEGIN
      v_AccountId := NULL ;

   END;
   END IF;
   IF NVL(v_UCICID, ' ') = ' ' THEN

   BEGIN
      v_UCICID := NULL ;

   END;
   END IF;
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
                         FROM AcceleratedProvision 
                          WHERE  AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM AcceleratedProvision_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
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
         SELECT NVL(MAX(AcceleratedProvisionEntityID) , 0) + 1 

           INTO v_AcceleratedProvisionEntityID
           FROM ( SELECT AcceleratedProvisionEntityID 
                  FROM AcceleratedProvision 
                  UNION 
                  SELECT AcceleratedProvisionEntityID 
                  FROM AcceleratedProvision_Mod  ) A;

      END;
      END IF;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         --IF @OperationFlag=2 
         --BEGIN
         --SET @AcceleratedProvisionEntityID=0
         --				Select @AcceleratedProvisionEntityID=AcceleratedProvisionEntityID
         --							from AcceleratedProvision_Mod A
         --							    WHERE
         --								(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
         --							 AcceleratedProvisionEntityID =@AcceleratedProvisionEntityID
         --							AND AuthorisationStatus IN('NP','MP','RM')
         --							 AND A.AcceleratedProvisionEntityID IN
         --                    (
         --                        SELECT MAX(AcceleratedProvisionEntityID)
         --                        FROM AcceleratedProvision_Mod
         --                        WHERE EffectiveFromTimeKey <= @TimeKey
         --                              AND EffectiveToTimeKey >= @TimeKey
         --                              AND AuthorisationStatus IN('NP','MP','RM')
         --                        GROUP BY AcceleratedProvisionEntityID
         --                    )
         --END
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
            ----SET @AcceleratedProvisionEntityID = (Select ISNULL(Max(AcceleratedProvisionEntityID),0)+1 from 
            ----						(Select AcceleratedProvisionEntityID from AcceleratedProvision
            ----						 UNION 
            ----						 Select AcceleratedProvisionEntityID from AcceleratedProvision_Mod
            ----						)A)
            GOTO GLCodeMaster_Insert;
            <<GLCodeMaster_Insert_Add>>

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
                 FROM AcceleratedProvision 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM AcceleratedProvision_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE AcceleratedProvision
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               DBMS_OUTPUT.PUT_LINE('SAC');
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('SAC1');
                  DBMS_OUTPUT.PUT_LINE('@AcceleratedProvisionEntityID');
                  DBMS_OUTPUT.PUT_LINE(v_AcceleratedProvisionEntityID);
                  UPDATE AcceleratedProvision_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               --IF @OperationFlag=3
               --BEGIN	
               --	UPDATE AcceleratedProvision_Mod
               --		SET AuthorisationStatus='FM'
               --		,ModifiedBy=@Modifiedby
               --		,DateModified=@DateModified
               --	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
               --			AND AcceleratedProvisionEntityID =@AcceleratedProvisionEntityID
               --			AND AuthorisationStatus IN('DP')
               --END
               GOTO GLCodeMaster_Insert;
               <<GLCodeMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE AcceleratedProvision
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;

               END;

               ----------------------------------NEW ADD FIRST LVL AUTH------------------
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE AcceleratedProvision_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM AcceleratedProvision 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE AcceleratedProvision
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -------------------------------------------------------------------------
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE AcceleratedProvision_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('Sunil');
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM AcceleratedProvision 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE AcceleratedProvision
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
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
                           UPDATE AcceleratedProvision_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;

                        END;

                        --------NEW ADD------------------

                        --ELSE IF @OperationFlag=16

                        --	BEGIN

                        --	SET @ApprovedBy	   = @CrModApBy 

                        --	SET @DateApproved  = GETDATE()

                        --	UPDATE AcceleratedProvision_Mod

                        --					SET AuthorisationStatus ='1A'

                        --						,ApprovedBy=@ApprovedBy

                        --						,DateApproved=@DateApproved

                        --						WHERE AcceleratedProvisionEntityID=@AcceleratedProvisionEntityID

                        --						AND AuthorisationStatus in('NP','MP','DP','RM')

                        --	END

                        ------------------------------
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE AcceleratedProvision_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy,
                                     DateApprovedFirstLevel = v_DateApproved
                               WHERE  AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                AND AuthorisationStatus IN ( 'NP','MP','RM' )
                              ;

                           END;
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
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM AcceleratedProvision 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;
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
                                    v_CurAcceleratedProvisionEntityID NUMBER(10,0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('B');
                                    DBMS_OUTPUT.PUT_LINE('C');
                                    SELECT MAX(AcceleratedProvisionEntityID)  

                                      INTO v_ExAcceleratedProvisionEntityID
                                      FROM AcceleratedProvision_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifiedBy ,
                                           DateModified 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModified
                                      FROM AcceleratedProvision_Mod 
                                     WHERE  AcceleratedProvisionEntityID = v_ExAcceleratedProvisionEntityID;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(AcceleratedProvisionEntityID)  

                                      INTO v_ExAcceleratedProvisionEntityID
                                      FROM AcceleratedProvision_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM AcceleratedProvision_Mod 
                                     WHERE  AcceleratedProvisionEntityID = v_ExAcceleratedProvisionEntityID;
                                    UPDATE AcceleratedProvision_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE AcceleratedProvision_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM AcceleratedProvision 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE AcceleratedProvision
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE AcceleratedProvision_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
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
                                                       FROM AcceleratedProvision 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
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
                                                          FROM AcceleratedProvision 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                                                    AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE AcceleratedProvision
                                             SET AcceProDuration = v_AcceProDuration,
                                                 EffectiveDate = v_EffectiveDate,
                                                 Secured_Unsecured = v_Secured_Unsecured,
                                                 AdditionalProvision = v_AdditionalProvision,
                                                 AdditionalProvACCT = v_AdditionalProvACCT,
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
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
                                            AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID;

                                       END;
                                       ELSE

                                       BEGIN
                                          v_IsSCD2 := 'Y' ;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    --select @IsAvailable,@IsSCD2
                                    IF v_IsAvailable = 'N'
                                      OR v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       INSERT INTO AcceleratedProvision
                                         ( AcceleratedProvisionEntityID, CustomerId, AccountId, UCICID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, AdditionalProvACCT, CustomerEntityId, UcifEntityID, AccountEntityId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, SegmentNameAlt_key, AssetClassNameAlt_key, CurrentProvisionPer )
                                         ( SELECT AcceleratedProvisionEntityID ,
                                                  CustomerId ,
                                                  AccountId ,
                                                  UCICID ,
                                                  AcceProDuration ,
                                                  EffectiveDate ,
                                                  Secured_Unsecured ,
                                                  AdditionalProvision ,
                                                  AdditionalProvACCT ,
                                                  CustomerEntityId ,
                                                  UcifEntityID ,
                                                  AccountEntityId ,
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
                                                         OR v_IsAvailable = 'Y' THEN v_DateModified
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                  ELSE NULL
                                                     END col  ,
                                                  SegmentNameAlt_key ,
                                                  AssetClassNameAlt_key ,
                                                  CurrentProvisionPer 
                                           FROM AcceleratedProvision_Mod A
                                            WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                     AND A.EffectiveToTimeKey >= v_TimeKey )
                                                     AND A.AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                                     AND NVL(A.AuthorisationStatus, 'A') = 'A' );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE AcceleratedProvision
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO GLCodeMaster_Insert;
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
         <<GLCodeMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            -----------------------------------------------------------
            --	IF Object_id('Tempdb..#Temp') Is Not Null
            --Drop Table #Temp
            --	IF Object_id('Tempdb..#final') Is Not Null
            --Drop Table #final
            --Create table #Temp
            --(ProductCode Varchar(20)
            --,SourceAlt_Key Varchar(20)
            --,ProductDescription Varchar(500)
            --)
            --Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)
            --Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
            --SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
            --                            FROM  (SELECT 
            --                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
            --											ProductCode,ProductDescription
            --                                            from #Temp
            --                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
            --)A 
            --ALTER TABLE #FINAL ADD AcceleratedProvisionEntityID INT
            --IF @OperationFlag=1 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.AcceleratedProvisionEntityID=ACCT.AcceleratedProvisionEntityID
            -- FROM #final TEMP
            --INNER JOIN (SELECT SourceAlt_Key,(@AcceleratedProvisionEntityID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) AcceleratedProvisionEntityID
            --			FROM #final
            --			WHERE AcceleratedProvisionEntityID=0 OR AcceleratedProvisionEntityID IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
            --END
            --IF @OperationFlag=2 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.AcceleratedProvisionEntityID=@AcceleratedProvisionEntityID
            -- FROM #final TEMP
            --END
            --------------------------------------------------
            IF ( v_AccountId <> ' '
              AND v_AuthorisationStatus = 'NP' ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SACAccount');
               ---Declare @Segment Varchar(10)=''
               --SET @Segment=
               INSERT INTO AcceleratedProvision_Mod
                 ( AcceleratedProvisionEntityID, CustomerId, AccountId, UCICID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, AdditionalProvACCT, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, changeField, ScreenFlag, SegmentNameAlt_key, AssetClassNameAlt_key, CurrentProvisionPer )
                 ( SELECT v_AcceleratedProvisionEntityID ,
                          v_CustomerId ,
                          v_AccountId ,
                          v_UCICID ,
                          v_AcceProDuration ,
                          v_EffectiveDate ,
                          v_Secured_Unsecured ,
                          v_AdditionalProvision ,
                          v_AdditionalProvACCT ,
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
                                 OR v_IsAvailable = 'Y' THEN v_DateModified
                          ELSE NULL
                             END col  ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                          ELSE NULL
                             END col  ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_DateApproved
                          ELSE NULL
                             END col  ,
                          v_AcceleratedProvisionMaster_changeFields ,
                          'S' ,
                          v_SegmentNameAlt_key ,
                          v_AssetClassNameAlt_key ,
                          v_CurrentProvisionPer 
                   FROM RBL_MISDB_PROD.AdvAcBasicDetail A
                          LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
                          JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
                          AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key

                   --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey
                   WHERE  CustomerACID = v_AccountId

                            --AND A.segmentcode=Convert(Varchar(10),@SegmentNameAlt_key)

                            --AND A.segmentcode in (SELECT AcBuSegmentCode FROM DimAcBuSegment 

                            --where AcBuRevisedSegmentCode=Convert(Varchar(100),@SegmentNameAlt_key))
                            AND B.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                            AND A.FlgSecured = CASE 
                                                    WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                                    WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey );

            END;
            END IF;
            IF ( ( v_CustomerId <> ' '
              OR v_UCICID <> ' ' )
              AND v_AuthorisationStatus = 'NP' ) THEN

            BEGIN
               INSERT INTO AcceleratedProvision_Mod
                 ( AcceleratedProvisionEntityID, CustomerId, AccountId, UCICID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, AdditionalProvACCT, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, changeField, ScreenFlag, SegmentNameAlt_key, AssetClassNameAlt_key, CurrentProvisionPer )
                 ( SELECT v_AcceleratedProvisionEntityID ,
                          v_CustomerId ,
                          CustomerACID ,
                          v_UCICID ,
                          v_AcceProDuration ,
                          v_EffectiveDate ,
                          v_Secured_Unsecured ,
                          v_AdditionalProvision ,
                          v_AdditionalProvACCT ,
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
                                 OR v_IsAvailable = 'Y' THEN v_DateModified
                          ELSE NULL
                             END col  ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                          ELSE NULL
                             END col  ,
                          CASE 
                               WHEN v_AuthMode = 'Y' THEN v_DateApproved
                          ELSE NULL
                             END col  ,
                          v_AcceleratedProvisionMaster_changeFields ,
                          'S' ,
                          v_SegmentNameAlt_key ,
                          v_AssetClassNameAlt_key ,
                          v_CurrentProvisionPer 
                   FROM RBL_MISDB_PROD.AdvAcBasicDetail A
                          JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerEntityId = B.CustomerEntityId
                          LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail C   ON A.CustomerEntityId = C.CustomerEntityId
                          JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
                          AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key

                   --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey
                   WHERE  ( ( B.CustomerId = v_CustomerId )
                            OR ( B.UCIF_ID = v_UCICID ) )

                            --AND A.segmentcode=Convert(Varchar(10),@SegmentNameAlt_key)

                            --AND A.segmentcode in (SELECT AcBuSegmentCode FROM DimAcBuSegment 

                            --		where AcBuRevisedSegmentCode=Convert(Varchar(100),@SegmentNameAlt_key))
                            AND C.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                            AND A.FlgSecured = CASE 
                                                    WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                                    WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            AND C.EffectiveFromTimeKey <= v_TimeKey
                            AND C.EffectiveToTimeKey >= v_TimeKey );

            END;
            END IF;
            IF ( v_AuthorisationStatus <> 'NP' ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
               DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM AcceleratedProvision_Mod 
                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey
                                            AND NVL(AuthorisationStatus, ' ') = 'A'
                                            AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  INSERT INTO AcceleratedProvision_Mod
                    ( AcceleratedProvisionEntityID, CustomerId, AccountId, UCICID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, AdditionalProvACCT, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, changeField, ScreenFlag, SegmentNameAlt_key, AssetClassNameAlt_key, CurrentProvisionPer, CustomerEntityId, UcifEntityID, AccountEntityId )
                    ( SELECT AcceleratedProvisionEntityID ,
                             CustomerId ,
                             AccountId ,
                             UCICID ,
                             v_AcceProDuration ,
                             v_EffectiveDate ,
                             v_Secured_Unsecured ,
                             v_AdditionalProvision ,
                             v_AdditionalProvACCT ,
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
                                    OR v_IsAvailable = 'Y' THEN v_DateModified
                             ELSE NULL
                                END col  ,
                             CASE 
                                  WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                             ELSE NULL
                                END col  ,
                             CASE 
                                  WHEN v_AuthMode = 'Y' THEN v_DateApproved
                             ELSE NULL
                                END col  ,
                             v_AcceleratedProvisionMaster_changeFields ,
                             'S' ,
                             v_SegmentNameAlt_key ,
                             v_AssetClassNameAlt_key ,
                             v_CurrentProvisionPer ,
                             CustomerEntityId ,
                             UcifEntityID ,
                             AccountEntityId 
                      FROM AcceleratedProvision_Mod A
                       WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey )
                                AND A.AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                AND AuthorisationStatus = 'A' );

               END;
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT EXISTS ( SELECT 1 
                                      FROM AcceleratedProvision_Mod 
                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                AND EffectiveToTimeKey >= v_TimeKey
                                                AND NVL(AuthorisationStatus, ' ') = 'A'
                                                AND AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Anuj');
                  INSERT INTO AcceleratedProvision_Mod
                    ( AcceleratedProvisionEntityID, CustomerId, AccountId, UCICID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, AdditionalProvACCT, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, changeField, ScreenFlag, SegmentNameAlt_key, AssetClassNameAlt_key, CurrentProvisionPer, CustomerEntityId, UcifEntityID, AccountEntityId )
                    ( SELECT AcceleratedProvisionEntityID ,
                             CustomerId ,
                             AccountId ,
                             UCICID ,
                             v_AcceProDuration ,
                             v_EffectiveDate ,
                             v_Secured_Unsecured ,
                             v_AdditionalProvision ,
                             v_AdditionalProvACCT ,
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
                                    OR v_IsAvailable = 'Y' THEN v_DateModified
                             ELSE NULL
                                END col  ,
                             CASE 
                                  WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                             ELSE NULL
                                END col  ,
                             CASE 
                                  WHEN v_AuthMode = 'Y' THEN v_DateApproved
                             ELSE NULL
                                END col  ,
                             v_AcceleratedProvisionMaster_changeFields ,
                             'S' ,
                             v_SegmentNameAlt_key ,
                             v_AssetClassNameAlt_key ,
                             v_CurrentProvisionPer ,
                             CustomerEntityId ,
                             UcifEntityID ,
                             AccountEntityId 
                      FROM AcceleratedProvision_Mod A
                       WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey )
                                AND A.AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                                AND AuthorisationStatus = 'FM' );
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, A.EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
                  FROM A ,AcceleratedProvision_Mod A 
                   WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
                    AND A.AcceleratedProvisionEntityID = v_AcceleratedProvisionEntityID
                    AND AuthorisationStatus = 'FM') src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;

               END;
               END IF;

            END;
            END IF;
            IF ( v_CustomerId <> ' ' ) THEN

            BEGIN
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN A.Secured_Unsecured = 'Secured' THEN D.ProvisionSecured
               WHEN A.Secured_Unsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
               FROM A ,AcceleratedProvision_Mod A
                      JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON A.AccountId = C.CustomerAcID
                      LEFT JOIN DimProvision_Seg D   ON C.ProvisionAlt_Key = D.ProvisionAlt_Key 
                WHERE A.CustomerId = v_CustomerId
                 AND C.EffectiveFromTimeKey <= v_Timekey
                 AND C.EffectiveToTimeKey >= v_Timekey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
               --AND Secured_Unsecured='Secured'
               --Update A
               --SET A.CurrentProvisionPer=D.ProvisionUnSecured
               --From AcceleratedProvision_Mod A 
               --INNER Join PRO.AccountCal_Hist C with (nolock)
               --ON A.AccountId=C.CustomerAcID 
               --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
               --Where A.CustomerId=@CustomerId
               --AND C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey
               --AND Secured_Unsecured='UnSecured'
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.CustomerEntityId
               FROM A ,AcceleratedProvision_Mod A
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON A.CustomerId = C.CustomerID 
                WHERE C.CustomerID = v_CustomerId
                 AND c.EffectiveFromTimeKey <= v_TimeKey
                 AND c.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.CustomerEntityId = src.CustomerEntityId;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.AccountEntityId
               FROM A ,AcceleratedProvision_Mod A
                      JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID 
                WHERE A.CustomerId = v_CustomerId
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AccountEntityId = src.AccountEntityId;

            END;
            END IF;
            IF ( v_UCICID <> ' ' ) THEN

            BEGIN
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN A.Secured_Unsecured = 'Secured' THEN D.ProvisionSecured
               WHEN A.Secured_Unsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
               FROM A ,AcceleratedProvision_Mod A
                      JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON A.AccountId = C.CustomerAcID
                      LEFT JOIN DimProvision_Seg D   ON C.ProvisionAlt_Key = D.ProvisionAlt_Key 
                WHERE A.UCICID = v_UCICID
                 AND C.EffectiveFromTimeKey <= v_Timekey
                 AND C.EffectiveToTimeKey >= v_Timekey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
               --AND Secured_Unsecured='Secured'
               --Update A
               --SET A.CurrentProvisionPer=D.ProvisionUnSecured
               --From AcceleratedProvision_Mod A 
               --INNER Join PRO.AccountCal_Hist C with (nolock)
               --ON A.AccountId=C.CustomerAcID 
               --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
               --Where A.UCICID=@UCICID
               --AND C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey
               --AND Secured_Unsecured='UnSecured'
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, C.UcifEntityID, C.CustomerEntityId
               FROM A ,AcceleratedProvision_Mod A
                      JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON A.UCICID = C.UCIF_ID 
                WHERE C.UCIF_ID = v_UCICID
                 AND C.EffectiveFromTimeKey <= v_TimeKey
                 AND C.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.UcifEntityID = src.UcifEntityID,
                                            A.CustomerEntityId = src.CustomerEntityId;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.AccountEntityId
               FROM A ,AcceleratedProvision_Mod A
                      JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID 
                WHERE A.UCICID = v_UCICID
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AccountEntityId = src.AccountEntityId;

            END;
            END IF;
            IF ( v_AccountId <> ' ' ) THEN

            BEGIN
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN A.Secured_Unsecured = 'Secured' THEN D.ProvisionSecured
               WHEN A.Secured_Unsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
               FROM A ,AcceleratedProvision_Mod A
                      JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON A.AccountId = C.CustomerAcID
                      LEFT JOIN DimProvision_Seg D   ON C.ProvisionAlt_Key = D.ProvisionAlt_Key 
                WHERE A.AccountId = v_AccountId
                 AND C.EffectiveFromTimeKey <= v_Timekey
                 AND C.EffectiveToTimeKey >= v_Timekey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
               --AND Secured_Unsecured='Secured'
               --Update A
               --SET A.CurrentProvisionPer=D.ProvisionUnSecured
               --From AcceleratedProvision_Mod A 
               --INNER Join PRO.AccountCal_Hist C with (nolock)
               --ON A.AccountId=C.CustomerAcID 
               --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
               --Where A.AccountId=@AccountId
               --AND C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey
               --AND Secured_Unsecured='UnSecured'
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.AccountEntityId
               FROM A ,AcceleratedProvision_Mod A
                      JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID 
                WHERE B.CustomerACID = v_AccountId
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AccountEntityId = src.AccountEntityId;

            END;
            END IF;
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO GLCodeMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO GLCodeMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND GLAlt_Key=@GLAlt_Key
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCEPROVISIONMASTER_INUP_18112023" TO "ADF_CDR_RBL_STGDB";
