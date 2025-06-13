--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_UPLOAD_PROD_BKUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" 
(
  --@XmlData XML=''  --,@MenuID INT=NULL  --   ,@TimeKey int   --   ,@Result int=0 output    
  v_TypeOfUpload IN VARCHAR2 DEFAULT ' ' ,
  v_XmlData IN CLOB DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_AuthMode IN CHAR DEFAULT NULL ,
  v_MenuID IN NUMBER DEFAULT NULL ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'hradmin' ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_cursor SYS_REFCURSOR;

BEGIN

   DECLARE
      v_APPBACIDS VARCHAR2(4000);
      v_DepartmentCode VARCHAR2(50);
      v_DepartmentAlt_Key NUMBER(10,0);
      v_UserRole NUMBER(10,0);
   --DECLARE 
   --	@TypeOfUpload VARCHAR(30) ='NULL' 
   --     , @XmlData XML='<DataSet><GridData><SrNo>2</SrNo><UserID>RAGL</UserID><UserName>RAGL</UserName><UserRole>operator</UserRole><UserDepartment>RAGL</UserDepartment><ApplicableBACID>2300195,2300196,2300197,2300198,23001AC,23001AE,23001AG,23001AH</ApplicableBACID><UserEmailId>PPPPPPPP@axisbank.com</UserEmailId><UserMobileNumber>9833333333</UserMobileNumber><UserExtensionNumber>777</UserExtensionNumber><IsCheckerYN>y</IsCheckerYN><IsActiveYN>y</IsActiveYN><ActionAU>a</ActionAU></GridData></DataSet>'     
   --     ,@OperationFlag  INT=1       
   --     ,@AuthMode char(2) = 'N'                                          
   --     ,@MenuID INT=58  
   --     ,@TimeKey int  =24957 
   --	 ,@UserLoginId varchar(20)='fnasuperadmin'

   BEGIN
      IF utils.object_id('tempdb..tt_OAOLMasterUploadData_8') IS NOT NULL THEN

      BEGIN
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_OAOLMasterUploadData_8 ';

      END;
      END IF;
      DELETE FROM tt_OAOLMasterUploadData_8;
      IF NVL(v_TimeKey, 0) = 0 THEN

      BEGIN
         SELECT Timekey 

           INTO v_TimeKey
           FROM SysDayMatrix 
          WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);

      END;
      END IF;
      -- Select @Timekey=Max(Timekey) from SysProcessingCycle
      --where Extracted='Y' and ProcessType='Full' and PreMOC_CycleFrozenDate IS NULL
      DBMS_OUTPUT.PUT_LINE(v_TimeKey);
      SELECT DEP.DeptGroupCode ,
             DEP.DeptGroupId ,
             UserRoleAlt_Key 

        INTO v_DepartmentCode,
             v_DepartmentAlt_Key,
             v_UserRole
        FROM DimUserInfo INFO
             --INNER JOIN DimDepartment	DEP

               JOIN DimUserDeptGroup DEP   ON INFO.EffectiveFromTimeKey <= v_Timekey
               AND INFO.EffectiveToTimeKey >= v_Timekey
               AND DEP.EffectiveFromTimeKey <= v_Timekey
               AND DEP.EffectiveToTimeKey >= v_Timekey
               AND UserLoginID = v_UserLoginId
               AND INFO.DepartmentId = DEP.DeptGroupId;
      DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
      IF v_MenuID = 58 THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         IF utils.object_id('TEMPDB..tt_UserMasterUploadData_18') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UserMasterUploadData_18 ';
         END IF;
         --Select * from DimUserInfo
         DELETE FROM tt_UserMasterUploadData_18;
         UTILS.IDENTITY_RESET('tt_UserMasterUploadData_18');

         INSERT INTO tt_UserMasterUploadData_18 ( 
         	SELECT /*TODO:SQLDEV*/ c.value('./SrNo[1]','int') /*END:SQLDEV*/ SrNo  ,
                 /*TODO:SQLDEV*/ c.value('./UserID[1]','varchar(max)') /*END:SQLDEV*/ UserID  ,
                 /*TODO:SQLDEV*/ c.value('./UserName[1]','varchar(max)') /*END:SQLDEV*/ UserName  ,
                 /*TODO:SQLDEV*/ c.value('./UserRole[1]','varchar(max)') /*END:SQLDEV*/ UserRole  ,
                 /*TODO:SQLDEV*/ c.value('./Designation[1]','varchar(max)') /*END:SQLDEV*/ Designation  ,
                 /*TODO:SQLDEV*/ c.value('./UserDepartment[1]','nvarchar(510)') /*END:SQLDEV*/ UserDepartment  ,
                 --,c.value('./ApplicableSolID[1]','varchar(max)')ApplicableSolID
                 --,c.value('./ApplicableBACID[1]','varchar(max)')ApplicableBACID
                 /*TODO:SQLDEV*/ c.value('./UserEmailId[1]','varchar(max)') /*END:SQLDEV*/ UserEmailId  ,
                 /*TODO:SQLDEV*/ c.value('./UserMobileNumber[1]','varchar(max)') /*END:SQLDEV*/ UserMobileNumber  ,
                 /*TODO:SQLDEV*/ c.value('./UserExtensionNumber [1]','varchar(max)') /*END:SQLDEV*/ UserExtensionNumber  ,
                 /*TODO:SQLDEV*/ c.value('./IsCheckerYN[1]','varchar(max)') /*END:SQLDEV*/ IsChecker  ,
                 /*TODO:SQLDEV*/ c.value('./IsChecker2YN[1]','varchar(max)') /*END:SQLDEV*/ IsChecker2 ,---Added By Sachin

                 /*TODO:SQLDEV*/ c.value('./IsActiveYN [1]','varchar(max)') /*END:SQLDEV*/ IsActive  ,
                 /*TODO:SQLDEV*/ c.value('./ActionAU[1]','varchar(max)') /*END:SQLDEV*/ Perform  
         	  FROM TABLE(/*TODO:SQLDEV*/ @XmlData.nodes('/DataSet/GridData') AS t(c) /*END:SQLDEV*/)  );
         --SELECT * FROM tt_UserMasterUploadData_18
         --uPDATE tt_UserMasterUploadData_18 SET --ApplicableSolID =REPLACE(REPLACE(ApplicableSolID, CHAR(13), ''), CHAR(10), '')
         --ApplicableBACID =REPLACE(REPLACE(ApplicableBACID, CHAR(13), ''), CHAR(10), ''),UserRole=LTRIM(RTRIM(UserRole))
         --SELECT 'tt_UserMasterUploadData_18', * FROM tt_UserMasterUploadData_18
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'Sr No' ColumnName  ,
                    NULL ErrorData  ,
                    'Please enter serial no ' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.SrNo, 0) = 0 );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'User ID' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserID, ' ') = ' '
             UNION 
             SELECT SrNo ,
                    -- ,RowNo  
                    'User Name' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserName, ' ') = ' '
             UNION 
             SELECT SrNo ,
                    -- ,RowNo  
                    'User Role' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserRole, ' ') = ' '
             UNION 

             ------------------------
             SELECT SrNo ,
                    -- ,RowNo  
                    'Designation' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.Designation 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.Designation, ' ') = ' '
             UNION 

             -----------------------------------------------------
             SELECT SrNo ,
                    -- ,RowNo  
                    'User Department' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserDepartment, ' ') = ' '
             UNION 

             ----UNION                           COMMENTED BY DIPTI

             ----SELECT  SrNo  

             ----    -- ,RowNo  

             ----     ,'Applicable Sol ID' ColumnName  

             ----     ,NULL ErrorData  

             ----     ,'is Mandatory Field For Departments other than  FNA AND BBOG' ErrorType  

             ----  ,T.UserID

             ----   FROM tt_UserMasterUploadData_18 T  	 

             ----	WHERE ISNULL(T.ApplicableBACID,'')=''

             ----	AND T.UserDepartment NOT IN ('FNA','BBOG')

             --UNION

             --SELECT  SrNo  

             --    -- ,RowNo  

             --     ,'Applicable BAC ID' ColumnName  

             --     ,NULL ErrorData  

             --     ,'is Mandatory Field For Departments other than  FNA,BBOG' ErrorType  

             --  ,T.UserID

             --   FROM tt_UserMasterUploadData_18 T  	 

             --	WHERE ISNULL(T.ApplicableBACID,'')=''

             --	AND T.UserDepartment NOT IN ('FNA','BBOG')
             SELECT SrNo ,
                    -- ,RowNo  
                    'User Email Id' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserEmailId, ' ') = ' '
             UNION 

             --UNION

             --SELECT  SrNo  

             --    -- ,RowNo  

             --     ,'User Email Id' ColumnName  

             --     ,NULL ErrorData  

             --     ,'is Mandatory Field' ErrorType  

             --  ,T.UserID

             --   FROM tt_UserMasterUploadData_18 T  	 

             --	WHERE ISNULL(T.UserEmailId,'')=''
             SELECT SrNo ,
                    -- ,RowNo  
                    'User Mobile Number' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.UserMobileNumber, ' ') = ' '
             UNION 

             --UNION

             --SELECT  SrNo  

             --    -- ,RowNo  

             --     ,'User Extension Number' ColumnName  

             --     ,NULL ErrorData  

             --     ,'is Mandatory Field' ErrorType 

             --  ,T.UserID 

             --   FROM tt_UserMasterUploadData_18 T  	 

             --	WHERE ISNULL(T.UserExtensionNumber,'')=''

             --   UNION

             --SELECT  SrNo  

             --    -- ,RowNo  

             --     ,'Is Checker' ColumnName  

             --     ,NULL ErrorData  

             --     ,'is Mandatory Field' ErrorType  

             --  ,T.UserID

             --   FROM tt_UserMasterUploadData_18 T  	 

             --	WHERE ISNULL(T.IsChecker,'')=''

             --Added By Sachin

             --UNION

             --SELECT  SrNo  

             --    -- ,RowNo  

             --     ,'Is Checker' ColumnName  

             --     ,NULL ErrorData  

             --     ,'is Mandatory Field' ErrorType  

             --  ,T.UserID

             --   FROM tt_UserMasterUploadData_18 T  	 

             --	WHERE ISNULL(T.IsChecker2 ,'')=''

             --Till Here
             SELECT SrNo ,
                    -- ,RowNo  
                    'Is Active' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.IsActive, ' ') = ' '
             UNION 
             SELECT SrNo ,
                    -- ,RowNo  
                    'Is Active' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.IsActive, ' ') = ' '
             UNION 
             SELECT SrNo ,
                    -- ,RowNo  
                    'Perform' ColumnName  ,
                    NULL ErrorData  ,
                    'is Mandatory Field' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  NVL(T.Perform, ' ') = ' ' );
         DBMS_OUTPUT.PUT_LINE('SNEHAL');
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_OAOLMasterUploadData_8  );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('11');

         END;
         END IF;
         --GOTO RETURNDATA
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                             WHERE  T.UserID IN ( SELECT UserID 
                                                  FROM tt_UserMasterUploadData_18 
                                                    GROUP BY UserID

                                                     HAVING COUNT(UserId)  > 1 )

                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                             WHERE  T.UserMobileNumber IN ( SELECT UserMobileNumber 
                                                            FROM tt_UserMasterUploadData_18 
                                                              GROUP BY UserMobileNumber

                                                               HAVING COUNT(UserMobileNumber)  > 1 )

                                      AND NVL(T.UserMobileNumber, ' ') <> ' '
                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                             WHERE  T.UserExtensionNumber IN ( SELECT UserExtensionNumber 
                                                               FROM tt_UserMasterUploadData_18 
                                                                 GROUP BY UserExtensionNumber

                                                                  HAVING COUNT(UserExtensionNumber)  > 1 )

                                      AND NVL(T.UserExtensionNumber, ' ') <> ' '
                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                             WHERE  T.UserEmailId IN ( SELECT UserEmailId 
                                                       FROM tt_UserMasterUploadData_18 
                                                         GROUP BY UserEmailId

                                                          HAVING COUNT(UserEmailId)  > 1 )

                                      AND NVL(T.UserEmailId, ' ') <> ' ' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_OAOLMasterUploadData_8
              ( SELECT DISTINCT SrNo ,
                                -- ,RowNo  
                                'User Id' ColumnName  ,
                                T.UserID ErrorData  ,
                                'Duplicate User Id In Upload Sheet' ErrorType  ,
                                T.UserID 
                FROM tt_UserMasterUploadData_18 T
                 WHERE  T.UserID IN ( SELECT UserID 
                                      FROM tt_UserMasterUploadData_18 
                                        GROUP BY UserID

                                         HAVING COUNT(UserId)  > 1 )

                UNION 
                SELECT DISTINCT SrNo ,
                                -- ,RowNo  
                                'User Mobile No' ColumnName  ,
                                T.UserMobileNumber ErrorData  ,
                                'Duplicate User Mobile Number In Upload Sheet' ErrorType  ,
                                T.UserID 
                FROM tt_UserMasterUploadData_18 T
                 WHERE  T.UserMobileNumber IN ( SELECT UserMobileNumber 
                                                FROM tt_UserMasterUploadData_18 
                                                  GROUP BY UserMobileNumber

                                                   HAVING COUNT(UserMobileNumber)  > 1 )

                          AND NVL(T.UserMobileNumber, ' ') <> ' '
                UNION 
                SELECT DISTINCT SrNo ,
                                -- ,RowNo  
                                'User Email Id' ColumnName  ,
                                T.UserEmailId ErrorData  ,
                                'Duplicate User Email Id In Upload Sheet' ErrorType  ,
                                T.UserID 
                FROM tt_UserMasterUploadData_18 T
                 WHERE  T.UserEmailId IN ( SELECT UserEmailId 
                                           FROM tt_UserMasterUploadData_18 
                                             GROUP BY UserEmailId

                                              HAVING COUNT(UserEmailId)  > 1 )

                          AND NVL(T.UserEmailId, ' ') <> ' ' );

         END;
         END IF;
         --UNION
         --		Select
         --		Distinct   SrNo  
         --		 -- ,RowNo  
         --		  ,'User Extension Number' ColumnName  
         --		  ,T.UserExtensionNumber ErrorData  
         --		  ,'Duplicate Extension Number In Upload Sheet' ErrorType  
         --		  ,T.UserID
         --		FROM tt_UserMasterUploadData_18 T  
         --		WHERE T.UserExtensionNumber IN 
         --		(
         --		   Select UserExtensionNumber from tt_UserMasterUploadData_18
         --		   group by UserExtensionNumber
         --		   having COUNT(UserExtensionNumber) > 1
         --		) AND ISNULL(T.UserExtensionNumber,'') <> ''
         --GOTO RETURNDATA
         ---- 
         IF utils.object_id('TEMPDB..tt_TempAlreadyExists_8') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempAlreadyExists_8 ';
         END IF;
         DELETE FROM tt_TempAlreadyExists_8;
         UTILS.IDENTITY_RESET('tt_TempAlreadyExists_8');

         INSERT INTO tt_TempAlreadyExists_8 ( 
         	SELECT * 
         	  FROM ( SELECT SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
                          SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
                          U.Email_ID ,
                          U.UserLoginID 
                   FROM DimUserInfo U
                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey ) ) K );
         ---INSERT INTO tt_OAOLMasterUploadData_8    
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN DimUserInfo    ON T.UserID = DimUserInfo.UserLoginID
                             WHERE  NVL(T.UserID, ' ') <> ' '
                                      AND NVL(T.Perform, ' ') = 'A'
                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.Email_ID = T.UserEmailId
                                   AND T.Perform = 'A'
                                   AND NVL(T.UserEmailId, ' ') <> ' '
                            UNION 

                            --INSERT INTO tt_OAOLMasterUploadData_8    
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.Email_ID = T.UserEmailId
                                   AND T.UserID NOT IN ( SELECT UserLoginID 
                                                         FROM tt_TempAlreadyExists_8  )

                                   AND T.Perform = 'U'
                                   AND NVL(T.UserEmailId, ' ') <> ' '
                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.MobileNo = T.UserMobileNumber
                                   AND T.Perform = 'A'
                                   AND NVL(T.UserMobileNumber, ' ') <> ' '
                            UNION 

                            --INSERT INTO tt_OAOLMasterUploadData_8    
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.MobileNo = T.UserMobileNumber
                                   AND T.UserID NOT IN ( SELECT UserLoginID 
                                                         FROM tt_TempAlreadyExists_8  )

                                   AND T.Perform = 'U'
                                   AND NVL(T.UserMobileNumber, ' ') <> ' '
                            UNION 
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.ExtensionNo = T.UserExtensionNumber
                                   AND T.Perform = 'A'
                                   AND NVL(T.UserExtensionNumber, ' ') <> ' '
                            UNION 

                            --INSERT INTO tt_OAOLMasterUploadData_8    
                            SELECT 1 
                            FROM tt_UserMasterUploadData_18 T
                                   JOIN tt_TempAlreadyExists_8 E   ON E.ExtensionNo = T.UserExtensionNumber
                                   AND T.UserID NOT IN ( SELECT UserLoginID 
                                                         FROM tt_TempAlreadyExists_8  )

                                   AND T.Perform = 'U'
                                   AND NVL(T.UserExtensionNumber, ' ') <> ' ' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            INSERT INTO tt_OAOLMasterUploadData_8
              ( SELECT SrNo ,
                       'User  Id' ColumnName  ,
                       T.UserID ErrorData  ,
                       'User Id Already Exists' ErrorType  ,
                       T.UserID 
                FROM tt_UserMasterUploadData_18 T
                       JOIN DimUserInfo    ON T.UserID = DimUserInfo.UserLoginID
                 WHERE  NVL(T.UserID, ' ') <> ' '
                          AND NVL(T.Perform, ' ') = 'A'
                UNION 
                SELECT SrNo ,
                       'User Email Id' ColumnName  ,
                       T.UserEmailId ErrorData  ,
                       'User Email Id Already Exists' ErrorType  ,
                       T.UserID 
                FROM tt_UserMasterUploadData_18 T
                       JOIN tt_TempAlreadyExists_8 E   ON E.Email_ID = T.UserEmailId
                       AND T.Perform = 'A'
                       AND NVL(T.UserEmailId, ' ') <> ' '
                UNION 
                SELECT SrNo ,
                       'User Email Id' ColumnName  ,
                       T.UserEmailId ErrorData  ,
                       'User Email Id Already Exists' ErrorType  ,
                       T.UserID 
                FROM tt_UserMasterUploadData_18 T
                       JOIN tt_TempAlreadyExists_8 E   ON E.Email_ID = T.UserEmailId
                       AND T.UserID NOT IN ( SELECT UserLoginID 
                                             FROM tt_TempAlreadyExists_8  )

                       AND T.Perform = 'U'
                       AND NVL(T.UserEmailId, ' ') <> ' '
                UNION 
                SELECT SrNo ,
                       'User Mobile Number' ColumnName  ,
                       T.UserMobileNumber ErrorData  ,
                       'User Mobile Number Already Exists' ErrorType  ,
                       T.UserID 
                FROM tt_UserMasterUploadData_18 T
                       JOIN tt_TempAlreadyExists_8 E   ON E.MobileNo = T.UserMobileNumber
                       AND T.Perform = 'A'
                       AND NVL(T.UserMobileNumber, ' ') <> ' '
                UNION 

                --INSERT INTO tt_OAOLMasterUploadData_8    
                SELECT SrNo ,
                       'User Mobile Number' ColumnName  ,
                       T.UserMobileNumber ErrorData  ,
                       'User Mobile Number Already Exists' ErrorType  ,
                       T.UserID 
                FROM tt_UserMasterUploadData_18 T
                       JOIN tt_TempAlreadyExists_8 E   ON E.MobileNo = T.UserMobileNumber
                       AND T.UserID NOT IN ( SELECT UserLoginID 
                                             FROM tt_TempAlreadyExists_8  )

                       AND T.Perform = 'U'
                       AND NVL(T.UserMobileNumber, ' ') <> ' ' );

         END;
         END IF;
         --UNION
         --Select
         --SrNo  
         --  ,'User Extension Number' ColumnName  
         --  ,T.UserExtensionNumber ErrorData  
         --  ,'User Extension Number Already Exists' ErrorType  
         --  ,T.UserID
         --FROM tt_UserMasterUploadData_18 T  
         --inner join tt_TempAlreadyExists_8 E ON E.ExtensionNo=T.UserExtensionNumber
         --AND T.Perform='A'
         --AND ISNULL(T.UserExtensionNumber,'') <> ''
         --UNION
         ----INSERT INTO tt_OAOLMasterUploadData_8 
         --Select
         --SrNo  
         --  ,'User Extension Number' ColumnName  
         --  ,T.UserExtensionNumber ErrorData  
         --  ,'User Extension Number Already Exists' ErrorType  
         --  ,T.UserID
         --FROM tt_UserMasterUploadData_18 T  
         --inner join tt_TempAlreadyExists_8 E ON E.ExtensionNo=T.UserExtensionNumber
         --AND T.UserID NOT IN (Select UserLoginID from tt_TempAlreadyExists_8)
         --AND T.Perform='U'
         --AND ISNULL(T.UserExtensionNumber,'') <> ''
         -- GOTO RETURNDATA 
         -----
         -----
         ---- Validations of UserId
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'User ID' ColumnName  ,
                    T.UserID ErrorData  ,
                    'User Id Does not Exists' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
                    LEFT JOIN DimUserInfo    ON T.UserID = DimUserInfo.UserLoginID
              WHERE  NVL(T.UserID, ' ') <> ' '
                       AND NVL(T.Perform, ' ') = 'U'
                       AND DimUserInfo.UserLoginID IS NULL );--- invalid user id entered
         ----------------------------------------Added condition for (should not Accept UserId length less than 5 Characters) //08-07-2019
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT SrNo ,
                             -- ,RowNo  
                             'User ID' ColumnName  ,
                             T.UserID ErrorData  ,
                             'Invalid User ID ,User ID should be greater than 5 Digits' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  LENGTH(T.UserID) < 5
                       AND NVL(T.UserID, ' ') <> ' ' );
         -----
         --- Validations of User Role
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'User Role' ColumnName  ,
                    T.UserRole ErrorData  ,
                    CASE 
                         WHEN NVL(T.UserDepartment, ' ') = 'FNA ' THEN 'Invalid User Role,User Role Should be one of  Admin, Operator, Viewer '
                    ELSE 'Invalid User Role,User Role Should be one of Admin, Operator, Viewer '
                       END ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
                    LEFT JOIN DimUserRole R   ON R.RoleDescription = T.UserRole
              WHERE  R.UserRoleAlt_Key IS NULL
                       AND NVL(T.UserRole, ' ') <> ' ' );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'User Role' ColumnName  ,
                    T.UserRole ErrorData  ,
                    'Only Super Admin Can  Create Super Admin User' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
                    JOIN DimUserRole R   ON R.RoleDescription = T.UserRole
                    AND R.UserRoleAlt_Key = 1
                    AND v_UserRole <> 1 );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'Designation' ColumnName  ,
                    T.Designation ErrorData  ,
                    'Invalid Designation' ErrorType  ,
                    T.Designation 
             FROM tt_UserMasterUploadData_18 T
              WHERE --D.DeptGroupId IS NULL 
               NVL(T.Designation, ' ') NOT IN ( SELECT ParameterName 
                                                FROM DimParameter 
                                                 WHERE  DimParameterName = 'DimUserDesignation' )
            );
         -- INSERT INTO tt_OAOLMasterUploadData_8    
         ----SELECT  SrNo  
         ----    -- ,RowNo  
         ----     ,'User Role' ColumnName  
         ----     ,T.UserRole ErrorData  
         ----     ,'Super Admin Role is Available only For FNA Department' ErrorType  
         ----  ,T.UserID
         ----   FROM tt_UserMasterUploadData_18 T  
         ----inner join DimUserRole R ON R.RoleDescription=T.UserRole
         ---- and R.UserRoleAlt_Key=1
         ---- AND T.UserDepartment <> 'FNA'
         --------
         ------ User Department
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT SrNo ,
                    -- ,RowNo  
                    'User Department' ColumnName  ,
                    T.UserDepartment ErrorData  ,
                    'Invalid Department' ErrorType  ,
                    T.UserID 
             FROM tt_UserMasterUploadData_18 T
                  --left join DimDepartment D ON D.DepartmentCode=T.UserDepartment

                    LEFT JOIN DimUserDeptGroup D   ON D.DeptGroupCode = T.UserDepartment
                    AND ( D.EffectiveFromTimeKey <= v_TimeKey
                    AND D.EffectiveToTimeKey >= v_TimeKey )
              WHERE  D.DeptGroupId IS NULL );
         --  IF @DepartmentCode <> 'FNA'
         --BEGIN
         --  INSERT INTO tt_OAOLMasterUploadData_8   
         -- SELECT  SrNo  
         --  -- ,RowNo  
         --   ,'User Department' ColumnName  
         --   ,T.UserDepartment ErrorData  
         --   ,'You can not  Create or Update Users of Other Department' ErrorType 
         --   ,T.UserID 
         -- FROM tt_UserMasterUploadData_18 T  	 
         -- 	WHERE  T.UserDepartment  <> @DepartmentCode
         --	AND ISNULL(T.UserDepartment,'') <> ''
         --END	
         ----------
         ---- Applicable Sol ID -----
         /****COMMENTED BY DIPTI ON 071119 AS APPLICABLE SOLID IS REMOVED**********************/
         ---- Applicable Sol Id
         ----        INSERT INTO tt_OAOLMasterUploadData_8   
         ----SELECT  SrNo  
         ----    -- ,RowNo  
         ----     ,'Applicable Sol ID' ColumnName  
         ----     ,T.ApplicableBACID ErrorData  
         ----     ,'Should be blank For Department  FNA AND BBOG' ErrorType  
         ----  ,T.UserID
         ----   FROM tt_UserMasterUploadData_18 T  	 
         ----	WHERE ISNULL(T.ApplicableBACID,'')<> ''
         ----	AND T.UserDepartment  IN ('FNA','BBOG')
         ----IF OBJECT_ID('TEMPDB..#TempDepartmentWiseSolIds')IS NOT NULL
         ----		DROP TABLE #TempDepartmentWiseSolIds
         ----Select * into #TempDepartmentWiseSolIds
         ----from
         ----(
         ----    SELECT DepartmentAlt_Key,DepartmentCode,
         ----	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BranchCode
         ----	FROM
         ----	(
         ----	SELECT DepartmentAlt_Key,DepartmentCode,CAST('<XMLRoot><RowData>' + REPLACE(d.ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
         ----	FROM   DimDepartment D
         ----	inner join tt_UserMasterUploadData_18 U ON U.UserDepartment=D.DepartmentCode
         ----    AND U.UserDepartment NOT IN ('BBOG','FNA')  --- Get only those department which are available in sheet
         ----	where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
         ----	AND DepartmentCode NOT IN ('FNA')
         ----	)t
         ----	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
         ----)K  --- Department wise Sol Id allocated
         ----IF OBJECT_ID('TEMPDB..#TempSelectedSolIdsUserWise')IS NOT NULL
         ----		DROP TABLE #TempSelectedSolIdsUserWise
         ----Select * into #TempSelectedSolIdsUserWise
         ----from
         ----(
         ----    SELECT UserID,SrNo,
         ----	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BranchCode
         ----	FROM
         ----	(
         ----	SELECT UserID,SrNo,CAST('<XMLRoot><RowData>' + REPLACE(ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
         ----	FROM   tt_UserMasterUploadData_18
         ----	where UserDepartment NOT IN ('BBOG','FNA')
         ----	and ISNULL(ApplicableBACID,'') <> ''
         ----	)t
         ----	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
         ----)K  ---- User wise sol id allocated 
         ----INSERT INTO tt_OAOLMasterUploadData_8    
         ----SELECT Distinct  t.SrNo  
         ----    -- ,RowNo  
         ----     ,'Applicable Sol Id' ColumnName  
         ----     ,U.ApplicableBACID ErrorData  
         ----     ,'Applicable SOL id  is invalid' ErrorType  
         ----  ,T.UserID
         ----   FROM #TempSelectedSolIdsUserWise T  
         ----inner join tt_UserMasterUploadData_18 U ON U.UserID=T.UserID
         ---- AND U.UserDepartment NOT IN ('BBOG','FNA')
         ----left join DimBranch D ON D.BranchCode=T.BranchCode
         ----and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
         ----where D.BranchCode IS NULL --- invalid sol id Selected
         ----INSERT INTO tt_OAOLMasterUploadData_8    
         ----SELECT Distinct  t.SrNo  
         ----    -- ,RowNo  
         ----     ,'Applicable Sol ID' ColumnName  
         ----     ,U.ApplicableBACID ErrorData  
         ----     ,'Invalid Branch Code,Branch Code Should belong to Department' ErrorType  
         ----  ,T.UserID
         ----   FROM #TempSelectedSolIdsUserWise T  
         ----inner join tt_UserMasterUploadData_18 U ON U.UserID=T.UserID
         ---- AND U.UserDepartment NOT IN ('BBOG','FNA')
         ----left join #TempDepartmentWiseSolIds D ON D.BranchCode=T.BranchCode
         ----AND U.UserDepartment=D.DepartmentCode
         ------and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
         ----where D.BranchCode IS NULL --- Sol id isnot one of Sols Selected in Department
         ----  -----
         ---- Applicabel BACID
         --INSERT INTO tt_OAOLMasterUploadData_8   
         --SELECT  SrNo  
         --    -- ,RowNo  
         --     ,'Applicable BAC ID' ColumnName  
         --     ,T.ApplicableBACID ErrorData  
         --     ,'Should be blank For Department FNA' ErrorType  
         --  ,T.UserID
         --   FROM tt_UserMasterUploadData_18 T  	 
         --	WHERE ISNULL(T.ApplicableBACID,'')<> ''
         --	AND T.UserDepartment  IN ('FNA')
         --IF OBJECT_ID('TEMPDB..#TempSelectedBACIDsUserWise')IS NOT NULL
         --		DROP TABLE #TempSelectedBACIDsUserWise
         --Select * into #TempSelectedBACIDsUserWise
         --from
         --(
         --    SELECT UserID,SrNo,
         --	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BACID
         --	FROM
         --	(
         --	SELECT UserID,SrNo,CAST('<XMLRoot><RowData>' + REPLACE(ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
         --	FROM   tt_UserMasterUploadData_18
         --	where 
         --	--UserDepartment NOT IN ('BBOG','FNA')
         --	UserDepartment NOT IN ('FNA')
         --	and ISNULL(ApplicableBACID,'') <> ''
         --	)t
         --	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
         --)K
         --Select * from #TempSelectedBACIDsUserWise
         ------SELECT * FROM #TempSelectedBACIDsUserWise
         ------SELECT * FROM tt_OAOLMasterUploadData_8
         --INSERT INTO tt_OAOLMasterUploadData_8    
         --SELECT Distinct  t.SrNo  
         --    -- ,RowNo  
         --     ,'Applicable BAC ID' ColumnName  
         --     ,U.ApplicableBACID ErrorData  
         --     ,'One of BAC Id Entered Is not Available' ErrorType  
         --  ,T.UserID
         --  --,D.BACID
         --  --,T.BACID
         --   FROM #TempSelectedBACIDsUserWise T  
         --INNER JOIN tt_UserMasterUploadData_18 U ON U.UserID=T.UserID
         -- --AND U.UserDepartment NOT IN ('BBOG','FNA')
         -- AND U.UserDepartment NOT IN ('FNA')
         --  AND ISNULL(U.ApplicableBACID,'') <> ''
         --LEFT JOIN DimOfficeAccountBACID D ON 
         --LTRIM(RTRIM(D.BACID)) =LTRIM (RTRIM(T.BACID))
         --AND 
         --(D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
         -------AND LTRIM(RTRIM(T.BACID))=LTRIM(RTRIM(D.BACID))
         --where D.BACID IS NULL --- invalid BAC id Selected
         --IF OBJECT_ID('TEMPDB..#TempDepartmentBACID')IS NOT NULL
         --		DROP TABLE #TempDepartmentBACID
         --Select * into #TempDepartmentBACID
         --from
         --(
         --  Select
         --     B.OAAlt_Key BACID-----OAALTKEY AS BACID
         -- ,B.DepartmentAlt_Key
         --,U.UserID
         ----,B.BranchCode
         --   from DimDepartmentBACID B
         --inner join tt_UserMasterUploadData_18 U ON 
         ----U.UserID=T.UserID
         ----AND 
         --U.UserDepartment NOT IN ('BBOG','FNA')
         --AND ISNULL(U.ApplicableBACID,'') <> ''
         --   --AND ISNULL(U.ApplicableSolID,'') <> ''
         --inner join DimDepartment D ON (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
         --   AND U.UserDepartment=D.DepartmentCode -- Joins department with Users
         --AND B.DepartmentAlt_Key=D.DepartmentAlt_Key
         --AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)
         /***** FOR REMOVING DimDepartmentBACID TABLE *****/
         -- SELECT  A.ApplicableBACID BACID,A.DepartmentAlt_Key,A.EffectiveFromTimeKey,A.EffectiveToTimeKey ,B.UserID
         --  INTO #TempDepartmentBACID
         -- FROM 
         -- (
         --SELECT  Split.a.value('.', 'VARCHAR(MAX)') AS ApplicableBACID  ,DepartmentAlt_Key,DepartmentCode,EffectiveFromTimeKey,EffectiveToTimeKey
         --					FROM  (SELECT 
         --							CAST ('<M>' + REPLACE(ApplicableBACID, ',', '</M><M>') + '</M>' AS XML) AS ControlName
         --							,DepartmentAlt_Key,DepartmentCode,EffectiveFromTimeKey,EffectiveToTimeKey
         --							FROM DimDepartment
         --						) AS A CROSS APPLY ControlName.nodes ('/M') AS Split(a) 
         -- )
         -- A 
         -- INNER JOIN tt_UserMasterUploadData_18 B 
         -- ON B.UserDepartment NOT IN ('FNA')
         --  AND ISNULL(B.ApplicableBACID,'')<>''
         -- AND B.UserDepartment=A.DepartmentCode
         -- AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         -- WHERE  EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
         --------BACIDS NEEDS TO BE TAKEN FROM DEPARTMENT TABLE
         --) K  --- find BACID Allocated to Department 
         --Select  Items AS BACID INTO #TempDepartmentBACID 
         --from Split(@APPBACIDS,',')
         ----Insert into #TempDepartmentBACID
         ----(
         ----  BACID
         ----)
         ----(
         ----    Select
         ----			OAAlt_Key
         ----			from DimOfficeAccountBACID BAC
         ----			where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)
         ----			AND ISNULL(BAC.AuthorisationStatus,'A')='A'
         ----			AND ISNULL(BAC.BACIDscope,1)=1
         ----)--- insert Bacid with generic type
         --Update #TempDepartmentBACID
         --SET #TempDepartmentBACID.DepartmentAlt_Key=K.DepartmentAlt_Key
         --from
         --(
         --  Select Distinct DepartmentAlt_Key from #TempDepartmentBACID
         --  WHERE DepartmentAlt_Key IS NOT NULL
         --)K
         --where #TempDepartmentBACID.DepartmentAlt_Key IS NULL  --- Update Department for Generic BAC ID
         --Update #TempDepartmentBACID
         --SET #TempDepartmentBACID.UserID=K.UserID
         --from
         --(
         --  Select Distinct UserID from #TempDepartmentBACID
         --  WHERE UserID IS NOT NULL
         --)K
         --where #TempDepartmentBACID.UserID IS NULL  --- Update UserId for Generic BAC ID
         --SELECT * FROM #TempSelectedBACIDsUserWise
         --SELECT * FROM tt_UserMasterUploadData_18
         --SELECT * FROM #TempDepartmentBACID
         --Insert into tt_OAOLMasterUploadData_8
         --Select
         -- U.SrNo
         -- ,'Applicable BAC ID'
         --,U.ApplicableBACID
         --,'Invalid BACID,BAC Id not belong to Department'
         --,T.UserID
         --from #TempSelectedBACIDsUserWise T
         --	inner join tt_UserMasterUploadData_18 U ON U.UserID=T.UserID
         -- --AND U.UserDepartment NOT IN ('BBOG','FNA')
         -- AND U.UserDepartment NOT IN ('FNA')
         -- -- AND ISNULL(U.ApplicableBACID,'') <> ''
         --  -- AND ISNULL(U.ApplicableSolID,'') <> ''
         --left join #TempDepartmentBACID D ON D.BACID=T.BACID
         --where D.BACID IS NULL
         --INSERT INTO tt_OAOLMasterUploadData_8    
         --SELECT Distinct  t.SrNo  
         --    -- ,RowNo  
         --     ,'Applicable BACID' ColumnName  
         --     ,U.ApplicableBACID ErrorData  
         --     ,'Invalid BACID,BACID not belong to Department' ErrorType  
         --  ,T.UserID
         --   FROM #TempSelectedBACIDsUserWise T  
         --inner join tt_UserMasterUploadData_18 U ON U.UserID=T.UserID
         -- AND U.UserDepartment NOT IN ('BBOG','FNA')
         --  AND ISNULL(U.ApplicableBACID,'') <> ''
         --   AND ISNULL(U.ApplicableSolID,'') <> ''
         --inner join DimDepartment D ON (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
         --AND U.UserDepartment=D.DepartmentCode -- Joins department with Users
         --inner join DimOfficeAccountBACID BA ON (BA.EffectiveFromTimeKey<=@TimeKey AND BA.EffectiveToTimeKey >=@TimeKey)
         --AND BA.BACID=T.BACID
         --left join DimDepartmentBACID B ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)
         --AND B.DepartmentAlt_Key=D.DepartmentAlt_Key-- join Department with Department BACID
         --AND B.BACID=BA.BACID
         --where B.DepartmentAlt_Key IS NULL
         --------
         ----- Email Id
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Email Id' ColumnName  ,
                             T.UserEmailId ErrorData  ,
                             'Invalid Email id ,Email Id should contain  @ only once ' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  ((LENGTH(UserEmailId) - LENGTH(REPLACE(UserEmailId, '@', ' '))) / LENGTH('@')) > 1 );
         -- AND ISNULL(T.UserEmailId,'') <> ''	 
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Email Id' ColumnName  ,
                             T.UserEmailId ErrorData  ,
                             'Invalid Email id ,Email Id should end with @Rblbank.com' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.UserEmailId NOT LIKE '%@Rblbank.com'
                       AND NVL(T.UserEmailId, ' ') <> ' ' );
         --INSERT INTO tt_OAOLMasterUploadData_8    
         --Select
         --Distinct  t.SrNo  
         --    -- ,RowNo  
         --     ,'User Email Id' ColumnName  
         --     ,T.UserEmailId ErrorData  
         --     ,'Invalid Email id ,enter minimum 5 char before @' ErrorType 
         --  ,T.UserID 
         --   FROM tt_UserMasterUploadData_18 T  
         ------where len(SUBSTRING(T.UserEmailId,1,CHARINDEX('@axisbank.com',T.UserEmailId,1))) < 5
         -- where len(SUBSTRING(T.UserEmailId,1,CHARINDEX('@',T.UserEmailId,1)-1)) < 5
         --AND ISNULL(T.UserEmailId,'') <> ''
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User Email Id' ColumnName  ,
                             T.UserEmailId ErrorData  ,
                             'Invalid Email id ,Email Id should start with character' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  SUBSTR(NVL(T.UserEmailId, ' '), 0, 1) IN ( '0','1','2','3','4','5','6','7','8','9' )

                       AND NVL(T.UserEmailId, ' ') <> ' ' );
         -- 
         -----User Mobile No
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User Mobile No' ColumnName  ,
                             T.UserMobileNumber ErrorData  ,
                             'Invalid Mobile No ,Mobile No should be of 10 Digits' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE
             --AND 
               NVL(T.UserMobileNumber, ' ') <> ' '
                 AND LENGTH(T.UserMobileNumber) < 10
                 OR LENGTH(T.UserMobileNumber) > 10 );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User Mobile No' ColumnName  ,
                             T.UserMobileNumber ErrorData  ,
                             'Invalid Mobile No ,Mobile No Should Contains Numbers only' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  utils.isnumeric(T.UserMobileNumber) <> 1
                       AND NVL(T.UserMobileNumber, ' ') <> ' ' );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User Mobile No' ColumnName  ,
                             T.UserMobileNumber ErrorData  ,
                             'Invalid Mobile No ,Mobile No Should Start from 6,7,8,9' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  SUBSTR(NVL(T.UserMobileNumber, ' '), 0, 1) NOT IN ( '6','7','8','9' )

                       AND NVL(T.UserMobileNumber, ' ') <> ' ' );
         ----
         ---- USer Extension No
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User Extension No' ColumnName  ,
                             T.UserExtensionNumber ErrorData  ,
                             'Invalid Extension No ,Extension No should be Upto 4 Digits' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  LENGTH(T.UserExtensionNumber) > 4
                       AND NVL(T.UserExtensionNumber, ' ') <> ' ' );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User ExtensionNo' ColumnName  ,
                             T.UserExtensionNumber ErrorData  ,
                             'Invalid Extension No ,Extension No Should Contains Numbers only' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  utils.isnumeric(T.UserExtensionNumber) <> 1
                       AND NVL(T.UserExtensionNumber, ' ') <> ' ' );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'User ExtensionNo' ColumnName  ,
                             T.UserExtensionNumber ErrorData  ,
                             'Invalid Extension No ,Extension No Can not be zero' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  (CASE 
                           WHEN utils.isnumeric(T.UserExtensionNumber) <> 1 THEN 0
                     ELSE CASE 
                               WHEN UTILS.CONVERT_TO_NUMBER(T.UserExtensionNumber,15,0) = 0 THEN 1   END
                        END) = 1
                       AND NVL(T.UserExtensionNumber, ' ') <> ' ' );
         --INSERT INTO tt_OAOLMasterUploadData_8    
         ------- 
         ----- Is Checker
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Checker ' ColumnName  ,
                             T.IsChecker ErrorData  ,
                             'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.IsChecker NOT IN ( 'Y','N' )
            );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Checker ' ColumnName  ,
                             T.IsChecker ErrorData  ,
                             'User role as Viewer will not have checker rights' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  ( T.IsChecker = 'Y'
                       OR T.IsChecker2 = 'Y' )
                       AND T.UserRole = 'Viewer' );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Checker ' ColumnName  ,
                             T.IsChecker ErrorData  ,
                             'User role as Operator will not have 2nd level checker rights' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  ( T.IsChecker2 = 'Y' )
                       AND T.UserRole = 'Operator' );
         ---Added By Sachin
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Checker2 ' ColumnName  ,
                             T.IsChecker ErrorData  ,
                             'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.IsChecker NOT IN ( 'Y','N' )
            );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Checker2 ' ColumnName  ,
                             T.IsChecker ErrorData  ,
                             'User role as Viewer will not have checker rights' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.IsChecker = 'Y'
                       AND T.UserRole = 'Viewer' );
         --Till Here
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Is Active ' ColumnName  ,
                             T.IsActive ErrorData  ,
                             'Invalid Value Provided for Is ActiveIt Should be One of Y And N' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.IsActive NOT IN ( 'Y','N' )
            );
         INSERT INTO tt_OAOLMasterUploadData_8
           ( SELECT DISTINCT t.SrNo ,
                             -- ,RowNo  
                             'Action' ColumnName  ,
                             T.Perform ErrorData  ,
                             'Invalid Value Provided for Action, It Should be One of A And U' ErrorType  ,
                             T.UserID 
             FROM tt_UserMasterUploadData_18 T
              WHERE  T.Perform NOT IN ( 'A','U' )
            );

      END;
      END IF;
      <<RETURNDATA>>
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_OAOLMasterUploadData_8 
           ORDER BY UserId,
                    EntityId ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--order by SR_No

   END;
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_UserMasterUploadData_18  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_UPLOAD_PROD_BKUP" TO "ADF_CDR_RBL_STGDB";
