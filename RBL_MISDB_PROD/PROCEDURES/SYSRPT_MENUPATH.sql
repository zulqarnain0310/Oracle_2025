--------------------------------------------------------
--  DDL for Procedure SYSRPT_MENUPATH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SYSRPT_MENUPATH" 
(
  v_ReportName IN VARCHAR2,
  v_TimeKey IN NUMBER
)
AS
   v_Menuid NUMBER(10,0);
   v_Parentid NUMBER(10,0);
   v_Isfirstgrp CHAR(1);
   v_ThirdGroup CHAR(1);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT ReportMenuid 

     INTO v_Menuid
     FROM RBL_MISDB_PROD.SysReportDirectory 
    WHERE  ReportRdlFullName = v_ReportName
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey 
     FETCH FIRST 1 ROWS ONLY;
   SELECT ParentId 

     INTO v_Parentid
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_Menuid
             AND Visible = 1 
     FETCH FIRST 1 ROWS ONLY;
   SELECT 'Y' 

     INTO v_Isfirstgrp
     FROM SysCRisMacMenu M
    WHERE  M.MenuId IS NULL
             AND M.ParentId IS NULL
             AND MenuTitleId = v_Parentid
             AND Visible = 1;
   SELECT ThirdGroup 

     INTO v_ThirdGroup
     FROM SysCRisMacMenu M
    WHERE  MenuId = v_Menuid
             AND Visible = 1;
   IF ( NVL(v_ThirdGroup, ' ') = 'Y'
     AND NVL(v_Isfirstgrp, ' ') <> 'Y' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT REPLACE('Menu Path: ' || NVL(M.MenuCaption || ' / ', ' ') || NVL(Main.CAP, ' '), '&', ' ') Path1  
           FROM SysCRisMacMenu M
                  JOIN ( SELECT F.ParentId ,
                                NVL(F.MenuCaption || ' / ', ' ') || NVL(SEC.SECCAP || ' / ', ' ') || NVL(SEC.THRIDCAP, ' ') CAP  
                         FROM SysCRisMacMenu F
                                JOIN ( SELECT S.ParentId ,
                                              S.MenuCaption SECCAP  ,
                                              THR.THRIDCAP 
                                       FROM SysCRisMacMenu S
                                              JOIN ( SELECT ParentId ,
                                                            MenuCaption THRIDCAP  
                                                     FROM SysCRisMacMenu 
                                                      WHERE  Menuid = v_Menuid
                                                               AND Visible = 1 ) THR   ON THR.ParentId = S.MenuId ) SEC   ON SEC.ParentId = F.MenuId ) Main   ON Main.ParentId = M.MenuTitleId
          WHERE  M.MenuId IS NULL
                   AND M.ParentId IS NULL
                   AND Visible = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      IF ( NVL(v_ThirdGroup, ' ') <> 'Y'
        AND NVL(v_Isfirstgrp, ' ') <> 'Y' ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT REPLACE('Menu Path: ' || NVL(M.MenuCaption || ' / ', ' ') || NVL(MAIN.CAP, ' '), '&', ' ') Path1  
              FROM SysCRisMacMenu M
                     JOIN ( SELECT S.ParentId ,
                                   NVL(S.MenuCaption || ' / ', ' ') || NVL(THR.THRIDCAP, ' ') CAP  
                            FROM ( SELECT ParentId ,
                                          MenuCaption THRIDCAP  
                                   FROM SysCRisMacMenu 
                                    WHERE  Menuid = v_Menuid
                                             AND Visible = 1 ) THR
                                   LEFT JOIN SysCRisMacMenu S   ON THR.ParentId = S.MenuId ) MAIN   ON MAIN.ParentId = M.MenuTitleId
             WHERE  M.MenuId IS NULL
                      AND M.ParentId IS NULL
                      AND Visible = 1 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         IF ( NVL(v_Isfirstgrp, ' ') = 'Y'
           AND NVL(v_ThirdGroup, ' ') <> 'Y' ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT REPLACE('Menu Path: ' || NVL(S.MenuCaption || ' / ', ' ') || NVL(THR.THRIDCAP, ' '), '&', ' ') Path1  
                 FROM ( SELECT ParentId ,
                               MenuCaption THRIDCAP  
                        FROM SysCRisMacMenu 
                         WHERE  Menuid = v_Menuid
                                  AND Visible = 1 ) THR
                        LEFT JOIN SysCRisMacMenu S   ON THR.ParentId = S.MenuTitleId
                        AND S.MenuId IS NULL
                        AND S.ParentId IS NULL
                        AND Visible = 1 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSRPT_MENUPATH" TO "ADF_CDR_RBL_STGDB";
