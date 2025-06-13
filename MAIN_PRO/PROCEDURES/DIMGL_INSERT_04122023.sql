--------------------------------------------------------
--  DDL for Procedure DIMGL_INSERT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."DIMGL_INSERT_04122023" /*==============================================
 AUTHER : TRILOKI SHANKER KHANNA
 CREATE DATE : 15-01-2020
 MODIFY DATE : 15-01-2020
 DESCRIPTION : INSERT DATA FOR DIMGL
 --EXEC PRO.DimGL_INSERT
 ================================================*/
--BEGIN
 ----/*-------INSERT GL DATA FOR Profile---------------------------------*/
 ----IF OBJECT_ID('TEMPDB..#NEWGLCodeProfile') IS NOT NULL
 ----   DROP TABLE #NEWGLCodeProfile
 ----DECLARE  @vEffectivefrom  Int SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----DECLARE @TimeKey  Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----DECLARE @DATE AS DATE =(SELECT Date FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----DECLARE @GLAlt_Key INT=0 
 ----SELECT @GLAlt_Key=MAX(GLAlt_Key) FROM  [RBL_MISDB].[dbo].[DimGL] 
 ----   SELECT DISTINCT [PRINCIPAL GL] GLCode INTO #NEWGLCodeProfile  FROM dbo.LNDAILYFULL
 ----   EXCEPT
 ----   SELECT GLCode FROM DBO.DimGL WHERE EffectiveToTimeKey=49999
 ----   INSERT INTO DBO.DimGL
 ----   (
 ----GLAlt_Key
 ----,GLCode
 ----,GLName
 ----,GLShortName
 ----,GLShortNameEnum
 ----,GLGroupType
 ----,GLGroupAlt_Key
 ----,GLGroup
 ----,GLSubGroupAlt_Key
 ----,GLSubGroup
 ----,GLSegmentAlt_Key
 ----,GLSegment
 ----,GLSubSegment
 ----,GLValidCode
 ----,AbstractCat
 ----,AbstractCode
 ----,AbstractDescription
 ----,AdvRefGLAlt_key
 ----,BsDescription
 ----,BsSchedule
 ----,BsScheduleDescription
 ----,ComputationBusinessLogic
 ----,WeeklyCode
 ----,WeeklyDescription
 ----,LfCode
 ----,LfDescription
 ----,Schd_Head_No
 ----,Schd_No
 ----,Sub_Schd_No
 ----,Sub_Sub_Schd_No
 ----,SrcSysGLCode
 ----,SrcSysGLName
 ----,DestSysGLCode
 ----,GLCode2
 ----,GLName2
 ----,AuthorisationStatus
 ----,EffectiveFromTimeKey
 ----,EffectiveToTimeKey
 ----,CreatedBy
 ----,DateCreated
 ----,ModifiedBy
 ----,DateModified
 ----,ApprovedBy
 ----,DateApproved
 ----,D2Ktimestamp
 ----,CR_GL_SubGroup
 ----,CR_GL_Group
 ----,DR_GL_SubGroup
 ----,DR_GL_Group
 ----,LiabilityOrderKey
 ----,AssetOrderKey
 ----,DR_Flg
 ----,CR_Flg
 ----   )
 ----SELECT 
 ----@GLAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS GLAlt_Key
 ----,A.GLCode AS GLCode
 ----,NULL AS GLName
 ----,NULL AS GLShortName
 ----,NULL AS GLShortNameEnum
 ----,NULL AS GLGroupType
 ----,NULL AS GLGroupAlt_Key
 ----,NULL AS GLGroup
 ----,NULL AS GLSubGroupAlt_Key
 ----,NULL AS GLSubGroup
 ----,NULL AS GLSegmentAlt_Key
 ----,NULL AS GLSegment
 ----,NULL AS GLSubSegment
 ----,NULL AS GLValidCode
 ----,NULL AS AbstractCat
 ----,NULL AS AbstractCode
 ----,NULL AS AbstractDescription
 ----,NULL AS AdvRefGLAlt_key
 ----,NULL AS BsDescription
 ----,NULL AS BsSchedule
 ----,NULL AS BsScheduleDescription
 ----,NULL AS ComputationBusinessLogic
 ----,NULL AS WeeklyCode
 ----,NULL AS WeeklyDescription
 ----,NULL AS LfCode
 ----,NULL AS LfDescription
 ----,NULL AS Schd_Head_No
 ----,NULL AS Schd_No
 ----,NULL AS Sub_Schd_No
 ----,NULL AS Sub_Sub_Schd_No
 ----,NULL AS SrcSysGLCode
 ----,NULL AS SrcSysGLName
 ----,NULL AS DestSysGLCode
 ----,NULL AS GLCode2
 ----,NULL AS GLName2
 ----,NULL AS AuthorisationStatus
 ----,EffectiveFromTimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----,EffectiveToTimeKey=49999
 ----,'SSISUSER' AS CreatedBy
 ----,GETDATE() AS DateCreated
 ----,NULL AS ModifiedBy
 ----,NULL AS DateModified
 ----,NULL AS ApprovedBy
 ----,NULL AS DateApproved
 ----,NULL AS D2Ktimestamp
 ----,NULL AS CR_GL_SubGroup
 ----,NULL AS CR_GL_Group
 ----,NULL AS DR_GL_SubGroup
 ----,NULL AS DR_GL_Group
 ----,NULL AS LiabilityOrderKey
 ----,NULL AS AssetOrderKey
 ----,NULL AS DR_Flg
 ----,NULL AS CR_Flg
 ----FROM #NEWGLCodeProfile A
 ----ORDER BY A.GLCode
 ----/*-------INSERT GL DATA DATA FOR BR NET---------------------------------*/
 ----IF OBJECT_ID('TEMPDB..#NEWGLCodeBRNET') IS NOT NULL
 ----   DROP TABLE #NEWGLCodeBRNET
 ----   SELECT DISTINCT COAID  GLCode INTO #NEWGLCodeBRNET   FROM  DBO.T_LOAN TL
 ----			INNER JOIN DBO.T_ACCOUNTCUSTOMER  TAC	ON TL.ACCOUNTID=TAC.ACCOUNTID	AND TL.OURBRANCHID=TAC.OURBRANCHID
 ----			INNER  JOIN  DBO.T_GLINTERFACE ON DBO.T_GLINTERFACE.RELEVANTID=TAC.PRODUCTID
 ----			INNER  JOIN  DBO.T_SMF_GLMAPPING ON DBO.T_SMF_GLMAPPING.GLID=DBO.T_GLINTERFACE.ACCOUNTID
 ----			WHERE TL.LOANSTATUSID IN('A','N','W')AND  ACCOUNTTAGID   ='CONTROL_AC'
 ----   EXCEPT
 ----   SELECT GLCode FROM DBO.DimGL WHERE EffectiveToTimeKey=49999
 ----   DECLARE @GLAlt_Keybrnet INT=0 
 ----  SELECT @GLAlt_Keybrnet=MAX(GLAlt_Key) FROM  [RBL_MISDB].[dbo].[DimGL] 
 ----  INSERT INTO DBO.DimGL
 ----   (
 ----GLAlt_Key
 ----,GLCode
 ----,GLName
 ----,GLShortName
 ----,GLShortNameEnum
 ----,GLGroupType
 ----,GLGroupAlt_Key
 ----,GLGroup
 ----,GLSubGroupAlt_Key
 ----,GLSubGroup
 ----,GLSegmentAlt_Key
 ----,GLSegment
 ----,GLSubSegment
 ----,GLValidCode
 ----,AbstractCat
 ----,AbstractCode
 ----,AbstractDescription
 ----,AdvRefGLAlt_key
 ----,BsDescription
 ----,BsSchedule
 ----,BsScheduleDescription
 ----,ComputationBusinessLogic
 ----,WeeklyCode
 ----,WeeklyDescription
 ----,LfCode
 ----,LfDescription
 ----,Schd_Head_No
 ----,Schd_No
 ----,Sub_Schd_No
 ----,Sub_Sub_Schd_No
 ----,SrcSysGLCode
 ----,SrcSysGLName
 ----,DestSysGLCode
 ----,GLCode2
 ----,GLName2
 ----,AuthorisationStatus
 ----,EffectiveFromTimeKey
 ----,EffectiveToTimeKey
 ----,CreatedBy
 ----,DateCreated
 ----,ModifiedBy
 ----,DateModified
 ----,ApprovedBy
 ----,DateApproved
 ----,D2Ktimestamp
 ----,CR_GL_SubGroup
 ----,CR_GL_Group
 ----,DR_GL_SubGroup
 ----,DR_GL_Group
 ----,LiabilityOrderKey
 ----,AssetOrderKey
 ----,DR_Flg
 ----,CR_Flg
 ----   )
 ----SELECT 
 ----@GLAlt_Keybrnet + ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS GLAlt_Key
 ----,A.GLCode AS GLCode
 ----,NULL AS GLName
 ----,NULL AS GLShortName
 ----,NULL AS GLShortNameEnum
 ----,NULL AS GLGroupType
 ----,NULL AS GLGroupAlt_Key
 ----,NULL AS GLGroup
 ----,NULL AS GLSubGroupAlt_Key
 ----,NULL AS GLSubGroup
 ----,NULL AS GLSegmentAlt_Key
 ----,NULL AS GLSegment
 ----,NULL AS GLSubSegment
 ----,NULL AS GLValidCode
 ----,NULL AS AbstractCat
 ----,NULL AS AbstractCode
 ----,NULL AS AbstractDescription
 ----,NULL AS AdvRefGLAlt_key
 ----,NULL AS BsDescription
 ----,NULL AS BsSchedule
 ----,NULL AS BsScheduleDescription
 ----,NULL AS ComputationBusinessLogic
 ----,NULL AS WeeklyCode
 ----,NULL AS WeeklyDescription
 ----,NULL AS LfCode
 ----,NULL AS LfDescription
 ----,NULL AS Schd_Head_No
 ----,NULL AS Schd_No
 ----,NULL AS Sub_Schd_No
 ----,NULL AS Sub_Sub_Schd_No
 ----,NULL AS SrcSysGLCode
 ----,NULL AS SrcSysGLName
 ----,NULL AS DestSysGLCode
 ----,NULL AS GLCode2
 ----,NULL AS GLName2
 ----,NULL AS AuthorisationStatus
 ----,EffectiveFromTimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----,EffectiveToTimeKey=49999
 ----,'SSISUSER' AS CreatedBy
 ----,GETDATE() AS DateCreated
 ----,NULL AS ModifiedBy
 ----,NULL AS DateModified
 ----,NULL AS ApprovedBy
 ----,NULL AS DateApproved
 ----,NULL AS D2Ktimestamp
 ----,NULL AS CR_GL_SubGroup
 ----,NULL AS CR_GL_Group
 ----,NULL AS DR_GL_SubGroup
 ----,NULL AS DR_GL_Group
 ----,NULL AS LiabilityOrderKey
 ----,NULL AS AssetOrderKey
 ----,NULL AS DR_Flg
 ----,NULL AS CR_Flg
 ----FROM #NEWGLCodeBRNET A
 ----ORDER BY A.GLCode
 ----/*-------INSERT GL DATA DATA DailyTB---------------------------------*/
 ----IF OBJECT_ID('TEMPDB..#NEWGLCodeDailyTB') IS NOT NULL
 ----   DROP TABLE #NEWGLCodeDailyTB
 ----   select distinct AccountCode as GLCode  INTO  #NEWGLCodeDailyTB from DBO.DailyTB 
 ----   EXCEPT
 ----   SELECT GLCode FROM DBO.DimGL WHERE EffectiveToTimeKey=49999
 ----   DECLARE @GLAlt_KeyeDailyTB INT=0 
 ----  SELECT @GLAlt_KeyeDailyTB=MAX(GLAlt_Key) FROM  [RBL_MISDB].[dbo].[DimGL] 
 ----   ALTER TABLE  #NEWGLCODEDAILYTB ADD GLNAME VARCHAR(200)
 ----   UPDATE A SET GLNAME=B.Descr 
 ----  FROM  #NEWGLCODEDAILYTB A 
 ----   INNER JOIN  DBO.DailyTB  B
 ----  ON A.GLCode=B.AccountCode
 ----  INSERT INTO DBO.DimGL
 ----   (
 ----GLAlt_Key
 ----,GLCode
 ----,GLName
 ----,GLShortName
 ----,GLShortNameEnum
 ----,GLGroupType
 ----,GLGroupAlt_Key
 ----,GLGroup
 ----,GLSubGroupAlt_Key
 ----,GLSubGroup
 ----,GLSegmentAlt_Key
 ----,GLSegment
 ----,GLSubSegment
 ----,GLValidCode
 ----,AbstractCat
 ----,AbstractCode
 ----,AbstractDescription
 ----,AdvRefGLAlt_key
 ----,BsDescription
 ----,BsSchedule
 ----,BsScheduleDescription
 ----,ComputationBusinessLogic
 ----,WeeklyCode
 ----,WeeklyDescription
 ----,LfCode
 ----,LfDescription
 ----,Schd_Head_No
 ----,Schd_No
 ----,Sub_Schd_No
 ----,Sub_Sub_Schd_No
 ----,SrcSysGLCode
 ----,SrcSysGLName
 ----,DestSysGLCode
 ----,GLCode2
 ----,GLName2
 ----,AuthorisationStatus
 ----,EffectiveFromTimeKey
 ----,EffectiveToTimeKey
 ----,CreatedBy
 ----,DateCreated
 ----,ModifiedBy
 ----,DateModified
 ----,ApprovedBy
 ----,DateApproved
 ----,D2Ktimestamp
 ----,CR_GL_SubGroup
 ----,CR_GL_Group
 ----,DR_GL_SubGroup
 ----,DR_GL_Group
 ----,LiabilityOrderKey
 ----,AssetOrderKey
 ----,DR_Flg
 ----,CR_Flg
 ----   )
 ----SELECT 
 ----@GLAlt_KeyeDailyTB + ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS GLAlt_Key
 ----,A.GLCode AS GLCode
 ----,A.GLName AS GLName
 ----,NULL AS GLShortName
 ----,NULL AS GLShortNameEnum
 ----,NULL AS GLGroupType
 ----,NULL AS GLGroupAlt_Key
 ----,NULL AS GLGroup
 ----,NULL AS GLSubGroupAlt_Key
 ----,NULL AS GLSubGroup
 ----,NULL AS GLSegmentAlt_Key
 ----,NULL AS GLSegment
 ----,NULL AS GLSubSegment
 ----,NULL AS GLValidCode
 ----,NULL AS AbstractCat
 ----,NULL AS AbstractCode
 ----,NULL AS AbstractDescription
 ----,NULL AS AdvRefGLAlt_key
 ----,NULL AS BsDescription
 ----,NULL AS BsSchedule
 ----,NULL AS BsScheduleDescription
 ----,NULL AS ComputationBusinessLogic
 ----,NULL AS WeeklyCode
 ----,NULL AS WeeklyDescription
 ----,NULL AS LfCode
 ----,NULL AS LfDescription
 ----,NULL AS Schd_Head_No
 ----,NULL AS Schd_No
 ----,NULL AS Sub_Schd_No
 ----,NULL AS Sub_Sub_Schd_No
 ----,NULL AS SrcSysGLCode
 ----,NULL AS SrcSysGLName
 ----,NULL AS DestSysGLCode
 ----,NULL AS GLCode2
 ----,NULL AS GLName2
 ----,NULL AS AuthorisationStatus
 ----,EffectiveFromTimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
 ----,EffectiveToTimeKey=49999
 ----,'SSISUSER' AS CreatedBy
 ----,GETDATE() AS DateCreated
 ----,NULL AS ModifiedBy
 ----,NULL AS DateModified
 ----,NULL AS ApprovedBy
 ----,NULL AS DateApproved
 ----,NULL AS D2Ktimestamp
 ----,NULL AS CR_GL_SubGroup
 ----,NULL AS CR_GL_Group
 ----,NULL AS DR_GL_SubGroup
 ----,NULL AS DR_GL_Group
 ----,NULL AS LiabilityOrderKey
 ----,NULL AS AssetOrderKey
 ----,NULL AS DR_Flg
 ----,NULL AS CR_Flg
 ----FROM #NEWGLCodeDailyTB A
 ----ORDER BY A.GLCode
 ----update a set GLAlt_Key=b.GLAlt_Key
 ----from curdat.FactGLData  a 
 ----inner join DBO.DimGL b
 ----on a.GLCode=b.GLCode
 ----where a.GLAlt_Key is null
 --END

AS

BEGIN

   NULL;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DIMGL_INSERT_04122023" TO "ADF_CDR_RBL_STGDB";
