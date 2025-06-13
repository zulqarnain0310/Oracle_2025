--------------------------------------------------------
--  DDL for Procedure BUSINESSRULESETUPEXPRESSION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" 
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

   IF utils.object_id('TEMPDB..GTT_BusinessRuleSetupData') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BusinessRuleSetupData ';
   END IF;
   DELETE FROM GTT_BusinessRuleSetupData;
   UTILS.IDENTITY_RESET('GTT_BusinessRuleSetupData');

   INSERT INTO GTT_BusinessRuleSetupData ( UniqueID,
                                        Businesscolalt_key,
                                        Scope,
                                        ParameterName,
                                        Businesscolvalues1,
                                        Businesscolvalues2
                                        )
                       SELECT UniqueID	,
                                Businesscolalt_key	,
                                Scope	,
                                ParameterName	,
                                Businesscolvalues1	,
                                Businesscolvalues2	
                    FROM XMLTABLE('/Root/Sheet1'  passing xmlparse(document v_XmlData)
                        columns UniqueID VARCHAR(20) PATH 'UniqueID',
                                Businesscolalt_key VARCHAR(20) PATH 'Businesscolalt_key',
                                Scope VARCHAR(20) PATH 'Scope',
                                ParameterName VARCHAR(20) PATH 'ParameterName',
                                Businesscolvalues1 VARCHAR(20) PATH 'Businesscolvalues1',
                                Businesscolvalues2 VARCHAR(20) PATH 'Businesscolvalues2'
                                )C;

      
      
   --SELECT * FROM GTT_BusinessRuleSetupData
   IF utils.object_id('TEMPDB..GTT_SplitValue') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_SplitValue ';
   END IF;
   DELETE FROM GTT_SplitValue;
   UTILS.IDENTITY_RESET('GTT_SplitValue');

   INSERT INTO GTT_SplitValue (UniqueID,Businesscolvalues1 )
   	  SELECT  UniqueID 
                    ,SPLIT_STRING(Businesscolvalues1)Businesscolvalues1 
             FROM GTT_BusinessRuleSetupData  
              ;
   IF utils.object_id('TEMPDB..GTT_Temp23') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_Temp23 ';
   END IF;
   DELETE FROM GTT_Temp23;
   UTILS.IDENTITY_RESET('GTT_Temp23');

   INSERT INTO GTT_Temp23 ( 
   	SELECT UniqueID ,
            Businesscolvalues1
   	  FROM GTT_SplitValue  );
   
   IF utils.object_id('TEMPDB..GTT_FinalTable') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_FinalTable ';
   END IF;
   
   DELETE FROM GTT_FinalTable;
   UTILS.IDENTITY_RESET('GTT_FinalTable');

   INSERT INTO GTT_FinalTable (uniqueid,businesscolvalues1)
   	SELECT uniqueid,LISTAGG(businesscolvalues1,',') WITHIN GROUP (ORDER BY uniqueid)  AS businesscolvalues1
                         FROM GTT_Temp23 a
                          GROUP BY uniqueid
                      ;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.Businesscolvalues1
   FROM A ,GTT_BusinessRuleSetupData A
          JOIN GTT_FinalTable B   ON A.UniqueID = B.UniqueID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Businesscolvalues1 = src.Businesscolvalues1;
   DELETE FROM tt_TEMP1_5;
   UTILS.IDENTITY_RESET('tt_TEMP1_5');

   INSERT INTO tt_TEMP1_5 SELECT A.UniqueID ,
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
        FROM GTT_BusinessRuleSetupData A
               JOIN DimBusinessRuleCol B   ON A.Businesscolalt_key = B.BusinessRuleColAlt_Key
               JOIN DimParameter DP   ON DP.ParameterName = A.ParameterName;
   v_Expression := REPLACE(v_Expression, '(', '( ') ;
   v_Expression := REPLACE(v_Expression, ')', ' )') ;
   IF utils.object_id('TEMPDB..tt_temp2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2 ';
   END IF;
   DELETE FROM tt_temp2;
   UTILS.IDENTITY_RESET('tt_temp2');

   INSERT INTO tt_temp2 ( 
   	SELECT * 
   	  FROM TABLE(SPLIT(v_EXPRESSION, ' '))  );
   IF utils.object_id('TEMPDB..tt_temp3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3 ';
   END IF;
   DELETE FROM tt_temp3;
   INSERT INTO tt_temp3
     ( SELECT utils.stuff(( SELECT ' ' || COALESCE(UTILS.CONVERT_TO_VARCHAR2(B.finalexpression,4000), A.Items) 
                            FROM tt_temp2 a
                                   LEFT JOIN tt_TEMP1_5 b   ON a.items = UTILS.CONVERT_TO_VARCHAR2(b.uniqueid,4000) ), 1, 1, ' ') finalexpression  
         FROM DUAL  );
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'LessThanEqualTo', '<=');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'GreaterThanEqualTo', '>=');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'LESSTHAN', '<');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'GreaterThan', '>');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'TypeOfAdvance', 'ADVTYPE');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'Productcode', 'GLProductAlt_Key');
   UPDATE tt_temp3
      SET FinalExpression = REPLACE(FinalExpression, 'GLCODE', 'GL_CODE');
   SELECT FinalExpression 

     INTO v_ResultString
     FROM tt_temp3 ;
   v_Result := 1 ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUSINESSRULESETUPEXPRESSION" TO "ADF_CDR_RBL_STGDB";
