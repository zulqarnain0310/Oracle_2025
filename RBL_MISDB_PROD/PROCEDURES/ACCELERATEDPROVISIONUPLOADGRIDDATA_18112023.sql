--------------------------------------------------------
--  DDL for Procedure ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  iv_Timekey IN NUMBER,
  v_UserLoginId IN VARCHAR2,
  v_Menuid IN NUMBER,
  v_OperationFlag IN NUMBER
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=49999
--	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
--	,@Menuid INT=161

BEGIN

   --Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
   -- where  Date=cast(getdate() as Date)
   --  Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
   --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
   -- where A.CurrentStatus='C')
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   IF ( v_OperationFlag = 20 ) THEN

   BEGIN
      DELETE FROM tt_INT1_3;
      UTILS.IDENTITY_RESET('tt_INT1_3');

      INSERT INTO tt_INT1_3 SELECT * 
           FROM ( SELECT UniqueUploadID ,
                         UploadedBy ,
                         UTILS.CONVERT_TO_VARCHAR2(DateofUpload,10,p_style=>103) DateofUpload  ,
                         --,DateofUpload,
                         CASE 
                              WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                              WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                              WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                              WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                         ELSE NULL
                            END AuthorisationStatus  ,
                         ---,Action
                         UploadType ,
                         NVL(ModifyBy, CreatedBy) CrModBy  ,
                         NVL(DateModified, DateCreated) CrModDate  ,
                         NVL(ApprovedBy, ApprovedByFirstLevel) CrAppBy  ,
                         NVL(DateApproved, DateApprovedFirstLevel) CrAppDate  ,
                         NVL(ApprovedBy, ModifyBy) ModAppBy  ,
                         NVL(DateApproved, DateModified) ModAppDate  
                  FROM ExcelUploadHistory 
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                            AND EffectiveToTimeKey >= v_Timekey
                            AND UploadType = CASE 
                                                  WHEN v_Menuid = 24745 THEN 'Acce Provision Upload'
                          ELSE NULL
                             END ) A
           ORDER BY DateofUpload DESC,
                    CASE 
                         WHEN AuthorisationStatus = 'NP' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                         WHEN AuthorisationStatus = 'A' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                         WHEN AuthorisationStatus = 'R' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                         WHEN AuthorisationStatus = '1A' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                    ELSE (ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  ))
                       END ASC;
      OPEN  v_cursor FOR
         SELECT UniqueUploadID ,
                UploadedBy ,
                UTILS.CONVERT_TO_VARCHAR2(DateofUpload,10,p_style=>103) DateofUpload  ,
                AuthorisationStatus ,
                UploadType ,
                CrModBy ,
                CrModDate ,
                CrAppBy ,
                CrAppDate ,
                ModAppBy ,
                ModAppDate 
           FROM tt_INT1_3 
          WHERE  AuthorisationStatus NOT IN ( 'Authorized','Rejected','Pending' )

           ORDER BY CASE 
                         WHEN AuthorisationStatus = 'Pending' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                         WHEN AuthorisationStatus = 'Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                         WHEN AuthorisationStatus = 'Rejected' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                         WHEN AuthorisationStatus = '1Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                    ELSE (ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  ))
                       END ASC,
                    DateofUpload DESC,
                    UniqueUploadID DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      IF ( v_OperationFlag IN ( 16 )
       ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('1');
         DELETE FROM tt_INT_3;
         UTILS.IDENTITY_RESET('tt_INT_3');

         INSERT INTO tt_INT_3 SELECT * 
              FROM ( SELECT UniqueUploadID ,
                            UploadedBy ,
                            UTILS.CONVERT_TO_VARCHAR2(DateofUpload,10,p_style=>103) DateofUpload  ,
                            --,DateofUpload,
                            CASE 
                                 WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                                 WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                                 WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                                 WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                            ELSE NULL
                               END AuthorisationStatus  ,
                            ---,Action
                            UploadType ,
                            NVL(ModifyBy, CreatedBy) CrModBy  ,
                            NVL(DateModified, DateCreated) CrModDate  ,
                            NVL(ApprovedBy, ApprovedByFirstLevel) CrAppBy  ,
                            NVL(DateApproved, DateApprovedFirstLevel) CrAppDate  ,
                            NVL(ApprovedBy, ModifyBy) ModAppBy  ,
                            NVL(DateApproved, DateModified) ModAppDate  
                     FROM ExcelUploadHistory 
                      WHERE  EffectiveFromTimeKey <= v_Timekey
                               AND EffectiveToTimeKey >= v_Timekey
                               AND UploadType = CASE 
                                                     WHEN v_Menuid = 24745 THEN 'Acce Provision Upload'
                             ELSE NULL
                                END ) A
              ORDER BY DateofUpload DESC,
                       CASE 
                            WHEN AuthorisationStatus = 'NP' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                            WHEN AuthorisationStatus = 'A' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                            WHEN AuthorisationStatus = 'R' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                            WHEN AuthorisationStatus = '1A' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                       ELSE (ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  ))
                          END ASC;
         OPEN  v_cursor FOR
            SELECT UniqueUploadID ,
                   UploadedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(DateofUpload,10,p_style=>103) DateofUpload  ,
                   AuthorisationStatus ,
                   UploadType ,
                   CrModBy ,
                   CrModDate ,
                   CrAppBy ,
                   CrAppDate ,
                   ModAppBy ,
                   ModAppDate 
              FROM tt_INT_3 
             WHERE  AuthorisationStatus NOT IN ( 'Authorized','Rejected','1Authorized' )

              ORDER BY CASE 
                            WHEN AuthorisationStatus = 'Pending' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                            WHEN AuthorisationStatus = 'Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                            WHEN AuthorisationStatus = 'Rejected' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                            WHEN AuthorisationStatus = '1Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                       ELSE (ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  ))
                          END ASC,
                       DateofUpload DESC,
                       UniqueUploadID DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONUPLOADGRIDDATA_18112023" TO "ADF_CDR_RBL_STGDB";
