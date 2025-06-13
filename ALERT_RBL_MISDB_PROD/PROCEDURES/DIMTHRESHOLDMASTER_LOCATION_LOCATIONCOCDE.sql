--------------------------------------------------------
--  DDL for Procedure DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" 
-- =============================================
 -- Author:		<HAMID>
 -- Create date: <25 JUNE 2019>
 -- Description:	<For FInding ThresholdMaster Location LocationCocde>
 -- =============================================
  --DECLARE   
  (
  v_timekey IN NUMBER DEFAULT 25292 ,
  iv_Location IN VARCHAR2 DEFAULT 'BO' ,
  iv_LocationCode IN VARCHAR2 DEFAULT '3064' ,
  v_ReturnLocation OUT VARCHAR2,
  v_ReturnLocationCode OUT VARCHAR2
)
AS
   v_Location VARCHAR2(2) := iv_Location;
   v_LocationCode VARCHAR2(10) := iv_LocationCode;

BEGIN

   IF v_Location = 'BO' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM GTT_BRANCH';
      UTILS.IDENTITY_RESET('GTT_BRANCH');

      INSERT INTO GTT_BRANCH ( 
      	SELECT BranchZone ,
              BranchZoneAlt_Key ,
              BranchRegion ,
              BranchRegionAlt_Key 
      	  FROM RBL_MISDB_PROD.DimBranch 
      	 WHERE  EffectiveFromTimeKey <= v_timekey
                 AND EffectiveToTimeKey >= v_timekey
                 AND BranchCode LIKE v_LocationCode );
      --CHECK BRANCH ALERT.DimThresholdMaster MASTER
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                          WHERE  Location = v_Location
                                   AND LocationCode = v_LocationCode );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Location := v_Location ;
         v_LocationCode := v_LocationCode ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      ELSE

      BEGIN
         v_Location := 'RO' ;
         SELECT BranchRegionAlt_Key 

           INTO v_LocationCode
           FROM GTT_BRANCH ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      END IF;
      --CHECK REGION ALERT.DimThresholdMaster MASTER
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                          WHERE  Location = v_Location
                                   AND LocationCode = v_LocationCode );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Location := v_Location ;
         v_LocationCode := v_LocationCode ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      ELSE

      BEGIN
         v_Location := 'ZO' ;
         SELECT BranchZoneAlt_Key 

           INTO v_LocationCode
           FROM GTT_BRANCH ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      END IF;
      --CHECK ZONE ALERT.DimThresholdMaster MASTER
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                          WHERE  Location = v_Location
                                   AND LocationCode = v_LocationCode );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Location := v_Location ;
         v_LocationCode := v_LocationCode ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      ELSE

      BEGIN
         v_Location := 'HO' ;
         v_LocationCode := 'HO' ;
         v_ReturnLocation := v_Location ;
         v_ReturnLocationCode := v_LocationCode ;

      END;
      END IF;

   END;
   ELSE 
      IF v_Location = 'RO' THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         EXECUTE IMMEDIATE 'DELETE FROM GTT_DimRegion';
         UTILS.IDENTITY_RESET('GTT_DimRegion');

         INSERT INTO GTT_DimRegion ( 
         	SELECT ZoneName ,
                 ZoneAlt_Key ,
                 RegionName ,
                 RegionAlt_Key 
         	  FROM RBL_MISDB_PROD.DimRegion 
         	 WHERE  EffectiveFromTimeKey <= v_timekey
                    AND EffectiveToTimeKey >= v_timekey
                    AND RegionAlt_Key = v_LocationCode );
         --CHECK REGION ALERT.DimThresholdMaster MASTER
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                             WHERE  Location = v_Location
                                      AND LocationCode = v_LocationCode );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            v_Location := v_Location ;
            v_LocationCode := v_LocationCode ;
            v_ReturnLocation := v_Location ;
            v_ReturnLocationCode := v_LocationCode ;

         END;
         ELSE

         BEGIN
            v_Location := 'ZO' ;
            SELECT ZoneAlt_Key 

              INTO v_LocationCode
              FROM GTT_DimRegion ;
            v_ReturnLocation := v_Location ;
            v_ReturnLocationCode := v_LocationCode ;

         END;
         END IF;
         --CHECK ZONE ALERT.DimThresholdMaster MASTER
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                             WHERE  Location = v_Location
                                      AND LocationCode = v_LocationCode );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            v_Location := v_Location ;
            v_LocationCode := v_LocationCode ;
            v_ReturnLocation := v_Location ;
            v_ReturnLocationCode := v_LocationCode ;

         END;
         ELSE

         BEGIN
            v_Location := 'HO' ;
            v_LocationCode := 'HO' ;
            v_ReturnLocation := v_Location ;
            v_ReturnLocationCode := v_LocationCode ;

         END;
         END IF;

      END;
      ELSE
         IF v_Location = 'ZO' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            --CHECK REGION ALERT.DimThresholdMaster MASTER
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster 
                                WHERE  Location = v_Location
                                         AND LocationCode = v_LocationCode );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               v_Location := v_Location ;
               v_LocationCode := v_LocationCode ;
               v_ReturnLocation := v_Location ;
               v_ReturnLocationCode := v_LocationCode ;

            END;
            ELSE

            BEGIN
               v_Location := 'HO' ;
               v_LocationCode := 'HO' ;
               v_ReturnLocation := v_Location ;
               v_ReturnLocationCode := v_LocationCode ;

            END;
            END IF;

         END;
         ELSE
            IF v_Location = 'HO' THEN

            BEGIN
               v_Location := 'HO' ;
               v_LocationCode := 'HO' ;
               v_ReturnLocation := v_Location ;
               v_ReturnLocationCode := v_LocationCode ;

            END;
            END IF;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_LOCATION_LOCATIONCOCDE" TO "ADF_CDR_RBL_STGDB";
