--------------------------------------------------------
--  DDL for Procedure BUSINESSRULESETUPEXPRESSION_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" 
-- =============================================
 -- Author:		<Author  Triloki Kumar>
 -- Create date: <Create Date 26/03/2020>
 -- Description:	<Description Business setup rule  expression >
 -- =============================================

(
  v_XmlData IN CLOB,
  v_BusinessRule_Alt_key IN NUMBER,
  iv_Expression IN VARCHAR2,
  v_Userid IN VARCHAR2,
  v_ResultString OUT VARCHAR2,
  v_Result OUT NUMBER
)
AS
   v_Expression VARCHAR2(4000) := iv_Expression;

BEGIN

   IF utils.object_id('TEMPDB..tt_BusinessRuleSetupData_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BusinessRuleSetupData_2 ';
   END IF;
   DELETE FROM tt_BusinessRuleSetupData_2;
   UTILS.IDENTITY_RESET('tt_BusinessRuleSetupData_2');

   INSERT INTO tt_BusinessRuleSetupData_2 ( 
   	SELECT /*TODO:SQLDEV*/ c.value('./UniqueID[1]','int') /*END:SQLDEV*/ UniqueID  ,
           /*TODO:SQLDEV*/ c.value('./Businesscolalt_key[1]','int') /*END:SQLDEV*/ Businesscolalt_key  ,
           /*TODO:SQLDEV*/ c.value('./Scope[1]','varchar(MAX)') /*END:SQLDEV*/ Scope  ,
           /*TODO:SQLDEV*/ c.value('./ParameterName[1]','varchar(MAX)') /*END:SQLDEV*/ ParameterName  ,
           /*TODO:SQLDEV*/ c.value('./Businesscolvalues1[1]','varchar(MAX)') /*END:SQLDEV*/ Businesscolvalues1  ,
           /*TODO:SQLDEV*/ c.value('./Businesscolvalues[1]','varchar(MAX)') /*END:SQLDEV*/ Businesscolvalues2  
   	  FROM TABLE(/*TODO:SQLDEV*/ @XmlData.nodes('/DataSet/FinalExpData') AS t(c) /*END:SQLDEV*/)  );--/DataSet/GridData
   --SELECT * FROM tt_BusinessRuleSetupData_2
   IF utils.object_id('TEMPDB..tt_SplitValue_16') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue_16 ';
   END IF;
   DELETE FROM tt_SplitValue_16;
   UTILS.IDENTITY_RESET('tt_SplitValue_16');

   INSERT INTO tt_SplitValue_16 ( 
   	SELECT UniqueID ,
           a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
   	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Businesscolvalues1, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                    UniqueID 
             FROM tt_BusinessRuleSetupData_2  ) A
              /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
   IF utils.object_id('TEMPDB..tt_Temp23_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp23_2 ';
   END IF;
   DELETE FROM tt_Temp23_2;
   UTILS.IDENTITY_RESET('tt_Temp23_2');

   INSERT INTO tt_Temp23_2 ( 
   	SELECT UniqueID ,
           '''' || Businesscolvalues1 || '''' businesscolvalues1  
   	  FROM tt_SplitValue_16  );
   IF utils.object_id('TEMPDB..tt_FinalTable_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FinalTable_2 ';
   END IF;
   DELETE FROM tt_FinalTable_2;
   UTILS.IDENTITY_RESET('tt_FinalTable_2');

   INSERT INTO tt_FinalTable_2 ( 
   	SELECT utils.stuff(( SELECT ',' || businesscolvalues1 
                         FROM tt_Temp23_2 a
                          WHERE  a.uniqueid = b.uniqueid ), 
                       --group by uniqueid
                       1, 1, ' ') businesscolvalues1  ,
           b.uniqueid 
   	  FROM tt_Temp23_2 b
   	  GROUP BY b.uniqueid );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.Businesscolvalues1
   FROM A ,tt_BusinessRuleSetupData_2 A
          JOIN tt_FinalTable_2 B   ON A.UniqueID = B.UniqueID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Businesscolvalues1 = src.Businesscolvalues1;
   DELETE FROM tt_TEMP1_6;
   UTILS.IDENTITY_RESET('tt_TEMP1_6');

   INSERT INTO tt_TEMP1_6 SELECT A.UniqueID ,
                                 B.BusinessRuleColDesc || ' ' || CASE 
                                                                      WHEN DP.ParameterName = 'LESSTHAN' THEN ' LESSTHAN ' || A.Businesscolvalues1
                                                                      WHEN DP.ParameterName = 'GreaterThan' THEN ' GreaterThan ' || A.Businesscolvalues1
                                                                      WHEN DP.ParameterName = 'LessThanEqualTo' THEN ' LessThanEqualTo ' || A.Businesscolvalues1
                                                                      WHEN DP.ParameterName = 'GreaterThanEqualTo' THEN ' GreaterThanEqualTo ' || A.Businesscolvalues1
                                                                      WHEN DP.ParameterName = 'Between' THEN 'Between ' || A.Businesscolvalues1 || ' AND ''' || A.Businesscolvalues2 || ''''
                                                                      WHEN DP.ParameterName = 'In' THEN 'IN( ' || A.Businesscolvalues1 || ')'
                                                                      WHEN DP.ParameterName = 'EqualTo' THEN '= ' || A.Businesscolvalues1
                                                                      WHEN DP.ParameterName = 'Like' THEN '''%''' || A.Businesscolvalues1 || '''%'''   END FINALEXPRESSION  ,
                                 ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                  FROM DUAL  )  ) row1  
        FROM tt_BusinessRuleSetupData_2 A
               JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
               JOIN DimParameter DP   ON DP.ParameterName = A.ParameterName;
   v_Expression := REPLACE(v_Expression, '(', '( ') ;
   v_Expression := REPLACE(v_Expression, ')', ' )') ;
   IF utils.object_id('TEMPDB..tt_temp2_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_2 ';
   END IF;
   DELETE FROM tt_temp2_2;
   UTILS.IDENTITY_RESET('tt_temp2_2');

   INSERT INTO tt_temp2_2 ( 
   	SELECT * 
   	  FROM TABLE(SPLIT(v_EXPRESSION, ' '))  );
   IF utils.object_id('TEMPDB..tt_temp3_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3_2 ';
   END IF;
   DELETE FROM tt_temp3_2;
   INSERT INTO tt_temp3_2
     ( SELECT utils.stuff(( SELECT ' ' || COALESCE(UTILS.CONVERT_TO_VARCHAR2(B.finalexpression,4000), A.Items) 
                            FROM tt_temp2_2 a
                                   LEFT JOIN tt_TEMP1_6 b   ON a.items = UTILS.CONVERT_TO_VARCHAR2(b.uniqueid,4000) ), 1, 1, ' ') finalexpression  
         FROM DUAL  );
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'LessThanEqualTo', '<=');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'GreaterThanEqualTo', '>=');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'LESSTHAN', '<');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'GreaterThan', '>');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'TypeOfAdvance', 'ADVTYPE');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'Productcode', 'GLProductAlt_Key');
   UPDATE tt_temp3_2
      SET FinalExpression = REPLACE(FinalExpression, 'GLCODE', 'GL_CODE');
   SELECT FinalExpression 

     INTO v_ResultString
     FROM tt_temp3_2 ;
   v_Result := 1 ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION_04122023" TO "ADF_CDR_RBL_STGDB";
