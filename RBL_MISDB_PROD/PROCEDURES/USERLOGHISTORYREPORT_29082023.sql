--------------------------------------------------------
--  DDL for Procedure USERLOGHISTORYREPORT_29082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" 
(
  iv_FromDate IN VARCHAR2,
  iv_ToDate IN VARCHAR2
)
AS
   v_FromDate VARCHAR2(10) := iv_FromDate;
   v_ToDate VARCHAR2(10) := iv_ToDate;
   v_cursor SYS_REFCURSOR;
--DECLARE
--	 @FromDate VARCHAR(10)=N'19/04/2023'
--	,@ToDate VARCHAR(10)=N'19/04/2023'

BEGIN

   v_FromDate := UTILS.CONVERT_TO_VARCHAR2(v_FromDate,200,p_style=>105) ;
   v_ToDate := UTILS.CONVERT_TO_VARCHAR2(v_ToDate,200,p_style=>105) ;
   --select		  a.UserLoginID,a.UserName,c.RoleDescription,d.DeptGroupName,a.Designation,a.IsChecker,a.IsChecker2,a.CreatedBy,a.DateCreated,a.ModifyBy,a.DateModified,
   --			  b.ApprovedByFirstLevel,b.DateApprovedFirstLevel,a.ApprovedBy,a.DateApproved
   --from		  DimUserInfo a
   --inner join    DimUserInfo_mod b
   --on            a.UserLoginID=b.UserLoginID
   --inner join    DimUserRole c
   --on            a.UserRoleAlt_Key=c.UserRoleAlt_Key
   --and           c.EffectiveToTimeKey=49999
   --inner join    DimUserDeptGroup d
   --on            a.DeptGroupCode=d.DeptGroupId
   --and           d.EffectiveToTimeKey=49999
   --where         a.EffectiveToTimeKey=49999 and b.EffectiveToTimeKey=49999
   --and           a.Activate='Y'
   ----and           a.UserLoginID='18423'
   --and           a.DateCreated between @FromDate and @ToDate
   --ORDER BY 9
   --select * from DimUserInfo
   --select distinct LogStatus from SysUserActivityLog_Attendence
   IF utils.object_id('TEMPDB..tt_DimUserInfo_Mod_Created_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimUserInfo_Mod_Created_4 ';
   END IF;
   DELETE FROM tt_DimUserInfo_Mod_Created_4;
   UTILS.IDENTITY_RESET('tt_DimUserInfo_Mod_Created_4');

   INSERT INTO tt_DimUserInfo_Mod_Created_4 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY UserLoginID ORDER BY UserLoginID, EntityKey DESC  ) RN  
               FROM DimUserInfo_mod 
                WHERE  DateCreated IS NOT NULL
                         AND AuthorisationStatus <> 'R' ) a
       WHERE  RN = 1;
   IF utils.object_id('TEMPDB..tt_DimUserInfo_Mod_Modify_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimUserInfo_Mod_Modify_4 ';
   END IF;
   DELETE FROM tt_DimUserInfo_Mod_Modify_4;
   UTILS.IDENTITY_RESET('tt_DimUserInfo_Mod_Modify_4');

   INSERT INTO tt_DimUserInfo_Mod_Modify_4 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY UserLoginID ORDER BY UserLoginID, EntityKey DESC  ) RN  
               FROM DimUserInfo_mod 
                WHERE  DateModified IS NOT NULL
                         AND DateCreated IS NOT NULL
                         AND AuthorisationStatus <> 'R' ) a
       WHERE  RN = 1;
   IF utils.object_id('TEMPDB..tt_DimUserInfo_Mod_Create_O_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimUserInfo_Mod_Create_O_4 ';
   END IF;
   DELETE FROM tt_DimUserInfo_Mod_Create_O_4;
   UTILS.IDENTITY_RESET('tt_DimUserInfo_Mod_Create_O_4');

   INSERT INTO tt_DimUserInfo_Mod_Create_O_4 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY UserLoginID ORDER BY UserLoginID, EntityKey  ) RN  
               FROM DimUserInfo_mod 
                WHERE  DateCreated IS NOT NULL
                         AND AuthorisationStatus <> 'R' ) a
       WHERE  RN = 1;
   IF utils.object_id('TEMPDB..tt_DimUserInfo_Mod_Modify_4_Upload') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimUserInfo_Mod_Modify_U_4 ';
   END IF;
   DELETE FROM tt_DimUserInfo_Mod_Modify_U_4;
   UTILS.IDENTITY_RESET('tt_DimUserInfo_Mod_Modify_U_4');

   INSERT INTO tt_DimUserInfo_Mod_Modify_U_4 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY UserLoginID ORDER BY UserLoginID, EntityKey DESC  ) RN  
               FROM DimUserInfo_mod 
                WHERE  EffectiveToTimeKey = 49999
                         AND ScreenFlag = 'U'
                         AND ActionAU = 'U' ) a
       WHERE  RN = 1;
   OPEN  v_cursor FOR
      SELECT a.UserLoginID ,
             a.UserName ,
             c.RoleDescription ,
             D.DeptGroupName ,
             A.Email_ID ,
             A.Designation Designation  ,
             --,CASE WHEN DM.Designation IS NULL THEN DC.Designation ELSE DM.Designation END AS Designation
             --,ISNULL(DM.Designation,DC.Designation) AS Designation 
             --,a.Designation
             CASE 
                  WHEN A.Activate = 'Y' THEN 'ACTIVE'
                  WHEN A.Activate = 'N' THEN 'INACTIVE'
             ELSE NULL
                END Active_Inactive  ,
             a.IsChecker ,
             a.IsChecker2 ,
             CASE 
                  WHEN A.ScreenFlag = 'S' THEN 'THROUGH SCEEN'
                  WHEN A.ScreenFlag = 'U' THEN 'THROUGH UPLOAD'
             ELSE A.ScreenFlag
                END ScreenFlag  ,
             --,DC.CreatedBy AS CreatedBy
             CASE 
                  WHEN NVL(DC_Old.CreatedBy, ' ') = ' ' THEN DC.CreatedBy
             ELSE DC_Old.CreatedBy
                END CreatedBy  ,
             --,(CONVERT(VARCHAR(10),DC.DateCreated,105) +' '+ CONVERT(VARCHAR,DC.DateCreated,108)) AS DateCreated
             (UTILS.CONVERT_TO_VARCHAR2(DC_Old.DateCreated,10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DC_Old.DateCreated,30,p_style=>108)) DateCreated  ,
             --,DC.DateCreated
             NVL(DC_Old.ApprovedByFirstLevel, DC.ApprovedByFirstLevel) ApprovedByFirstLevel  ,
             (UTILS.CONVERT_TO_VARCHAR2(NVL(DC_Old.DateApprovedFirstLevel, DC.DateApprovedFirstLevel),10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(NVL(DC_Old.DateApprovedFirstLevel, DC.DateApprovedFirstLevel),30,p_style=>108)) DateApprovedFirstLevel  ,
             --,CONVERT(VARCHAR(10),DC.DateApprovedFirstLevel,105) AS DateApprovedFirstLevel
             --,DC.DateApprovedFirstLevel
             NVL(DC_Old.ApprovedBy, DC.ApprovedBy) ApprovedBy  ,
             (UTILS.CONVERT_TO_VARCHAR2(NVL(DC_Old.DateApproved, DC.DateApproved),10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(NVL(DC_Old.DateApproved, DC.DateApproved),30,p_style=>108)) DateApproved  ,
             --,DC.DateApproved
             NVL(DM.ModifyBy, DMU.CreatedBy) ModifyBy  ,
             (UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateModified, DMU.DateCreated),10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateModified, DMU.DateCreated),30,p_style=>108)) DateModified  ,
             --,DM.DateModified
             NVL(DM.ApprovedByFirstLevel, DMU.ApprovedByFirstLevel) ApprovedByFirstLevelModify  ,
             (UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateApprovedFirstLevel, DMU.DateApprovedFirstLevel),10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateApprovedFirstLevel, DMU.DateApprovedFirstLevel),30,p_style=>108)) DateApprovedFirstLevelModify  ,
             --,CONVERT(VARCHAR(10),DM.DateApprovedFirstLevel,105) AS DateApprovedFirstLevelModify
             --,DM.DateApprovedFirstLevel DateApprovedFirstLevelModify
             NVL(DM.ApprovedBy, DMU.ApprovedBy) ApprovedByModify  ,
             (UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateApproved, DMU.DateApproved),10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(NVL(DM.DateApproved, DMU.DateApproved),30,p_style=>108)) DateApprovedModify  

        --,DM.DateApproved DateApprovedModify
        FROM DimUserInfo a
             --inner join  DimUserInfo_mod b
              --on          a.UserLoginID=b.UserLoginID

               JOIN DimUserRole c   ON a.UserRoleAlt_Key = c.UserRoleAlt_Key
               AND c.EffectiveToTimeKey = 49999
               JOIN DimUserDeptGroup D   ON a.DeptGroupCode = D.DeptGroupId
               AND D.EffectiveToTimeKey = 49999
               LEFT JOIN tt_DimUserInfo_Mod_Created_4 DC   ON a.UserLoginID = dc.UserLoginID
             --AND			DC.EffectiveToTimeKey=49999

               LEFT JOIN tt_DimUserInfo_Mod_Modify_4 DM   ON a.UserLoginID = DM.UserLoginID
               AND DM.EffectiveToTimeKey = 49999
               LEFT JOIN tt_DimUserInfo_Mod_Create_O_4 DC_Old   ON A.UserLoginID = DC_Old.UserLoginID
               LEFT JOIN tt_DimUserInfo_Mod_Modify_U_4 DMU   ON a.UserLoginID = DMU.UserLoginID
               AND DMU.EffectiveToTimeKey = 49999
               LEFT JOIN DimDesignation DEG   ON A.DesignationAlt_Key = DEG.DesignationAlt_Key
               AND DEG.EffectiveToTimeKey = 49999
       WHERE  a.EffectiveToTimeKey = 49999 --and b.EffectiveToTimeKey=49999


                --and         a.Activate='Y'

                --and         a.UserLoginID='V12334offf'

                --AND			CONVERT(DATE,DC_Old.DateCreated,103)>=@FromDate AND CONVERT(DATE,DC_Old.DateCreated,103)<=@ToDate
                AND UTILS.CONVERT_TO_VARCHAR2(DC_Old.DateCreated,200) >= v_FromDate
                AND UTILS.CONVERT_TO_VARCHAR2(DC_Old.DateCreated,200) <= v_ToDate
        ORDER BY 
                 --and         a.DateCreated between @FromDate and @ToDate
                 12 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGHISTORYREPORT_29082023" TO "ADF_CDR_RBL_STGDB";
