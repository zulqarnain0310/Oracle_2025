--------------------------------------------------------
--  DDL for Procedure TRESHOLDQUICKSERACHSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" 
-- =============================================
 -- Author:		<HAMID>
 -- Create date: <09 MAY 2019>
 -- Description:	<TO GET A  LIST OF Treshold Quick Serach>
 -- =============================================

(
  --DECLARE		
  v_Location IN CHAR DEFAULT 'HO' ,
  v_LocationCode IN VARCHAR2 DEFAULT '3064' ,
  v_MasterNameAlt_Key IN NUMBER DEFAULT 0 ,
  iv_EffectiveDt IN VARCHAR2 DEFAULT ' ' ,
  v_Timekey IN NUMBER DEFAULT 49999 ,
  v_OperationFlag IN NUMBER DEFAULT 0 
)
AS
   v_EffectiveDt VARCHAR2(10) := iv_EffectiveDt;
   --,DB.BranchName
   --,DR.RegionName
   --,DZ.ZoneName
   --END
   v_MaxEffectiveDt VARCHAR2(200);
   /*******************************************************************************************

   					LOCATION NAME 

   	*******************************************************************************************/
   v_LocationName VARCHAR2(4000);
   /***********************************************************************************************************
   							FINAL SELECT CLAUSE
   	***********************************************************************************************************/
   v_cursor SYS_REFCURSOR;
    V_COUNT VARCHAR(20);
BEGIN
    

   v_EffectiveDt := UTILS.CONVERT_TO_VARCHAR2(v_EffectiveDt,200,p_style=>103) ;
   IF ( v_EffectiveDt = '1900-01-01'
     OR v_EffectiveDt = '01/01/1900' ) THEN

   BEGIN
      v_EffectiveDt := NULL ;

   END;
   END IF;
   SELECT COUNT(1) INTO V_COUNT FROM DimThresholdMaster;
   IF V_COUNT>0
   THEN
    EXECUTE IMMEDIATE ('TRUNCATE TABLE DimThresholdMaster');
    END IF;
   UTILS.IDENTITY_RESET('DimThresholdMaster');

   INSERT INTO DimThresholdMaster( Threshold_SetId,LOCATION,LocationCode ,MasterNameAlt_Key ,EffectiveDt,IsEditable,AuthorisationStatus,CrModApBy,ISMAINTABLE)
   	SELECT A.Threshold_SetId ,
           Location ,
           LocationCode ,
           MasterNameAlt_Key ,
           --,MasterAlt_Key
           EffectiveDt ,
           UTILS.CONVERT_TO_CHAR(0,1) IsEditable  ,
           NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
           NVL(A.ModifiedBy, A.CreatedBy) CrModApBy  ,
           'N' IsMainTable  
   	  FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster_Mod A
             JOIN ( SELECT Threshold_SetId ,
                           MAX(ThresHold_Key)  ThresHold_Key  
                    FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster_Mod 
                     WHERE
                    --EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey 
                     --AND 
                      AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                        AND Location = 'HO'
                        AND LocationCode = v_LocationCode
                        AND MasterNameAlt_Key = CASE 
                                                     WHEN v_MasterNameAlt_Key = 0 THEN MasterNameAlt_Key
                      ELSE v_MasterNameAlt_Key
                         END
                      GROUP BY Threshold_SetId ) B   ON A.Threshold_SetId = B.Threshold_SetId
   	  GROUP BY A.Threshold_SetId,Location,LocationCode,MasterNameAlt_Key,EffectiveDt,AuthorisationStatus,NVL(A.AuthorisationStatus, 'A'),NVL(A.ModifiedBy, A.CreatedBy);
   --IF @OperationFlag<>16
   --BEGIN
   INSERT INTO DimThresholdMaster(Threshold_SetId ,
              Location ,
              LocationCode ,
              MasterNameAlt_Key ,
              EffectiveDt ,
              IsEditable  ,
              AuthorisationStatus  ,
              CrModApBy  ,
              IsMainTable  )
     ( SELECT A.Threshold_SetId ,
              Location ,
              LocationCode ,
              --,CASE WHEN A.Location='HO' THEN 'HO' WHEN A.Location='BO' THEN DB.BranchName WHEN A.Location='RO' THEN DR.RegionName WHEN A.Location='ZO' THEN DZ.ZoneName END  LocationCode
              MasterNameAlt_Key ,
              --,MasterAlt_Key
              EffectiveDt ,
              UTILS.CONVERT_TO_CHAR(0,1) IsEditable  ,
              NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
              NVL(A.ModifiedBy, A.CreatedBy) CrModApBy  ,
              --,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
              --,NULL ChangeFields
              'Y' IsMainTable  
       FROM ALERT_RBL_MISDB_PROD.DimThresholdMaster A

       --LEFT JOIN DIMBRANCH DB

       --	ON A.LocationCode=DB.BranchCode

       --	AND (DB.EffectiveFromTimeKey<=@Timekey AND DB.EffectiveToTimeKey>=@Timekey)

       --LEFT JOIN DimRegion DR

       --	ON (DR.EffectiveFromTimeKey<=@Timekey AND DR.EffectiveToTimeKey>=@Timekey)

       --	AND DR.RegionAlt_Key=A.LocationCode

       --LEFT JOIN DimZone DZ

       --	ON (DZ.EffectiveFromTimeKey<=@Timekey AND DZ.EffectiveToTimeKey>=@Timekey)

       --	AND DZ.ZoneAlt_Key=A.LocationCode
       WHERE
       --EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
        --AND 
         NVL(A.AuthorisationStatus, 'A') = 'A'

           --and Location = @Location 
           AND LocationCode = v_LocationCode
           AND MasterNameAlt_Key = CASE 
                                        WHEN v_MasterNameAlt_Key = 0 THEN MasterNameAlt_Key
         ELSE v_MasterNameAlt_Key
            END
         GROUP BY A.Threshold_SetId,Location,LocationCode,MasterNameAlt_Key,EffectiveDt,NVL(A.AuthorisationStatus, 'A'),NVL(A.ModifiedBy, A.CreatedBy) );
   SELECT MAX(UTILS.CONVERT_TO_VARCHAR2(EffectiveDt,200,p_style=>103))  

     INTO v_MaxEffectiveDt
     FROM DimThresholdMaster ;
   /*******************************************************************************************

   					UPDATING ISEDITABLE COLUMN 

   	*******************************************************************************************/
   MERGE INTO DimThresholdMaster A 
   USING (SELECT A.ROWID row_id, 1
   FROM DimThresholdMaster A
          JOIN ( SELECT DimThresholdMaster.Location ,
                        DimThresholdMaster.LocationCode ,
                        DimThresholdMaster.MasterNameAlt_Key ,
                        MAX(DimThresholdMaster.EffectiveDt)  EffectiveDt  
                 FROM DimThresholdMaster 
                   GROUP BY DimThresholdMaster.Location,DimThresholdMaster.LocationCode,DimThresholdMaster.MasterNameAlt_Key ) B   ON A.Location = B.Location
          AND A.LocationCode = B.LocationCode
          AND A.MasterNameAlt_Key = B.MasterNameAlt_Key
          AND A.EffectiveDt = B.EffectiveDt ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET IsEditable = 1;
   IF v_Location = 'HO' THEN

   BEGIN
      v_LocationName := 'Head Office' ;

   END;
   ELSE
      IF v_Location = 'ZO' THEN

      BEGIN
         SELECT ZoneName 

           INTO v_LocationName
           FROM RBL_MISDB_PROD.DimZone 
          WHERE  EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey
                   AND ZoneAlt_Key = v_LocationCode;

      END;
      ELSE
         IF v_Location = 'RO' THEN

         BEGIN
            SELECT RegionName 

              INTO v_LocationName
              FROM RBL_MISDB_PROD.DimRegion 
             WHERE  EffectiveFromTimeKey <= v_Timekey
                      AND EffectiveToTimeKey >= v_Timekey
                      AND RegionAlt_Key = v_LocationCode;

         END;
         ELSE
            IF v_Location = 'BO' THEN

            BEGIN
               SELECT BranchName 

                 INTO v_LocationName
                 FROM RBL_MISDB_PROD.DimBranch 
                WHERE  EffectiveFromTimeKey <= v_Timekey
                         AND EffectiveToTimeKey >= v_Timekey
                         AND BranchCode = v_LocationCode;

            END;
            END IF;
         END IF;
      END IF;
   END IF;
   OPEN  v_cursor FOR
      SELECT Threshold_SetId ,
             v_Location Location  ,
             v_LocationCode LocationCode  ,
             v_LocationName LocationName  ,
             M.MasterNameAlt_Key MasterAlt_Key  ,
             M.MasterName ,
             UTILS.CONVERT_TO_VARCHAR2(EffectiveDt,10,p_style=>103) EffectiveDt  ,
             NVL(D.IsEditable, 0) IsEditable  ,
             D.AuthorisationStatus ,
             D.CrModApBy ,
             --,D.D2Ktimestamp
             --,D.ChangeFields
             D.IsMainTable 
        FROM ALERT_RBL_MISDB_PROD.DImMasterName M
               LEFT JOIN DimThresholdMaster D   ON M.MasterNameAlt_Key = D.MasterNameAlt_Key
       WHERE  M.MasterNameAlt_Key = CASE 
                                         WHEN NVL(v_MasterNameAlt_Key, 0) = 0 THEN M.MasterNameAlt_Key
              ELSE v_MasterNameAlt_Key
                 END
                AND NVL(D.EffectiveDt, ' ') = CASE 
                                                   WHEN NVL(v_EffectiveDt, ' ') = ' ' THEN NVL(D.EffectiveDt, ' ')
              ELSE v_EffectiveDt
                 END
                AND M.ThresholdName NOT IN ( 'Activity Group','Activity Sub Group','Constitution Group','Constitution Sub Group','Asset Classification Group','Asset Classification Sub Group','Sector Group','Sector Sub Group' -- changes for coming duplicate data for specific master. 
               )

        ORDER BY M.MasterNameAlt_Key,
                 UTILS.CONVERT_TO_VARCHAR2(D.EffectiveDt,200,p_style=>103) DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDQUICKSERACHSELECT" TO "ADF_CDR_RBL_STGDB";
