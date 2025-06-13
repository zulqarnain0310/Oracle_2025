--------------------------------------------------------
--  DDL for Procedure ACCOUNTFLAGGINGGRIDDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" 
(
  iv_Timekey IN NUMBER,
  v_UserLoginId IN VARCHAR2,
  v_Menuid IN NUMBER,
  v_Operationflag IN NUMBER
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=49999
--	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
--	,@Menuid INT=161

BEGIN

   SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

     INTO v_Timekey
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
   IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
      ACLProcessStatusCheck() ;

   END;
   END IF;
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
                                                  WHEN v_Menuid = 1470 THEN 'Account Flagging Upload'
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
                                                     WHEN v_Menuid = 1470 THEN 'Account Flagging Upload'
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
            DBMS_SQL.RETURN_RESULT(v_cursor);/*Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
           where  Date=cast(getdate() as Date)

             PRINT @Timekey  


           SELECT * INTO GTT_INT FROM(
            SELECT  UniqueUploadID,UploadedBy
            ,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,
            --,DateofUpload,
            CASE WHEN  AuthorisationStatus='A' THEN 'Authorized'
         		WHEN   AuthorisationStatus='R' THEN 'Rejected'
         		WHEN  AuthorisationStatus='NP' THEN 'Pending' ELSE NULL END AS AuthorisationStatus
         	---,Action
         	,UploadType

            FROM ExcelUploadHistory
            WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            and UploadType =CASE WHEN @Menuid=1470 THEN'Account Flagging Upload'
         						ELSE  NULL END 
            )   A
            ORDER BY DateofUpload  DESC,CASE WHEN AuthorisationStatus='NP' THEN CAST(1 AS VARCHAR(50))
                                         WHEN AuthorisationStatus='A' THEN CAST(2 AS VARCHAR(50))
                                         WHEN AuthorisationStatus='R' THEN CAST(3 AS VARCHAR(50))
                                         ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(3 AS VARCHAR(50)))) 
                                         END ASC





                                         SELECT UniqueUploadID ,UploadedBy,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload,AuthorisationStatus,UploadType
                                         FROM GTT_INT Where AuthorisationStatus Not In ('Authorized','Rejected')
                                          ORDER BY CASE WHEN AuthorisationStatus='Pending' THEN CAST(1 AS VARCHAR(50))
                                         WHEN AuthorisationStatus='Authorized' THEN CAST(2 AS VARCHAR(50))
                                         WHEN AuthorisationStatus='Rejected' THEN CAST(3 AS VARCHAR(50))
                                         ELSE (ROW_NUMBER () OVER(ORDER BY(AuthorisationStatus)+CAST(3 AS VARCHAR(50)))) 
                                         END ASC,DateofUpload  DESC,UniqueUploadID Desc



         END */

      END;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGGRIDDATA" TO "ADF_CDR_RBL_STGDB";
