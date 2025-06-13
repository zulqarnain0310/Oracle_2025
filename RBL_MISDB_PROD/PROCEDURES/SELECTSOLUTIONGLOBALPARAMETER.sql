--------------------------------------------------------
--  DDL for Procedure SELECTSOLUTIONGLOBALPARAMETER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" 
(
  v_operationFlag IN NUMBER DEFAULT 2 
)
AS
   v_TimeKey NUMBER(10,0);
   v_SystemDate VARCHAR2(200);
   --END;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

     INTO v_SystemDate
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_269') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_269 ';
            END IF;
            DELETE FROM tt_temp_269;
            UTILS.IDENTITY_RESET('tt_temp_269');

            INSERT INTO tt_temp_269 ( 
            	SELECT 'a' ProcessDate  ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    A.ParameterValue ,
                    A.ParameterNatureAlt_Key ,
                    A.NatureName ,
                    --,A.From_Date
                    A.From_Date ,
                    --,A.To_Date
                    A.To_Date ,
                    A.ParameterStatusAlt_Key ,
                    A.StatusName ,
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
            	  FROM ( SELECT * 
                      FROM ( SELECT * 
                             FROM ( SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Frequency' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Frequency' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 1,2,13 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Holidays' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Holidays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'System' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'System' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 4,10,11,12 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Status' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Status' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 6 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Model' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Model' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 15 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'CumulativeDefinePeriod' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'CumulativeDefinePeriod' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 7 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'CumulativeDefineDays' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'CumulativeDefineDays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 8 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'CumulativeDefineInterestServiced' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'CumulativeDefineInterestServiced' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 9 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'securityvalue' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 19 )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    UTILS.CONVERT_TO_VARCHAR2(A.ParameterValueAlt_Key,20) ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key IN ( 16,17,18 ----,20,21
                      )

            	UNION ALL 
            	SELECT v_SystemDate ProcessDate  ,
                    A.EntityKey ,
                    A.ParameterAlt_Key ,
                    A.ParameterName ,
                    A.ParameterValueAlt_Key ,
                    B.ParameterName ParameterValue  ,
                    A.ParameterNatureAlt_Key ,
                    C.ParameterName NatureName  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                    A.ParameterStatusAlt_Key ,
                    D.ParameterName StatusName  ,
                    NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ApprovedBy ,
                    DateApproved ,
                    ModifiedBy ,
                    DateModified ,
                    NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                    NVL(A.DateModified, A.DateCreated) CrModDate  ,
                    NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                    NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                    NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                    NVL(A.DateApproved, A.DateModified) ModAppDate  
            	  FROM SolutionGlobalParameter A
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'securityvalue' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'Nature' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                      JOIN ( SELECT Parameter_Key ,
                                    ParameterAlt_Key ,
                                    ParameterName ,
                                    'ParameterStatus' TableName  
                             FROM DimParameter 
                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                       AND EffectiveToTimeKey >= v_TimeKey
                                       AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
            	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND NVL(A.AuthorisationStatus, 'A') = 'A'
                       AND A.ParameterAlt_Key NOT IN ( 1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21 )
                                   ) A
                             UNION 
                             SELECT * 
                             FROM ( SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Frequency' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Frequency' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 1,2,13 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Holidays' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'System' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'System' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 4,10,11,12 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Status' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Status' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 6 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Model' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Model' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 15 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'CumulativeDefinePeriod' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'CumulativeDefinePeriod' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 7 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'CumulativeDefineDays' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'CumulativeDefineDays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 8 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'CumulativeDefineInterestServiced' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'CumulativeDefineInterestServiced' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 9 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'securityvalue' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key IN ( 19 )

                                    UNION 
                                    --------
                                    ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.ParameterValueAlt_Key,20) ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                              AND A.ParameterAlt_Key IN ( 16,17,18 ---,20,21
                                             )

                                    UNION ALL 
                                    SELECT v_SystemDate ProcessDate  ,
                                           A.EntityKey ,
                                           A.ParameterAlt_Key ,
                                           A.ParameterName ,
                                           A.ParameterValueAlt_Key ,
                                           B.ParameterName ParameterValue  ,
                                           A.ParameterNatureAlt_Key ,
                                           C.ParameterName NatureName  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                           UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                           A.ParameterStatusAlt_Key ,
                                           D.ParameterName StatusName  ,
                                           NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                           EffectiveFromTimeKey ,
                                           EffectiveToTimeKey ,
                                           CreatedBy ,
                                           DateCreated ,
                                           ApprovedBy ,
                                           DateApproved ,
                                           ModifiedBy ,
                                           DateModified ,
                                           NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                           NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                           NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                           NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                           NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                           NVL(A.DateApproved, A.DateModified) ModAppDate  
                                    FROM SolutionGlobalParameter_Mod A
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'securityvalue' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'Nature' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                           JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'ParameterStatus' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey
                                              AND A.ParameterAlt_Key NOT IN ( 1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21 )
                                   ) B
                              WHERE  B.EntityKey IN ( SELECT MAX(EntityKey)  
                                                      FROM SolutionGlobalParameter_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                        GROUP BY ParameterAlt_Key )
                            ) A
                        GROUP BY ProcessDate,A.EntityKey,A.ParameterAlt_Key,A.ParameterName,A.ParameterValueAlt_Key,A.ParameterValue,A.NatureName,A.ParameterNatureAlt_Key,A.From_Date,A.To_Date,A.StatusName,A.ParameterStatusAlt_Key,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate ) 
                    --SELECT *

                    --FROM

                    --(

                    --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 

                    --           COUNT(*) OVER() AS TotalCount, 

                    --           'SolutionGlobalParameterMaster' TableName, 

                    --           *

                    --    FROM

                    --    (

                    --        SELECT *

                    --        FROM SolutionGlobalParameter_Mod A

                    ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'

                    --    ) AS DataPointOwner

                    --) AS DataPointOwner

                    --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

                    --      AND RowNumber <= (@PageNo * @PageSize);
                    A );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ParameterAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SolutionGlobalParameterMaster' TableName  ,
                               * ,
                               (CASE 
                                     WHEN ParameterAlt_Key = 3 THEN 1
                                     WHEN ParameterAlt_Key = 4 THEN 2
                                     WHEN ParameterAlt_Key = 5 THEN 3
                                     WHEN ParameterAlt_Key = 12 THEN 4
                                     WHEN ParameterAlt_Key = 6 THEN 5
                                     WHEN ParameterAlt_Key = 13 THEN 6
                                     WHEN ParameterAlt_Key = 7 THEN 7
                                     WHEN ParameterAlt_Key = 8 THEN 8
                                     WHEN ParameterAlt_Key = 9 THEN 9
                                     WHEN ParameterAlt_Key = 10 THEN 10
                                     WHEN ParameterAlt_Key = 14 THEN 11
                                     WHEN ParameterAlt_Key = 11 THEN 12
                                     WHEN ParameterAlt_Key = 16 THEN 13
                                     WHEN ParameterAlt_Key = 17 THEN 14
                                     WHEN ParameterAlt_Key = 18 THEN 15
                                     WHEN ParameterAlt_Key = 15 THEN 16
                                     WHEN ParameterAlt_Key = 22 THEN 17
                                     WHEN ParameterAlt_Key = 23 THEN 18
                                     WHEN ParameterAlt_Key = 24 THEN 19
                                     WHEN ParameterAlt_Key = 25 THEN 20
                                     WHEN ParameterAlt_Key = 32 THEN 21
                                     WHEN ParameterAlt_Key = 27 THEN 22
                                     WHEN ParameterAlt_Key = 28 THEN 23
                                     WHEN ParameterAlt_Key = 26 THEN 24
                                     WHEN ParameterAlt_Key = 29 THEN 25
                                     WHEN ParameterAlt_Key = 30 THEN 26
                                     WHEN ParameterAlt_Key = 19 THEN 27
                                     WHEN ParameterAlt_Key = 31 THEN 28
                                     WHEN ParameterAlt_Key = 1 THEN 29
                                     WHEN ParameterAlt_Key = 2 THEN 30   END) Srno  
                        FROM ( SELECT * 
                               FROM tt_temp_269 A ) 
                             --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
                             DataPointOwner ) DataPointOwner
                      --order by ParameterNatureAlt_Key desc,ParameterStatusAlt_Key asc,DateModified desc

                 ORDER BY Srno ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --             
         ELSE
            --			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_operationFlag IN ( 16 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_26916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_216 ';
               END IF;
               DELETE FROM tt_temp16_216;
               UTILS.IDENTITY_RESET('tt_temp16_216');

               INSERT INTO tt_temp16_216 ( 
               	SELECT 'a' ProcessDate  ,
                       A.EntityKey ,
                       A.ParameterAlt_Key ,
                       A.ParameterName ,
                       A.ParameterValueAlt_Key ,
                       A.ParameterValue ,
                       A.ParameterNatureAlt_Key ,
                       A.NatureName ,
                       A.From_Date ,
                       A.To_Date ,
                       A.ParameterStatusAlt_Key ,
                       A.StatusName ,
                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                       EffectiveFromTimeKey ,
                       EffectiveToTimeKey ,
                       CreatedBy ,
                       DateCreated ,
                       ApprovedBy ,
                       DateApproved ,
                       ModifiedBy ,
                       DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT * 
                         FROM ( SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Frequency' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Frequency' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 1,2,13 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Holidays' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Holidays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'System' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'System' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 4,10,11,12 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Status' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Status' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 6 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Model' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Model' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 15 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'CumulativeDefinePeriod' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'CumulativeDefinePeriod' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 7 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'CumulativeDefineDays' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'CumulativeDefineDays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 8 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'CumulativeDefineInterestServiced' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'CumulativeDefineInterestServiced' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 9 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'securityvalue' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key IN ( 19 )

                                UNION 
                                --------
                                ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.ParameterValueAlt_Key,20) ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                          AND A.ParameterAlt_Key IN ( 16,17,18 ---,20,21
                                         )

                                UNION ALL 
                                SELECT v_SystemDate ProcessDate  ,
                                       A.EntityKey ,
                                       A.ParameterAlt_Key ,
                                       A.ParameterName ,
                                       A.ParameterValueAlt_Key ,
                                       B.ParameterName ParameterValue  ,
                                       A.ParameterNatureAlt_Key ,
                                       C.ParameterName NatureName  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                       UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                       A.ParameterStatusAlt_Key ,
                                       D.ParameterName StatusName  ,
                                       NVL(AuthorisationStatus, 'A') AuthorisationStatus  ,
                                       EffectiveFromTimeKey ,
                                       EffectiveToTimeKey ,
                                       CreatedBy ,
                                       DateCreated ,
                                       ApprovedBy ,
                                       DateApproved ,
                                       ModifiedBy ,
                                       DateModified ,
                                       NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                       NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                       NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                       NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                       NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                       NVL(A.DateApproved, A.DateModified) ModAppDate  
                                FROM SolutionGlobalParameter_Mod A
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'securityvalue' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'Nature' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                       JOIN ( SELECT Parameter_Key ,
                                                     ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ParameterStatus' TableName  
                                              FROM DimParameter 
                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                        AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                          AND A.EffectiveToTimeKey >= v_TimeKey
                                          AND A.ParameterAlt_Key NOT IN ( 1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21 )
                               ) B
                          WHERE  B.EntityKey IN ( SELECT MAX(EntityKey)  
                                                  FROM SolutionGlobalParameter_Mod 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                    GROUP BY ParameterAlt_Key )
                        ) A
               	  GROUP BY ProcessDate,A.EntityKey,A.ParameterAlt_Key,A.ParameterName,A.ParameterValueAlt_Key,A.ParameterValue,A.NatureName,A.ParameterNatureAlt_Key,A.From_Date,A.To_Date,A.StatusName,A.ParameterStatusAlt_Key,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               --SELECT *
               --FROM
               --(
               --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
               --           COUNT(*) OVER() AS TotalCount, 
               --           'SolutionGlobalParameterMaster' TableName, 
               --           *
               --    FROM
               --    (
               --        SELECT *
               --        FROM SolutionGlobalParameter_Mod A
               ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
               --    ) AS DataPointOwner
               --) AS DataPointOwner
               --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
               --      AND RowNumber <= (@PageNo * @PageSize);
               --) A
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ParameterAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SolutionGlobalParameterMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_216 A ) 
                                --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY ParameterNatureAlt_Key DESC,
                             ParameterStatusAlt_Key ASC,
                             DateModified DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE
               --			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
               IF ( v_operationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_26920') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_181 ';
                  END IF;
                  DELETE FROM tt_temp20_181;
                  UTILS.IDENTITY_RESET('tt_temp20_181');

                  INSERT INTO tt_temp20_181 ( 
                  	SELECT 'a' ProcessDate  ,
                          A.EntityKey ,
                          A.ParameterAlt_Key ,
                          A.ParameterName ,
                          A.ParameterValueAlt_Key ,
                          A.ParameterValue ,
                          A.ParameterNatureAlt_Key ,
                          A.NatureName ,
                          A.From_Date ,
                          A.To_Date ,
                          A.ParameterStatusAlt_Key ,
                          A.StatusName ,
                          --,isnull(AuthorisationStatus, 'A') 
                          A.AuthorisationStatus ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey ,
                          CreatedBy ,
                          DateCreated ,
                          ApprovedBy ,
                          DateApproved ,
                          ModifiedBy ,
                          DateModified ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT * 
                            FROM ( SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Frequency' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Frequency' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 1,2,13 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Holidays' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Holidays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'System' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'System' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 4,10,11,12 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Status' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Status' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 6 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Model' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Model' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 15 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'CumulativeDefinePeriod' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'CumulativeDefinePeriod' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 7 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'CumulativeDefineDays' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'CumulativeDefineDays' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 8 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'CumulativeDefineInterestServiced' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'CumulativeDefineInterestServiced' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 9 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'securityvalue' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key IN ( 19 )

                                   UNION 
                                   --------
                                   ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.ParameterValueAlt_Key,20) ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND NVL(A.AuthorisationStatus, 'A') = '1A'
                                             AND A.ParameterAlt_Key IN ( 16,17,18 ---,20,21
                                            )

                                   UNION ALL 
                                   SELECT v_SystemDate ProcessDate  ,
                                          A.EntityKey ,
                                          A.ParameterAlt_Key ,
                                          A.ParameterName ,
                                          A.ParameterValueAlt_Key ,
                                          B.ParameterName ParameterValue  ,
                                          A.ParameterNatureAlt_Key ,
                                          C.ParameterName NatureName  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
                                          UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
                                          A.ParameterStatusAlt_Key ,
                                          D.ParameterName StatusName  ,
                                          --,isnull(AuthorisationStatus, 'A') 
                                          A.AuthorisationStatus ,
                                          EffectiveFromTimeKey ,
                                          EffectiveToTimeKey ,
                                          CreatedBy ,
                                          DateCreated ,
                                          ApprovedBy ,
                                          DateApproved ,
                                          ModifiedBy ,
                                          DateModified ,
                                          NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                          NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                          NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                          NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                          NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                          NVL(A.DateApproved, A.DateModified) ModAppDate  
                                   FROM SolutionGlobalParameter_Mod A
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'securityvalue' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'securityvalue' ) B   ON A.ParameterValueAlt_Key = B.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'Nature' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'Nature' ) C   ON A.ParameterNatureAlt_Key = C.ParameterAlt_key
                                          JOIN ( SELECT Parameter_Key ,
                                                        ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ParameterStatus' TableName  
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                           AND DimParameterName = 'ParameterStatus' ) D   ON A.ParameterStatusAlt_Key = D.ParameterAlt_key
                                    WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                             AND A.EffectiveToTimeKey >= v_TimeKey
                                             AND A.ParameterAlt_Key NOT IN ( 1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21 )
                                  ) B
                             WHERE  B.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM SolutionGlobalParameter_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                       GROUP BY ParameterAlt_Key )
                           ) A
                  	  GROUP BY ProcessDate,A.EntityKey,A.ParameterAlt_Key,A.ParameterName,A.ParameterValueAlt_Key,A.ParameterValue,A.NatureName,A.ParameterNatureAlt_Key,A.From_Date,A.To_Date,A.StatusName,A.ParameterStatusAlt_Key,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  --SELECT *
                  --FROM
                  --(
                  --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                  --           COUNT(*) OVER() AS TotalCount, 
                  --           'SolutionGlobalParameterMaster' TableName, 
                  --           *
                  --    FROM
                  --    (
                  --        SELECT *
                  --        FROM SolutionGlobalParameter_Mod A
                  ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
                  --    ) AS DataPointOwner
                  --) AS DataPointOwner
                  --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                  --      AND RowNumber <= (@PageNo * @PageSize);
                  --) A
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ParameterAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'SolutionGlobalParameterMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_181 A ) 
                                   --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY ParameterNatureAlt_Key DESC,
                                ParameterStatusAlt_Key ASC,
                                DateModified DESC ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSOLUTIONGLOBALPARAMETER" TO "ADF_CDR_RBL_STGDB";
