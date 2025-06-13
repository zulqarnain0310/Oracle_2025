--------------------------------------------------------
--  DDL for Procedure EXCEPTIONALDEGRATIONSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" 
(
  --declare												
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_AccountID IN VARCHAR2 DEFAULT NULL ,--'9987880000000003'
  v_PageNo IN NUMBER DEFAULT 1 ,
  v_PageSize IN NUMBER DEFAULT 10 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         IF utils.object_id('TempDB..tt_Reminder') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Reminder ';
         END IF;
         DELETE FROM tt_Reminder;
         UTILS.IDENTITY_RESET('tt_Reminder');

         INSERT INTO tt_Reminder ( 
         	SELECT * 
         	  FROM ( SELECT B.ParameterAlt_Key FlagAlt_Key  ,
                          A.ACID AccountID  
                   FROM RBL_MISDB_PROD.ExceptionFinalStatusType A
                          JOIN DimParameter B   ON A.StatusType = B.ParameterName
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          AND A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                    WHERE  NVL(A.AuthorisationStatus, 'A') = 'A'
                             AND B.DimParameterName = 'UploadFLagType'
                   UNION 
                   SELECT FlagAlt_Key ,
                          AccountID 
                   FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey
                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
                  ) A );
         --Select * from tt_Reminder
         IF utils.object_id('TempDB..tt_ReminderReport') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReminderReport ';
         END IF;
         DELETE FROM tt_ReminderReport;
         INSERT INTO tt_ReminderReport
           ( FlagAlt_Key, AccountID )
           ( SELECT A.Businesscolvalues1 FlagAlt_Key  ,
                    A.AccountID 
             FROM ( SELECT AccountID ,
                           a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
                    FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(FlagAlt_Key, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                                  AccountID 
                           FROM tt_Reminder  ) A
                            /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A
              WHERE  A.Businesscolvalues1 <> ' ' );
         --Select * from tt_ReminderReport1
         IF utils.object_id('TempDB..tt_ReminderReport1') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReminderReport1 ';
         END IF;
         DELETE FROM tt_ReminderReport1;
         UTILS.IDENTITY_RESET('tt_ReminderReport1');

         INSERT INTO tt_ReminderReport1 ( 
         	SELECT A.* ,
                 B.ParameterName FlagName  
         	  FROM tt_ReminderReport A
                   JOIN DimParameter B   ON A.FlagAlt_Key = B.ParameterAlt_Key
         	 WHERE  B.DimParameterName = 'UploadFLagType' );
         --IF OBJECT_ID('TempDB..#Secondary') IS NOT NULL
         --Drop Table #Secondary
         --Select * Into #Secondary From (
         --Select A.AccountID,A.REPORTIDSLIST as FlagName From (
         --SELECT SS.AccountID,
         --                STUFF((SELECT ',' + US.FlagName 
         --                        FROM tt_ReminderReport1 US
         --                        WHERE US.AccountID = SS.AccountID 
         --                        FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
         --                FROM tt_ReminderReport1 SS 
         --                GROUP BY SS.AccountID
         --                )A
         --        )A
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
         IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
            ACLProcessStatusCheck() ;

         END;
         END IF;
         IF ( v_Accountid = ' '
           OR ( v_Accountid IS NULL ) ) THEN

         BEGIN
            IF ( v_OperationFlag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('AKSHAY');
               IF utils.object_id('TempDB..tt_temp_134') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_134 ';
               END IF;
               DELETE FROM tt_temp_134;
               UTILS.IDENTITY_RESET('tt_temp_134');

               INSERT INTO tt_temp_134 ( 
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
                       A.AuthorisationStatus_1 ,
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
                       A.ModAppDate ,
                       A.changeFields 

               	  --,A.ApprovedByFirstLevel

               	  --,A.DateApprovedFirstLevel
               	  FROM ( SELECT A.DegrationAlt_Key ,
                                B.SourceName ,
                                C.SourceAlt_Key ,
                                D.ACID AccountID  ,
                                D.CustomerID RefCustomerId  ,
                                --case when s.FlagName='TWO' then 1 else 9 end as FlagAlt_Key,
                                --case when D.StatusType='TWO' then 1 else 9 end as FlagAlt_Key,
                                S.FlagAlt_Key ,
                                --S.FlagName,
                                D.StatusType FlagName  ,
                                --Convert(Varchar(20),A.Date,103) Date,
                                UTILS.CONVERT_TO_VARCHAR2(D.StatusDate,20,p_style=>103) Date_  ,
                                H.ParameterName Marking  ,
                                A.MarkingAlt_Key ,
                                D.Amount ,
                                NVL(D.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(D.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                     WHEN NVL(D.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(D.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                     WHEN NVL(D.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                D.EffectiveFromTimeKey ,
                                D.EffectiveToTimeKey ,
                                D.CreatedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateCreated,20,p_style=>103) DateCreated  ,
                                D.ApprovedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateApproved,20,p_style=>103) DateApproved  ,
                                D.ModifyBy ModifiedBy  ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateModified,20,p_style=>103) DateModified  ,
                                NVL(A.ModifiedBy, D.CreatedBy) CrModBy  ,
                                NVL(D.DateModified, A.DateCreated) CrModDate  ,
                                NVL(D.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(D.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(D.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(D.DateApproved, A.DateModified) ModAppDate  ,
                                ' ' changeFields  

                         --,A.ApprovedByFirstLevel

                         --,A.DateApprovedFirstLevel
                         FROM ExceptionFinalStatusType D
                                LEFT JOIN RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A   ON A.AccountID = D.ACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = D.ACID

                                --AND A.FlagAlt_Key = S.FlagAlt_Key
                                AND D.StatusType = S.FlagName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'DimYesNo' Tablename  
               	  FROM DimParameter 
               	 WHERE  DimParameterName = 'DimYesNo'
                          AND EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                JOIN AdvAcBasicDetail C   ON D.ACID = C.CustomerACID
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                          WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(D.AuthorisationStatus, 'A') = 'A'
                         UNION 

                         --AND A.AuthorisationStatus NOT IN ('NP','MP','1A')

                         --AND A.AccountID=@AccountID
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
                                CASE 
                                     WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                     WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                     WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                     WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
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
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                a.ChangeFields 

                         --,A.ApprovedByFirstLevel

                         --,A.DateApprovedFirstLevel
                         FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A
                                LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                AND A.FlagAlt_Key = S.FlagAlt_Key
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
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
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND A.AccountID=@AccountID

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                         FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                           GROUP BY AccountID,FlagAlt_Key )
                        ) 
                       -- UNION

                       --               SELECT NULL AS DegrationAlt_Key,

                       --	B.SourceName,

                       --	C.SourceAlt_Key,

                       --	A.ACID AccountID,

                       --	C.RefCustomerId,

                       --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                       --	S.FlagName,

                       --	Convert(Varchar(20),A.Date,103) Date,

                       --	H.ParameterName as Marking,

                       --	H.ParameterAlt_Key MarkingAlt_Key,

                       --	Amount,

                       --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                       --                      A.EffectiveFromTimeKey, 

                       --                      A.EffectiveToTimeKey, 

                       --                      A.CreatedBy, 

                       --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                       --                      A.ApprovedBy, 

                       --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                       --                      A.ModifyBy  ModifiedBy, 

                       --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                       --	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

                       --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                       --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                       --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                       --	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy

                       --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                       --	--,A.ApprovedByFirstLevel

                       --	--,A.DateApprovedFirstLevel

                       --               FROM		[dbo].AccountFlaggingDetails_Mod A

                       --LEFT JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                       --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                       --LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                       --  from DimParameter where DimParameterName='DimYesNo'

                       --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                       --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                       --  inner join dbo.AdvAcBasicDetail C

                       --  ON A.Acid=C.CustomerACID

                       --  AND C.EffectiveFromTimeKey <= @TimeKey

                       --                     AND C.EffectiveToTimeKey >= @TimeKey

                       --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                       --WHERE A.EffectiveFromTimeKey <= @TimeKey

                       --                     AND A.EffectiveToTimeKey >= @TimeKey

                       --   --AND A.AccountID=@AccountID

                       --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                       --                     AND A.Entity_Key IN

                       --               (

                       --                   SELECT MAX(Entity_Key)

                       --                   FROM [dbo].AccountFlaggingDetails_Mod

                       --                   WHERE EffectiveFromTimeKey <= @TimeKey

                       --                         AND EffectiveToTimeKey >= @TimeKey

                       --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                       --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                       --               )
                       A
               	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
               --A.ApprovedByFirstLevel,
               --A.DateApprovedFirstLevel
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ExceptionalDegrationDetail' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp_134 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                   WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                            AND RowNumber <= (v_PageNo * v_PageSize) ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            ------------------------------------------------------------------------------

            --IF (@OperationFlag in (1))

            --BEGIN

            -- IF NOT EXISTS (select 1 from tt_temp_134 where AccountID=@AccountID)

            -- BEGIN 

            --    select C.SourceSystemAlt_Key ,CustomerID,SourceName ,'CustomerSourceDetails' TableName

            -- from curdat.AdvAcBasicDetail A

            -- inner join curdat.CustomerBasicDetail C On C.CustomerEntityId=A.CustomerEntityId

            -- inner join DIMSOURCEDB  S oN S.SourceAlt_Key=C.SourceSystemAlt_Key

            -- where CustomerACID=@AccountID

            --AND  A.EffectiveFromTimeKey <= @TimeKey      AND A.EffectiveToTimeKey >= @TimeKey

            --AND  C.EffectiveFromTimeKey <= @TimeKey      AND C.EffectiveToTimeKey >= @TimeKey

            -- --select * from CustomerBasicDetail

            -- --select * from AdvAcBasicDetail

            -- END 

            --END

            --------------------------------------------------------------------------------------
            ELSE
               /*  IT IS Used For GRID Search which are Pending for Authorization    */
               IF ( v_OperationFlag IN ( 16,17 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_13416') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_103 ';
                  END IF;
                  DELETE FROM tt_temp16_103;
                  UTILS.IDENTITY_RESET('tt_temp16_103');

                  INSERT INTO tt_temp16_103 ( 
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
                          A.AuthorisationStatus_1 ,
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
                          A.ModAppDate ,
                          A.ChangeFields 

                  	  --A.ApprovedByFirstLevel,

                  	  --A.DateApprovedFirstLevel
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
                                   CASE 
                                        WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                        WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                        WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                        WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  ,
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
                                   NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                   a.ChangeFields 

                            --,A.ApprovedByFirstLevel

                            --,A.DateApprovedFirstLevel
                            FROM ExceptionalDegrationDetail_Mod A
                                   LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                   AND S.FlagAlt_Key = A.FlagAlt_Key
                                   LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                      ParameterName ,
                                                      'DimYesNo' Tablename  
                                               FROM DimParameter 
                                                WHERE  DimParameterName = 'DimYesNo'
                                                         AND EffectiveFromTimeKey <= v_TimeKey
                                                         AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                   JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
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
                           ) 
                          --  UNION

                          --               SELECT NULL AS DegrationAlt_Key,

                          --	B.SourceName,

                          --	C.SourceAlt_Key,

                          --	A.ACID AccountID,

                          --	C.RefCustomerId,

                          --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                          --	S.FlagName,

                          --	Convert(Varchar(20),A.Date,103) Date,

                          --	H.ParameterName as Marking,

                          --	H.ParameterAlt_Key MarkingAlt_Key,

                          --	Amount,

                          --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                          --                      A.EffectiveFromTimeKey, 

                          --                      A.EffectiveToTimeKey, 

                          --                      A.CreatedBy, 

                          --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                          --                      A.ApprovedBy, 

                          --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                          --                      A.ModifyBy ModifiedBy, 

                          --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                          --	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

                          --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                          --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                          --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                          --	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy

                          --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                          --	--,A.ApprovedByFirstLevel

                          --	--,A.DateApprovedFirstLevel

                          --               FROM		[dbo].AccountFlaggingDetails_Mod A

                          --left JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                          --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                          --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                          --  from DimParameter where DimParameterName='DimYesNo'

                          --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                          --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                          --  inner join AdvAcBasicDetail C

                          --  ON A.Acid=C.CustomerACID

                          --  AND C.EffectiveFromTimeKey <= @TimeKey

                          --                     AND C.EffectiveToTimeKey >= @TimeKey

                          --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                          --WHERE A.EffectiveFromTimeKey <= @TimeKey

                          --                     AND A.EffectiveToTimeKey >= @TimeKey

                          --   --AND A.AccountID=@AccountID

                          --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                          --                     AND A.Entity_Key IN

                          --               (

                          --                   SELECT MAX(Entity_Key)

                          --                   FROM [dbo].AccountFlaggingDetails_Mod

                          --                   WHERE EffectiveFromTimeKey <= @TimeKey

                          --                         AND EffectiveToTimeKey >= @TimeKey

                          --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                          --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                          --               )
                          A
                  	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerID,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                  --A.ApprovedByFirstLevel,
                  --A.DateApprovedFirstLevel;
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'ExceptionalDegrationDetail' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp16_103 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                      WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                               AND RowNumber <= (v_PageNo * v_PageSize) ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF ( v_OperationFlag IN ( 20 )
                   ) THEN

                  BEGIN
                     IF utils.object_id('TemrefpDB..tt_temp_13420') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_68 ';
                     END IF;
                     DELETE FROM tt_temp20_68;
                     UTILS.IDENTITY_RESET('tt_temp20_68');

                     INSERT INTO tt_temp20_68 ( 
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
                             A.AuthorisationStatus_1 ,
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
                             A.ModAppDate ,
                             A.ChangeFields 

                     	  --A.ApprovedByFirstLevel,

                     	  --A.DateApprovedFirstLevel
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
                                      CASE 
                                           WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                           WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                           WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                           WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                            THEN 'Pending'
                                      ELSE NULL
                                         END AuthorisationStatus_1  ,
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
                                      NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                      NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                      NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                      NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                      a.ChangeFields 

                               --,A.ApprovedByFirstLevel

                               --,A.DateApprovedFirstLevel
                               FROM ExceptionalDegrationDetail_Mod A
                                      LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                      AND S.FlagAlt_Key = A.FlagAlt_Key
                                      LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'DimYesNo' Tablename  
                                                  FROM DimParameter 
                                                   WHERE  DimParameterName = 'DimYesNo'
                                                            AND EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                      LEFT JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
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
                              ) 
                             --  UNION

                             --               SELECT NULL AS DegrationAlt_Key,

                             --	B.SourceName,

                             --	C.SourceAlt_Key,

                             --	A.ACID AccountID,

                             --	C.RefCustomerId,

                             --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                             --	S.FlagName,

                             --	Convert(Varchar(20),A.Date,103) Date,

                             --	H.ParameterName as Marking,

                             --	H.ParameterAlt_Key MarkingAlt_Key,

                             --	Amount,

                             --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                             --                      A.EffectiveFromTimeKey, 

                             --                      A.EffectiveToTimeKey, 

                             --                      A.CreatedBy, 

                             --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                             --                      A.ApprovedBy, 

                             --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                             --                      A.ModifyBy ModifiedBy, 

                             --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                             --	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

                             --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                             --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                             --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                             --	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy

                             --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                             --	--,A.ApprovedByFirstLevel

                             --	--,A.DateApprovedFirstLevel

                             --               FROM		[dbo].AccountFlaggingDetails_Mod A

                             --left JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                             --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                             --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                             --  from DimParameter where DimParameterName='DimYesNo'

                             --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                             --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                             --  inner join AdvAcBasicDetail C

                             --  ON A.Acid=C.CustomerACID

                             --  AND C.EffectiveFromTimeKey <= @TimeKey

                             --                     AND C.EffectiveToTimeKey >= @TimeKey

                             --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                             --WHERE A.EffectiveFromTimeKey <= @TimeKey

                             --                     AND A.EffectiveToTimeKey >= @TimeKey

                             --   --AND A.AccountID=@AccountID

                             --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                             --                     AND A.Entity_Key IN

                             --               (

                             --                   SELECT MAX(Entity_Key)

                             --                   FROM [dbo].AccountFlaggingDetails_Mod

                             --                   WHERE EffectiveFromTimeKey <= @TimeKey

                             --                         AND EffectiveToTimeKey >= @TimeKey

                             --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                             --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                             --               )
                             A
                     	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                     --A.ApprovedByFirstLevel,
                     --A.DateApprovedFirstLevel;
                     OPEN  v_cursor FOR
                        SELECT * 
                          FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                        COUNT(*) OVER ( ) TotalCount  ,
                                        'ExceptionalDegrationDetail' TableName  ,
                                        * 
                                 FROM ( SELECT * 
                                        FROM tt_temp20_68 A ) 
                                      --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                      --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                      DataPointOwner ) DataPointOwner
                         WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                                  AND RowNumber <= (v_PageNo * v_PageSize) ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;
               END IF;
            END IF;

         END;
         ELSE

         BEGIN
            IF ( v_OperationFlag NOT IN ( 16,17,20 )
             ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('AKSHAY');
               IF utils.object_id('TempDB..tt_temp_13430') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp30 ';
               END IF;
               DELETE FROM tt_temp30;
               UTILS.IDENTITY_RESET('tt_temp30');

               INSERT INTO tt_temp30 ( 
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
                       A.AuthorisationStatus_1 ,
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
                       A.ModAppDate ,
                       A.ChangeFields 

               	  --,A.ApprovedByFirstLevel

               	  --,A.DateApprovedFirstLevel
               	  FROM ( SELECT A.DegrationAlt_Key ,
                                B.SourceName ,
                                C.SourceAlt_Key ,
                                D.ACID AccountID  ,
                                D.CustomerID RefCustomerId  ,
                                --case when s.FlagName='TWO' then 1 else 9 end as FlagAlt_Key,
                                --case when D.StatusType='TWO' then 1 else 9 end as FlagAlt_Key,
                                S.FlagAlt_Key ,
                                --S.FlagName,
                                D.StatusType FlagName  ,
                                --Convert(Varchar(20),A.Date,103) Date,
                                UTILS.CONVERT_TO_VARCHAR2(D.StatusDate,20,p_style=>103) Date_  ,
                                H.ParameterName Marking  ,
                                A.MarkingAlt_Key ,
                                D.Amount ,
                                NVL(D.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                CASE 
                                     WHEN NVL(D.AuthorisationStatus, 'A') = 'A' THEN 'Authorized'
                                     WHEN NVL(D.AuthorisationStatus, 'A') = 'R' THEN 'Rejected'
                                     WHEN NVL(D.AuthorisationStatus, 'A') = '1A' THEN '1Authorized'
                                     WHEN NVL(D.AuthorisationStatus, 'A') IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
                                D.EffectiveFromTimeKey ,
                                D.EffectiveToTimeKey ,
                                D.CreatedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateCreated,20,p_style=>103) DateCreated  ,
                                D.ApprovedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateApproved,20,p_style=>103) DateApproved  ,
                                D.ModifyBy ModifiedBy  ,
                                UTILS.CONVERT_TO_VARCHAR2(D.DateModified,20,p_style=>103) DateModified  ,
                                NVL(A.ModifiedBy, D.CreatedBy) CrModBy  ,
                                NVL(D.DateModified, A.DateCreated) CrModDate  ,
                                NVL(D.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(D.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(D.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(D.DateApproved, A.DateModified) ModAppDate  ,
                                a.ChangeFields 

                         --,A.ApprovedByFirstLevel

                         --,A.DateApprovedFirstLevel
                         FROM ExceptionFinalStatusType D
                                LEFT JOIN RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A   ON A.AccountID = D.ACID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = D.ACID

                                --AND A.FlagAlt_Key = S.FlagAlt_Key
                                AND D.StatusType = S.FlagName
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'DimYesNo' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'DimYesNo'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                JOIN AdvAcBasicDetail C   ON D.ACID = C.CustomerACID
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                          WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   AND NVL(D.AuthorisationStatus, 'A') = 'A'
                                   AND D.ACID = v_AccountID
                         UNION 

                         --AND A.AuthorisationStatus NOT IN ('NP','MP','1A')

                         --AND A.AccountID=@AccountID
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
                                CASE 
                                     WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                     WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                     WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                     WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus_1  ,
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
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                a.ChangeFields 

                         --,A.ApprovedByFirstLevel

                         --,A.DateApprovedFirstLevel
                         FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A
                                LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                AND A.FlagAlt_Key = S.FlagAlt_Key
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'DimYesNo' Tablename  
                                            FROM DimParameter 
                                             WHERE  DimParameterName = 'DimYesNo'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND A.AccountID = v_AccountID

                                   --AND A.AccountID=@AccountID

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                         FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                           GROUP BY AccountID,FlagAlt_Key )
                        ) 
                       -- UNION

                       --               SELECT NULL AS DegrationAlt_Key,

                       --	B.SourceName,

                       --	C.SourceAlt_Key,

                       --	A.ACID AccountID,

                       --	C.RefCustomerId,

                       --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                       --	S.FlagName,

                       --	Convert(Varchar(20),A.Date,103) Date,

                       --	H.ParameterName as Marking,

                       --	H.ParameterAlt_Key MarkingAlt_Key,

                       --	Amount,

                       --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                       --                      A.EffectiveFromTimeKey, 

                       --                      A.EffectiveToTimeKey, 

                       --                      A.CreatedBy, 

                       --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                       --                      A.ApprovedBy, 

                       --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                       --                      A.ModifyBy  ModifiedBy, 

                       --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                       --	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

                       --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                       --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                       --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                       --	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy

                       --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                       --	--,A.ApprovedByFirstLevel

                       --	--,A.DateApprovedFirstLevel

                       --               FROM		[dbo].AccountFlaggingDetails_Mod A

                       --LEFT JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                       --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                       --LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                       --  from DimParameter where DimParameterName='DimYesNo'

                       --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                       --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                       --  inner join AdvAcBasicDetail C

                       --  ON A.Acid=C.CustomerACID

                       --  AND C.EffectiveFromTimeKey <= @TimeKey

                       --                     AND C.EffectiveToTimeKey >= @TimeKey

                       --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                       --WHERE A.EffectiveFromTimeKey <= @TimeKey

                       --                     AND A.EffectiveToTimeKey >= @TimeKey

                       --   AND A.ACID=@AccountID

                       --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                       --                     AND A.Entity_Key IN

                       --               (

                       --                   SELECT MAX(Entity_Key)

                       --                   FROM [dbo].AccountFlaggingDetails_Mod

                       --                   WHERE EffectiveFromTimeKey <= @TimeKey

                       --                         AND EffectiveToTimeKey >= @TimeKey

                       --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                       --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                       --               )
                       A
               	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
               --A.ApprovedByFirstLevel,
               --A.DateApprovedFirstLevel
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ExceptionalDegrationDetail' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp30 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                   WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                            AND RowNumber <= (v_PageNo * v_PageSize) ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            ------------------------------------------------------------------------------
            IF ( v_OperationFlag IN ( 1 )
             ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('K2');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT EXISTS ( SELECT 1 
                                      FROM tt_temp30 
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
                  IF utils.object_id('TempDB..tt_temp_134161') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp161_4 ';
                  END IF;
                  DELETE FROM tt_temp161_4;
                  UTILS.IDENTITY_RESET('tt_temp161_4');

                  INSERT INTO tt_temp161_4 ( 
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
                          A.AuthorisationStatus_1 ,
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
                          A.ModAppDate ,
                          A.ChangeFields 

                  	  --A.ApprovedByFirstLevel,

                  	  --A.DateApprovedFirstLevel
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
                                   CASE 
                                        WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                        WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                        WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                        WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus_1  ,
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
                                   NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                   a.ChangeFields 

                            --,A.ApprovedByFirstLevel

                            --,A.DateApprovedFirstLevel
                            FROM ExceptionalDegrationDetail_Mod A
                                   LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                   AND S.FlagAlt_Key = A.FlagAlt_Key
                                   LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                      ParameterName ,
                                                      'DimYesNo' Tablename  
                                               FROM DimParameter 
                                                WHERE  DimParameterName = 'DimYesNo'
                                                         AND EffectiveFromTimeKey <= v_TimeKey
                                                         AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                   JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND A.AccountID = v_AccountID

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                            FROM ExceptionalDegrationDetail_Mod 
                                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                              GROUP BY AccountID,FlagAlt_Key )
                           ) 
                          --  UNION

                          --               SELECT NULL AS DegrationAlt_Key,

                          --	B.SourceName,

                          --	C.SourceAlt_Key,

                          --	A.ACID AccountID,

                          --	C.RefCustomerId,

                          --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                          --	S.FlagName,

                          --	Convert(Varchar(20),A.Date,103) Date,

                          --	H.ParameterName as Marking,

                          --	H.ParameterAlt_Key MarkingAlt_Key,

                          --	Amount,

                          --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                          --                      A.EffectiveFromTimeKey, 

                          --                      A.EffectiveToTimeKey, 

                          --                      A.CreatedBy, 

                          --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                          --                      A.ApprovedBy, 

                          --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                          --                      A.ModifyBy ModifiedBy, 

                          --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                          --	IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

                          --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                          --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                          --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                          --	,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy

                          --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                          --	--,A.ApprovedByFirstLevel

                          --	--,A.DateApprovedFirstLevel

                          --               FROM		[dbo].AccountFlaggingDetails_Mod A

                          --left JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                          --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                          --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                          --  from DimParameter where DimParameterName='DimYesNo'

                          --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                          --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                          --  inner join AdvAcBasicDetail C

                          --  ON A.Acid=C.CustomerACID

                          --  AND C.EffectiveFromTimeKey <= @TimeKey

                          --                     AND C.EffectiveToTimeKey >= @TimeKey

                          --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                          --WHERE A.EffectiveFromTimeKey <= @TimeKey

                          --                     AND A.EffectiveToTimeKey >= @TimeKey

                          --   AND A.ACID=@AccountID

                          --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                          --                     AND A.Entity_Key IN

                          --               (

                          --                   SELECT MAX(Entity_Key)

                          --                   FROM [dbo].AccountFlaggingDetails_Mod

                          --                   WHERE EffectiveFromTimeKey <= @TimeKey

                          --                         AND EffectiveToTimeKey >= @TimeKey

                          --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                          --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                          --               )
                          A
                  	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerID,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                  --A.ApprovedByFirstLevel,
                  --A.DateApprovedFirstLevel;
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'ExceptionalDegrationDetail' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp161_4 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                      WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                               AND RowNumber <= (v_PageNo * v_PageSize) ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF ( v_OperationFlag IN ( 20 )
                   ) THEN

                  BEGIN
                     IF utils.object_id('TemrefpDB..tt_temp_134201') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp201_4 ';
                     END IF;
                     DELETE FROM tt_temp201_4;
                     UTILS.IDENTITY_RESET('tt_temp201_4');

                     INSERT INTO tt_temp201_4 ( 
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
                             A.AuthorisationStatus_1 ,
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
                             A.ModAppDate ,
                             A.ChangeFields 

                     	  --A.ApprovedByFirstLevel,

                     	  --A.DateApprovedFirstLevel
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
                                      CASE 
                                           WHEN A.AuthorisationStatus = 'A' THEN 'Authorized'
                                           WHEN A.AuthorisationStatus = 'R' THEN 'Rejected'
                                           WHEN A.AuthorisationStatus = '1A' THEN '1Authorized'
                                           WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                                            THEN 'Pending'
                                      ELSE NULL
                                         END AuthorisationStatus_1  ,
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
                                      NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                      NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                      NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                      NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                      a.ChangeFields 

                               --,A.ApprovedByFirstLevel

                               --,A.DateApprovedFirstLevel
                               FROM ExceptionalDegrationDetail_Mod A
                                      LEFT JOIN tt_ReminderReport1 S   ON S.AccountID = A.AccountID
                                      AND S.FlagAlt_Key = A.FlagAlt_Key
                                      LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'DimYesNo' Tablename  
                                                  FROM DimParameter 
                                                   WHERE  DimParameterName = 'DimYesNo'
                                                            AND EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
                                      LEFT JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                      AND C.EffectiveFromTimeKey <= v_TimeKey
                                      AND C.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON C.SourceAlt_Key = B.SourceAlt_Key
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND A.AccountID = v_AccountID

                                         --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                         AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                               FROM ExceptionalDegrationDetail_Mod 
                                                                WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                         AND EffectiveToTimeKey >= v_TimeKey
                                                                         AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                                 GROUP BY AccountID,FlagAlt_Key )
                              ) 
                             --  UNION

                             --               SELECT NULL AS DegrationAlt_Key,

                             --	B.SourceName,

                             --	C.SourceAlt_Key,

                             --	A.ACID AccountID,

                             --	C.RefCustomerId,

                             --	A.UploadTypeParameterAlt_Key FlagAlt_Key,

                             --	S.FlagName,

                             --	Convert(Varchar(20),A.Date,103) Date,

                             --	H.ParameterName as Marking,

                             --	H.ParameterAlt_Key MarkingAlt_Key,

                             --	Amount,

                             --	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 

                             --                      A.EffectiveFromTimeKey, 

                             --                      A.EffectiveToTimeKey, 

                             --                      A.CreatedBy, 

                             --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 

                             --                      A.ApprovedBy, 

                             --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 

                             --                      A.ModifyBy ModifiedBy, 

                             --                      Convert(Varchar(20),A.DateModified,103) DateModified,

                             --	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

                             --	,IsNull(A.DateModified,A.DateCreated)as CrModDate

                             --	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

                             --	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

                             --	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy

                             --	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate

                             --	--,A.ApprovedByFirstLevel

                             --	--,A.DateApprovedFirstLevel

                             --               FROM		[dbo].AccountFlaggingDetails_Mod A

                             --left JOIn tt_ReminderReport1 S ON S.AccountID=A.ACID

                             --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key

                             --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 

                             --  from DimParameter where DimParameterName='DimYesNo'

                             --  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H

                             --  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end

                             --  inner join AdvAcBasicDetail C

                             --  ON A.Acid=C.CustomerACID

                             --  AND C.EffectiveFromTimeKey <= @TimeKey

                             --                     AND C.EffectiveToTimeKey >= @TimeKey

                             --    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key

                             --WHERE A.EffectiveFromTimeKey <= @TimeKey

                             --                     AND A.EffectiveToTimeKey >= @TimeKey

                             --   AND A.ACID=@AccountID

                             --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                             --                     AND A.Entity_Key IN

                             --               (

                             --                   SELECT MAX(Entity_Key)

                             --                   FROM [dbo].AccountFlaggingDetails_Mod

                             --                   WHERE EffectiveFromTimeKey <= @TimeKey

                             --                         AND EffectiveToTimeKey >= @TimeKey

                             --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                             --                   GROUP BY ACID,UploadTypeParameterAlt_Key

                             --               )
                             A
                     	  GROUP BY A.DegrationAlt_Key,A.SourceName,A.SourceAlt_Key,A.AccountID,A.RefCustomerId,A.FlagAlt_Key,A.FlagName,A.Date_,A.Marking,A.MarkingAlt_Key,Amount,A.AuthorisationStatus,A.AuthorisationStatus_1,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.ChangeFields );
                     --A.ApprovedByFirstLevel,
                     --A.DateApprovedFirstLevel;
                     OPEN  v_cursor FOR
                        SELECT * 
                          FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DegrationAlt_Key  ) RowNumber  ,
                                        COUNT(*) OVER ( ) TotalCount  ,
                                        'ExceptionalDegrationDetail' TableName  ,
                                        * 
                                 FROM ( SELECT * 
                                        FROM tt_temp201_4 A ) 
                                      --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                      --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                      DataPointOwner ) DataPointOwner
                         WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                                  AND RowNumber <= (v_PageNo * v_PageSize) ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;
               END IF;
            END IF;

         END;
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
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;
   --RETURN -1
   OPEN  v_cursor FOR
      SELECT * ,
             'ExceptionDegradation' tableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'ExceptionDegradationAssets' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
