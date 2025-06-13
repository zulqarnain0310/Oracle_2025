--------------------------------------------------------
--  DDL for Procedure METADYNAMICSCREENSELECTCONTROL_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" 
-- ====================================================================================================================
 -- Author:			<Amar>
 -- Create Date:		<30-11-2014>
 -- Loading Master Data for Common Master Screen>
 -- ====================================================================================================================
 --- [MetaDynamicScreenSelectControl]  @MenuId =480, @TimeKey =24528, @Mode =1, @BaseColumnValue  = 0
 --alter table [BOB_LEGAL_PLUS_TEST].[dbo].[MetaDynamicMasterFilter] ADD FilterBySelectValue varchar(100),FilterByRemoveValue varchar(100), MenuId smallint

(
  v_MenuId IN NUMBER DEFAULT 6668 ,
  v_TimeKey IN NUMBER DEFAULT 24528 ,
  v_Mode IN NUMBER DEFAULT 2 ,
  iv_BaseColumnValue IN VARCHAR2 DEFAULT 1 ,
  iv_TabId IN NUMBER DEFAULT 0 
)
AS
   v_BaseColumnValue VARCHAR2(50) := iv_BaseColumnValue;
   v_TabId NUMBER(10,0) := iv_TabId;
   v_TabApplicable NUMBER(1,0) := 0;
   v_cursor SYS_REFCURSOR;
   v_temp NUMBER(1, 0) := 0;

BEGIN

   IF v_Mode = 1 THEN
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
   /*  fetch data from SysCrisMacMenu Table*/
   --DECLARE @Gridapplicable BIT= 0
   --SELECT @Gridapplicable=	1 FROM MetaDynamicScreenField A 
   --		INNER JOIN MetaDynamicGrid B
   --			ON A.ControlId=B.ControlId
   --	WHERE MENUID=@MENUID
   --		AND ISNULL(A.ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(A.ParentcontrolID,0) END 
   --		AND ISNULL(ValidCode,'N')='Y' 
   /*	FETCH META DATA  CONTROLS*/
   DBMS_OUTPUT.PUT_LINE(v_MenuId);
   OPEN  v_cursor FOR
      SELECT 'ScreenDetail' TableName  ,
             MenuCaption ,
             MenuId ,
             NonAllowOperation ,
             DeptGroupCode ,
             EnableMakerChecker ,
             ResponseTimeDisplay ,
             AccessLevel ,
             CASE 
                  WHEN NVL(GridApplicable, 'N') = 'Y' THEN 1
             ELSE 0
                END GridApplicable  ,
             CASE 
                  WHEN NVL(Accordian, 'N') = 'Y' THEN 1
             ELSE 0
                END Accordian  ,
             v_TabApplicable TabApplicable  ,
             UTILS.CONVERT_TO_VARCHAR2(SYSDATE,10,p_style=>103) CURDATE  ,
             sd.TimeKey 
        FROM SysCRisMacMenu 
               JOIN SysDayMatrix sd   ON UTILS.CONVERT_TO_VARCHAR2(sd.Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200)
       WHERE  MenuId = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'Meta' TableName  ,
             ControlID ,
             ParentcontrolID ,
             Label ,
             'DynamicMaster_' || REPLACE(Label, ' ', ' ') || '_Msg' FieldMessage  ,
             ControlName ColumnName  ,
             ControlType ,
             ------------------------------Added by Vijay ----
             --,CASE WHEN ControlName='BranchCode' AND ControlType='shutter' THEN 'f2autocomplete' 
             --	WHEN ControlName <> 'BranchCode' AND ControlType='shutter' THEN 'text'	
             --	ELSE ControlType END ControlType 
             ---------------------
             AutoCmpltMinLength ,
             Col_sm ,
             Col_lg ,
             Col_md ,
             SourceTable ,
             DisplayRowOrder ,
             DisplayColumnOrder ,
             SourceColumn ,
             ReferenceTableFilter ,
             NVL(ReferenceTable, 'NA') ReferenceTable  ,
             NVL(ReferenceColumn, 'NA') ReferenceColumn  ,
             RefColumnValue ,
             ReferenceTableCond ,
             BaseColumnType ,
             DataType ,
             NVL(DataMinLength, 0) DataMinLength  ,
             NVL(DataMaxLength, 0) DataMaxLength  ,
             ControlName ,
             Placeholder ,
             NVL(IsMandatory, 0) IsMandatory  ,
             NVL(IsVisible, 0) IsVisible  ,
             NVL(IsEditable, 0) IsEditable  ,
             NVL(IsUpper, 0) IsUpper  ,
             NVL(IsLower, 0) IsLower  ,
             NVL(ISDBPull, 0) ISDBPull  ,
             NVL(IsF2Button, 0) IsF2Button  ,
             NVL(IsCloseButton, 0) IsCloseButton  ,
             NVL(IsParentToChild, 0) IsParentToChild  ,
             NVL(IsChildToParent, 0) IsChildToParent  ,
             NVL(IsAlwaysDisable, 0) IsAlwaysDisable ,--Added by Amol 05 12 2017

             DisAllowedChar ,
             AllowedChar ,
             OnBlur ,
             OnBlurParameter ,
             OnClick ,
             OnClickParameter ,
             OnChange ,
             OnChangeParameter ,
             OnKeyPress ,
             OnKeyPressParameter ,
             OnFormLoad ,
             OnFormLoadParameter ,
             DefaultValue ,
             NVL(SkipColumnInQuery, 'N') SkipColumnInQuery  ,
             NVL(Class, ' ') Class  ,
             NVL(Style, ' ') Style  ,
             --,CASE WHEN @Gridapplicable=1 THEN 'Y' ELSE 'N' END AS GridApplicable
             NVL(ApplicableForWorkFlow, 'N') ApplicableForWorkFlow  ,
             NVL(EditprevStageData, 0) EditprevStageData  ,
             NVL(IsAlwaysDisable, ' ') IsAlwaysDisable  ,
             NVL(ScreenFieldNo, 0) ScreenFieldNo  ,
             IsMocVisible 
        FROM MetaDynamicScreenField B
       WHERE  MenuId = v_MenuId --B.SourceTable=@TableName

                AND NVL(ParentcontrolID, 0) = CASE 
                                                   WHEN v_TabId > 0 THEN v_TabId
              ELSE NVL(ParentcontrolID, 0)
                 END
                AND NVL(ValidCode, 'N') = 'Y'
        ORDER BY DisplayRowOrder,
                 DisplayColumnOrder ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ----select * from ##TmpDataSelect
   /* Dynamic Validation Data Fetch Logic */
   OPEN  v_cursor FOR
      SELECT 'Validation' TableName  ,
             ValidationGrpKey ,
             ValidationKey ,
             --,VAL.ControlID
             FLD.ControlName ControlID  ,
             CurrExpectedValue ,
             CurrExpectedKey ,
             ExpControlID ,
             ExpKey ,
             ExpControlValue ,
             Operator ,
             Message 
        FROM MetaDynamicValidation VAL
               JOIN MetaDynamicScreenField FLD   ON VAL.ControlID = FLD.ControlID
               AND FLD.MenuID = v_MenuId
             --   WHERE ISNUMERIC(VAL.ExpControlID) = 0

        ORDER BY ValidationGrpKey,
                 ValidationKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   /* Dynamic Validation Data Fetch Logic END */
   /* Dynamic Master Data Fetch Logic */
   IF utils.object_id('TEMPBD..tt_MASTERTMP_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MASTERTMP_2 ';
   END IF;
   DELETE FROM tt_MASTERTMP_2;
   UTILS.IDENTITY_RESET('tt_MASTERTMP_2');

   INSERT INTO tt_MASTERTMP_2 ( 
   	SELECT 'Master' TableName  ,
           A.ControlID ,
           MasterTable 
   	  FROM MetaDynamicScreenField A
             JOIN MetaDynamicMaster B   ON A.ControlID = B.ControlID
   	 WHERE  MENUID = v_MENUID );
   /*FOR UPDATING SUIT MASTER RUN TIME*/
   IF v_MenuId = 480 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage1CurrStage'
       WHERE  ControlID = 150020;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage1NextPostPurpose'
       WHERE  ControlID = 150005;

   END;
   END IF;
   IF v_MenuId = 510 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage2CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage2NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 530 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage3CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage3NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 540 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage4CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage4NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 560 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage5CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'Stage5NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   /*FOR UPDATE DRT MASTER RUN TIME*/
   IF v_MenuId = 500 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage1CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage1NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 520 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage2CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage2NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 4000 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage3CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage3NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 550 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage4CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage4NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 4010 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage5CurrStage'
       WHERE  ControlID = 9818;
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DRTStage5NextPostPurpose'
       WHERE  ControlID = 9803;

   END;
   END IF;
   IF v_MenuId = 720 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DimSuitJudge1'
       WHERE  ControlID = 11721;

   END;
   END IF;
   IF v_MenuId = 730 THEN

   BEGIN
      UPDATE tt_MASTERTMP_2
         SET MasterTable = 'DimDRTJudge1'
       WHERE  ControlID = 11821;

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_MASTERTMP_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   /*Dynamic Data for fetching resource file.*/
   OPEN  v_cursor FOR
      SELECT 'ResourceDetail' TableName  ,
             REPLACE(MenuCaption, ' ', ' ') ResourceName  
        FROM SysCRisMacMenu 
       WHERE  MenuId = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'StaticSP' TableName  ,
             SSP.ControlID ,
             SPName ,
             ClientSideParams ,
             ServerSideParams 
        FROM RBL_MISDB_PROD.MetaDynamicCallStaticSP SSP
               JOIN MetaDynamicScreenField FLD   ON SSP.ControlID = FLD.ControlID
               AND FLD.MenuID = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT MasterFilterGrpKey ,
             MasterFilterKey ,
             FilterMasterControlName ,
             RefColumnName ,
             FilterByColumnName ,
             ExpectedValue ,
             FilterBySelectValue ,
             FilterByRemoveValue ,
             M.MenuID ,
             'MasterFilter' TableName  
        FROM RBL_MISDB_PROD.MetaDynamicMasterFilter M
               JOIN MetaDynamicScreenField S   ON M.ControlID = S.ControlID
               AND S.MenuID = v_MenuId
               AND M.MenuID = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   /*Dynamic Grid meta Fetch */
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM SysCRisMacMenu 
                       WHERE  MenuId = v_MenuId
                                AND ( NVL(GridApplicable, 'N') = 'Y'
                                OR NVL(Accordian, 'N') = 'Y' ) );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'MetaGrid' TableName  ,
                A.ControlName ,
                B.* 
           FROM MetaDynamicScreenField A
                  JOIN MetaDynamicGrid B   ON A.ControlID = B.ControlId
          WHERE  MENUID = v_MENUID
                   AND NVL(A.ParentcontrolID, 0) = CASE 
                                                        WHEN v_TabId > 0 THEN v_TabId
                 ELSE NVL(A.ParentcontrolID, 0)
                    END
                   AND NVL(ValidCode, 'N') = 'Y' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);/* Dynamic Master Data Fetch Logic END*/

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICSCREENSELECTCONTROL_04122023" TO "ADF_CDR_RBL_STGDB";
