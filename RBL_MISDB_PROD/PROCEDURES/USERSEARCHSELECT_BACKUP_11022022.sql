--------------------------------------------------------
--  DDL for Procedure USERSEARCHSELECT_BACKUP_11022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_UserLoginID IN VARCHAR2,
  v_UserName IN VARCHAR2,
  v_ExtensionNo IN VARCHAR2,
  v_ApplicableSOLID IN VARCHAR2,
  v_UserDepartment IN VARCHAR2,
  v_UserRole IN VARCHAR2,
  v_Email_ID IN VARCHAR2,
  v_MobileNo IN VARCHAR2,
  v_IsChecker IN CHAR,
  --,@IsChecker2 Varchar(1)
  v_IsActive IN CHAR,
  iv_TimeKey IN NUMBER,
  v_ApplicableBacid IN VARCHAR2 DEFAULT ' ' ,
  v_LoginID IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_cursor SYS_REFCURSOR;

BEGIN

   --DECLAre
   --	@UserLoginID		Varchar(50)='111kk'
   --	,@UserName  Varchar(50)='ak'
   --	,@ExtensionNo Varchar(11)
   --	,@ApplicableSOLID varchar(11)=''
   --	,@UserDepartment	varchar(100)='14'
   --	,@UserRole  varchar(100)=2
   --	,@Email_ID varchar(200)
   --	,@MobileNo varchar(10)
   --	,@IsChecker Char(1)
   --	,@IsActive  Char(1)
   --	,@TimeKey	INT=25202
   --	,@ApplicableBacid VARCHAR(MAX)=''
   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   --Select @TimeKey= MAX(Timekey) from SysProcessingCycle 
   --WHERE Extracted='Y' and ProcessType='Full'
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   ------------MULTI SELECT FOR USER DEPARTMENT 
   IF utils.object_id('TEMPDB..tt_Dept_ALTKEY_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Dept_ALTKEY_5 ';
   END IF;
   DELETE FROM tt_Dept_ALTKEY_5;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   IF NVL(v_UserDepartment, ' ') <> ' ' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('Dp');
      INSERT INTO tt_Dept_ALTKEY_5
        ( SELECT Items Dept_ALTKEY  
          FROM TABLE(SPLIT(v_UserDepartment, ','))  );

   END;

   ----SELECT * FROM #Dept_codeS
   ELSE

   BEGIN
      INSERT INTO tt_Dept_ALTKEY_5
        ( SELECT deptgroupid Dept_ALTKEY  

          --FROM dimdepartment A
          FROM DimUserDeptGroup A
                 LEFT JOIN DimUserInfo B   ON A.DeptGroupId = B.DeptGroupCode
                 AND b.EffectiveFromTimeKey <= v_TimeKey
                 AND b.EffectiveToTimeKey >= v_TimeKey
           WHERE  B.UserLoginID = v_UserLoginID
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey );

   END;
   END IF;
   --DECLARE @DEPTALTKEY INT
   --SET @DEPTALTKEY =(SELECT DISTINCT B.DepartmentAlt_Key FROM DimUserInfo A
   --					INNER JOIN dimdepartment B ON A.DepartmentId=B.DepartmentAlt_Key
   --												AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   --					WHERE B.DepartmentCode IN (SELECT Dept_code FROM #Dept_codeS))
   ----IF OBJECT_ID('tempdb..#tempItem') IS NOT NULL
   ----    DROP TABLE #tempItem
   ----	    SELECT * INTO #tempItem FROM Split(@ApplicableSOLID ,',')
   ----SELECT * FROM #tempItem
   -----------APPLICABLE BACIDS
   IF utils.object_id('TEMPDB..tt_BACID_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BACID_5 ';
   END IF;
   DELETE FROM tt_BACID_5;
   DBMS_OUTPUT.PUT_LINE('TABLE CREATED');
   IF NVL(v_ApplicableBacid, ' ') <> ' ' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_BACID_5
        ( SELECT Items BACID  
          FROM TABLE(SPLIT(v_ApplicableBacid, ','))  );

   END;

   ----SELECT * FROM tt_BACID_5
   ELSE

   BEGIN
      DBMS_OUTPUT.PUT_LINE(2);
      INSERT INTO tt_BACID_5
        ( SELECT BACID 
          FROM DimDepttoBacid 
           WHERE  DepartmentAlt_Key = 10 );

   END;
   END IF;
   -------------TO DISPLAY LIST OF BACIDS ASSIGNED
   ----	SELECT A.BACID AS CODE,A.BACID AS DESCRIPTION , 'Bacid_list_Department' AS TABLENAME
   ----	FROM DimDepttoBacid A
   ----	INNER JOIN dimdepartment B ON A.DepartmentAlt_Key=B.DepartmentAlt_Key
   ----								AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   ----	WHERE B.DepartmentCode =ISNULL(@UserDepartment,10)
   ----IF OBJECT_ID('tempdb..#tempSelectedItem') IS NOT NULL
   ----   DROP TABLE #tempSelectedItem
   ---- Select * into #tempSelectedItem
   ---- from
   ---- (
   ---- SELECT DISTINCT C.BranchCode,@UserLoginID as UserLoginId
   ----   FROM OAOLEntryDetaiL A
   ----INNER JOIN FACTOFFICE B ON A.OAOLAlt_Key =B.OAAlt_Key	
   ----						AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   ----						AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   ----INNER JOIN DimBranch C ON A.BranchCode =C.BranchCode
   ----						AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   ----						AND C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey 
   ----    --WHERE 
   ---- )ANC
   --Declare @ApplicableSolidForBBOG varchar(max)
   --Select @ApplicableSolidForBBOG=ApplicableBACID
   --from DimDepartment where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   --AND DepartmentCode='BBOG'
   ------SELECT * FROM #tempSelectedItem
   --SELECT * FROM tt_BACID_5
   --SELECT * FROM #Dept_codeS
   OPEN  v_cursor FOR
      SELECT U.UserLoginID ,
             U.UserName ,
             U.UserRoleAlt_Key UserRole  ,
             R.RoleDescription ,
             U.DepartmentId ,
             U.DeptGroupCode ,
             D.DeptGroupCode UserDepartment  ,
             CASE ---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  

              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL SOL ID'
             ELSE U.ApplicableSolIds
                END ApplicableSOLID  ,
             ----,'' AS ApplicableSOLID
             CASE ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 

              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL BACID'
             ELSE U.ApplicableBACID
                END ApplicableBACID  ,
             U.Email_ID ,
             SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
             SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
             U.MobileNo ,
             U.IsChecker ,
             U.IsChecker2 ,
             U.Activate IsActive  ,
             'QuickSearchTable' TableName  
        FROM DimUserInfo U
             --LEFT JOIN DimDepartment D ON

               LEFT JOIN DimUserDeptGroup D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey )
               AND ( u.EffectiveFromTimeKey <= v_TimeKey
               AND u.EffectiveToTimeKey >= v_TimeKey )
               AND D.DeptGroupId = U.DeptGroupCode
               LEFT JOIN DimUserRole R   ON ( R.EffectiveFromTimeKey <= v_TimeKey
               AND R.EffectiveToTimeKey >= v_TimeKey )
               AND ( u.EffectiveFromTimeKey <= v_TimeKey
               AND U.EffectiveToTimeKey >= v_TimeKey )
               AND R.UserRoleAlt_Key = U.UserRoleAlt_Key

      ----left join #tempSelectedItem I ON I.UserLoginId=U.UserLoginID

      --LEFT JOIN DimDepttoBacid DB ON D.DepartmentAlt_Key =DB.DepartmentAlt_Key

      --					AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey

      --INNER JOIN tt_BACID_5 BD ON BD.BACID=DB.BACID
      WHERE  ( U.UserLoginID LIKE CASE 
                                       WHEN v_UserLoginID <> ' ' THEN '%' || v_UserLoginID || '%'
             ELSE U.UserLoginID
                END )
               AND ( NVL(U.UserName, ' ') LIKE CASE 
                                                    WHEN v_UserName <> ' ' THEN '%' || v_UserName || '%'
             ELSE NVL(U.UserName, ' ')
                END )
               AND ( SUBSTR(NVL(U.MobileNo, ' '), 1, 10) LIKE CASE 
                                                                   WHEN v_MobileNo <> ' ' THEN '%' || v_MobileNo || '%'
             ELSE SUBSTR(NVL(U.MobileNo, ' '), 1, 10)
                END )
               AND ( SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) LIKE CASE 
                                                                                              WHEN v_ExtensionNo <> ' ' THEN '%' || v_ExtensionNo || '%'
             ELSE SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' ')))
                END )
               AND ( NVL(D.deptgroupid, ' ') IN ( SELECT Dept_ALTKEY 
                                                  FROM tt_Dept_ALTKEY_5  )
              )

               -------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
               AND ( U.UserRoleAlt_Key = CASE 
                                              WHEN v_UserRole <> ' ' THEN v_UserRole
             ELSE U.UserRoleAlt_Key
                END )
               AND ( NVL(U.Email_ID, ' ') LIKE CASE 
                                                    WHEN v_Email_ID <> ' ' THEN '%' || v_Email_ID || '%'
             ELSE NVL(U.Email_ID, ' ')
                END )
               AND ( NVL(U.IsChecker, ' ') LIKE CASE 
                                                     WHEN v_IsChecker <> ' ' THEN v_IsChecker
             ELSE U.IsChecker
                END )

               --AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
               AND ( NVL(U.Activate, ' ') LIKE CASE 
                                                    WHEN v_IsActive <> ' ' THEN v_IsActive
             ELSE U.Activate
                END )

               ----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end

               --AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM tt_BACID_5))
               AND U.UserLoginID <> v_LoginID
        ORDER BY U.UserLoginID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
