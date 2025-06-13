--------------------------------------------------------
--  DDL for Procedure SYSCRISMACMODULEMENU_MVC_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" --'addauth11' , 3652    

(
  v_UserLoginID IN VARCHAR2 DEFAULT 'pwomake' ,
  iv_TimeKey IN NUMBER DEFAULT 49999 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_DeptGrpCode NUMBER(10,0);
   v_MenuID VARCHAR2(4000);
   v_UserRoleAlt_Key NUMBER(5,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   DBMS_OUTPUT.PUT_LINE('A');
   SELECT DeptGroupCode 

     INTO v_DeptGrpCode
     FROM DimUserInfo 
    WHERE  UserLoginID = v_UserLoginID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   DBMS_OUTPUT.PUT_LINE(v_DeptGrpCode);
   DBMS_OUTPUT.PUT_LINE('B');
   --SET @MenuID = (Select Menus from DimUserDeptGroup where DeptGroupId = @DeptGrpCode AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)    
   --Select Menus from DimUserDeptGroup where DeptGroupId = 7 --AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey    
   SELECT Menus 

     INTO v_MenuID
     FROM DimUserDeptGroup 
    WHERE  DeptGroupId = v_DeptGrpCode
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   DBMS_OUTPUT.PUT_LINE(v_MenuID);
   DBMS_OUTPUT.PUT_LINE('C');
   SELECT UserRoleAlt_Key 

     INTO v_UserRoleAlt_Key
     FROM DimUserInfo 
    WHERE  UserLoginID = v_UserLoginID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   DBMS_OUTPUT.PUT_LINE(v_UserRoleAlt_Key);
   --SET @UserRoleAlt_Key = 3    
   DBMS_OUTPUT.PUT_LINE('D');
   OPEN  v_cursor FOR
      SELECT EntityKey ,
             MenuTitleId ,
             DataSeq ,
             NVL(MenuId, 0) MenuId  ,
             NVL(ParentId, 0) ParentId  ,
             MenuCaption ,
             NVL(UTILS.CONVERT_TO_VARCHAR2(ActionName,4000), ReportUrl) ActionName  ,
             Viewpath ,
             ngController ,
             BusFld ,
             EnableMakerChecker ,
             AuthLevel ,
             NonAllowOperation ,
             NVL(AccessLevel, 'VIEWER') AccessLevel  
        FROM SysCRisMacMenu M
               LEFT JOIN SysReportDirectory R   ON M.MenuId = R.ReportMenuId
       WHERE  visible = 1 --and  MenuTitleId<>50     

                AND MenuId IN ( SELECT a_SPLIT.VALUE('.', 'VARCHAR(100)') MenuId  
                                FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(v_MenuID, ',', '</M><M>') || '</M>') MenuId  
                                         FROM DUAL  ) A
                                        /*TODO:SQLDEV*/ CROSS APPLY MenuId.nodes ('/M') AS Split(a) /*END:SQLDEV*/ 
                                UNION 
                                SELECT ParentId MenuId  
                                FROM SysCRisMacMenu 
                                 WHERE  MenuId IN ( SELECT a_SPLIT.VALUE('.', 'VARCHAR(100)') MenuId  
                                                    FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(v_MenuID, ',', '</M><M>') || '</M>') MenuId  
                                                             FROM DUAL  ) A
                                                            /*TODO:SQLDEV*/ CROSS APPLY MenuId.nodes ('/M') AS Split(a) /*END:SQLDEV*/  )
               )

                AND (CASE 
                          WHEN v_UserRoleAlt_Key = 1
                            AND M.MenuId <> 0 THEN 1
                          WHEN v_UserRoleAlt_Key <> 1
                            AND M.MenuId NOT IN ( 105 )
                           THEN 1   END) = 1
              --AND ParentId = 0     
               --UNION    
               -- SELECT  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,    
               --  MenuCaption,  ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)      
               --  ActionName,Viewpath,ngController,BusFld,EnableMakerChecker,    
               --   NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel    
               -- FROM SysCRisMacMenu M     
               --  LEFT JOIN SysReportDirectory R    
               --  ON M.MenuId = R.ReportMenuId    
               -- WHERE --DeptGroupCode='ALL' and     
               -- visible=1 --and  MenuTitleId<>50     
               -- --AND (CASE WHEN @UserRoleAlt_Key = 1 AND M.MenuId<>0 THEN 1     
               -- --    WHEN @UserRoleAlt_Key <> 1 AND M.MenuId NOT IN (52,56,58,60,62,64,65,66,67,68,150,305) THEN 1 END )= 1    

        ORDER BY MenuTitleID,
                 DataSeq ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   -- For update the Userlogged=1 after successfull login   
   UPDATE DimUserInfo
      SET UserLogged = 1,
          CurrentLoginDate = SYSDATE
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
     AND EffectiveToTimeKey >= v_TimeKey )
     AND UserLoginID = v_UserLoginID;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSCRISMACMODULEMENU_MVC_04122023" TO "ADF_CDR_RBL_STGDB";
