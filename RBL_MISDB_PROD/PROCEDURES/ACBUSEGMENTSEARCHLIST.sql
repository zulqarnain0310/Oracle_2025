--------------------------------------------------------
--  DDL for Procedure ACBUSEGMENTSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" 
--exec [ACBUSegmentSearchList] '','','','',20

(
  --Declare
  v_SourceAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_ACBUSegmentCode IN VARCHAR2 DEFAULT ' ' ,
  v_AcBuRevisedSegmentCode IN VARCHAR2 DEFAULT ' ' ,
  v_ACBUSegmentDescription IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_MenuID IN NUMBER DEFAULT 24703 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_SQLCODE VARCHAR(1000);
   v_SQLERRM VARCHAR(1000);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   BEGIN

      BEGIN
         --Declare
         --@PageNo         INT         = 1, 
         --@PageSize       INT         = 10, 
         --select * from 	SysCRisMacMenu where menucaption like '%Product%'				
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..GTT_TEMP') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP ';
            END IF;
            DELETE FROM GTT_TEMP;
            UTILS.IDENTITY_RESET('GTT_TEMP');

            INSERT INTO GTT_TEMP ( 
            	SELECT A.SourceAlt_Key ,
                    SourceName ,
                    ACBUSegmentCode ,
                    ACBUSegmentDescription ,
                    AcBuRevisedSegmentCode ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifyBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    AcBuSegmentAlt_Key ,
                    AcBuSegment_Key ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.ChangeFields 
            	  FROM ( SELECT A.SourceAlt_Key ,
                             SourceName ,
                             ACBUSegmentCode ,
                             ACBUSegmentDescription ,
                             AcBuRevisedSegmentCode ,
                             RTRIM(LTRIM(A.AuthorisationStatus)) AuthorisationStatus ,--- changed on 15/07/2024 by kapil, Previously it was                 ,A.AuthorisationStatus

                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifyBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             AcBuSegmentAlt_Key ,
                             AcBuSegment_Key ,
                             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifyBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             ' ' ChangeFields  
                      FROM DimAcBuSegment A
                             LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.SourceAlt_Key ,
                             SourceName ,
                             ACBUSegmentCode ,
                             ACBUSegmentDescription ,
                             AcBuRevisedSegmentCode ,
                             RTRIM(LTRIM(A.AuthorisationStatus)) AuthorisationStatus ,--- changed on 15/07/2024 by kapil, Previously it was                 ,A.AuthorisationStatus

                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifyBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             AcBuSegmentAlt_Key ,
                             AcBuSegment_Key ,
                             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedByFirstLevel, A.ModifyBy) ModAppBy  ,
                             NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                             A.ChangeFields 
                      FROM DimAcBuSegment_Mod A
                             LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.AcBuSegment_Key IN ( SELECT MAX(AcBuSegment_Key)  
                                                           FROM DimAcBuSegment_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                             GROUP BY AcBuSegment_Key )
                     ) A
            	  GROUP BY A.SourceAlt_Key,SourceName,ACBUSegmentCode,ACBUSegmentDescription,AcBuRevisedSegmentCode,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifyBy,A.DateModified,A.ApprovedBy,A.DateApproved,AcBuSegmentAlt_Key,AcBuSegment_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
            OPEN  v_cursor FOR
               SELECT RowNumber,TotalCount,TableName,SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ACBUSegmentAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'AccountBusinessSegmentMaster' TableName  ,
                               SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS
                        FROM ( SELECT SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS
 
                               FROM GTT_TEMP A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..GTT_TEMP2') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP2 ';
               END IF;
               DELETE FROM GTT_TEMP2;
               UTILS.IDENTITY_RESET('GTT_TEMP2');

               INSERT INTO GTT_TEMP2 ( 
               	SELECT A.SourceAlt_Key ,
                       SourceName ,
                       ACBUSegmentCode ,
                       ACBUSegmentDescription ,
                       AcBuRevisedSegmentCode ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifyBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       AcBuSegmentAlt_Key ,
                       AcBuSegment_Key ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.ChangeFields 
               	  FROM ( SELECT A.SourceAlt_Key ,
                                SourceName ,
                                ACBUSegmentCode ,
                                ACBUSegmentDescription ,
                                AcBuRevisedSegmentCode ,
                                RTRIM(LTRIM(A.AuthorisationStatus)) AuthorisationStatus ,--- changed on 15/07/2024 by kapil, Previously it was                 ,A.AuthorisationStatus

                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifyBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                AcBuSegmentAlt_Key ,
                                AcBuSegment_Key ,
                                -- ,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
                                --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                                --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
                                --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
                                --,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
                                --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                                NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedByFirstLevel, A.ModifyBy) ModAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                A.ChangeFields 
                         FROM DimAcBuSegment_Mod A
                                LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.AcBuSegment_Key IN ( SELECT MAX(AcBuSegment_Key)  
                                                              FROM DimAcBuSegment_Mod 
                                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                                        AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                                GROUP BY AcBuSegment_Key )
                        ) A
               	  GROUP BY A.SourceAlt_Key,SourceName,ACBUSegmentCode,ACBUSegmentDescription,AcBuRevisedSegmentCode,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifyBy,A.DateModified,A.ApprovedBy,A.DateApproved,AcBuSegmentAlt_Key,AcBuSegment_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
               OPEN  v_cursor FOR
                  SELECT RowNumber,TotalCount,TableName,SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcBuSegmentAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AccountBusinessSegmentMaster' TableName  ,
                                  SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS 
                           FROM ( SELECT SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS
                                  FROM GTT_TEMP2 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  IF utils.object_id('TempDB..GTT_TEMP3') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP3 ';
                  END IF;
                  DELETE FROM GTT_TEMP3;
                  UTILS.IDENTITY_RESET('GTT_TEMP3');

                  INSERT INTO GTT_TEMP3 ( 
                  	SELECT A.SourceAlt_Key ,
                          SourceName ,
                          ACBUSegmentCode ,
                          ACBUSegmentDescription ,
                          AcBuRevisedSegmentCode ,
                          RTRIM(LTRIM(A.AuthorisationStatus)) AuthorisationStatus ,--- changed on 15/07/2024 by kapil, Previously it was                 ,A.AuthorisationStatus

                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifyBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          AcBuSegmentAlt_Key ,
                          AcBuSegment_Key ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate ,
                          A.ChangeFields 
                  	  FROM ( SELECT A.SourceAlt_Key ,
                                   SourceName ,
                                   ACBUSegmentCode ,
                                   ACBUSegmentDescription ,
                                   AcBuRevisedSegmentCode ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifyBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   AcBuSegmentAlt_Key ,
                                   AcBuSegment_Key ,
                                   -- ,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
                                   --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                                   --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
                                   --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
                                   --,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
                                   --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                                   NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.ModifyBy) ModAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                   A.ChangeFields 
                            FROM DimAcBuSegment_Mod A
                                   LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                                      AND A.AcBuSegment_Key IN ( SELECT MAX(AcBuSegment_Key)  
                                                                 FROM DimAcBuSegment_Mod 
                                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                           AND EffectiveToTimeKey >= v_TimeKey

                                                                           --AND AuthorisationStatus IN('1A')
                                                                           AND (CASE 
                                                                                     WHEN v_AuthLevel = 2
                                                                                       AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                  	 THEN 1
                  	WHEN v_AuthLevel = 1
                  	  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                  	 THEN 1
                                                                         ELSE 0
                                                                            END) = 1
                                                                   GROUP BY AcBuSegment_Key )
                           ) A
                  	  GROUP BY A.SourceAlt_Key,SourceName,ACBUSegmentCode,ACBUSegmentDescription,AcBuRevisedSegmentCode,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifyBy,A.DateModified,A.ApprovedBy,A.DateApproved,AcBuSegmentAlt_Key,AcBuSegment_Key,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                  OPEN  v_cursor FOR
                     SELECT RowNumber,TotalCount,TableName,SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AcBuSegmentAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'AccountBusinessSegmentMaster' TableName  ,
                                     SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS 
                              FROM ( SELECT SOURCEALT_KEY,	SOURCENAME,	ACBUSEGMENTCODE,	ACBUSEGMENTDESCRIPTION,	ACBUREVISEDSEGMENTCODE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFYBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	ACBUSEGMENTALT_KEY,	ACBUSEGMENT_KEY,	CRMODBY,	CRMODDATE,	CRAPPBY,	CRAPPDATE,	MODAPPBY,	MODAPPDATE,	CHANGEFIELDS 
                                     FROM GTT_TEMP3 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
            END IF;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLCODE:=SQLCODE;
   v_SQLERRM:=SQLERRM;
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
      INSERT INTO RBL_MISDB_PROD.Error_Log(ERRORLINE,	ERRORMESSAGE,	ERRORNUMBER,	ERRORPROCEDURE,	ERRORSEVERITY,	ERRORSTATE,	ERRORDATETIME)
        SELECT utils.error_line ErrorLine  ,
                 v_SQLERRM ErrorMessage  ,
                 v_SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  ;
      OPEN  v_cursor FOR
         SELECT v_SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
