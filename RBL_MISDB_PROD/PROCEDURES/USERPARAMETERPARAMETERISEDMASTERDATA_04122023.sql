--------------------------------------------------------
--  DDL for Procedure USERPARAMETERPARAMETERISEDMASTERDATA_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" 
--Select Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --UserParameterParameterisedMasterData 16
 --USE YES_MISDB
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14551 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551

BEGIN

   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..tt_temp_301') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_301 ';
            END IF;
            DELETE FROM tt_temp_301;
            UTILS.IDENTITY_RESET('tt_temp_301');

            INSERT INTO tt_temp_301 ( 
            	SELECT A.ShortNameEnum ,
                    A.ParameterType ,
                    A.ParameterValue ,
                    A.SeqNo ,
                    A.MinValue ,
                    A.MaxValue ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifyBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.IsMainTable ,
                    A.CreatedModifiedBy 
            	  FROM ( SELECT U.ShortNameEnum ,
                             U.ParameterType ,
                             U.ParameterValue ,
                             U.SeqNo ,
                             U.MinValue ,
                             U.MaxValue ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.CreatedBy) CrAppBy  ,
                             NVL(U.DateApproved, U.DateCreated) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             'N' IsMainTable  ,
                             CASE 
                                  WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                             ELSE U.ModifyBy
                                END CreatedModifiedBy  

                      --select *
                      FROM DimUserParameters U
                       WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND NVL(U.AuthorisationStatus, 'A') = 'A'
                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserParameters 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                                                       GROUP BY ShortNameEnum )

                      UNION 
                      SELECT U.ShortNameEnum ,
                             U.ParameterType ,
                             U.ParameterValue ,
                             U.SeqNo ,
                             U.MinValue ,
                             U.MaxValue ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             'N' IsMainTable  ,
                             CASE 
                                  WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                             ELSE U.ModifyBy
                                END CreatedModifiedBy  

                      --select *
                      FROM DimUserParameters_mod U
                       WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND NVL(U.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserParameters_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY ShortNameEnum )
                     ) A
            	  GROUP BY A.ShortNameEnum,A.ParameterType,A.ParameterValue,A.SeqNo,A.MinValue,A.MaxValue,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.IsMainTable,A.CreatedModifiedBy );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ShortNameEnum  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'UserPolicyTable' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_301 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT CtrlName ,
                      FldName ,
                      FldCaption ,
                      FldDataType ,
                      FldLength ,
                      ErrorCheck ,
                      DataSeq ,
                      CriticalErrorType ,
                      MsgFlag ,
                      MsgDescription ,
                      ReportFieldNo ,
                      ScreenFieldNo ,
                      ViableForSCD2 
                 FROM metaUserFieldDetail 
                WHERE  FrmName = 'frmUserPolicy' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT MsgDescription ,
                      ParameterType ,
                      ParameterValue ,
                      MinValue ,
                      MaxValue ,
                      IsMainTable ,
                      CreatedModifiedBy ,
                      --,SeqNo
                      'HO' UserLocation  ,
                      dimUser.AuthorisationStatus ,
                      dimUser.EffectiveFromTimeKey ,
                      dimUser.EffectiveToTimeKey ,
                      dimUser.CreatedBy ,
                      dimUser.DateCreated ,
                      dimUser.ApprovedBy ,
                      dimUser.DateApproved ,
                      dimUser.ModifyBy ,
                      dimUser.DateModified ,
                      dimUser.CrModBy ,
                      dimUser.CrModDate ,
                      dimUser.CrAppBy ,
                      dimUser.CrAppDate ,
                      dimUser.ModAppBy ,
                      dimUser.ModAppDate ,
                      dimUser.IsMainTable ,
                      dimUser.CreatedModifiedBy 
                 FROM metaUserFieldDetail meta
                        JOIN tt_temp_301 dimUser   ON meta.FldCaption = dimUser.ShortNameEnum

               --left join DimUserInfo D

               --ON D.UserLoginID=dimuser.CreatedModifiedBy
               WHERE  FrmName = 'frmUserPolicy'
                        AND ( dimUser.EffectiveFromTimeKey <= v_TimeKey
                        AND dimUser.EffectiveToTimekey >= v_TimeKey )

               --AND SeqNo IN (1,6)
               GROUP BY MsgDescription,ParameterType,ParameterValue,MinValue,MaxValue,IsMainTable,CreatedModifiedBy,SeqNo,dimUser.AuthorisationStatus,dimUser.EffectiveFromTimeKey,dimUser.EffectiveToTimeKey,dimUser.CreatedBy,dimUser.DateCreated,dimUser.ApprovedBy,dimUser.DateApproved,dimUser.ModifyBy,dimUser.DateModified,dimUser.CrModBy,dimUser.CrModDate,dimUser.CrAppBy,dimUser.CrAppDate,dimUser.ModAppBy,dimUser.ModAppDate,dimUser.IsMainTable,dimUser.CreatedModifiedBy
                 ORDER BY SeqNo ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_30116') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_246 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Sac16');
               DELETE FROM tt_temp16_246;
               UTILS.IDENTITY_RESET('tt_temp16_246');

               INSERT INTO tt_temp16_246 ( 
               	SELECT A.ShortNameEnum ,
                       A.ParameterType ,
                       A.ParameterValue ,
                       A.SeqNo ,
                       A.MinValue ,
                       A.MaxValue ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifyBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.IsMainTable ,
                       A.CreatedModifiedBy 
               	  FROM ( SELECT U.ShortNameEnum ,
                                U.ParameterType ,
                                U.ParameterValue ,
                                U.SeqNo ,
                                U.MinValue ,
                                U.MaxValue ,
                                --,'QuickSearchTable' as TableName
                                NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                U.EffectiveFromTimeKey ,
                                U.EffectiveToTimeKey ,
                                U.CreatedBy ,
                                U.DateCreated ,
                                U.ApprovedBy ,
                                U.DateApproved ,
                                U.ModifyBy ,
                                U.DateModified ,
                                NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                                NVL(U.DateModified, U.DateCreated) CrModDate  ,
                                NVL(U.ApprovedBy, U.CreatedBy) CrAppBy  ,
                                NVL(U.DateApproved, U.DateCreated) CrAppDate  ,
                                NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                                NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                                'N' IsMainTable  ,
                                CASE 
                                     WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                                ELSE U.ModifyBy
                                   END CreatedModifiedBy  

                         --select *
                         FROM DimUserParameters U
                          WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                   AND U.EffectiveToTimeKey >= v_TimeKey

                                   --AND ShortNameEnum in('NONUSE','UNLOGON')
                                   AND NVL(U.AuthorisationStatus, 'A') = 'A'
                                   AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimUserParameters 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                                                          GROUP BY ShortNameEnum )

                         UNION 
                         SELECT U.ShortNameEnum ,
                                U.ParameterType ,
                                U.ParameterValue ,
                                U.SeqNo ,
                                U.MinValue ,
                                U.MaxValue ,
                                --,'QuickSearchTable' as TableName
                                NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                U.EffectiveFromTimeKey ,
                                U.EffectiveToTimeKey ,
                                U.CreatedBy ,
                                U.DateCreated ,
                                U.ApprovedBy ,
                                U.DateApproved ,
                                U.ModifyBy ,
                                U.DateModified ,
                                NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                                NVL(U.DateModified, U.DateCreated) CrModDate  ,
                                NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                                NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                                NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                                NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                                'N' IsMainTable  ,
                                CASE 
                                     WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                                ELSE U.ModifyBy
                                   END CreatedModifiedBy  

                         --select *
                         FROM DimUserParameters_mod U
                          WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                   AND U.EffectiveToTimeKey >= v_TimeKey

                                   --AND ShortNameEnum in('NONUSE','UNLOGON')
                                   AND NVL(U.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                   AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimUserParameters_mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                          GROUP BY ShortNameEnum )
                        ) A
               	  GROUP BY A.ShortNameEnum,A.ParameterType,A.ParameterValue,A.SeqNo,A.MinValue,A.MaxValue,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.IsMainTable,A.CreatedModifiedBy );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ShortNameEnum  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'UserPolicyTable' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_246 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               OPEN  v_cursor FOR
                  SELECT CtrlName ,
                         FldName ,
                         FldCaption ,
                         FldDataType ,
                         FldLength ,
                         ErrorCheck ,
                         DataSeq ,
                         CriticalErrorType ,
                         MsgFlag ,
                         MsgDescription ,
                         ReportFieldNo ,
                         ScreenFieldNo ,
                         ViableForSCD2 
                    FROM metaUserFieldDetail 
                   WHERE  FrmName = 'frmUserPolicy' ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               OPEN  v_cursor FOR
                  SELECT MsgDescription ,
                         ParameterType ,
                         ParameterValue ,
                         MinValue ,
                         MaxValue ,
                         IsMainTable ,
                         CreatedModifiedBy ,
                         --,SeqNo
                         'HO' UserLocation  ,
                         dimUser.AuthorisationStatus ,
                         dimUser.EffectiveFromTimeKey ,
                         dimUser.EffectiveToTimeKey ,
                         dimUser.CreatedBy ,
                         dimUser.DateCreated ,
                         dimUser.ApprovedBy ,
                         dimUser.DateApproved ,
                         dimUser.ModifyBy ,
                         dimUser.DateModified ,
                         dimUser.CrModBy ,
                         dimUser.CrModDate ,
                         dimUser.CrAppBy ,
                         dimUser.CrAppDate ,
                         dimUser.ModAppBy ,
                         dimUser.ModAppDate ,
                         dimUser.IsMainTable ,
                         dimUser.CreatedModifiedBy 
                    FROM metaUserFieldDetail meta
                           JOIN tt_temp16_246 dimUser   ON meta.FldCaption = dimUser.ShortNameEnum

                  --left join DimUserInfo D

                  --ON D.UserLoginID=dimuser.CreatedModifiedBy
                  WHERE  FrmName = 'frmUserPolicy'
                           AND ( dimUser.EffectiveFromTimeKey <= v_TimeKey
                           AND dimUser.EffectiveToTimekey >= v_TimeKey )

                  --AND SeqNo IN (1,6)
                  GROUP BY MsgDescription,ParameterType,ParameterValue,MinValue,MaxValue,IsMainTable,CreatedModifiedBy,SeqNo,dimUser.AuthorisationStatus,dimUser.EffectiveFromTimeKey,dimUser.EffectiveToTimeKey,dimUser.CreatedBy,dimUser.DateCreated,dimUser.ApprovedBy,dimUser.DateApproved,dimUser.ModifyBy,dimUser.DateModified,dimUser.CrModBy,dimUser.CrModDate,dimUser.CrAppBy,dimUser.CrAppDate,dimUser.ModAppBy,dimUser.ModAppDate,dimUser.IsMainTable,dimUser.CreatedModifiedBy
                    ORDER BY SeqNo ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize)
         IF ( v_OperationFlag IN ( 20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_30120') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_211 ';
            END IF;
            DELETE FROM tt_temp20_211;
            UTILS.IDENTITY_RESET('tt_temp20_211');

            INSERT INTO tt_temp20_211 ( 
            	SELECT A.ShortNameEnum ,
                    A.ParameterType ,
                    A.ParameterValue ,
                    A.SeqNo ,
                    A.MinValue ,
                    A.MaxValue ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifyBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.IsMainTable ,
                    A.CreatedModifiedBy 
            	  FROM ( SELECT U.ShortNameEnum ,
                             U.ParameterType ,
                             U.ParameterValue ,
                             U.SeqNo ,
                             U.MinValue ,
                             U.MaxValue ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.CreatedBy) CrAppBy  ,
                             NVL(U.DateApproved, U.DateCreated) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             'N' IsMainTable  ,
                             CASE 
                                  WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                             ELSE U.ModifyBy
                                END CreatedModifiedBy  

                      --select *
                      FROM DimUserParameters U
                       WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND NVL(U.AuthorisationStatus, 'A') = 'A'
                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserParameters 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                                                       GROUP BY ShortNameEnum )

                      UNION 
                      SELECT U.ShortNameEnum ,
                             U.ParameterType ,
                             U.ParameterValue ,
                             U.SeqNo ,
                             U.MinValue ,
                             U.MaxValue ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             'N' IsMainTable  ,
                             CASE 
                                  WHEN NVL(U.ModifyBy, ' ') = ' ' THEN U.CreatedBy
                             ELSE U.ModifyBy
                                END CreatedModifiedBy  

                      --select *
                      FROM DimUserParameters_mod U
                       WHERE  U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND NVL(U.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserParameters_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY ShortNameEnum )
                     ) A
            	  GROUP BY A.ShortNameEnum,A.ParameterType,A.ParameterValue,A.SeqNo,A.MinValue,A.MaxValue,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.IsMainTable,A.CreatedModifiedBy );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ShortNameEnum  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'UserPolicyTable' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp20_211 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT CtrlName ,
                      FldName ,
                      FldCaption ,
                      FldDataType ,
                      FldLength ,
                      ErrorCheck ,
                      DataSeq ,
                      CriticalErrorType ,
                      MsgFlag ,
                      MsgDescription ,
                      ReportFieldNo ,
                      ScreenFieldNo ,
                      ViableForSCD2 
                 FROM metaUserFieldDetail 
                WHERE  FrmName = 'frmUserPolicy' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT MsgDescription ,
                      ParameterType ,
                      ParameterValue ,
                      MinValue ,
                      MaxValue ,
                      IsMainTable ,
                      CreatedModifiedBy ,
                      --,SeqNo
                      'HO' UserLocation  ,
                      dimUser.AuthorisationStatus ,
                      dimUser.EffectiveFromTimeKey ,
                      dimUser.EffectiveToTimeKey ,
                      dimUser.CreatedBy ,
                      dimUser.DateCreated ,
                      dimUser.ApprovedBy ,
                      dimUser.DateApproved ,
                      dimUser.ModifyBy ,
                      dimUser.DateModified ,
                      dimUser.CrModBy ,
                      dimUser.CrModDate ,
                      dimUser.CrAppBy ,
                      dimUser.CrAppDate ,
                      dimUser.ModAppBy ,
                      dimUser.ModAppDate ,
                      dimUser.IsMainTable ,
                      dimUser.CreatedModifiedBy 
                 FROM metaUserFieldDetail meta
                        JOIN tt_temp20_211 dimUser   ON meta.FldCaption = dimUser.ShortNameEnum

               --left join DimUserInfo D

               --ON D.UserLoginID=dimuser.CreatedModifiedBy
               WHERE  FrmName = 'frmUserPolicy'
                        AND ( dimUser.EffectiveFromTimeKey <= v_TimeKey
                        AND dimUser.EffectiveToTimekey >= v_TimeKey )

               --AND SeqNo IN (1,6)
               GROUP BY MsgDescription,ParameterType,ParameterValue,MinValue,MaxValue,IsMainTable,CreatedModifiedBy,SeqNo,dimUser.AuthorisationStatus,dimUser.EffectiveFromTimeKey,dimUser.EffectiveToTimeKey,dimUser.CreatedBy,dimUser.DateCreated,dimUser.ApprovedBy,dimUser.DateApproved,dimUser.ModifyBy,dimUser.DateModified,dimUser.CrModBy,dimUser.CrModDate,dimUser.CrAppBy,dimUser.CrAppDate,dimUser.ModAppBy,dimUser.ModAppDate,dimUser.IsMainTable,dimUser.CreatedModifiedBy
                 ORDER BY SeqNo ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_04122023" TO "ADF_CDR_RBL_STGDB";
