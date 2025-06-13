--------------------------------------------------------
--  DDL for Procedure BUSINESSRULESETUPSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================
 -- Author:		<Author Triloki Kumar>
 -- Create date: <Create Date 13/03/2020>
 -- Description:	<Description Business rule setup details select>
 -- =============================================

(
  v_CatAlt_key IN NUMBER,
  v_UserId IN VARCHAR2,
  v_OperationFlag IN NUMBER,
  v_MenuID IN NUMBER DEFAULT 14613 
)
AS
   --declare 
   ----@Territoryalt_key			INT,
   --@CatAlt_key				INT=101
   --,@UserId					Varchar(50)='FnaChecker'
   --,@OperationFlag INT='20'
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   --select * from SysCRisMacMenu where MenuCaption like '%Business%'

   BEGIN
      IF ( v_OperationFlag IN ( 16,17 )
       ) THEN

      BEGIN
         IF utils.object_id('TEMPDB..tt_PRODUCTCODE_2') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PRODUCTCODE_2 ';
         END IF;
         DELETE FROM tt_PRODUCTCODE_2;
         UTILS.IDENTITY_RESET('tt_PRODUCTCODE_2');

         INSERT INTO tt_PRODUCTCODE_2 ( 
         	SELECT A.UniqueID ,
                 Businesscolvalues1 
         	  FROM DimBusinessRuleSetup A
                   JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
         	 WHERE  B.BusinessRuleColDesc = 'PRODUCTCODE'
                    AND A.CatAlt_key = v_CatAlt_key );
         IF utils.object_id('TEMPDB..tt_SplitValue1_2') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue1_2 ';
         END IF;
         DELETE FROM tt_SplitValue1_2;
         UTILS.IDENTITY_RESET('tt_SplitValue1_2');

         INSERT INTO tt_SplitValue1_2 ( 
         	SELECT UniqueID ,
                 a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
         	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Businesscolvalues1, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                          UniqueID 
                   FROM tt_PRODUCTCODE_2  ) A
                    /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
         IF utils.object_id('TEMPDB..tt_TempValue_2') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempValue_2 ';
         END IF;
         DELETE FROM tt_TempValue_2;
         UTILS.IDENTITY_RESET('tt_TempValue_2');

         INSERT INTO tt_TempValue_2 ( 
         	SELECT A.UniqueID ,
                 B.ProductCode 
         	  FROM tt_SplitValue1_2 A
                   JOIN DimGLProduct B   ON A.Businesscolvalues1 = B.GLProductAlt_Key );
         IF utils.object_id('TEMPDB..tt_FinalTable1_2') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FinalTable1_2 ';
         END IF;
         DELETE FROM tt_FinalTable1_2;
         UTILS.IDENTITY_RESET('tt_FinalTable1_2');

         INSERT INTO tt_FinalTable1_2 ( 
         	SELECT utils.stuff(( SELECT DISTINCT ',' || ProductCode 
                               FROM tt_TempValue_2 a
                                WHERE  a.uniqueid = b.uniqueid ), 
                             --group by uniqueid
                             1, 1, ' ') ProductCode  ,
                 b.uniqueid 
         	  FROM tt_TempValue_2 b
         	  GROUP BY b.uniqueid );
         OPEN  v_cursor FOR
            SELECT A.BusinessRule_Alt_key ,
                   A.UniqueID ,
                   A.Businesscolalt_key ,
                   B.BusinessRuleColDesc ,
                   A.Scope SelectScopeAlt_Key  ,
                   C.ParameterName ,
                   A.Businesscolvalues1 Businesscolvalues1  ,
                   CASE 
                        WHEN D.UniqueID IS NOT NULL THEN D.ProductCode
                   ELSE A.Businesscolvalues1
                      END Businesscolvalues1_Display  ,
                   A.Businesscolvalues ,
                   A.Businesscolvalues ColumnValuesSecAlt_Key  ,
                   A.Businesscolvalues1 || CASE 
                                                WHEN NVL(A.Businesscolvalues, ' ') <> ' ' THEN '|' || A.Businesscolvalues
                   ELSE ' '
                      END BusinesscolvaluesPipe  ,
                   --,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                   A.CreatedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20) DateCreated  ,
                   A.ApprovedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20) DateApproved  ,
                   A.ModifiedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20) DateModified  ,
                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                   NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                   'BusinessGridData' TableName  
              FROM DimBusinessRuleSetup_mod A
                     JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
                     JOIN DimParameter C   ON C.ParameterAlt_Key = A.Scope
                     AND C.DimParameterName = 'DimScopeType'
                     LEFT JOIN tt_FinalTable1_2 D   ON D.UniqueID = A.UniqueID
             WHERE
            --A.Territoryalt_key=@Territoryalt_key
             --AND 
              A.CatAlt_key = v_CatAlt_key
                AND A.Entitykey IN ( SELECT MAX(EntityKey)  
                                     FROM DimBusinessRuleSetup_mod 
                                      WHERE  EffectiveFromTimeKey <= 49999
                                               AND EffectiveToTimeKey >= 49999
                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                       GROUP BY BusinessRule_Alt_key )

              ORDER BY A.UniqueID ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF ( v_OperationFlag NOT IN ( 16,17,20 )
       ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         DBMS_OUTPUT.PUT_LINE('go');
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM DimProvision_SegStd_Mod 
                             WHERE  BankCategoryID = v_CatAlt_key
                                      AND AuthorisationStatus IN ( 'NP','MP' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN
          DECLARE
            v_Result NUMBER(10,0);

         BEGIN
            DBMS_OUTPUT.PUT_LINE('00');
            v_Result := 1 ;

         END;
         ELSE

         BEGIN
            v_Result := 0 ;

         END;
         END IF;
         OPEN  v_cursor FOR
            SELECT v_Result Result  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         IF utils.object_id('TEMPDB..tt_PRODUCTCODE_216') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PRODUCTCODE16_2 ';
         END IF;
         DELETE FROM tt_PRODUCTCODE16_2;
         UTILS.IDENTITY_RESET('tt_PRODUCTCODE16_2');

         INSERT INTO tt_PRODUCTCODE16_2 ( 
         	SELECT A.UniqueID ,
                 Businesscolvalues1 
         	  FROM DimBusinessRuleSetup A
                   JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
         	 WHERE  B.BusinessRuleColDesc = 'PRODUCTCODE'
                    AND A.CatAlt_key = v_CatAlt_key );
         IF utils.object_id('TEMPDB..tt_SplitValue1_26') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue16_2 ';
         END IF;
         DELETE FROM tt_SplitValue16_2;
         UTILS.IDENTITY_RESET('tt_SplitValue16_2');

         INSERT INTO tt_SplitValue16_2 ( 
         	SELECT UniqueID ,
                 a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
         	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Businesscolvalues1, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                          UniqueID 
                   FROM tt_PRODUCTCODE16_2  ) A
                    /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
         IF utils.object_id('TEMPDB..tt_TempValue_216') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempValue16_2 ';
         END IF;
         DELETE FROM tt_TempValue16_2;
         UTILS.IDENTITY_RESET('tt_TempValue16_2');

         INSERT INTO tt_TempValue16_2 ( 
         	SELECT A.UniqueID ,
                 B.ProductCode 
         	  FROM tt_SplitValue16_2 A
                   JOIN DimGLProduct B   ON A.Businesscolvalues1 = B.GLProductAlt_Key );
         IF utils.object_id('TEMPDB..tt_FinalTable1_26') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FinalTable16_2 ';
         END IF;
         DELETE FROM tt_FinalTable16_2;
         UTILS.IDENTITY_RESET('tt_FinalTable16_2');

         INSERT INTO tt_FinalTable16_2 ( 
         	SELECT utils.stuff(( SELECT DISTINCT ',' || ProductCode 
                               FROM tt_TempValue16_2 a
                                WHERE  a.uniqueid = b.uniqueid ), 
                             --group by uniqueid
                             1, 1, ' ') ProductCode  ,
                 b.uniqueid 
         	  FROM tt_TempValue16_2 b
         	  GROUP BY b.uniqueid );
         OPEN  v_cursor FOR
            SELECT A.BusinessRule_Alt_key ,
                   A.UniqueID ,
                   A.Businesscolalt_key ,
                   B.BusinessRuleColDesc ,
                   A.Scope SelectScopeAlt_Key  ,
                   C.ParameterName ,
                   A.Businesscolvalues1 Businesscolvalues1  ,
                   CASE 
                        WHEN D.UniqueID IS NOT NULL THEN D.ProductCode
                   ELSE A.Businesscolvalues1
                      END Businesscolvalues1_Display  ,
                   A.Businesscolvalues ,
                   A.Businesscolvalues ColumnValuesSecAlt_Key  ,
                   A.Businesscolvalues1 || CASE 
                                                WHEN NVL(A.Businesscolvalues, ' ') <> ' ' THEN '|' || A.Businesscolvalues
                   ELSE ' '
                      END BusinesscolvaluesPipe  ,
                   --,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                   A.CreatedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20) DateCreated  ,
                   A.ApprovedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20) DateApproved  ,
                   A.ModifiedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20) DateModified  ,
                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                   NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                   'BusinessGridData' TableName  
              FROM DimBusinessRuleSetup A
                     JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
                     JOIN DimParameter C   ON C.ParameterAlt_Key = A.Scope
                     AND C.DimParameterName = 'DimScopeType'
                     LEFT JOIN tt_FinalTable16_2 D   ON D.UniqueID = A.UniqueID
             WHERE
            --A.Territoryalt_key=@Territoryalt_key
             --AND 
              A.CatAlt_key = v_CatAlt_key
                AND NVL(A.AuthorisationStatus, 'A') = 'A'
            UNION 

            --order by a.UniqueID
            SELECT A.BusinessRule_Alt_key ,
                   A.UniqueID ,
                   A.Businesscolalt_key ,
                   B.BusinessRuleColDesc ,
                   A.Scope SelectScopeAlt_Key  ,
                   C.ParameterName ,
                   A.Businesscolvalues1 Businesscolvalues1  ,
                   CASE 
                        WHEN D.UniqueID IS NOT NULL THEN D.ProductCode
                   ELSE A.Businesscolvalues1
                      END Businesscolvalues1_Display  ,
                   A.Businesscolvalues ,
                   A.Businesscolvalues ColumnValuesSecAlt_Key  ,
                   A.Businesscolvalues1 || CASE 
                                                WHEN NVL(A.Businesscolvalues, ' ') <> ' ' THEN '|' || A.Businesscolvalues
                   ELSE ' '
                      END BusinesscolvaluesPipe  ,
                   --,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                   A.CreatedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20) DateCreated  ,
                   A.ApprovedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20) DateApproved  ,
                   A.ModifiedBy ,
                   UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20) DateModified  ,
                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                   NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                   'BusinessGridData' TableName  
              FROM DimBusinessRuleSetup_mod A
                     JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
                     JOIN DimParameter C   ON C.ParameterAlt_Key = A.Scope
                     AND C.DimParameterName = 'DimScopeType'
                     LEFT JOIN tt_FinalTable16_2 D   ON D.UniqueID = A.UniqueID
             WHERE
            --A.Territoryalt_key=@Territoryalt_key
             --AND 
              A.CatAlt_key = v_CatAlt_key
                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                     FROM DimBusinessRuleSetup_mod 
                                      WHERE  EffectiveFromTimeKey <= 49999
                                               AND EffectiveToTimeKey >= 49999
                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                       GROUP BY BusinessRule_Alt_key )

              ORDER BY A.UniqueID ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      OPEN  v_cursor FOR
         SELECT Expression ,
                SystemFinalExpression ,
                UserFinalExpression ,
                'ExpressionSelect' TableName  
           FROM DimProvision_SegStd_Mod 
          WHERE
         --ProvisionAlt_Key=@CatAlt_key AND EffectiveToTimeKey=49999
           BankCategoryID = v_CatAlt_key
             AND EffectiveToTimeKey = 49999
             AND NVL(Expression, ' ') <> ' ' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      IF utils.object_id('TEMPDB..tt_PRODUCTCODE_220') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PRODUCTCODE20_2 ';
      END IF;
      DELETE FROM tt_PRODUCTCODE20_2;
      UTILS.IDENTITY_RESET('tt_PRODUCTCODE20_2');

      INSERT INTO tt_PRODUCTCODE20_2 ( 
      	SELECT A.UniqueID ,
              Businesscolvalues1 
      	  FROM DimBusinessRuleSetup A
                JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
      	 WHERE  B.BusinessRuleColDesc = 'PRODUCTCODE'
                 AND A.CatAlt_key = v_CatAlt_key );
      IF utils.object_id('TEMPDB..tt_SplitValue20_2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue20_2 ';
      END IF;
      DELETE FROM tt_SplitValue20_2;
      UTILS.IDENTITY_RESET('tt_SplitValue20_2');

      INSERT INTO tt_SplitValue20_2 ( 
      	SELECT UniqueID ,
              a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
      	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Businesscolvalues1, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                       UniqueID 
                FROM tt_PRODUCTCODE20_2  ) A
                 /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
      IF utils.object_id('TEMPDB..tt_TempValue_220') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempValue20_2 ';
      END IF;
      DELETE FROM tt_TempValue20_2;
      UTILS.IDENTITY_RESET('tt_TempValue20_2');

      INSERT INTO tt_TempValue20_2 ( 
      	SELECT A.UniqueID ,
              B.ProductCode 
      	  FROM tt_SplitValue20_2 A
                JOIN DimGLProduct B   ON A.Businesscolvalues1 = B.GLProductAlt_Key );
      IF utils.object_id('TEMPDB..tt_FinalTable20_2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FinalTable20_2 ';
      END IF;
      DELETE FROM tt_FinalTable20_2;
      UTILS.IDENTITY_RESET('tt_FinalTable20_2');

      INSERT INTO tt_FinalTable20_2 ( 
      	SELECT utils.stuff(( SELECT DISTINCT ',' || ProductCode 
                            FROM tt_TempValue20_2 a
                             WHERE  a.uniqueid = b.uniqueid ), 
                          --group by uniqueid
                          1, 1, ' ') ProductCode  ,
              b.uniqueid 
      	  FROM tt_TempValue20_2 b
      	  GROUP BY b.uniqueid );
      --print 'AA'
      OPEN  v_cursor FOR
         SELECT A.BusinessRule_Alt_key ,
                A.UniqueID ,
                A.Businesscolalt_key ,
                B.BusinessRuleColDesc ,
                A.Scope SelectScopeAlt_Key  ,
                C.ParameterName ,
                A.Businesscolvalues1 Businesscolvalues1  ,
                CASE 
                     WHEN D.UniqueID IS NOT NULL THEN D.ProductCode
                ELSE A.Businesscolvalues1
                   END Businesscolvalues1_Display  ,
                A.Businesscolvalues ,
                A.Businesscolvalues ColumnValuesSecAlt_Key  ,
                A.Businesscolvalues1 || CASE 
                                             WHEN NVL(A.Businesscolvalues, ' ') <> ' ' THEN '|' || A.Businesscolvalues
                ELSE ' '
                   END BusinesscolvaluesPipe  ,
                --,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                A.CreatedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20) DateCreated  ,
                A.ApprovedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20) DateApproved  ,
                A.ModifiedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20) DateModified  ,
                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                'BusinessGridData' TableName  
           FROM DimBusinessRuleSetup_mod A
                  JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
                  JOIN DimParameter C   ON C.ParameterAlt_Key = A.Scope
                  AND C.DimParameterName = 'DimScopeType'
                  LEFT JOIN tt_FinalTable20_2 D   ON D.UniqueID = A.UniqueID
          WHERE
         --A.Territoryalt_key=@Territoryalt_key
          --AND 
           A.CatAlt_key = v_CatAlt_key
             AND A.Entitykey IN ( SELECT MAX(EntityKey)  
                                  FROM DimBusinessRuleSetup_mod 
                                   WHERE  EffectiveFromTimeKey <= 49999
                                            AND EffectiveToTimeKey >= 49999

                                            --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                                            AND (CASE 
                                                      WHEN v_AuthLevel = 2
                                                        AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                                                       THEN 1
                                                      WHEN v_AuthLevel = 1
                                                        AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                                                       THEN 1
                                          ELSE 0
                                             END) = 1
                                    GROUP BY BusinessRule_Alt_key )

           ORDER BY A.UniqueID ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
