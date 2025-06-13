--------------------------------------------------------
--  DDL for Procedure USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" 
-- UserCreationParameterisedMasterData_New 'pwomaker',3652,'Y'
 --exec UserCreationParameterisedMasterData_New @UserLoginID=N'pwomake',@TimeKey=0,@UserCreationModification=N'Y'

(
  v_UserLoginID IN VARCHAR2,
  v_TimeKey IN NUMBER,
  v_UserCreationModification IN CHAR,
  v_DeptCode IN VARCHAR2
)
AS
   --DECLARE @UserLoginID varchar(20)='fnasuperadmin',  
   --@TimeKey INT=24957,  
   --@UserCreationModification AS CHAR(1) ='Y'
   --,@DeptCode VARCHAR(100)='cbo'
   v_Code VARCHAR2(20);
   v_Tier NUMBER(10,0);
   v_UserLocation VARCHAR2(50);
   v_UserRole_Key NUMBER(5,0);
   v_DepartmentAlt_Key NUMBER(10,0);
   v_DepartmentCode VARCHAR2(4000);
   v_cursor SYS_REFCURSOR;
   v_DEPTALTKEY NUMBER(10,0);

BEGIN

   -- SELECT @Timekey=Max(Timekey) from SysProcessingCycle
   --WHERE Extracted='Y' and ProcessType='Full' --and PreMOC_CycleFrozenDate IS NULL
   DBMS_OUTPUT.PUT_LINE('TimeKey');
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   SELECT Tier 

     INTO v_Tier
     FROM SysReportformat ;
   ----VIEW ALL USER ROLES TO ONLY FNA CHANGED BY DIPTI
   IF NVL(v_DeptCode, ' ') = ' ' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('FNA USER');
      SELECT UserRoleAlt_Key 

        INTO v_UserRole_Key
        FROM DimUserInfo 
       WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                AND UserLoginID = v_UserLoginID;

   END;
   ELSE

   BEGIN
      DBMS_OUTPUT.PUT_LINE('OTHERS ');
      --SET @UserRole_Key=(SELECT  MIN(UserRoleAlt_Key)  FROM DimUserInfo A
      --											INNER JOIN DIMDEPARTMENT B ON A.DepartmentId=B.DepartmentAlt_Key
      --																		AND(A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimekey>=@TimeKey)  
      --																		AND (B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimekey>=@TimeKey)
      --											WHERE   B.DepartmentCode =@DeptCode)
      SELECT MIN(UserRoleAlt_Key)  

        INTO v_UserRole_Key
        FROM DimUserInfo A
               JOIN DimUserDeptGroup B   ON A.DeptGroupCode = B.DeptGroupId
               AND ( A.EffectiveFromTimekey <= v_TimeKey
               AND A.EffectiveToTimekey >= v_TimeKey )
               AND ( B.EffectiveFromTimekey <= v_TimeKey
               AND B.EffectiveToTimekey >= v_TimeKey )
       WHERE  A.UserLoginID = v_UserLoginID;

   END;
   END IF;
   SELECT CASE 
               WHEN NVL(UserLocation, ' ') = ' ' THEN 'HO'
          ELSE NVL(UserLocation, ' ')
             END col  

     INTO v_UserLocation
     FROM DimUserInfo 
    WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
             AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   SELECT CASE 
               WHEN NVL(UserLocation, ' ') = ' ' THEN 'HO'
          ELSE NVL(UserLocation, ' ')
             END col  

     INTO v_Code
     FROM DimUserInfo 
    WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
             AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   DBMS_OUTPUT.PUT_LINE(v_UserRole_Key);
   DBMS_OUTPUT.PUT_LINE(v_UserLocation);
   DBMS_OUTPUT.PUT_LINE(v_Code);
   DBMS_OUTPUT.PUT_LINE(v_tier);
   SELECT DEP.DeptGroupCode ,
          DEP.DeptGroupId 

     INTO v_DepartmentCode,
          v_DepartmentAlt_Key
     FROM DimUserInfo INFO
            JOIN DimUserDeptGroup DEP   ON INFO.EffectiveFromTimeKey <= v_Timekey
            AND INFO.EffectiveToTimeKey >= v_Timekey
            AND DEP.EffectiveFromTimeKey <= v_Timekey
            AND DEP.EffectiveToTimeKey >= v_Timekey
            AND UserLoginID = v_UserLoginId
            AND INFO.DeptGroupCode = DEP.DeptGroupId;
   DBMS_OUTPUT.PUT_LINE('@DepartmentAlt_Key' || UTILS.CONVERT_TO_VARCHAR2(v_DepartmentAlt_Key,20));
   -------  
   IF ( v_Tier = '4' ) THEN

   BEGIN
      IF v_UserLocation = 'HO' THEN
       OPEN  v_cursor FOR
         SELECT UserLocationAlt_Key ,
                LocationShortName ,
                LocationName LocationDescription  
           FROM dimuserlocation 
          WHERE  UserLocationAlt_Key IN ( 1 --,3,4 --ii ,4
                  )

           ORDER BY 2 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ELSE
         IF v_UserLocation = 'ZO' THEN
          OPEN  v_cursor FOR
            SELECT UserLocationAlt_Key ,
                   LocationShortName ,
                   LocationName LocationDescription  
              FROM dimuserlocation 
             WHERE  UserLocationAlt_Key IN ( 2,3 --ii ,4 
                     )

              ORDER BY 2 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         ELSE
            IF v_UserLocation = 'RO' THEN
             OPEN  v_cursor FOR
               SELECT UserLocationAlt_Key ,
                      LocationShortName ,
                      LocationName LocationDescription  
                 FROM dimuserlocation 
                WHERE  UserLocationAlt_Key IN ( 3,4 --ii ,4
                        )

                 ORDER BY 2 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            ELSE
               IF v_UserLocation = 'BO' THEN
                OPEN  v_cursor FOR
                  SELECT UserLocationAlt_Key ,
                         LocationShortName ,
                         LocationName LocationDescription  
                    FROM dimuserlocation 
                   WHERE  EffectiveFromTimekey <= v_TimeKey
                            AND EffectiveToTimekey >= v_TimeKey
                            AND UserLocationAlt_Key IN ( 4 )

                    ORDER BY 2 ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               END IF;
            END IF;
         END IF;
      END IF;

   END;
   ELSE
      IF ( v_Tier = '3' ) THEN

      BEGIN
         IF v_UserLocation = 'HO' THEN
          OPEN  v_cursor FOR
            SELECT UserLocationAlt_Key ,
                   LocationShortName ,
                   LocationName LocationDescription  
              FROM dimuserlocation 
             WHERE  UserLocationAlt_Key IN ( 1,3,4 --ii ,4
                     )

              ORDER BY 2 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         ELSE
            IF v_UserLocation = 'RO' THEN
             OPEN  v_cursor FOR
               SELECT UserLocationAlt_Key ,
                      LocationShortName ,
                      LocationName LocationDescription  
                 FROM dimuserlocation 
                WHERE  UserLocationAlt_Key IN ( 3,4 --ii ,4
                        )

                 ORDER BY 2 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            ELSE
               IF v_UserLocation = 'BO' THEN
                OPEN  v_cursor FOR
                  SELECT UserLocationAlt_Key ,
                         LocationShortName ,
                         LocationName LocationDescription  
                    FROM dimuserlocation 
                   WHERE  EffectiveFromTimekey <= v_TimeKey
                            AND EffectiveToTimekey >= v_TimeKey
                            AND UserLocationAlt_Key IN ( 4 )

                    ORDER BY 2 ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               END IF;
            END IF;
         END IF;

      END;
      ELSE
         IF ( v_Tier = '2' ) THEN

         BEGIN
            IF v_UserLocation = 'HO' THEN
             OPEN  v_cursor FOR
               SELECT UserLocationAlt_Key ,
                      LocationShortName ,
                      LocationName LocationDescription  
                 FROM dimuserlocation 
                WHERE  UserLocationAlt_Key IN ( 1 --ii ,4 
                        )

                 ORDER BY 2 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            ELSE
               IF v_UserLocation = 'BO' THEN
                OPEN  v_cursor FOR
                  SELECT UserLocationAlt_Key ,
                         LocationShortName ,
                         LocationName LocationDescription  
                    FROM dimuserlocation 
                    ORDER BY 
                             --ii Where UserLocationAlt_Key IN(4)  
                             2 ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               END IF;
            END IF;

         END;
         END IF;
      END IF;
   END IF;
   --  
   IF v_UserLocation = 'ZO' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT Branch_Key ,
                BranchCode ,
                BranchName ,
                DimBranch.BranchZoneAlt_Key 
           FROM DimBranch 
          WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                   AND DimBranch.EffectiveToTimeKey >= v_TimeKey )

                   --AND BranchType ='ZO'  
                   AND DimBranch.BranchRegionAlt_Key = v_Code
                   AND NVL(DimBranch.AllowLogin, 'N') = 'Y'
           ORDER BY DimBranch.BranchName ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      OPEN  v_cursor FOR
         SELECT RegionAlt_Key ,
                RegionName 
           FROM DimBranch 
                  JOIN DimRegion    ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key
          WHERE  ( DimRegion.EffectiveFromTimeKey <= v_TimeKey
                   AND DimRegion.EffectiveToTimeKey >= v_TimeKey )
                   AND RegionAlt_Key = v_Code
           ORDER BY RegionName ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      OPEN  v_cursor FOR
         SELECT ZoneAlt_Key ,
                DimZone.ZoneName 
           FROM DimBranch 
                  JOIN DimZone    ON DimBranch.BranchZoneAlt_Key = DimZone.ZoneAlt_Key
          WHERE  ( DimZone.EffectiveFromTimeKey <= v_TimeKey
                   AND DimZone.EffectiveToTimeKey >= v_TimeKey )
                   AND ZoneAlt_Key = v_Code
           ORDER BY DimZone.ZoneName ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      OPEN  v_cursor FOR
         SELECT ZoneName BranchName  ,
                'ZO' BranchType  
           FROM DimZone 
          WHERE  ZoneAlt_Key = v_Code
                   AND DimZone.EffectiveFromTimeKey <= v_TimeKey
                   AND DimZone.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      IF v_UserRole_Key = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserRoleAlt_Key ,
                   RoleDescription 
              FROM DimUserRole 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
              ORDER BY 2 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         IF v_UserRole_Key = 2 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT UserRoleAlt_Key ,
                      RoleDescription 
                 FROM DimUserRole 
                WHERE  UserRoleAlt_Key IN ( 2,3,4 )

                 ORDER BY 2 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF v_UserRole_Key = 3 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT UserRoleAlt_Key ,
                         RoleDescription 
                    FROM DimUserRole 
                   WHERE  UserRoleAlt_Key IN ( 3,4 )

                    ORDER BY 2 ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE
               IF v_UserRole_Key = 4 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT UserRoleAlt_Key ,
                            RoleDescription 
                       FROM DimUserRole 
                      WHERE  UserRoleAlt_Key IN ( 4 )

                       ORDER BY 2 ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
            END IF;
         END IF;
      END IF;

   END;

   -- why we need a seperate condition for RI  

   --ELSE IF  @UserLocation = 'RI'  

   -- BEGIN  

   --    SELECT DISTINCT BranchCode AS RegionAlt_Key, BranchName AS RegionName, 2 AS CODE   

   --     FROM DimBranch   

   --     WHERE BranchType='RI'  

   --   END  
   ELSE
      IF v_UserLocation = 'RO'
        OR v_UserLocation = 'RI' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT Branch_Key ,
                   BranchCode LocationCode  ,
                   BranchName LocationName  ,
                   DimBranch.BranchRegionAlt_Key BranchZoneAlt_Key  
              FROM DimBranch 
             WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                      AND DimBranch.EffectiveToTimeKey >= v_TimeKey )

                      -- and   BranchType  IN ('RI','RO') and  
                      AND DimBranch.BranchRegionAlt_Key = v_Code

                      --AND BranchType NOT IN ('HO','HI','RI','RO')  
                      AND ( NVL(DimBranch.AllowLogin, 'N') = 'Y'
                      OR NVL(DimBranch.AllowMakerChecker, 'N') = 'Y' )
              ORDER BY DimBranch.BranchName ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT RegionAlt_Key ,
                   RegionName 
              FROM ( SELECT RegionAlt_Key ,
                            RegionName ,
                            1 CODE --'RO - '+RegionName AS RegionName

                     FROM DimBranch 
                            JOIN DimRegion    ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key
                      WHERE  ( DimRegion.EffectiveFromTimeKey <= v_TimeKey
                               AND DimRegion.EffectiveToTimeKey >= v_TimeKey )
                               AND RegionAlt_Key = v_Code
                     UNION 
                     SELECT BranchCode RegionAlt_Key  ,
                            BranchName RegionName  ,
                            2 CODE  
                     FROM DimBranch 
                      WHERE  BranchType = 'RI' ) DimBranch
              ORDER BY CODE ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT ' ' ZoneAlt_Key  ,
                   ' ' ZoneName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT RegionName BranchName  ,
                   'RO' BranchType  
              FROM DimRegion 
             WHERE  RegionAlt_Key = v_Code
                      AND DimRegion.EffectiveFromTimeKey <= v_TimeKey
                      AND DimRegion.EffectiveToTimeKey >= v_TimeKey
              ORDER BY 2 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         IF v_UserRole_Key = 1 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT UserRoleAlt_Key ,
                      RoleDescription 
                 FROM DimUserRole  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF v_UserRole_Key = 2 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT UserRoleAlt_Key ,
                         RoleDescription 
                    FROM DimUserRole 
                   WHERE  UserRoleAlt_Key IN ( 2,3,4 )
                ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE
               IF v_UserRole_Key = 3 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT UserRoleAlt_Key ,
                            RoleDescription 
                       FROM DimUserRole 
                      WHERE  UserRoleAlt_Key IN ( 3,4 )
                   ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF v_UserRole_Key = 4 THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT UserRoleAlt_Key ,
                               RoleDescription 
                          FROM DimUserRole 
                         WHERE  UserRoleAlt_Key IN ( 4 )
                      ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;
               END IF;
            END IF;
         END IF;

      END;
      ELSE
         IF v_UserLocation = 'BO' THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Branch_Key ,
                      BranchCode ,
                      BranchName ,
                      BranchZoneAlt_Key 
                 FROM DimBranch 
                WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                         AND DimBranch.EffectiveToTimeKey >= v_TimeKey )

                         --AND  BranchType NOT IN ('HO','HI','RI','RO')   

                         -- AND  BranchType='BO'   
                         AND BranchCode = v_Code
                 ORDER BY BranchName ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT ' ' RegionAlt_Key  ,
                      ' ' RegionName  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT ' ' ZoneAlt_Key  ,
                      ' ' ZoneName  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT BranchName ,
                      'BO' BranchType  
                 FROM DimBranch 
                WHERE  BranchCode = v_Code
                         AND DimBranch.EffectiveFromTimeKey <= v_TimeKey
                         AND DimBranch.EffectiveToTimeKey >= v_TimeKey ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            IF v_UserRole_Key = 1 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT UserRoleAlt_Key ,
                         RoleDescription 
                    FROM DimUserRole  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE
               IF v_UserRole_Key = 2 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT UserRoleAlt_Key ,
                            RoleDescription 
                       FROM DimUserRole 
                      WHERE  UserRoleAlt_Key IN ( 2,3,4 )
                   ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF v_UserRole_Key = 3 THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT UserRoleAlt_Key ,
                               RoleDescription 
                          FROM DimUserRole 
                         WHERE  UserRoleAlt_Key IN ( 3,4 )
                      ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  ELSE
                     IF v_UserRole_Key = 4 THEN

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT UserRoleAlt_Key ,
                                  RoleDescription 
                             FROM DimUserRole 
                            WHERE  UserRoleAlt_Key IN ( 4 )
                         ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     END IF;
                  END IF;
               END IF;
            END IF;

         END;
         ELSE
            IF v_UserLocation = 'HO' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('t');
               OPEN  v_cursor FOR
                  SELECT Branch_Key ,
                         BranchCode LocationCode  ,
                         BranchName LocationName  ,
                         BranchZoneAlt_Key 
                    FROM DimBranch 
                   WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                            AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                            AND NVL(BranchType, 'ZO') NOT IN ( 'HO','HI','RI','RO' )


                            --and BranchType='HO' not worked when user select Branch in UI  
                            AND BranchName IS NOT NULL
                            AND ( NVL(DimBranch.AllowLogin, 'Y') = 'Y'
                            OR NVL(DimBranch.AllowMakerChecker, 'Y') = 'Y' )
                    ORDER BY DimBranch.BranchName ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               OPEN  v_cursor FOR
                  SELECT RegionAlt_Key LocationCode  ,
                         RegionName LocationName  
                    FROM ( SELECT RegionAlt_Key ,
                                  RegionName ,
                                  1 CODE -- 'RO - '+RegionName AS RegionName

                           FROM DimBranch 
                                  JOIN DimRegion    ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key
                            WHERE  ( DimRegion.EffectiveFromTimeKey <= v_TimeKey
                                     AND DimRegion.EffectiveToTimeKey >= v_TimeKey )
                           UNION 
                           SELECT BranchCode RegionAlt_Key  ,
                                  BranchName RegionName  ,
                                  2 CODE  
                           FROM DimBranch 
                            WHERE  BranchType = 'RI' ) DimBranch
                    ORDER BY CODE ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               OPEN  v_cursor FOR
                  SELECT ZoneAlt_Key LocationCode  ,
                         DimZone.ZoneName LocationName  
                    FROM DimBranch 
                           LEFT JOIN DimZone    ON DimBranch.BranchZoneAlt_Key = DimZone.ZoneAlt_Key
                   WHERE  ( DimZone.EffectiveFromTimeKey <= v_TimeKey
                            AND DimZone.EffectiveToTimeKey >= v_TimeKey )
                    ORDER BY ZoneName ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               OPEN  v_cursor FOR
                  SELECT BranchName LocationName  ,
                         BranchType LocationCode  
                    FROM DimBranch 
                   WHERE  NVL(BranchType, 'HO') IN ( 'HO','HI' )
                ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               IF v_UserRole_Key = 1 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT UserRoleAlt_Key ,
                            RoleDescription 
                       FROM DimUserRole  ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF v_UserRole_Key = 2 THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT UserRoleAlt_Key ,
                               RoleDescription 
                          FROM DimUserRole 
                         WHERE  UserRoleAlt_Key IN ( 2,3,4 )
                      ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  ELSE
                     IF v_UserRole_Key = 3 THEN

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT UserRoleAlt_Key ,
                                  RoleDescription 
                             FROM DimUserRole 
                            WHERE  UserRoleAlt_Key IN ( 3,4 )
                         ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     ELSE
                        IF v_UserRole_Key = 4 THEN

                        BEGIN
                           OPEN  v_cursor FOR
                              SELECT UserRoleAlt_Key ,
                                     RoleDescription 
                                FROM DimUserRole 
                               WHERE  UserRoleAlt_Key IN ( 4 )
                            ;
                              DBMS_SQL.RETURN_RESULT(v_cursor);

                        END;
                        END IF;
                     END IF;
                  END IF;
               END IF;

            END;
            END IF;
         END IF;
      END IF;
   END IF;
   --  IF @UserLocation='HO'AND @UserRole_Key=1  
   --BEGIN  
   -- SELECT UserRoleAlt_Key ,UserRoleShortNameEnum as RoleDescription FROM  DimUserRole --Where [RecordStatus]='c'   
   --END   
   --  ELSE   
   --BEGIN  
   -- SELECT UserRoleAlt_Key ,UserRoleShortNameEnum as RoleDescription FROM  DimUserRole   
   --Where  UserRoleAlt_Key IN(2,3,4)  
   --END   
   IF v_UserCreationModification = 'N' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('meta data');
      OPEN  v_cursor FOR
         SELECT * 
           FROM metaUserFieldDetail 
          WHERE  FrmName = 'frmUserCreationNew' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM metaUserFieldDetail 
          WHERE  FrmName = 'frmUserModification' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT * 
        FROM DimUserParameters 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
        ORDER BY SeqNo ;
      DBMS_SQL.RETURN_RESULT(v_cursor);-- EffectiveToTimeKey     =9999  order by SeqNo    
   IF v_UserCreationModification = 'Y' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT 1 Code  ,
                'Change User Location' DESCRIPTION  
           FROM DUAL 
         UNION ALL 
         SELECT 2 Code  ,
                'Activate/Deactivate' DESCRIPTION  
           FROM DUAL 
         UNION ALL 
         SELECT 3 Code  ,
                'Changing Of Role' DESCRIPTION  
           FROM DUAL 
         UNION ALL 
         SELECT 4 Code  ,
                'Change Dept/Group' DESCRIPTION  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --select DeptGroupId, REPLACE(DeptGroupCode,'#','') as DeptGroupCode,DeptGroupName,Menus from DimUserDeptGroup
   --	where EffectiveFromTimeKey    < = @TimeKey     
   --  AND EffectiveToTimeKey  > = @TimeKey
   --Union
   -- Select 0, 'Select','Select','' from DimUserDeptGroup 
   -- Union
   -- Select 1, 'ALL','ALL','' from DimUserDeptGroup 
   UserGroupsAuxSelect(v_TimeKey) ;
   DBMS_OUTPUT.PUT_LINE('UserGroupsAuxSelect ');
   --Select DataSequence
   --			  ,MenuTitleId
   --			  ,MenuId
   --			  ,Isnull(ParentId,0) as ParentId
   --			  ,MenuCaption
   --			  ,BusFld
   --			  ,ThirdGroup
   --			  ,ApplicableFor
   --			  ,Visible
   --			  ,Report
   --			  ,AvailableFor
   --			  ,DeptGroupCode as Department
   --			  ,AuthorisationStatus 
   --				from SysCRisMacMenu 
   --			 where report='N' and Visible=1 AND Menucaption<>'Authorize' 
   --			 AND ((len(ISNULL(ApplicableFor,''))=4 OR ApplicableFor IS NULL)) and MenuCaption not in ('&Operations','Mode of Operation','Add','Edit/Delete','View','E&xit','Exit','Change Branch Selection')
   --			 ORDER BY MENUTITLEID,DATASEQ
   OPEN  v_cursor FOR
      SELECT EntityKey ,
             MenuTitleId ,
             DataSeq ,
             NVL(MenuId, 0) MenuId  ,
             NVL(ParentId, 0) ParentId  ,
             MenuCaption ,
             ActionName ,
             BusFld 
        FROM SysCRisMacMenu 
       WHERE  Visible = 1
        ORDER BY MenuTitleID,
                 DataSeq ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT UserDeletionReasonAlt_Key Code  ,
             UserDeletionReasonName DESCRIPTION  ,
             UserDeletionReason_Key ,
             UserDeletionReasonGroup Group_  ,
             UserDeletionReasonSubGroup SubGroup  ,
             UserDeletionReasonSegment Segment  ,
             UserDeletionReasonShortName ShortName  ,
             UserDeletionReasonShortNameEnum ShortNameEnum  ,
             EffectiveFROMTimeKey ,
             EffectiveToTimeKey 
        FROM DimUserDeletionReason  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterValue 
        FROM SysSolutionParameter 
       WHERE  ParameterName = 'BankEmpIdUIdSame' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT DesignationAlt_Key, DesignationName, DesignationShortName  FROM DimDesignation 
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key DesignationAlt_Key  ,
             ParameterName DesignationName  ,
             'DimUserDesignation' TableName  ,
             ParameterShortName DesignationShortName  
        FROM DimParameter 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey
                AND DimParameterName = 'DimUserDesignation' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT EntityKey,DeptGroupId,REPLACE(DeptGroupCode,'#','') AS DeptGroupName,DeptGroupName AS DeptGroupDesc,Menus,DateCreated,EffectiveFromTimeKey,EffectiveToTimeKey 
   DBMS_OUTPUT.PUT_LINE('@DepartmentCode');
   DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
   OPEN  v_cursor FOR
      SELECT DeptGroupId Code  ,
             DeptGroupCode Description  ,
             'DimUserDeptGroup' TableName  
        FROM DimUserDeptGroup 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND NVL(AuthorisationStatus, 'A') = 'A' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   /*
   	Select DepartmentAlt_Key as Code,DepartmentCode as [Description],'DimDepartment' as TableName from DimDepartment
   	where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

   	AND ISNULL(AuthorisationStatus,'A')='A'
   AND (
   	       CASE 
   		   WHEN LTRIM(RTRIM(@DepartmentCode)) IN ('FNA') THEN 1
   		   WHEN LTRIM(RTRIM(@DepartmentCode)) =DepartmentCode THEN 1
   		   end
   	    )=1
   		ORDER BY 2
   	Declare @ApplicableSolId varchar(max)=''
   	Select @ApplicableSolId=
   	ApplicableBACID
   	from DimDepartment
   	where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   	AND ISNULL(AuthorisationStatus,'A')='A'
   	AND (
   	       CASE 
   		   WHEN @DepartmentCode IN ('FNA') THEN 0
   		   WHEN @DepartmentCode =DepartmentCode THEN 1
   		   end
   	    )=1
   		*/
   IF utils.object_id('TEMPDB..#BranchCode') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BranchCode_2 ';
   END IF;
   --SELECT Items AS BranchCode    
   --INTO #BranchCode  
   --FROM dbo.Split(@ApplicableSolId,',')  
   --SELECT *,'BRANCH' FROM #BranchCode
   DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
   DBMS_OUTPUT.PUT_LINE(v_DepartmentAlt_key);
   SELECT DeptGroupId 

     INTO v_DEPTALTKEY
     FROM DimUserDeptGroup 
    WHERE  DeptGroupCode = v_DeptCode
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   DBMS_OUTPUT.PUT_LINE('SQL');
   DBMS_OUTPUT.PUT_LINE(v_DepTCode);
   DBMS_OUTPUT.PUT_LINE(v_DEPTALTKEY);
   --IF @DepartmentCode IN ('FNA')
   --BEGIN
   --   PRINT 'FNA  FNA '
   --Select 
   --B.BACID as Code ,OAName as Description,'DimOfficeAccountBACID' as TableName
   --from DimOfficeAccountBACID A
   --INNER JOIN DimDepttoBacid B ON A.BACID=B.BACID
   --where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   --AND ISNULL(AuthorisationStatus,'A')='A'
   ------AND B.DepartmentAlt_Key=@DepartmentAlt_Key
   --   Select
   --	BranchCode as Code,BranchCode as [Description],'DimBranch' as TableName
   --	from DimBranch
   --	WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   --END
   --ELSE
   --BEGIN
   DBMS_OUTPUT.PUT_LINE('CBO');--		IF OBJECT_ID ('TEMPDB..#TempDimDepartmentBACID') IS NOT NULL
   --		DROP TABLE #TempDimDepartmentBACID
   --      Select * into #TempDimDepartmentBACID
   --		from
   --		(
   --		   Select
   --			 DepartmentAlt_Key
   --			 ,B.BACID
   --			from DimOfficeAccountBACID BAC
   --				INNER JOIN DimDepttoBacid B ON BAC.BACID=B.BACID
   --			where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)
   --			AND ISNULL(BAC.AuthorisationStatus,'A')='A'
   --			AND ISNULL(BAC.BACIDscope,1)=1
   --			AND B.DepartmentAlt_Key=@DEPTALTKEY
   --		)ABVV
   --		----SELECT *,'DIPTI' FROM #TempDimDepartmentBACID
   --	 Select 
   --DBAC.BACID as Code ,OAName as Description,'DimOfficeAccountBACID' as TableName
   --from DimOfficeAccountBACID BAC
   --inner join #TempDimDepartmentBACID DBAC
   --ON 
   ----(DBAC.EffectiveFromTimeKey<=@TimeKey AND DBAC.EffectiveToTimeKey >=@TimeKey)
   ----AND 
   --DBAC.BACID=BAC.BACID
   --AND DBAC.DepartmentAlt_Key=@DEPTALTKEY
   --where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)
   --AND ISNULL(BAC.AuthorisationStatus,'A')='A'
   --AND DepartmentAlt_Key=@DEPTALTKEY
   --ORDER BY 2
   --     Select
   --	B.BranchCode as Code,B.BranchCode as [Description],'DimBranch' as TableName
   --	from DimBranch B
   --	inner join #BranchCode ON B.BranchCode=#BranchCode.BranchCode
   --	WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   --END
   /*TODO:SQLDEV*/ SET ANSI_NULLS ON /*END:SQLDEV*/

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONPARAMETERISEDMASTERDATA_NEW_04122023" TO "ADF_CDR_RBL_STGDB";
