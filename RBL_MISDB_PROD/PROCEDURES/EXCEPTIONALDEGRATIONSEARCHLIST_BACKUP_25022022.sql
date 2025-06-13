--------------------------------------------------------
--  DDL for Procedure EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" 
-- exec ExceptionalDegrationSearchList @AccountID=9987880000000003,@operationFlag=1
 --exec ExceptionalDegrationSearchList @AccountID=NULL,@operationFlag=16
 --go
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --declare												--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_AccountID IN VARCHAR2 DEFAULT NULL 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--9987880000000003

 --'9987880000000003'
BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         IF utils.object_id('TempDB..tt_Reminder_5') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Reminder_5 ';
         END IF;
         DELETE FROM tt_Reminder_5;
         UTILS.IDENTITY_RESET('tt_Reminder_5');

         INSERT INTO tt_Reminder_5 ( 
         	SELECT * 
         	  FROM ( SELECT FlagAlt_Key ,
                          AccountID 
                   FROM RBL_MISDB_PROD.ExceptionalDegrationDetail 
                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey
                             AND NVL(AuthorisationStatus, 'A') = 'A'
                   UNION 
                   SELECT FlagAlt_Key ,
                          AccountID 
                   FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey
                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
                  ) A );
         --Select * from tt_Reminder_5
         IF utils.object_id('TempDB..tt_Reminder_5Report') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReminderReport_5 ';
         END IF;
         DELETE FROM tt_ReminderReport_5;
         INSERT INTO tt_ReminderReport_5
           ( FlagAlt_Key, AccountID )
           ( SELECT A.Businesscolvalues1 FlagAlt_Key  ,
                    A.AccountID 
             FROM ( SELECT AccountID ,
                           a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
                    FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(FlagAlt_Key, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                                  AccountID 
                           FROM tt_Reminder_5  ) A
                            /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A
              WHERE  A.Businesscolvalues1 <> ' ' );
         --Select * from tt_Reminder_5Report1
         IF utils.object_id('TempDB..tt_Reminder_5Report1') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReminderReport1_5 ';
         END IF;
         DELETE FROM tt_ReminderReport1_5;
         UTILS.IDENTITY_RESET('tt_ReminderReport1_5');

         INSERT INTO tt_ReminderReport1_5 ( 
         	SELECT A.* ,
                 B.ParameterName FlagName  
         	  FROM tt_ReminderReport_5 A
                   JOIN DimParameter B   ON A.FlagAlt_Key = B.ParameterAlt_Key
         	 WHERE  B.DimParameterName = 'UploadFLagType' );
         --IF OBJECT_ID('TempDB..#Secondary') IS NOT NULL
         --Drop Table #Secondary
         --Select * Into #Secondary From (
         --Select A.AccountID,A.REPORTIDSLIST as FlagName From (
         --SELECT SS.AccountID,
         --                STUFF((SELECT ',' + US.FlagName 
         --                        FROM tt_Reminder_5Report1 US
         --                        WHERE US.AccountID = SS.AccountID 
         --                        FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
         --                FROM tt_Reminder_5Report1 SS 
         --                GROUP BY SS.AccountID
         --                )A
         --        )A
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_138') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_138 ';
            END IF;
            DELETE FROM tt_temp_138;
            UTILS.IDENTITY_RESET('tt_temp_138');

            INSERT INTO tt_temp_138 ( 
            	SELECT A.DegrationAlt_Key ,
                    A.SourceName ,
                    A.SourceAlt_Key ,
                    A.AccountID ,
                    A.RefCustomerId CustomerID  ,
                    A.FlagAlt_Key ,
                    A.FlagName ,
                    A.Date_ ,
                    A.Marking ,
                    A.MarkingAlt_Key ,
                    Amount ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT A.DegrationAlt_Key ,
                             B.SourceName ,
                             C.SourceAlt_Key ,
                             A.AccountID ,
                             C.RefCustomerId ,
                             A.FlagAlt_Key ,
                             S.FlagName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.Date_,20,p_style=>103) Date_  ,
                             H.ParameterName Marking  ,
                             A.MarkingAlt_Key ,
                             Amount ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                             A.ApprovedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM RBL_MISDB_PROD.ExceptionalDegrationDetail A
                             JOIN tt_ReminderReport1_5 S   ON S.AccountID = A.AccountID
                             AND A.FlagAlt_Key = S.FlagAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DimYesNo' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                             JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND A.AccountID = v_AccountID
                      UNION 
                      SELECT A.DegrationAlt_Key ,
                             B.SourceName ,
                             C.SourceAlt_Key ,
                             A.AccountID ,
                             C.RefCustomerId ,
                             A.FlagAlt_Key ,
                             S.FlagName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.Date_,20,p_style=>103) Date_  ,
                             H.ParameterName Marking  ,
                             A.MarkingAlt_Key ,
                             Amount ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                             A.ApprovedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A
                             JOIN tt_ReminderReport1_5 S   ON S.AccountID = A.AccountID
                             AND A.FlagAlt_Key = S.FlagAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DimYesNo' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                             JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND A.AccountID = v_AccountID

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                        GROUP BY AccountID,FlagAlt_Key )
                     ) A
            	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'ExceptionalDegrationDetail' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_138 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize);
         ------------------------------------------------------------------------------
         IF ( v_OperationFlag IN ( 1 )
          ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT EXISTS ( SELECT 1 
                                   FROM tt_temp_138 
                                    WHERE  AccountID = v_AccountID );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT C.SourceSystemAlt_Key ,
                         CustomerID ,
                         SourceName ,
                         'CustomerSourceDetails' TableName  
                    FROM AdvAcBasicDetail A
                           JOIN CustomerBasicDetail C   ON C.CustomerEntityId = A.CustomerEntityId
                           JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = C.SourceSystemAlt_Key
                   WHERE  CustomerACID = v_AccountID
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                            AND C.EffectiveFromTimeKey <= v_TimeKey
                            AND C.EffectiveToTimeKey >= v_TimeKey ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;

         END;

         --select * from CustomerBasicDetail

         --select * from AdvAcBasicDetail

         --------------------------------------------------------------------------------------
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_13816') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_107 ';
               END IF;
               DELETE FROM tt_temp16_107;
               UTILS.IDENTITY_RESET('tt_temp16_107');

               INSERT INTO tt_temp16_107 ( 
               	SELECT A.DegrationAlt_Key ,
                       A.SourceName ,
                       A.SourceAlt_Key ,
                       A.AccountID ,
                       A.RefCustomerId CustomerID  ,
                       A.FlagAlt_Key ,
                       A.FlagName ,
                       A.Date_ ,
                       A.Marking ,
                       A.MarkingAlt_Key ,
                       Amount ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT A.DegrationAlt_Key ,
                                B.SourceName ,
                                C.SourceAlt_Key ,
                                A.AccountID ,
                                C.RefCustomerId ,
                                S.FlagAlt_Key ,
                                S.FlagName ,
                                UTILS.CONVERT_TO_VARCHAR2(A.Date_,20,p_style=>103) Date_  ,
                                H.ParameterName Marking  ,
                                A.MarkingAlt_Key ,
                                Amount ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                                A.ApprovedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                                A.ModifiedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  
                         FROM ExceptionalDegrationDetail_Mod A
                                JOIN tt_ReminderReport1_5 S   ON S.AccountID = A.AccountID
                                AND S.FlagAlt_Key = A.FlagAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'DimYesNo' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimYesNo'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                LEFT JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   -- AND A.AccountID=@AccountID

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                         FROM ExceptionalDegrationDetail_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                           GROUP BY AccountID,FlagAlt_Key )
                        ) A
               	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerID,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ExceptionalDegrationDetail' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_107 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TemrefpDB..tt_temp_13820') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_72 ';
                  END IF;
                  DELETE FROM tt_temp20_72;
                  UTILS.IDENTITY_RESET('tt_temp20_72');

                  INSERT INTO tt_temp20_72 ( 
                  	SELECT A.DegrationAlt_Key ,
                          A.SourceName ,
                          A.SourceAlt_Key ,
                          A.AccountID ,
                          A.RefCustomerId CustomerID  ,
                          A.FlagAlt_Key ,
                          A.FlagName ,
                          A.Date_ ,
                          A.Marking ,
                          A.MarkingAlt_Key ,
                          Amount ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT A.DegrationAlt_Key ,
                                   B.SourceName ,
                                   C.SourceAlt_Key ,
                                   A.AccountID ,
                                   C.RefCustomerId ,
                                   S.FlagAlt_Key ,
                                   S.FlagName ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.Date_,20,p_style=>103) Date_  ,
                                   H.ParameterName Marking  ,
                                   A.MarkingAlt_Key ,
                                   Amount ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                                   A.ApprovedBy ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                                   A.ModifiedBy ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApproved, A.DateModified) ModAppDate  
                            FROM ExceptionalDegrationDetail_Mod A
                                   JOIN tt_ReminderReport1_5 S   ON S.AccountID = A.AccountID
                                   AND S.FlagAlt_Key = A.FlagAlt_Key
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'DimYesNo' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'DimYesNo'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                   LEFT JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND A.AccountID=@AccountID

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                            FROM ExceptionalDegrationDetail_Mod 
                                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                              GROUP BY AccountID,FlagAlt_Key )
                           ) A
                  	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'ExceptionalDegrationDetail' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_72 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST_BACKUP_25022022" TO "ADF_CDR_RBL_STGDB";
