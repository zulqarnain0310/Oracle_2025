--------------------------------------------------------
--  DDL for Procedure WILFULDEFAULTERSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 
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
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_309') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_309 ';
            END IF;
            DELETE FROM tt_temp_309;
            UTILS.IDENTITY_RESET('tt_temp_309');

            INSERT INTO tt_temp_309 ( 
            	SELECT Z.ReportedByAlt_Key ,
                    Z.CategoryofBankFIAlt_Key ,
                    Z.ReportingBankFIAlt_Key ,
                    Z.ReportingBranchAlt_Key ,
                    Z.StateUTofBranchAlt_Key ,
                    Z.CustomerID ,
                    Z.PartyName ,
                    Z.PAN ,
                    Z.ReportingSerialNo ,
                    Z.RegisteredOfficeAddress ,
                    Z.OSAmountinlacs ,
                    Z.WillfulDefaultDate ,
                    Z.SuitFiledorNotAlt_Key ,
                    Z.OtherBanksFIInvolvedAlt_Key ,
                    Z.NameofOtherBanksFIAlt_Key ,
                    Z.CustomerTypeAlt_Key ,
                    Z.AuthorisationStatus ,
                    Z.EffectiveFromTimeKey ,
                    Z.EffectiveToTimeKey ,
                    Z.CreatedBy ,
                    Z.DateCreated ,
                    Z.ApprovedBy ,
                    Z.DateApproved ,
                    Z.ModifiedBy ,
                    Z.DateModified ,
                    Z.CrModBy ,
                    Z.CrModDate ,
                    Z.CrAppBy ,
                    Z.CrAppDate ,
                    Z.ModAppBy ,
                    Z.ModAppDate 
            	  FROM ( SELECT A.ReportedByAlt_Key ,
                             B.ParameterName ReportedBy  ,
                             A.CategoryofBankFIAlt_Key ,
                             J.ParameterName CategoryofBankFI  ,
                             A.ReportingBankFIAlt_Key ,
                             C.BankName ReportedBank  ,
                             A.ReportingBranchAlt_Key ,
                             D.BranchName ReportingBranch  ,
                             A.StateUTofBranchAlt_Key ,
                             E.StateName StateUTofBranch  ,
                             A.CustomerID ,
                             A.PartyName ,
                             A.PAN ,
                             A.ReportingSerialNo ,
                             A.RegisteredOfficeAddress ,
                             A.OSAmountinlacs ,
                             A.WillfulDefaultDate ,
                             A.SuitFiledorNotAlt_Key ,
                             F.ParameterName SuitFiledornot  ,
                             A.OtherBanksFIInvolvedAlt_Key ,
                             G.ParameterName OtherbanksFIinvolved  ,
                             A.NameofOtherBanksFIAlt_Key ,
                             H.BranchName NameofOtherBanksFI  ,
                             A.CustomerTypeAlt_Key ,
                             I.ParameterName CustomerType  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM WillfulDefaulters A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'Reportedby' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Reportedby'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.ReportedByAlt_Key = B.ParameterAlt_Key
                           -------------

                             JOIN DIMBANK C   ON C.BankAlt_Key = A.ReportedByAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                           --------

                             JOIN DimBranch D   ON A.ReportingBranchAlt_Key = D.BranchAlt_Key
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                           --------

                             JOIN DimState E   ON E.StateAlt_Key = A.StateUTofBranchAlt_Key
                             AND E.EffectiveFromTimeKey <= v_TimeKey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( 
                                    -------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'SuitFiledornot' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'SuitFiledornot'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.StateUTofBranchAlt_Key
                             JOIN ( 
                                    --------------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'OtherbanksFIinvolved' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) G   ON G.ParameterAlt_Key = A.OtherBanksFIInvolvedAlt_Key
                           ---------

                             JOIN DimBranch H   ON H.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                             AND H.EffectiveFromTimeKey <= v_TimeKey
                             AND H.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( 
                                    ------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CustomerType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CustomerType'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) I   ON I.ParameterAlt_Key = A.CustomerTypeAlt_Key
                             JOIN ( 
                                    -------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CategoryofBankFI' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CategoryofBankFI'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) J   ON J.ParameterAlt_Key = A.CategoryofBankFIAlt_Key
                      UNION 
                      SELECT A.ReportedByAlt_Key ,
                             B.ParameterName ReportedBy  ,
                             A.CategoryofBankFIAlt_Key ,
                             J.ParameterName CategoryofBankFI  ,
                             A.ReportingBankFIAlt_Key ,
                             C.BankName ReportedBank  ,
                             A.ReportingBranchAlt_Key ,
                             D.BranchName ReportingBranch  ,
                             A.StateUTofBranchAlt_Key ,
                             E.StateName StateUTofBranch  ,
                             A.CustomerID ,
                             A.PartyName ,
                             A.PAN ,
                             A.ReportingSerialNo ,
                             A.RegisteredOfficeAddress ,
                             A.OSAmountinlacs ,
                             A.WillfulDefaultDate ,
                             A.SuitFiledorNotAlt_Key ,
                             F.ParameterName SuitFiledornot  ,
                             A.OtherBanksFIInvolvedAlt_Key ,
                             G.ParameterName OtherbanksFIinvolved  ,
                             A.NameofOtherBanksFIAlt_Key ,
                             H.BranchName NameofOtherBanksFI  ,
                             A.CustomerTypeAlt_Key ,
                             I.ParameterName CustomerType  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM WillfulDefaulters_mod A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'Reportedby' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Reportedby'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.ReportedByAlt_Key = B.ParameterAlt_Key
                           -------------

                             JOIN DIMBANK C   ON C.BankAlt_Key = A.ReportedByAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                           --------

                             JOIN DimBranch D   ON A.ReportingBranchAlt_Key = D.BranchAlt_Key
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                           --------

                             JOIN DimState E   ON E.StateAlt_Key = A.StateUTofBranchAlt_Key
                             AND E.EffectiveFromTimeKey <= v_TimeKey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( 
                                    -------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'SuitFiledornot' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'SuitFiledornot'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.StateUTofBranchAlt_Key
                             JOIN ( 
                                    --------------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'OtherbanksFIinvolved' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) G   ON G.ParameterAlt_Key = A.OtherBanksFIInvolvedAlt_Key
                           ---------

                             JOIN DimBranch H   ON H.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                             AND H.EffectiveFromTimeKey <= v_TimeKey
                             AND H.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( 
                                    ------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CustomerType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CustomerType'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) I   ON I.ParameterAlt_Key = A.CustomerTypeAlt_Key
                             JOIN ( 
                                    -------
                                    SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CategoryofBankFI' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CategoryofBankFI'
                                              AND EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) J   ON J.ParameterAlt_Key = A.CategoryofBankFIAlt_Key
                             AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                   FROM WillfulDefaulters_mod 
                                                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey
                                                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                     GROUP BY CustomerID )
                     ) Z
            	  GROUP BY Z.ReportedByAlt_Key,Z.CategoryofBankFIAlt_Key,Z.ReportingBankFIAlt_Key,Z.ReportingBranchAlt_Key,Z.StateUTofBranchAlt_Key,Z.CustomerID,Z.PartyName,Z.PAN,Z.ReportingSerialNo,Z.RegisteredOfficeAddress,Z.OSAmountinlacs,Z.WillfulDefaultDate,Z.SuitFiledorNotAlt_Key,Z.OtherBanksFIInvolvedAlt_Key,Z.NameofOtherBanksFIAlt_Key,Z.CustomerTypeAlt_Key,Z.AuthorisationStatus,Z.EffectiveFromTimeKey,Z.EffectiveToTimeKey,Z.CreatedBy,Z.DateCreated,Z.ApprovedBy,Z.DateApproved,Z.ModifiedBy,Z.DateModified,Z.CrModBy,Z.CrModDate,Z.CrAppBy,Z.CrAppDate,Z.ModAppBy,Z.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'Customer' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_309 A ) 
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
               IF utils.object_id('TempDB..tt_temp_30916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_252 ';
               END IF;
               DELETE FROM tt_temp16_252;
               UTILS.IDENTITY_RESET('tt_temp16_252');

               INSERT INTO tt_temp16_252 ( 
               	SELECT P.ReportedByAlt_Key ,
                       P.CategoryofBankFIAlt_Key ,
                       P.ReportingBankFIAlt_Key ,
                       P.ReportingBranchAlt_Key ,
                       P.StateUTofBranchAlt_Key ,
                       P.CustomerID ,
                       P.PartyName ,
                       P.PAN ,
                       P.ReportingSerialNo ,
                       P.RegisteredOfficeAddress ,
                       P.OSAmountinlacs ,
                       P.WillfulDefaultDate ,
                       P.SuitFiledorNotAlt_Key ,
                       P.OtherBanksFIInvolvedAlt_Key ,
                       P.NameofOtherBanksFIAlt_Key ,
                       P.CustomerTypeAlt_Key ,
                       P.AuthorisationStatus ,
                       P.EffectiveFromTimeKey ,
                       P.EffectiveToTimeKey ,
                       P.CreatedBy ,
                       P.DateCreated ,
                       P.ApprovedBy ,
                       P.DateApproved ,
                       P.ModifiedBy ,
                       P.DateModified ,
                       P.CrModBy ,
                       P.CrModDate ,
                       P.CrAppBy ,
                       P.CrAppDate ,
                       P.ModAppBy ,
                       P.ModAppDate 
               	  FROM ( SELECT A.ReportedByAlt_Key ,
                                B.ParameterName ReportedBy  ,
                                A.CategoryofBankFIAlt_Key ,
                                J.ParameterName CategoryofBankFI  ,
                                A.ReportingBankFIAlt_Key ,
                                C.BankName ReportedBank  ,
                                A.ReportingBranchAlt_Key ,
                                D.BranchName ReportingBranch  ,
                                A.StateUTofBranchAlt_Key ,
                                E.StateName StateUTofBranch  ,
                                A.CustomerID ,
                                A.PartyName ,
                                A.PAN ,
                                A.ReportingSerialNo ,
                                A.RegisteredOfficeAddress ,
                                A.OSAmountinlacs ,
                                A.WillfulDefaultDate ,
                                A.SuitFiledorNotAlt_Key ,
                                F.ParameterName SuitFiledornot  ,
                                A.OtherBanksFIInvolvedAlt_Key ,
                                G.ParameterName OtherbanksFIinvolved  ,
                                A.NameofOtherBanksFIAlt_Key ,
                                H.BranchName NameofOtherBanksFI  ,
                                A.CustomerTypeAlt_Key ,
                                I.ParameterName CustomerType  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  
                         FROM WillfulDefaulters_mod A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'Reportedby' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'Reportedby'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.ReportedByAlt_Key = B.ParameterAlt_Key
                              -------------

                                JOIN DIMBANK C   ON C.BankAlt_Key = A.ReportedByAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                              --------

                                JOIN DimBranch D   ON A.ReportingBranchAlt_Key = D.BranchAlt_Key
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                              --------

                                JOIN DimState E   ON E.StateAlt_Key = A.StateUTofBranchAlt_Key
                                AND E.EffectiveFromTimeKey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( 
                                       -------
                                       SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'SuitFiledornot' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'SuitFiledornot'
                                                 AND EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.StateUTofBranchAlt_Key
                                JOIN ( 
                                       --------------
                                       SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'OtherbanksFIinvolved' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimYesNo'
                                                 AND EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey ) G   ON G.ParameterAlt_Key = A.OtherBanksFIInvolvedAlt_Key
                              ---------

                                JOIN DimBranch H   ON H.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                                AND H.EffectiveFromTimeKey <= v_TimeKey
                                AND H.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( 
                                       ------
                                       SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'CustomerType' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CustomerType'
                                                 AND EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey ) I   ON I.ParameterAlt_Key = A.CustomerTypeAlt_Key
                                JOIN ( 
                                       -------
                                       SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'CategoryofBankFI' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CategoryofBankFI'
                                                 AND EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey ) J   ON J.ParameterAlt_Key = A.CategoryofBankFIAlt_Key
                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM WillfulDefaulters_mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                        GROUP BY CustomerID )
                        ) P
               	  GROUP BY P.ReportedByAlt_Key,P.CategoryofBankFIAlt_Key,P.ReportingBankFIAlt_Key,P.ReportingBranchAlt_Key,P.StateUTofBranchAlt_Key,P.CustomerID,P.PartyName,P.PAN,P.ReportingSerialNo,P.RegisteredOfficeAddress,P.OSAmountinlacs,P.WillfulDefaultDate,P.SuitFiledorNotAlt_Key,P.OtherBanksFIInvolvedAlt_Key,P.NameofOtherBanksFIAlt_Key,P.CustomerTypeAlt_Key,P.AuthorisationStatus,P.EffectiveFromTimeKey,P.EffectiveToTimeKey,P.CreatedBy,P.DateCreated,P.ApprovedBy,P.DateApproved,P.ModifiedBy,P.DateModified,P.CrModBy,P.CrModDate,P.CrAppBy,P.CrAppDate,P.ModAppBy,P.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Customer' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_252 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_30920') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_215 ';
                  END IF;
                  DELETE FROM tt_temp20_215;
                  UTILS.IDENTITY_RESET('tt_temp20_215');

                  INSERT INTO tt_temp20_215 ( 
                  	SELECT A.ReportedByAlt_Key ,
                          A.CategoryofBankFIAlt_Key ,
                          A.ReportingBankFIAlt_Key ,
                          A.ReportingBranchAlt_Key ,
                          A.StateUTofBranchAlt_Key ,
                          A.CustomerID ,
                          A.PartyName ,
                          A.PAN ,
                          A.ReportingSerialNo ,
                          A.RegisteredOfficeAddress ,
                          A.OSAmountinlacs ,
                          A.WillfulDefaultDate ,
                          A.SuitFiledorNotAlt_Key ,
                          A.OtherBanksFIInvolvedAlt_Key ,
                          A.NameofOtherBanksFIAlt_Key ,
                          A.CustomerTypeAlt_Key ,
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
                  	  FROM ( SELECT A.ReportedByAlt_Key ,
                                   B.ParameterName ReportedBy  ,
                                   A.CategoryofBankFIAlt_Key ,
                                   J.ParameterName CategoryofBankFI  ,
                                   A.ReportingBankFIAlt_Key ,
                                   C.BankName ReportedBank  ,
                                   A.ReportingBranchAlt_Key ,
                                   D.BranchName ReportingBranch  ,
                                   A.StateUTofBranchAlt_Key ,
                                   E.StateName StateUTofBranch  ,
                                   A.CustomerID ,
                                   A.PartyName ,
                                   A.PAN ,
                                   A.ReportingSerialNo ,
                                   A.RegisteredOfficeAddress ,
                                   A.OSAmountinlacs ,
                                   A.WillfulDefaultDate ,
                                   A.SuitFiledorNotAlt_Key ,
                                   F.ParameterName SuitFiledornot  ,
                                   A.OtherBanksFIInvolvedAlt_Key ,
                                   G.ParameterName OtherbanksFIinvolved  ,
                                   A.NameofOtherBanksFIAlt_Key ,
                                   H.BranchName NameofOtherBanksFI  ,
                                   A.CustomerTypeAlt_Key ,
                                   I.ParameterName CustomerType  ,
                                   --isnull(A.AuthorisationStatus, 'A') 
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApproved, A.DateModified) ModAppDate  
                            FROM WillfulDefaulters_mod A
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'Reportedby' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'Reportedby'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.ReportedByAlt_Key = B.ParameterAlt_Key
                                 -------------

                                   JOIN DIMBANK C   ON C.BankAlt_Key = A.ReportedByAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                 --------

                                   JOIN DimBranch D   ON A.ReportingBranchAlt_Key = D.BranchAlt_Key
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                 --------

                                   JOIN DimState E   ON E.StateAlt_Key = A.StateUTofBranchAlt_Key
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   JOIN ( 
                                          -------
                                          SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'SuitFiledornot' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'SuitFiledornot'
                                                    AND EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.StateUTofBranchAlt_Key
                                   JOIN ( 
                                          --------------
                                          SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'OtherbanksFIinvolved' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'DimYesNo'
                                                    AND EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey ) G   ON G.ParameterAlt_Key = A.OtherBanksFIInvolvedAlt_Key
                                 ---------

                                   JOIN DimBranch H   ON H.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                                   AND H.EffectiveFromTimeKey <= v_TimeKey
                                   AND H.EffectiveToTimeKey >= v_TimeKey
                                   JOIN ( 
                                          ------
                                          SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'CustomerType' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'CustomerType'
                                                    AND EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey ) I   ON I.ParameterAlt_Key = A.CustomerTypeAlt_Key
                                   JOIN ( 
                                          -------
                                          SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'CategoryofBankFI' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'CategoryofBankFI'
                                                    AND EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey ) J   ON J.ParameterAlt_Key = A.CategoryofBankFIAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                            FROM WillfulDefaulters_mod 
                                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                                      AND AuthorisationStatus IN ( '1A' )

                                                              GROUP BY CustomerID )
                           ) A
                  	  GROUP BY A.ReportedByAlt_Key,A.CategoryofBankFIAlt_Key,A.ReportingBankFIAlt_Key,A.ReportingBranchAlt_Key,A.StateUTofBranchAlt_Key,A.CustomerID,A.PartyName,A.PAN,A.ReportingSerialNo,A.RegisteredOfficeAddress,A.OSAmountinlacs,A.WillfulDefaultDate,A.SuitFiledorNotAlt_Key,A.OtherBanksFIInvolvedAlt_Key,A.NameofOtherBanksFIAlt_Key,A.CustomerTypeAlt_Key,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'Customer' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_215 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
