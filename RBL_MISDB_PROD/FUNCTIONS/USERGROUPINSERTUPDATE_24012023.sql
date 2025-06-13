--------------------------------------------------------
--  DDL for Function USERGROUPINSERTUPDATE_24012023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" 
--Text
 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --sp_rename 'UserGroupInsertUpdate','UserGroupInsertUpdate_07052022'
 -- -- select * from DimUserDeptGroup_Mod

(
  --@EntityKey int,        
  iv_DeptGroupId IN NUMBER DEFAULT 1 ,
  v_DeptGroupName IN VARCHAR2 DEFAULT 'test department' ,
  v_DeptGroupDesc IN VARCHAR2 DEFAULT 'test' ,
  v_MenuId IN VARCHAR2 DEFAULT '1,2,3,4,5,6,7' ,
  v_IsUniversal IN CHAR DEFAULT 'Y' ,
  v_AssignedReturns IN VARCHAR2 DEFAULT ' ' ,
  v_AssignedSLBC IN VARCHAR2 DEFAULT ' ' ,
  iv_timekey IN NUMBER DEFAULT 0 ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 49999 ,
  v_DateCreatedModifiedApproved IN VARCHAR2 DEFAULT NULL ,
  v_CreateModifyApprovedBy IN VARCHAR2 DEFAULT NULL ,
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,-- null		
  v_Remark IN VARCHAR2 DEFAULT NULL ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --@CreatedBy varchar(20),        
   v_timekey NUMBER(10,0) := iv_timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_DeptGroupId NUMBER(10,0) := iv_DeptGroupId;
   v_sys_error NUMBER := 0;
   v_AuthorisationStatus CHAR(2) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_Modifiedby VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_IsAvailable CHAR(1) := 'N';
   v_IsSCD2 CHAR(1) := 'N';

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   -- 	set @TimeKey = 
   --      (
   --          SELECT TimeKey
   --          FROM SysDayMatrix
   --          WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103)
   --      );
   --set @EffectiveFromTimeKey = (
   --          SELECT TimeKey
   --          FROM SysDayMatrix
   --          WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103)
   --      );
   SELECT TimeKey 

     INTO v_TimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT TimeKey 

     INTO v_EffectiveFromTimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF v_OperationFlag = 1 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

    -- when adding, check whether it already exist or not
   BEGIN
      IF v_AuthMode = 'N' THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('ABC');
         --select @DeptGroupId =  max(DeptGroupId)+1 from DimUserDeptGroup
         SELECT MAX(DeptGroupId)  + 1 

           INTO v_DeptGroupId
           FROM ( SELECT DeptGroupId 
                  FROM DimUserDeptGroup 
                  UNION 
                  SELECT DeptGroupId 
                  FROM DimUserDeptGroup_Mod  ) A;

      END;
      ELSE
         IF v_AuthMode = 'Y' THEN

         BEGIN
            --select @DeptGroupId =  max(DeptGroupId)+1 from DimUserDeptGroup_Mod
            SELECT MAX(DeptGroupId)  + 1 

              INTO v_DeptGroupId
              FROM ( SELECT DeptGroupId 
                     FROM DimUserDeptGroup 
                     UNION 
                     SELECT DeptGroupId 
                     FROM DimUserDeptGroup_Mod  ) A;

         END;
         END IF;
      END IF;
      IF v_DeptGroupId IS NULL THEN

      BEGIN
         v_DeptGroupId := 1 ;

      END;
      END IF;
      DBMS_OUTPUT.PUT_LINE('sb');
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                                   AND DeptGroupCode = v_DeptGroupName
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                         UNION 
                         SELECT 1 
                         FROM RBL_MISDB_PROD.DimUserDeptGroup 
                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                                   AND DeptGroupCode = v_DeptGroupName
                                   AND NVL(AuthorisationStatus, 'A') = 'A' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('@-6');
         v_D2Ktimestamp := 2 ;
         v_Result := -6 ;
         RETURN -6;

      END;
      END IF;

   END;
   END IF;
   IF v_OperationFlag = 1
     AND v_AuthMode = 'Y' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('@CreateModifyApprovedBy');
      DBMS_OUTPUT.PUT_LINE(v_CreateModifyApprovedBy);
      v_CreatedBy := v_CreateModifyApprovedBy ;
      v_DateCreated := SYSDATE ;
      v_AuthorisationStatus := 'NP' ;
      GOTO AdvValuerAddressDetails_Insert;
      <<AdvValuerAddressDetails_Insert_Add>>

   END;
   ELSE
      IF ( v_OperationFlag = 2
        OR v_OperationFlag = 3 )
        AND v_AuthMode = 'Y' THEN

      BEGIN
         v_Modifiedby := v_CreateModifyApprovedBy ;
         v_DateModified := SYSDATE ;
         IF v_AuthMode = 'Y' THEN

         BEGIN
            IF v_OperationFlag = 2 THEN

            BEGIN
               v_AuthorisationStatus := 'MP' ;

            END;
            ELSE

            BEGIN
               v_AuthorisationStatus := 'DP' ;

            END;
            END IF;
            ---FIND CREATEDBY from MAIN 
            SELECT CreatedBy ,
                   DateCreated 

              INTO v_CreatedBy,
                   v_DateCreated
              FROM RBL_MISDB_PROD.DimUserDeptGroup 
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey )
                      AND DeptGroupId = v_DeptGroupId;
            ---FIND CREATED BY FROM MOD TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
            IF NVL(v_CreatedBy, ' ') = ' ' THEN

            BEGIN
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND DeptGroupId = v_DeptGroupId
                         AND AuthorisationStatus IN ( 'NP','MP','A' )
               ;

            END;
            ELSE

             ---IF DATA IS AVAILABLE IN MAIN TABLE
            BEGIN
               ----UPDATE FLAG IN MAIN TABLES AS MP										
               UPDATE RBL_MISDB_PROD.DimUserDeptGroup
                  SET AuthorisationStatus = v_AuthorisationStatus
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND DeptGroupId = v_DeptGroupId;

            END;
            END IF;
            --UPDATE NP,MP  STATUS 
            IF v_OperationFlag = 2 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('update mod by FM');
               UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifiedBy = v_Modifiedby,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND DeptGroupId = v_DeptGroupId
                 AND AuthorisationStatus IN ( 'NP','MP','RM' )
               ;

            END;
            END IF;
            GOTO AdvValuerAddressDetails_Insert;
            <<AdvValuerAddressDetails_Insert_Edit_Delete>>

         END;
         END IF;

      END;
      ELSE
         IF v_OperationFlag = 3
           AND v_AuthMode = 'N' THEN

          -- DELETE WITHOUT MAKER CHECKER	
         BEGIN
            v_Modifiedby := v_CreateModifyApprovedBy ;
            v_DateModified := SYSDATE ;
            UPDATE RBL_MISDB_PROD.DimUserDeptGroup
               SET ModifiedBy = v_Modifiedby,
                   DateModified = v_DateModified,
                   EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
             WHERE  ( EffectiveFromTimeKey <= v_EffectiveFromTimeKey
              AND EffectiveToTimeKey >= v_TimeKey )
              AND DeptGroupId = v_DeptGroupId;

         END;
         ELSE
            IF v_OperationFlag = 21
              AND v_AuthMode = 'Y' THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               v_ApprovedBy := v_CreateModifyApprovedBy ;
               v_DateApproved := SYSDATE ;
               UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_ApprovedBy,
                      DateApproved = v_DateApproved,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND DeptGroupId = v_DeptGroupId
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
               ;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND DeptGroupId = v_DeptGroupId );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE DimUserDeptGroup
                     SET AuthorisationStatus = 'A'
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND DeptGroupId = v_DeptGroupId
                    AND AuthorisationStatus IN ( 'MP','DP','RM' )
                  ;

               END;
               END IF;

            END;
            ELSE
               IF v_OperationFlag = 17
                 AND v_AuthMode = 'Y' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  v_ApprovedBy := v_CreateModifyApprovedBy ;
                  v_DateApproved := SYSDATE ;
                  UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND DeptGroupId = v_DeptGroupId
                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                  ;
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND DeptGroupId = v_DeptGroupId );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     UPDATE DimUserDeptGroup
                        SET AuthorisationStatus = 'A'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND DeptGroupId = v_DeptGroupId
                       AND AuthorisationStatus IN ( 'MP','DP','RM' )
                     ;

                  END;
                  END IF;

               END;
               ELSE
                  IF v_OperationFlag = 18
                    AND v_AuthMode = 'Y' THEN

                  BEGIN
                     v_ApprovedBy := v_CreateModifyApprovedBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimUserDeptGroup_Mod
                        SET AuthorisationStatus = 'RM'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                       AND DeptGroupId = v_DeptGroupId;

                  END;

                  --------NEW ADD------------------
                  ELSE
                     IF v_OperationFlag = 16 THEN

                     BEGIN
                        v_ApprovedBy := v_CreateModifyApprovedBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimUserDeptGroup_Mod
                           SET AuthorisationStatus = '1A',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved
                         WHERE  DeptGroupId = v_DeptGroupId
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;

                     END;

                     ------------------------------
                     ELSE
                        IF v_OperationFlag = 20
                          OR v_AuthMode = 'N' THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE('a1');
                           IF v_AuthMode = 'N' THEN

                            ---- set parameter for  maker checker disabled
                           BEGIN
                              IF v_OperationFlag = 1 THEN

                              BEGIN
                                 v_CreatedBy := v_CreateModifyApprovedBy ;
                                 v_DateCreated := SYSDATE ;

                              END;
                              ELSE

                              BEGIN
                                 v_Modifiedby := v_CreateModifyApprovedBy ;
                                 v_DateModified := SYSDATE ;
                                 SELECT CreatedBy ,
                                        DATECreated 

                                   INTO v_CreatedBy,
                                        v_DateCreated
                                   FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey )
                                           AND DeptGroupId = v_DeptGroupId;
                                 v_ApprovedBy := v_CreateModifyApprovedBy ;
                                 v_DateApproved := SYSDATE ;

                              END;
                              END IF;

                           END;
                           END IF;
                           ---set parameters and update mod table in case maker checker enabled
                           IF v_AuthMode = 'Y' THEN
                            DECLARE
                              v_DelStatus CHAR(2);
                              v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                              v_CurEntityKey NUMBER(10,0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('a2');
                              SELECT MAX(EntityKey)  

                                INTO v_ExEntityKey
                                FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND DeptGroupId = v_DeptGroupId
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
                                     v_Modifiedby,
                                     v_DateModified
                                FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              DBMS_OUTPUT.PUT_LINE(v_ExEntityKey);
                              DBMS_OUTPUT.PUT_LINE(v_DateModified);
                              v_ApprovedBy := v_CreateModifyApprovedBy ;
                              v_DateApproved := SYSDATE ;
                              SELECT MIN(EntityKey)  

                                INTO v_ExEntityKey
                                FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND DeptGroupId = v_DeptGroupId
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT EffectiveFromTimeKey 

                                INTO v_CurrRecordFromTimeKey
                                FROM DimUserDeptGroup_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              --FOR CHILD SCREEN
                              UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                                 SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND DeptGroupId = v_DeptGroupId
                                AND AuthorisationStatus = 'A';
                              IF v_DelStatus = 'DP' THEN
                               DECLARE
                                 v_temp NUMBER(1, 0) := 0;

                               --- DELETE RECORD AUTHORISE
                              BEGIN
                                 UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved,
                                        EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                  WHERE  DeptGroupId = v_DeptGroupId
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                 ;
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND DeptGroupId = v_DeptGroupId );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    UPDATE RBL_MISDB_PROD.DimUserDeptGroup
                                       SET AuthorisationStatus = 'A',
                                           ModifiedBy = v_Modifiedby,
                                           DateModified = v_DateModified,
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved,
                                           EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND DeptGroupId = v_DeptGroupId;

                                 END;
                                 END IF;

                              END;
                               -- END @DelStatus='DP'
                              ELSE

                               -- OTHER THAN DELETE STATUS
                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('SAC1');
                                 UPDATE RBL_MISDB_PROD.DimUserDeptGroup_Mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  DeptGroupId = v_DeptGroupId
                                   AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                 ;

                              END;
                              END IF;

                           END;
                           END IF;
                           DBMS_OUTPUT.PUT_LINE('@DelStatus');
                           DBMS_OUTPUT.PUT_LINE(v_DelStatus);
                           IF v_DelStatus <> 'DP'
                             OR v_AuthMode = 'N' THEN
                            DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE(v_AuthMode);
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND DeptGroupId = v_DeptGroupId );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN
                               DECLARE
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('a6');
                                 v_IsAvailable := 'Y' ;
                                 v_AuthorisationStatus := 'A' ;
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM RBL_MISDB_PROD.DimUserDeptGroup 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                                              AND DeptGroupId = v_DeptGroupId );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('a7');
                                    UPDATE RBL_MISDB_PROD.DimUserDeptGroup
                                       SET DeptGroupId = v_DeptGroupId,
                                           DeptGroupCode = v_DeptGroupName,
                                           DeptGroupName = v_DeptGroupDesc,
                                           Menus = v_MenuId,
                                           IsUniversal = v_IsUniversal
                                           --,AssignedReturns=@AssignedReturns
                                            --,AssignedSLBC=@AssignedSLBC
                                           ,
                                           ModifiedBy = v_Modifiedby,
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
                                     WHERE  DeptGroupId = v_DeptGroupId
                                      AND ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey;

                                 END;
                                 ELSE

                                 BEGIN
                                    v_IsSCD2 := 'Y' ;
                                    DBMS_OUTPUT.PUT_LINE('set @IsSCD2=Y');

                                 END;
                                 END IF;

                              END;
                              END IF;
                              IF v_IsAvailable = 'N'
                                OR v_IsSCD2 = 'Y' THEN

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('@IsAvailable');
                                 DBMS_OUTPUT.PUT_LINE(v_IsAvailable);
                                 INSERT INTO DimUserDeptGroup
                                   ( DeptGroupId, DeptGroupCode, DeptGroupName, Menus, IsUniversal, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                   ( 
                                     --,AssignedReturns	

                                     --,AssignedSLBC											
                                     SELECT v_DeptGroupId ,
                                            v_DeptGroupName ,
                                            v_DeptGroupDesc ,
                                            v_MenuId ,
                                            v_IsUniversal ,
                                            v_EffectiveFromTimeKey ,
                                            v_EffectiveToTimeKey ,
                                            v_CreatedBy ,--,CASE WHEN @IsAvailable='N' THEN CreatedBy ELSE @CreateModifyApprovedBy END	

                                            v_DateCreated ,--,CASE WHEN @IsAvailable='N' THEN DateCreated ELSE  @DateCreatedModifiedApproved END													

                                            CASE 
                                                 WHEN v_IsAvailable = 'Y' THEN v_Modifiedby
                                            ELSE NULL
                                               END col  ,
                                            CASE 
                                                 WHEN v_IsAvailable = 'Y' THEN v_DateModified
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
                                       FROM DUAL  );
                                 --,@AssignedReturns
                                 --,@AssignedSLBC
                                 --------- update in sysCrismacMenu		
                                 --IF (@EffectiveFromTimeKey =(SELECT EffectiveFromTimeKey                                   
                                 --		    FROM DimUserDeptGroup                                
                                 --	    WHERE (EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey) and DeptGroupCode=@DeptGroupName ) )       											      
                                 --BEGIN        
                                 DBMS_OUTPUT.PUT_LINE('same timekey');
                                 --SQL Server BEGIN TRANSACTION;
                                 utils.incrementTrancount;
                                 --Update DimUserDeptGroup Set DeptGroupName=@DeptGroupDesc,DateModified=GETDATE(),ModifiedBy=@CreatedBy,Menus=@MenuId where (EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey) and DeptGroupCode=@DeptGroupName        
                                 --Update SysCRisMacMenu Set Department=@MenuDept where MenuTitleId in (@Menus)        										         
                                 UPDATE SysCRisMacMenu
                                    SET DeptGroupCode = REPLACE(DeptGroupCode, v_DeptGroupName || ',', ' ')
                                  WHERE  DeptGroupCode LIKE '%' || v_DeptGroupName || '%';
                                 UPDATE SysCRisMacMenu
                                    SET DeptGroupCode = REPLACE(DeptGroupCode, ',' || v_DeptGroupName, ' ')
                                  WHERE  DeptGroupCode LIKE '%' || v_DeptGroupName || '%';
                                 UPDATE SysCRisMacMenu
                                    SET DeptGroupCode = REPLACE(DeptGroupCode, v_DeptGroupName || ',', ' ')
                                  WHERE  DeptGroupCode LIKE '%' || v_DeptGroupName || '%';
                                 UPDATE SysCRisMacMenu
                                    SET DeptGroupCode = REPLACE(DeptGroupCode, v_DeptGroupName, ' ')
                                  WHERE  DeptGroupCode LIKE '%' || v_DeptGroupName || '%';
                                 BEGIN
                                    UPDATE SysCRisMacMenu
                                       SET DeptGroupCode = CASE NVL(DeptGroupCode, ' ')
                                                                                       WHEN ' ' THEN v_DeptGroupName
                                           ELSE DeptGroupCode || ',' || v_DeptGroupName
                                              END
                                     WHERE  MenuId IN ( SELECT Items 
                                                        FROM TABLE(SPLIT(v_MenuId, ','))  )
                                 ;
                                 EXCEPTION WHEN OTHERS THEN
                                       v_sys_error := SQLCODE;
                                 END;
                                 IF v_sys_error <> 0 THEN

                                 BEGIN
                                    ROLLBACK;
                                    utils.resetTrancount;
                                    v_Result := -1 ;
                                    RETURN -1;

                                 END;
                                 END IF;
                                 v_sys_error := 0;
                                 utils.commit_transaction;
                                 --SET @Result  = 1  
                                 --SET @D2Ktimestamp =                   
                                 --RETURN 1         
                                 --END        
                                 --ELSE         
                                 --			  BEGIN        
                                 --			     print 'different time key'        
                                 --			  BEGIN TRANSACTION          
                                 --			  Update DimUserDeptGroup Set  EffectiveToTimeKey = @EffectiveFromTimeKey - 1,         
                                 --			    ModifiedBy=@CreatedBy,        
                                 --			    DateModified=GETDATE()        
                                 --			    WHERE EffectiveToTimeKey =@EffectiveToTimeKey and DeptGroupCode=@DeptGroupName        
                                 --			 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode,  @DeptGroupName+ ',','')        
                                 --			  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
                                 --			 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode, ',' + @DeptGroupName,'')        
                                 --			  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
                                 --			 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode,  @DeptGroupName+ ',','')        
                                 --			  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
                                 --			 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode, @DeptGroupName,'')        
                                 --			  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
                                 --			   update SysCRisMacMenu set DeptGroupCode= case ISNULL(DeptGroupCode,'') when '' then  @DeptGroupName        
                                 --			                                       ELSE DeptGroupCode+','+  @DeptGroupName END        
                                 --			               where MenuId IN (Select Items from dbo.split(@MenuId,','))     
                                 --			  IF @@ERROR <> 0                 
                                 --			 BEGIN                
                                 --			  ROLLBACK TRANSACTION   
                                 --				set @Result      =-1                
                                 --			  RETURN -1                
                                 --			 END                
                                 --			 COMMIT TRANSACTION        
                                 --			 set @Result      =1    
                                 --			  RETURN 1         
                                 --			end     		
                                 ---------
                                 DBMS_OUTPUT.PUT_LINE('@CreateModifyApprovedBy');
                                 DBMS_OUTPUT.PUT_LINE(v_CreateModifyApprovedBy);

                              END;
                              END IF;
                              IF v_IsSCD2 = 'Y' THEN

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE(777);
                                 UPDATE RBL_MISDB_PROD.DimUserDeptGroup
                                    SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                        AuthorisationStatus = CASE 
                                                                   WHEN v_AUTHMODE = 'Y' THEN 'A'
                                        ELSE NULL
                                           END
                                  WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND DeptGroupId = v_DeptGroupId
                                   AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                              END;
                              END IF;

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
   --***********maintain log table
   --IF @OperationFlag IN(1,2,3,16,17,18) AND @AuthMode ='Y'
   --	BEGIN
   --			IF @OperationFlag=2 
   --				BEGIN 
   --					SET @CreatedBy=@Modifiedby
   --				END
   --			IF @OperationFlag IN(16,17) 
   --				BEGIN 
   --					SET @DateCreated= GETDATE()
   --				END
   --			EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
   --					0,
   --				@MenuID,
   --				@UserLoginID,-- ReferenceID ,
   --				@CreatedBy,
   --				@ApprovedBy,-- @ApproveBy 
   --				@DateCreated,
   --				@Remark,
   --				@MenuID, -- for FXT060 screen
   --				@OperationFlag,
   --				@AuthMode 	
   --	END
   v_ErrorHandle := 1 ;
   <<AdvValuerAddressDetails_Insert>>
   IF v_ErrorHandle = 0 THEN

   BEGIN
      /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
      INSERT INTO RBL_MISDB_PROD.DimUserDeptGroup_Mod
        ( DeptGroupId, DeptGroupCode, DeptGroupName, Menus, IsUniversal, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, AuthorisationStatus )
        ( SELECT v_DeptGroupId ,
                 v_DeptGroupName ,
                 v_DeptGroupDesc ,
                 v_MenuId ,
                 v_IsUniversal ,
                 v_EffectiveFromTimeKey ,
                 v_EffectiveToTimeKey ,
                 v_CreateModifyApprovedBy ,
                 UTILS.CONVERT_TO_VARCHAR2(v_DateCreatedModifiedApproved,200) ,
                 v_Modifiedby ,--CASE WHEN @IsAvailable='N' THEN @CreateModifyApprovedBy ELSE NULL END

                 UTILS.CONVERT_TO_VARCHAR2(v_DateModified ,--CASE WHEN @IsAvailable='N' THEN @DateCreatedModifiedApproved ELSE NULL END													
200) ,
                 v_ApprovedBy ,--CASE WHEN @IsAvailable='N' THEN NULL ELSE @CreateModifyApprovedBy END

                 UTILS.CONVERT_TO_VARCHAR2(v_DateApproved ,--CASE WHEN @IsAvailable='N' THEN NULL ELSE @DateCreatedModifiedApproved END													
200) ,
                 v_AuthorisationStatus 
            FROM DUAL  );
      --print 'Inserted'									
      IF v_OperationFlag = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE(3);
         GOTO AdvValuerAddressDetails_Insert_Add;

      END;
      ELSE
         IF v_OperationFlag = 2
           OR v_OperationFlag = 3 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(99);
            GOTO AdvValuerAddressDetails_Insert_Edit_Delete;

         END;
         END IF;
      END IF;

   END;
   END IF;
   SELECT UTILS.CONVERT_TO_NUMBER(D2Ktimestamp,10,0) 

     INTO v_D2Ktimestamp
     FROM ( SELECT D2Ktimestamp 
            FROM DimUserDeptGroup 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DeptGroupId = v_DeptGroupId
                      AND NVL(AuthorisationStatus, 'A') = 'A' 
              FETCH FIRST 1 ROWS ONLY
            UNION 
            SELECT D2Ktimestamp 
            FROM DimUserDeptGroup_Mod 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DeptGroupId = v_DeptGroupId
                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

              FETCH FIRST 1 ROWS ONLY ) timestamp1;
   v_D2Ktimestamp := NVL(v_D2Ktimestamp, 1) ;
   v_Result := NVL(v_Result, 1) ;
   DBMS_OUTPUT.PUT_LINE(v_D2Ktimestamp);
   IF v_OperationFlag = 1 THEN

   BEGIN
      SELECT UTILS.CONVERT_TO_NUMBER(D2Ktimestamp,10,0) 

        INTO v_D2Ktimestamp
        FROM ( SELECT D2Ktimestamp 
               FROM DimUserDeptGroup 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DeptGroupCode = v_DeptGroupName
                         AND NVL(AuthorisationStatus, 'A') = 'A' 
                 FETCH FIRST 1 ROWS ONLY
               UNION 
               SELECT D2Ktimestamp 
               FROM DimUserDeptGroup_Mod 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DeptGroupCode = v_DeptGroupName
                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                 FETCH FIRST 1 ROWS ONLY ) timestamp1;
      DBMS_OUTPUT.PUT_LINE('timestamp');
      DBMS_OUTPUT.PUT_LINE(v_D2Ktimestamp);
      v_Result := v_DeptGroupId ;
      RETURN v_Result;
      RETURN v_D2Ktimestamp;

   END;
   ELSE
      IF v_OperationFlag = 3 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('aaaaaaaa');
         v_Result := 0 ;
         IF ( v_AuthMode = 'N' ) THEN
          SELECT ( SELECT D2Ktimestamp 
                   FROM DimUserDeptGroup 
                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                             AND DeptGroupCode = v_DeptGroupName
                             AND NVL(AuthorisationStatus, 'A') = 'A' 
                     FETCH FIRST 1 ROWS ONLY ) 

           INTO v_D2Ktimestamp
           FROM DUAL ;
         END IF;
         RETURN v_D2Ktimestamp;
         RETURN v_Result;

      END;
      ELSE

      BEGIN
         v_Result := v_DeptGroupId ;
         DBMS_OUTPUT.PUT_LINE('@Result');
         DBMS_OUTPUT.PUT_LINE(v_Result);
         RETURN v_Result;
         RETURN v_D2Ktimestamp;--Completion time: 2023-01-24T12:03:13.7487601+05:30

      END;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPINSERTUPDATE_24012023" TO "ADF_CDR_RBL_STGDB";
