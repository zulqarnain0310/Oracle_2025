--------------------------------------------------------
--  DDL for Function METADYNAMICINUPMAIN_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" 
(
  iv_BaseColumnValue IN VARCHAR2 DEFAULT '0' ,
  iv_ParentColumnValue IN VARCHAR2 DEFAULT '0' ,
  iv_TabID IN NUMBER DEFAULT 0 ,
  v_ColumnName IN VARCHAR2 DEFAULT '|Advocate|JuniorAdvocate|ProfEntityId|ProfParentEntityId|ConstitutionAlt_Key|SalutationAlt_Key|ProfessionalName|RegistrationNo|BarCouncilStateAlt_key|Qualification|CategoryAlt_Key|WealthTaxActRegNo|PANNo|AccountNo|IFSCCode|BankBranchCode|BankBranchName|GuardianName|ReligionAlt_Key|CasteAlt_Key|WorkAreaCity|MobileNo|Email|ContactPerName|ContactPerMobileNo|EmpRefNo|EmpanelmentNo|EmpanellingAuthorityAlt_key|RefNoforreimbursofBill|RenewalRefNo|DepanelmentRefNo|DepanalmentReasonAlt_key|AdvocateStatus|Address' ,
  iv_DataValue IN VARCHAR2 DEFAULT '|151|20|dasd|asd|1321546464|54654564|654654654|564564|564fdsdf|dfsdf|8087879797|jhasdhkasd@fasd.com' ,
  v_DataValueAuth IN VARCHAR2,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 3500 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 9999 ,
  v_CreateModifyApprovedBy IN VARCHAR2 DEFAULT 'D2KAMAR' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_TimeKey IN NUMBER DEFAULT 9999 ,
  iv_AuthMode IN CHAR DEFAULT 'Y' ,
  v_MenuID IN NUMBER DEFAULT 6669 ,
  v_Remark IN VARCHAR2 DEFAULT NULL ,
  v_ChangeFields IN VARCHAR2 DEFAULT NULL ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_DataValue VARCHAR2(4000) := iv_DataValue;
   v_AuthMode CHAR(2) := iv_AuthMode;
   v_BaseColumnValue VARCHAR2(50) := iv_BaseColumnValue;
   v_TabID NUMBER(10,0) := iv_TabID;
   v_ParentColumnValue VARCHAR2(50) := iv_ParentColumnValue;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   DECLARE
      /*DECLARE LOCAL VARIABLES*/
      v_ColName VARCHAR2(4000);
      v_DataVal VARCHAR2(4000);
      v_ColName_DataVal VARCHAR2(4000);
      v_SourceTableName VARCHAR2(50);
      v_BranchCode VARCHAR2(20) := ' ';
      v_TabApplicable NUMBER(1,0) := 0;
      /*	LOOP FIR MULTIPLI TABLE INSERT	*/
      --select * from tt_TmpSrcTable_3
      v_RowId NUMBER(3,0) := 1;
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      v_DataValue := REPLACE(v_DataValue, '&', '_AND_') ;
      IF v_AuthMode IN ( 'S','H','A' )
       THEN
       v_AuthMode := 'Y' ;
      END IF;
      DBMS_OUTPUT.PUT_LINE('Begin1');
      IF v_OperationFlag = 1 THEN
       v_BaseColumnValue := 0 ;
      END IF;
      SELECT 1 

        INTO v_TabApplicable
        FROM MetaDynamicScreenField 
       WHERE  MenuId = v_MenuId
                AND NVL(ParentcontrolID, 0) > 0
                AND ValidCode = 'Y';
      IF v_TabApplicable = 1
        AND v_TabId = 0 THEN

      BEGIN
         SELECT MIN(ParentcontrolID)  

           INTO v_TabId
           FROM MetaDynamicScreenField 
          WHERE  MenuId = v_MenuId
                   AND NVL(ParentcontrolID, 0) > 0
                   AND ValidCode = 'Y';

      END;
      END IF;
      DBMS_OUTPUT.PUT_LINE('Begin12');
      /*base work for data preparing */
      IF utils.object_id('Tempdb..tt_TmpData_3') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpData_3 ';
      END IF;
      /*	PREPARE	TEMP TABLE WITH SPLIT OF PIPE "|" SEPERATED COLUMNS AND DATA VALUE */
      DELETE FROM tt_TmpData_3;
      UTILS.IDENTITY_RESET('tt_TmpData_3');

      INSERT INTO tt_TmpData_3 SELECT DENSE_RANK() OVER ( PARTITION BY c.SourceTable ORDER BY c.SourceTable  ) TableSeq  ,
                                      c.SourceTable ,
                                      A.ControlName ,
                                      b.DataVal ,
                                      BaseColumnType 
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                          FROM DUAL  )  ) ColSeq  ,
                         a_SPLIT.VALUE('.', 'VARCHAR(8000)') ControlName  
                  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(v_ColumnName, '|', '</M><M>') || '</M>') ControlName  
                           FROM DUAL  ) A
                          /*TODO:SQLDEV*/ CROSS APPLY ControlName.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A
                  JOIN ( SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                 FROM DUAL  )  ) DataSeq  ,
                                a_SPLIT.VALUE('.', 'VARCHAR(8000)') DataVal  
                         FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(v_DataValue, '|', '</M><M>') || '</M>') DataVal  
                                  FROM DUAL  ) A
                                 /*TODO:SQLDEV*/ CROSS APPLY DataVal.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) b   ON A.ColSeq = b.DataSeq
                  LEFT JOIN MetaDynamicScreenField c   ON A.ControlName = c.ControlName
          WHERE  c.MenuID = v_MenuID
                   AND NVL(C.ParentcontrolID, 0) = CASE 
                                                        WHEN v_TabID > 0 THEN v_TabID
                 ELSE NVL(C.ParentcontrolID, 0)
                    END
                   AND ValidCode = 'Y';
      /* WORK FOR PREPARE UNIQUE TABLE LIST USING IN THE MENUID */
      IF utils.object_id('Tempdb..tt_TmpSrcTable_3') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpSrcTable_3 ';
      END IF;
      DELETE FROM tt_TmpSrcTable_3;
      /* FIND AND INSERT MAIN TABLE */
      INSERT INTO tt_TmpSrcTable_3
        ( SELECT 1 ,
                 SourceTable 
          FROM MetaDynamicScreenField A
                 JOIN ( SELECT MIN(ControlID)  ControlID  
                        FROM MetaDynamicScreenField 
                         WHERE  MenuID = v_MenuID
                                  AND BaseColumnType = 'BASE'
                                  AND NVL(ParentcontrolID, 0) = CASE 
                                                                     WHEN v_TabID > 0 THEN v_TabID
                                ELSE NVL(ParentcontrolID, 0)
                                   END
                                  AND ValidCode = 'Y' ) B   ON A.ControlID = B.ControlID
                 AND A.MenuID = v_MenuID
                 AND NVL(ParentcontrolID, 0) = CASE 
                                                    WHEN v_TabID > 0 THEN v_TabID
               ELSE NVL(ParentcontrolID, 0)
                  END
                 AND ValidCode = 'Y' );
      /* FIND AND INSERT OTHER TABLES */
      INSERT INTO tt_TmpSrcTable_3
        SELECT 1 + ROW_NUMBER() OVER ( ORDER BY SourceTable  ) ,
               SourceTable 
          FROM tt_TmpData_3 
         WHERE  SourceTable NOT IN ( SELECT SourceTable 
                                     FROM tt_TmpSrcTable_3  )

          GROUP BY SourceTable;
      /* DELETE RECORDS FOR SOURCE TABLE COLUM IS NULL*/
      DELETE tt_TmpSrcTable_3

       WHERE  SourceTable IS NULL;
      LOOP
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE v_RowId <= ( SELECT COUNT(1)  
                                FROM tt_TmpSrcTable_3  );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp != 1 THEN
            EXIT;
         END IF;

         DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            SELECT SourceTable 

              INTO v_SourceTableName
              FROM tt_TmpSrcTable_3 
             WHERE  RowId_ = v_RowId;
            /*PREPARING DATA FOR INSERT/UPDATE	*/
            /*merging of columns using in the table find in loop*/
            SELECT utils.stuff(( SELECT ',' || ControlName 
                                 FROM tt_TmpData_3 M1
                                  WHERE  SourceTable = v_SourceTableName ), 1, 1, ' ') 

              INTO v_ColName
              FROM tt_TmpData_3 M2;
            /*merging of data value  using in the table find in loop*/
            SELECT utils.stuff(( SELECT ',''' || DataVal || '''' 
                                 FROM tt_TmpData_3 M1
                                  WHERE  SourceTable = v_SourceTableName ), 1, 1, ' ') 

              INTO v_DataVal
              FROM tt_TmpData_3 M2;
            --SELECT * FROM tt_TmpData_3		
            --SELECT @DataVal,@ColName
            /*merging of Columns with data value  using in the table find in loop*/
            IF v_OperationFlag = 2 THEN

            BEGIN
               SELECT utils.stuff(( SELECT ',' || ControlName || '=''' || DataVal || '''' 
                                    FROM tt_TmpData_3 M1
                                     WHERE  SourceTable = v_SourceTableName ), 1, 1, ' ') 

                 INTO v_ColName_DataVal
                 FROM tt_TmpData_3 M2;

            END;
            END IF;
            /* Finding and Prepareing the Base column as Parent for Other Associated tables*/
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM MetaDynamicScreenField 
                                WHERE  MenuId = v_MenuID
                                         AND NVL(ParentcontrolID, 0) = CASE 
                                                                            WHEN v_TabID > 0 THEN v_TabID
                                       ELSE NVL(ParentcontrolID, 0)
                                          END
                                         AND BaseColumnType = 'PARENT'
                                         AND SourceTable = v_SourceTableName
                                         AND ValidCode = 'Y' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               IF NVL(v_ParentColumnValue, '0') = '0' THEN
                v_ParentColumnValue := v_BaseColumnValue ;
               END IF;

            END;
            END IF;
            /*Calling of Insert Update SP for refelecting the data in Main/Mod tables*/
            /* Will be call for each table usig for screen*/
            --select @ColName_DataVal
            utils.var_number :=MetaDynamicInUp(v_ColName,
                                               v_DataVal,
                                               v_DataValueAuth,
                                               v_ColName_DataVal,
                                               v_BaseColumnValue,
                                               v_ParentColumnValue,
                                               v_SourceTableName,
                                               v_EffectiveFromTimeKey,
                                               v_EffectiveToTimeKey,
                                               v_CreateModifyApprovedBy,
                                               v_OperationFlag,
                                               v_TimeKey,
                                               v_AuthMode,
                                               v_MenuID,
                                               v_TabID,
                                               v_Remark,
                                               v_ChangeFields,
                                               v_D2Ktimestamp,
                                               v_Result) ;
            DBMS_OUTPUT.PUT_LINE('Completed');
            IF v_Result = -1 THEN
             RETURN v_Result;
            END IF;
            v_BaseColumnValue := v_Result ;
            v_RowId := v_RowId + 1 ;

         END;
      END LOOP;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICINUPMAIN_15122023" TO "ADF_CDR_RBL_STGDB";
