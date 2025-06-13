--------------------------------------------------------
--  DDL for Function BUSINESSRULESETUPINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" 
-- =============================================
 -- Author:		<Author Triloki Kumar>
 -- Create date: <Create Date 13/03/2020>
 -- Description:	<Description  Business Rule Setup Inup >
 -- =============================================

(
  iv_BusinessRule_Alt_key IN NUMBER,
  --,@Territoryalt_key			INT
  v_CatAlt_key IN NUMBER,
  iv_UniqueID IN NUMBER,
  v_Businesscolalt_key IN NUMBER,
  v_Scope IN NUMBER,
  v_Businesscolvalues1 IN VARCHAR2,
  v_Businesscolvalues IN VARCHAR2,
  iv_UserId IN VARCHAR2,
  v_OperationFlag IN NUMBER,
  v_D2kTimestamp OUT NUMBER,
  v_Result OUT NUMBER,
  v_AuthMode IN CHAR DEFAULT 'Y' ,
  v_Expression IN VARCHAR2 DEFAULT ' ' ,
  v_FinalExpression IN VARCHAR2 DEFAULT ' ' 
)
RETURN NUMBER
AS
   v_UniqueID NUMBER(10,0) := iv_UniqueID;
   v_BusinessRule_Alt_key NUMBER(10,0) := iv_BusinessRule_Alt_key;
   v_UserId VARCHAR2(50) := iv_UserId;
   v_temp NUMBER(1, 0) := 0;

BEGIN

   ---------------Added by Poonam----------------
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
      v_unid NUMBER(10,0);
      -----------------------------------------------f
      v_Timekey NUMBER(10,0);
      v_EffectiveFromTimeKey NUMBER(10,0);
      v_EffectiveToTimeKey NUMBER(10,0);
      v_AuthorisationStatus VARCHAR2(2) := NULL;
      v_CreatedBy VARCHAR2(20) := NULL;
      v_DateCreated DATE := NULL;
      v_ModifiedBy VARCHAR2(20) := NULL;
      v_DateModified DATE := NULL;
      v_ApprovedBy VARCHAR2(20) := NULL;
      v_DateApproved DATE := NULL;
      v_BusinessCol VARCHAR2(50);

   BEGIN
      SELECT NVL(MAX(UniqueID) , 0) 

        INTO v_Unid
        FROM DimBusinessRuleSetup_mod ;
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  CurrentStatus = 'C';
      v_EffectiveFromTimeKey := v_TimeKey ;
      v_EffectiveToTimeKey := 49999 ;
      SELECT BusinessRuleColDesc 

        INTO v_BusinessCol
        FROM DimBusinessRuleCol 
       WHERE  EffectiveToTimeKey = 49999
                AND BusinessRuleColAlt_Key = v_Businesscolalt_key;
      IF utils.object_id('TEMPDB..tt_TEMP123') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP123 ';
      END IF;
      DELETE FROM tt_TEMP123;
      UTILS.IDENTITY_RESET('tt_TEMP123');

      INSERT INTO tt_TEMP123 ( 
      	SELECT * 
      	  FROM TABLE(SPLIT(v_Businesscolvalues1, ','))  );
      UPDATE tt_TEMP123
         SET Items = LTRIM(RTRIM(Items));
      --select * from tt_TEMP123
      IF v_OperationFlag = 1 THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM DimBusinessRuleSetup 
                             WHERE  UniqueID = v_UniqueID
                                      AND CatAlt_key = v_CatAlt_key
                                      AND EffectiveToTimeKey = 49999
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                            UNION 
                            SELECT 1 
                            FROM DimBusinessRuleSetup_mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND UniqueID = v_UniqueID
                                      AND CatAlt_key = v_CatAlt_key
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            v_Result := -6 ;
            RETURN v_Result;

         END;
         ELSE

         BEGIN
            SELECT MAX(UniqueID)  

              INTO v_UniqueID
              FROM DimBusinessRuleSetup 
             WHERE  CatAlt_key = v_CatAlt_key
                      AND EffectiveToTimeKey = 49999;
            SELECT MAX(BusinessRule_Alt_key)  

              INTO v_BusinessRule_Alt_key
              FROM DimBusinessRuleSetup 
             WHERE  CatAlt_key = v_CatAlt_key
                      AND EffectiveToTimeKey = 49999;

         END;
         END IF;

      END;
      END IF;
      /*
      			 IF @BusinessCol='ProductCode'
      					BEGIN		

      				select * from tt_TEMP123

      							IF EXISTS (SELECT 1 FROM tt_TEMP123 A
      								LEFT JOIN DimGLProduct_AU B
      									ON A.Items=B.ProductCode
      									WHERE B.ProductCode IS NULL
      								)	
      								BEGIN
      									SET @Result=-2
      									RETURN @Result
      								END 														
      						END 
      */
      IF NVL(v_UniqueID, 0) = 0 THEN

      BEGIN
         v_UniqueID := 0 ;

      END;
      END IF;
      IF NVL(v_BusinessRule_Alt_key, 0) = 0 THEN

      BEGIN
         SELECT MAX(BusinessRule_Alt_key)  + 1 

           INTO v_BusinessRule_Alt_key
           FROM DimBusinessRuleSetup ;

      END;
      END IF;
      IF NVL(v_BusinessRule_Alt_key, 0) = 0 THEN

      BEGIN
         v_BusinessRule_Alt_key := 1 ;

      END;
      END IF;
      BEGIN

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
            /*
            			 IF @BusinessCol='ProductCode'
            				BEGIN
            				 SELECT @Businesscolvalues1=STUFF(
                                     (                             							 
            							SELECT ','+CONVERT(VARCHAR(MAX),GLProductAlt_Key) FROM DimGLProduct WHERE ProductCode IN(SELECT ITEMS FROM tt_TEMP123)							
            							 FOR XML PATH('')
                                     ), 1, 1, '')
            					END 
            					*/
            IF v_OperationFlag = 16 THEN

            BEGIN
               --   --SET @UserId=@UserId
               --PRINT '@UserId'
               --PRINT @UserId
               --PRINT '@UserId'
               --PRINT @UserId
               v_ApprovedBy := v_UserId ;
               v_DateApproved := SYSDATE ;
               UPDATE DimBusinessRuleSetup_mod
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserId,
                      DateApproved = v_DateApproved
                WHERE --BusinessRule_Alt_key=@BusinessRule_Alt_key AND     -------------Changed on 29042021 
                 CatAlt_key = v_CatAlt_key
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
               ;

            END;
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('G');
                  v_AuthorisationStatus := 'A' ;
                  v_Modifiedby := v_UserId ;
                  v_DateModified := SYSDATE ;
                  v_ApprovedBy := v_UserId ;
                  v_DateApproved := SYSDATE ;
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimBusinessRuleSetup_mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND CatAlt_key = v_CatAlt_key
                            AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                  ;
                  --               IF EXISTS(SELECT 1 FROM DimBusinessRuleSetup WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
                  --AND EffectiveFromTimeKey=@TimeKey AND CatAlt_key =@CatAlt_key )
                  --AND UniqueID=@UniqueID

                  BEGIN
                     INSERT INTO DimBusinessRuleSetup
                       ( BusinessRule_Alt_key, CatAlt_key, UniqueID, Businesscolalt_key, Scope, Businesscolvalues1, Businesscolvalues, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                       ( SELECT BusinessRule_Alt_key ,
                                CatAlt_key ,
                                UniqueID ,
                                Businesscolalt_key ,
                                Scope ,
                                Businesscolvalues1 ,
                                Businesscolvalues ,
                                'A' AuthorisationStatusAS  ,
                                v_Timekey ,
                                49999 ,
                                v_UserId CreatedBy  ,
                                v_DateCreated ,
                                v_Modifiedby ,
                                v_DateModified ,
                                NULL ApprovedBy  ,
                                NULL DateApproved  
                         FROM DimBusinessRuleSetup_mod 
                          WHERE  CatAlt_key = v_CatAlt_key
                                   AND AuthorisationStatus IN ( '1A' )

                                   AND ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) );
                     UPDATE DimBusinessRuleSetup_mod
                        SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                      WHERE  CatAlt_key = v_CatAlt_key
                       AND AuthorisationStatus IN ( 'A' )
                     ;--AND UniqueID=@UniqueID
                     UPDATE DimBusinessRuleSetup_mod
                        SET AuthorisationStatus = 'A',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved

                     --,EffectiveToTimeKey=EffectiveFromTimeKey-1
                     WHERE  CatAlt_key = v_CatAlt_key
                       AND AuthorisationStatus IN ( '1A' )
                     ;--AND UniqueID=@UniqueID
                     UPDATE DimBusinessRuleSetup
                        SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                      WHERE  CatAlt_key = v_CatAlt_key
                       AND AuthorisationStatus IN ( 'MP' )
                     ;
                     UPDATE DimBusinessRuleSetup
                        SET AuthorisationStatus = 'A',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved

                     --,EffectiveToTimeKey=EffectiveFromTimeKey-1
                     WHERE  CatAlt_key = v_CatAlt_key
                       AND AuthorisationStatus IN ( 'MP','NP' )
                     ;

                  END;
                  --   ELSE
                  --                    BEGIN
                  --	INSERT INTO DimBusinessRuleSetup
                  --		(
                  --			BusinessRule_Alt_key
                  --			,CatAlt_key
                  --			,UniqueID
                  --			,Businesscolalt_key
                  --			,Scope
                  --			,Businesscolvalues1
                  --			,Businesscolvalues
                  --			,AuthorisationStatus
                  --			,EffectiveFromTimeKey
                  --			,EffectiveToTimeKey
                  --			,CreatedBy
                  --			,DateCreated
                  --			,ApprovedBy
                  --			,DateApproved																
                  --		)
                  --		SELECT 
                  --			BusinessRule_Alt_key
                  --			,CatAlt_key
                  --			,UniqueID
                  --			,Businesscolalt_key
                  --			,Scope
                  --			,Businesscolvalues1
                  --			,Businesscolvalues
                  --			,'A' AuthorisationStatusAS
                  --			,@Timekey
                  --			,49999
                  --	        ,@CreatedBy
                  --			,@DateCreated
                  --			,@UserId ApprovedBy
                  --			,GETDATE() DateApproved
                  --			From DimBusinessRuleSetup_mod
                  --	Where CatAlt_key=@CatAlt_key AND AuthorisationStatus in('1A')
                  --	AND  (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
                  --UPDATE DimBusinessRuleSetup_mod
                  --			SET AuthorisationStatus ='A'
                  --				,ApprovedBy=@ApprovedBy
                  --				,DateApproved=@DateApproved
                  --				--,EffectiveToTimeKey=EffectiveFromTimeKey-1
                  --			WHERE CatAlt_key=@CatAlt_key				
                  --				AND AuthorisationStatus in('1A') 	--AND UniqueID=@UniqueID
                  --      UPDATE DimBusinessRuleSetup_mod
                  --SET 
                  --	EffectiveToTimeKey=EffectiveFromTimeKey-1
                  --WHERE CatAlt_key=@CatAlt_key				
                  --	AND AuthorisationStatus in('A')
                  --	AND UniqueID=@UniqueID
                  --END
                  --AND EntityKey IN
                  --(
                  --    SELECT MAX(EntityKey)
                  --    FROM DimBusinessRuleSetup_mod
                  --    WHERE EffectiveFromTimeKey <= @TimeKey
                  --          AND EffectiveToTimeKey >= @TimeKey
                  --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                  --    GROUP BY CatAlt_key
                  --)
                  utils.var_number :=RBL_MISDB_PROD.Provision_Update(v_ProvisionAlt_Key => v_CatAlt_key,
                                                                     v_Expression => v_Expression,
                                                                     v_FinalExpression => v_FinalExpression,
                                                                     v_UserId => v_UserId,
                                                                     v_UserId => v_OperationFlag,
                                                                     v_OperationFlag => v_Result) ;

               END;
               END IF;
            END IF;
            --BEGIN
            --print'R'
            --		UPDATE DimBusinessRuleSetup_mod
            --			SET AuthorisationStatus ='A'
            --				,ApprovedBy=@ApprovedBy
            --				,DateApproved=@DateApproved
            --			WHERE CatAlt_key=@CatAlt_key				
            --				AND AuthorisationStatus in('NP','MP','RM')
            --				AND EntityKey IN
            --      (
            --                    SELECT MAX(EntityKey)
            --                    FROM DimBusinessRuleSetup_mod
            --                    WHERE EffectiveFromTimeKey <= @TimeKey
            --                        AND EffectiveToTimeKey >= @TimeKey
            --                     AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
            --                    GROUP BY CatAlt_key
            --                )
            --END	
            -----------------------------------------------------
            --IF @OperationFlag=2
            --	BEGIN
            --		UPDATE DimBusinessRuleSetup
            --			SET Businesscolalt_key		=@Businesscolalt_key	
            --				,Scope					=@Scope
            --				,Businesscolvalues1		=@Businesscolvalues1
            --				,Businesscolvalues		=@Businesscolvalues
            --				,ModifiedBy				=@UserId
            --				,DateModified			=GETDATE()																			
            --			WHERE UniqueID=@UniqueID 
            --			AND BusinessRule_Alt_key=@BusinessRule_Alt_key
            --			AND Territoryalt_key=@Territoryalt_key 
            --			AND CatAlt_key=@CatAlt_key 
            --	END 
            IF v_OperationFlag = 3 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('8');
               --DELETE FROM DimBusinessRuleSetup								
               --	WHERE UniqueID=@UniqueID 
               --	AND BusinessRule_Alt_key=@BusinessRule_Alt_key
               --	AND Territoryalt_key=@Territoryalt_key 
               --	AND CatAlt_key=@CatAlt_key 
               v_Modifiedby := v_UserId ;
               v_DateModified := SYSDATE ;
               UPDATE DimBusinessRuleSetup
                  SET ModifiedBy = v_Modifiedby,
                      DateModified = v_DateModified,
                      EffectiveToTimeKey = v_TimeKey - 1
                WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )

                 --AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
                 AND CatAlt_key = v_CatAlt_key;

            END;

            ------------------------------------------NEW ADD FIRST LVL AUTHT...----------------------
            ELSE
               IF v_OperationFlag = 21
                 AND v_AuthMode = 'Y' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  v_ApprovedBy := v_UserId ;
                  v_DateApproved := SYSDATE ;
                  UPDATE DimBusinessRuleSetup_mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND   BusinessRule_Alt_key=@BusinessRule_Alt_key 
                    AND CatAlt_key = v_CatAlt_key
                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                  ;
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM DimBusinessRuleSetup 
                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_Timekey )

                                               --AND   BusinessRule_Alt_key=@BusinessRule_Alt_key 
                                               AND CatAlt_key = v_CatAlt_key );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     UPDATE DimBusinessRuleSetup
                        SET AuthorisationStatus = 'A'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BusinessRule_Alt_key = v_BusinessRule_Alt_key
                       AND CatAlt_key = v_CatAlt_key
                       AND AuthorisationStatus IN ( 'MP','DP','RM' )
                     ;

                  END;
                  END IF;

               END;
               END IF;
            END IF;
            ------------------------------------------------------------------------------
            IF v_OperationFlag = 17 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('J');
               v_ApprovedBy := v_UserId ;
               v_DateApproved := SYSDATE ;
               UPDATE DimBusinessRuleSetup_mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_ApprovedBy,
                      DateApproved = v_DateApproved,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )

                 --AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
                 AND CatAlt_key = v_CatAlt_key
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
               ;
               DBMS_OUTPUT.PUT_LINE('Sunil');
               --
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM DimBusinessRuleSetup 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND BusinessRule_Alt_key = v_BusinessRule_Alt_key
                                            AND CatAlt_key = v_CatAlt_key );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('K');
                  UPDATE DimBusinessRuleSetup
                     SET AuthorisationStatus = 'A'
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
                    AND CatAlt_key = v_CatAlt_key
                    AND AuthorisationStatus IN ( 'MP','DP','RM' )
                  ;

               END;
               END IF;

            END;
            END IF;
            IF v_OperationFlag IN ( 1,2 )
             THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Add');
                  v_CreatedBy := v_UserId ;
                  v_DateCreated := SYSDATE ;
                  v_AuthorisationStatus := 'NP' ;
                  SELECT NVL(MAX(BusinessRule_Alt_key) , 0) + 1 

                    INTO v_BusinessRule_Alt_key
                    FROM ( SELECT BusinessRule_Alt_key 
                           FROM DimBusinessRuleSetup 
                           UNION 
                           SELECT BusinessRule_Alt_key 
                           FROM DimBusinessRuleSetup_mod  ) A;

               END;
               ELSE
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('Edit');
                     v_AuthorisationStatus := 'MP' ;
                     v_Modifiedby := v_UserId ;
                     v_DateModified := SYSDATE ;

                  END;
                  END IF;
               END IF;
               --SET @CreatedBy= @UserId
               --SET @DateCreated = GETDATE()
               --Set @Modifiedby=@UserId   
               --Set @DateModified =GETDATE() 
               ---FIND CREATED BY FROM MAIN TABLE
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM DimBusinessRuleSetup 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )

                         --AND BusinessRule_Alt_key =@Businesscolalt_key
                         AND CatAlt_key = v_CatAlt_key;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimBusinessRuleSetup_mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )

                            --AND Businesscolalt_key =@Businesscolalt_key
                            AND CatAlt_key = v_CatAlt_key
                            AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Sachin');
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  DBMS_OUTPUT.PUT_LINE('@CatAlt_key');
                  DBMS_OUTPUT.PUT_LINE(v_CatAlt_key);
                  DBMS_OUTPUT.PUT_LINE('@UniqueID');
                  DBMS_OUTPUT.PUT_LINE(v_UniqueID);
                  DBMS_OUTPUT.PUT_LINE('@AuthorisationStatus');
                  DBMS_OUTPUT.PUT_LINE(v_AuthorisationStatus);
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  IF ( v_OperationFlag = 2 ) THEN

                  BEGIN
                     UPDATE DimBusinessRuleSetup
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND Businesscolalt_key =@Businesscolalt_key
                       AND CatAlt_key = v_CatAlt_key;--and UniqueID=@UniqueID

                  END;
                  END IF;

               END;
               END IF;
               --UPDATE NP,MP  STATUS
               IF v_OperationFlag = 2 THEN

               BEGIN
                  --UPDATE DimBusinessRuleSetup_MOD 
                  --	SET AuthorisationStatus=@AuthorisationStatus
                  --	,ModifiedBy=@Modifiedby
                  --	,DateModified=@DateModified
                  --WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
                  --		--AND Businesscolalt_key =@Businesscolalt_key
                  --		AND CatAlt_key=@CatAlt_key --and UniqueID=@UniqueID
                  UPDATE DimBusinessRuleSetup
                     SET AuthorisationStatus = v_AuthorisationStatus,
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND Businesscolalt_key =@Businesscolalt_key
                    AND CatAlt_key = v_CatAlt_key;-- and UniqueID=@UniqueID
                  --Select CatAlt_key, UniqueID into #tmp from DimBusinessRuleSetup_MOD
                  --WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
                  --AND CatAlt_key=@CatAlt_key 		
                  --Declare @CatAlt_key int,@UniqueID Int,@Count Int,@I Int
                  --Select @Count=Count(*) from #tmp
                  --SET @I=1
                  --While(@I<=@Count)
                  --Begin
                  --If (UniqueID=@UniqueID)
                  INSERT INTO DimBusinessRuleSetup_mod
                    ( BusinessRule_Alt_key, CatAlt_key, UniqueID, Businesscolalt_key, Scope, Businesscolvalues1, Businesscolvalues, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT v_BusinessRule_Alt_key ,
                             v_CatAlt_key ,
                             v_UniqueID ,
                             v_Businesscolalt_key ,
                             v_Scope ,
                             v_Businesscolvalues1 ,
                             v_Businesscolvalues ,
                             v_AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             v_UserId CreatedBy  ,
                             v_DateCreated ,
                             v_Modifiedby ,
                             v_DateModified ,
                             NULL ApprovedBy  ,
                             NULL DateApproved  
                        FROM DUAL  );
                  INSERT INTO DimBusinessRuleSetup_mod
                    ( BusinessRule_Alt_key, CatAlt_key, UniqueID, Businesscolalt_key, Scope, Businesscolvalues1, Businesscolvalues, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT BusinessRule_Alt_key ,
                             CatAlt_key ,
                             UniqueID ,
                             Businesscolalt_key ,
                             Scope ,
                             Businesscolvalues1 ,
                             Businesscolvalues ,
                             'MP' AuthorisationStatusAS  ,
                             v_Timekey ,
                             49999 ,
                             v_UserId CreatedBy  ,
                             v_DateCreated ,
                             v_Modifiedby ,
                             v_DateModified ,
                             NULL ApprovedBy  ,
                             NULL DateApproved  
                      FROM DimBusinessRuleSetup_mod 
                       WHERE  CatAlt_key = v_CatAlt_key
                                AND AuthorisationStatus IN ( 'A' )

                                AND UniqueID <> v_UniqueID
                                AND ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey ) );

               END;
               END IF;
               IF v_OperationFlag = 1 THEN

               BEGIN
                  --print'Start'
                  INSERT INTO DimBusinessRuleSetup_mod
                    ( BusinessRule_Alt_key, CatAlt_key, UniqueID, Businesscolalt_key, Scope, Businesscolvalues1, Businesscolvalues, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT v_BusinessRule_Alt_key ,
                             v_CatAlt_key ,
                             v_Unid + 1 ,
                             v_Businesscolalt_key ,
                             v_Scope ,
                             v_Businesscolvalues1 ,
                             v_Businesscolvalues ,
                             v_AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             v_UserId CreatedBy  ,
                             v_DateCreated ,
                             v_Modifiedby ,
                             v_DateModified ,
                             NULL ApprovedBy  ,
                             NULL DateApproved  
                        FROM DUAL  );

               END;
               END IF;

            END;
            END IF;
            utils.commit_transaction;
            --SELECT @D2kTimestamp =CAST(D2kTimestamp AS INT) FROM DimBusinessRuleSetup								
            --					WHERE UniqueID=@UniqueID 
            --					AND BusinessRule_Alt_key=@BusinessRule_Alt_key
            --					AND Territoryalt_key=@Territoryalt_key 
            --					AND CatAlt_key=@CatAlt_key 
            v_Result := 1 ;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         ROLLBACK;
         utils.resetTrancount;
         v_Result := -1 ;
         RETURN v_Result;

      END;END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPINUP" TO "ADF_CDR_RBL_STGDB";
