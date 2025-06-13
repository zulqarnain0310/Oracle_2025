--------------------------------------------------------
--  DDL for Procedure TRESHOLD_META
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" 
(
  v_TImekey IN NUMBER DEFAULT 49999 ,
  v_Location IN CHAR DEFAULT 'HO' ,
  v_UserLoginID IN VARCHAR2 DEFAULT 'reema12345' 
)
AS
   v_LocationCode VARCHAR2(10);
   v_LoginUserLocationCode CHAR(2);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT UserLocationCode ,
          UserLocation 

     INTO v_LocationCode,
          v_LoginUserLocationCode
     FROM RBL_MISDB_PROD.DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= 49999
             AND EffectiveToTimeKey >= 49999 )
             AND UserLoginID = v_UserLoginID;
   IF v_Location = 'HO' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT LocationShortName Code  ,
                LocationName DESCRIPTION  ,
                LocationShortName LocationShortName  ,
                LocationName LocationName  ,
                'AdminLocation' TableName  
           FROM RBL_MISDB_PROD.dimuserlocation 
          WHERE  LocationShortName = 'HO' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF v_Location = 'ZO' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT ZoneAlt_Key Code  ,
                ZoneName DESCRIPTION  ,
                ZoneAlt_Key ZoneAlt_Key  ,
                ZoneName ZoneName  ,
                'AdminLocation' TableName  
           FROM RBL_MISDB_PROD.DimZone 
          WHERE  EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey
                   AND UTILS.CONVERT_TO_VARCHAR2(ZoneAlt_Key,10) = CASE 
                                                                        WHEN v_LoginUserLocationCode = 'ZO' THEN v_LocationCode
                 ELSE ZoneAlt_Key
                    END ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF v_Location = 'RO' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT RegionAlt_Key Code  ,
                RegionName DESCRIPTION  ,
                RegionAlt_Key RegionAlt_Key  ,
                RegionName RegionName  ,
                'AdminLocation' TableName  
           FROM RBL_MISDB_PROD.DimRegion 
          WHERE  EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey
                   AND UTILS.CONVERT_TO_VARCHAR2(RegionAlt_Key,10) = CASE 
                                                                          WHEN v_LoginUserLocationCode = 'RO' THEN v_LocationCode
                 ELSE RegionAlt_Key
                    END ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF v_Location = 'BO' THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT BranchCode Code  ,
                BranchName DESCRIPTION  ,
                BranchCode BranchCode  ,
                BranchName BranchName  ,
                'AdminLocation' TableName  
           FROM RBL_MISDB_PROD.DimBranch 
          WHERE  EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey
                   AND BranchCode = CASE 
                                         WHEN v_LoginUserLocationCode = 'BO' THEN v_LocationCode
                 ELSE BranchCode
                    END ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT 0 ParameterAlt_key  ,
             0 Code  ,
             'ALL' DESCRIPTION  ,
             'ALL' ParameterName  ,
             'MasterName' TableName  
        FROM DUAL 
     /* UNION 
      SELECT MasterNameAlt_Key MasterNameAlt_Key  ,
             MasterNameAlt_Key Code  ,
             --,ThresholdName ThresholdName 
             ThresholdName MasterName  ,
             ThresholdName ,
             'MasterName' TableName  
        FROM ALERT_RBL_MISDB_PROD.DImMasterName 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey */;
      DBMS_SQL.RETURN_RESULT(v_cursor);
--   RBL_MISDB_PROD.GetReportDateSelect(v_Loc'ation) ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLD_META" TO "ADF_CDR_RBL_STGDB";
