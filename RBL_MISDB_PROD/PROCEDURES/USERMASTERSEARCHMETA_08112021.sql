--------------------------------------------------------
--  DDL for Procedure USERMASTERSEARCHMETA_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" 
-- =============================================  
 -- Author:  <Author,,Name>  
 -- Create date: <Create Date,,>  
 -- Description: <Description,,>  
 -- =============================================  

(
  v_UserLoginID IN VARCHAR2,
  iv_TimeKey IN NUMBER
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_DepartmentCode VARCHAR2(50);
   v_DepartmentAlt_Key VARCHAR2(50);
   v_cursor SYS_REFCURSOR;
--DECLARE   
--@UserLoginID varchar(20)='FNASUPERADMIN',    
--@TimeKey INT =25202  

BEGIN

   --Select DepartmentAlt_Key as Code,DepartmentName as [Description],'DimDepartment' as TableName from DimDepartment  
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
   SELECT dep.DeptGroupCode ,
          DEP.DeptGroupId 

     INTO v_DepartmentCode,
          v_DepartmentAlt_Key
     FROM DimUserInfo INFO
          --INNER JOIN DimDepartment DEP

            JOIN DimUserDeptGroup DEP   ON INFO.EffectiveFromTimeKey <= v_Timekey
            AND INFO.EffectiveToTimeKey >= v_Timekey
            AND DEP.EffectiveFromTimeKey <= v_Timekey
            AND DEP.EffectiveToTimeKey >= v_Timekey
            AND UserLoginID = v_UserLoginId
            AND INFO.DepartmentId = DEP.DeptGroupId;
   DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
   DBMS_OUTPUT.PUT_LINE(v_DepartmentAlt_Key);
   OPEN  v_cursor FOR
      SELECT deptgroupid Code  ,
             DeptgroupCode Description  ,
             'DimDepartment' TableName  
        FROM DimUserDeptGroup 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND NVL(AuthorisationStatus, 'A') = 'A'
                AND (CASE 
                          WHEN v_DepartmentCode IN ( 'FNA' )
                           THEN 1
                          WHEN v_DepartmentCode = deptgroupcode THEN 1   END) = 1
        ORDER BY 2 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --  Declare @ApplicableBACID varchar(max)=''  
   --Select @ApplicableBACID=  
   --ApplicableBACID from DimDepartment  
   --where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
   --AND DepartmentAlt_Key=@DepartmentAlt_Key
   ------AND ISNULL(AuthorisationStatus,'A')='A'  
   ----AND (  
   ----       CASE   
   ----    WHEN @DepartmentCode IN ('FNA') THEN 0  
   ----    WHEN @DepartmentCode =DepartmentCode THEN 1  
   ----    end  
   ----    )=1 AND DepartmentAlt_Key=@DepartmentAlt_Key  
   --PRINT '@ApplicableBACID '+@ApplicableBACID  
   --IF OBJECT_ID('TEMPDB..#BACID') IS NOT NULL  
   --DROP TABLE #BACID  
   --SELECT Items AS BACID      
   --INTO #BACID    
   --FROM dbo.Split(@ApplicableBACID,',')    
   --  UPDATE #BACID SET BACID =REPLACE(REPLACE(BACID, CHAR(13), ''), CHAR(10), '')   
   --     UPDATE #BACID SET BACID =LTRIM(RTRIM(BACID))  
   ----select * from #bacid  
   --IF @DepartmentCode IN ('FNA')  
   --BEGIN  
   --   Select   
   --BACID,OAName,'DimOfficeAccountBACID' as TableName  
   --from DimOfficeAccountBACID  
   --where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
   --AND ISNULL(AuthorisationStatus,'A')='A'  
   --Select  
   --BranchCode as Code,BranchCode as [Description],'DimBranch' as TableName  
   --from DimBranch  
   --WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
   --END  
   --ELSE  

   BEGIN
      --  Select * into #TempDimDepartmentBACID  
      --from  
      --(  
      --  Select  
      --  DepartmentAlt_Key,applicableBACID  
      --  from DimDepartment DBAC  
      --  --Inner join DimBranch B ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)  
      --  --AND #BranchCode.BranchCode=B.BranchCode  
      --  where (DBAC.EffectiveFromTimeKey<=@TimeKey AND DBAC.EffectiveToTimeKey >=@TimeKey)  
      --   AND DBAC.DepartmentAlt_Key=@DepartmentAlt_Key  
      --) K  
      --Insert into #TempDimDepartmentBACID  
      --(  
      --    DepartmentAlt_Key  
      --  ,BACID  
      --)  
      --(  
      --   Select  
      --  @DepartmentAlt_Key  
      --  ,BACID  
      -- from DimOfficeAccountBACID BAC  
      -- where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)  
      -- AND ISNULL(BAC.AuthorisationStatus,'A')='A'  
      -- --AND ISNULL(BAC.BACIDscope,1)=1  
      --)  
      --   Select   
      --BAC.BACID as Code ,BAC.BACID as Description,'DimOfficeAccountBACID' as TableName  
      ----BAC.BACID as Code ,OAName as Description,'DimOfficeAccountBACID' as TableName  
      --from DimOfficeAccountBACID BAC  
      ------inner join #BACID DBAC  
      ------ ON DBAC.BACID=BAC.BACID  
      -- --AND DBAC.DepartmentAlt_Key=@DepartmentAlt_Key  
      --where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)  
      --AND ISNULL(BAC.AuthorisationStatus,'A')='A'  
      ----AND DBAC.BACID NOT LIKE'%[A-Z]%'  
      --ORDER BY 2
      OPEN  v_cursor FOR
         SELECT B.BranchCode Code  ,
                b.BranchCode Description  ,
                'DimBranch' TableName  
           FROM DimBranch B

         --inner join #BranchCode ON B.BranchCode=#BranchCode.BranchCode  
         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                  AND EffectiveToTimeKey >= v_TimeKey )
           ORDER BY 2 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   IF v_DepartmentCode = 'FNA' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT UserRoleAlt_Key Code  ,
                RoleDescription Description  ,
                'DimUserRole' TableName  
           FROM DimUserRole 
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
           ORDER BY 2 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT UserRoleAlt_Key Code  ,
                RoleDescription Description  ,
                'DimUserRole' TableName  
           FROM DimUserRole 
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND UserRoleAlt_Key IN ( 2,3,4 )

           ORDER BY 2 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT ParameterShortName Code  ,
             ParameterName Description  ,
             'DimYesNo' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
        ORDER BY 2 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT v_DepartmentAlt_Key Code  ,
             v_DepartmentCode Description  ,
             'UserDept' TableName  
        FROM DUAL 
        ORDER BY 2 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   /*TODO:SQLDEV*/ SET ANSI_NULLS ON /*END:SQLDEV*/

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMASTERSEARCHMETA_08112021" TO "ADF_CDR_RBL_STGDB";
