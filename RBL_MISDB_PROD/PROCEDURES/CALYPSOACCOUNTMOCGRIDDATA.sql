--------------------------------------------------------
--  DDL for Procedure CALYPSOACCOUNTMOCGRIDDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
   -- SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   IF ( v_OperationFlag = 20 ) THEN

   BEGIN
      DELETE FROM GTT_INT1;
      UTILS.IDENTITY_RESET('GTT_INT1');

      INSERT INTO GTT_INT1 SELECT * 
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
                         NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                         NVL(DateApproved, DateCreated) CrAppDate  ,
                         NVL(ApprovedBy, ModifyBy) ModAppBy  ,
                         NVL(DateApproved, DateModified) ModAppDate  
                  FROM ExcelUploadHistory 
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                            AND EffectiveToTimeKey >= v_Timekey
                            AND UploadType = CASE 
                                                  WHEN v_Menuid = 27767 THEN 'Calypso Account MOC Upload'
                          ELSE NULL
                             END ) A
           ORDER BY DateofUpload DESC,
                    CASE 
                         WHEN AuthorisationStatus = 'NP' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                         WHEN AuthorisationStatus = 'A' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                         WHEN AuthorisationStatus = 'R' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                         WHEN AuthorisationStatus = '1A' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                    ELSE CAST((ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  )) AS VARCHAR(1000)) 
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
           FROM GTT_INT1 
          WHERE  AuthorisationStatus NOT IN ( 'Authorized','Rejected','Pending' )

           ORDER BY CASE 
                         WHEN AuthorisationStatus = 'Pending' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                         WHEN AuthorisationStatus = 'Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                         WHEN AuthorisationStatus = 'Rejected' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                         WHEN AuthorisationStatus = '1Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                    ELSE CAST((ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  )) AS VARCHAR(1000)) 
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
         DELETE FROM GTT_INT;
         UTILS.IDENTITY_RESET('GTT_INT');

         INSERT INTO GTT_INT SELECT * 
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
                            NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                            NVL(DateApproved, DateCreated) CrAppDate  ,
                            NVL(ApprovedBy, ModifyBy) ModAppBy  ,
                            NVL(DateApproved, DateModified) ModAppDate  
                     FROM ExcelUploadHistory 
                      WHERE  EffectiveFromTimeKey <= v_Timekey
                               AND EffectiveToTimeKey >= v_Timekey
                               AND UploadType = CASE 
                                                     WHEN v_Menuid = 27767 THEN 'Calypso Account MOC Upload'
                             ELSE NULL
                                END ) A
              ORDER BY DateofUpload DESC,
                       CASE 
                            WHEN AuthorisationStatus = 'NP' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                            WHEN AuthorisationStatus = 'A' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                            WHEN AuthorisationStatus = 'R' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                            WHEN AuthorisationStatus = '1A' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                       ELSE CAST((ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  )) AS VARCHAR(1000)) 
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
              FROM GTT_INT 
             WHERE  AuthorisationStatus NOT IN ( 'Authorized','Rejected','1Authorized' )

              ORDER BY CASE 
                            WHEN AuthorisationStatus = 'Pending' THEN UTILS.CONVERT_TO_VARCHAR2(1,50)
                            WHEN AuthorisationStatus = 'Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(2,50)
                            WHEN AuthorisationStatus = 'Rejected' THEN UTILS.CONVERT_TO_VARCHAR2(3,50)
                            WHEN AuthorisationStatus = '1Authorized' THEN UTILS.CONVERT_TO_VARCHAR2(4,50)
                       ELSE CAST((ROW_NUMBER() OVER ( ORDER BY (AuthorisationStatus) || UTILS.CONVERT_TO_VARCHAR2(4,50)  )) AS VARCHAR(1000)) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTMOCGRIDDATA" TO "ADF_CDR_RBL_STGDB";
