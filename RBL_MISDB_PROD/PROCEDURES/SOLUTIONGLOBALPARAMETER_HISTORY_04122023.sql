--------------------------------------------------------
--  DDL for Procedure SOLUTIONGLOBALPARAMETER_HISTORY_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" 
(
  --declare 
  v_ParameterAlt_Key IN NUMBER DEFAULT 5 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  

        -- from SolutionGlobalParameter A

        --  Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName

        --                    from DimParameter Where DimParameterName='Frequency' )B 

        --                     ON A.ParameterValueAlt_Key=B.ParameterAlt_key

        --Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName

        --                     from DimParameter Where DimParameterName='Nature' )C 

        --                     ON A.ParameterNatureAlt_Key=C.ParameterAlt_key

        --Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName

        --                     from DimParameter Where DimParameterName='ParameterStatus' )D 

        --                     ON A.ParameterStatusAlt_Key=D.ParameterAlt_key

        --Where 
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
                AND A.ParameterAlt_key IN ( 1,2,13 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 4,10,11,12 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 6 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 15 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 7 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 8 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 9 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 19 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
             A.ParameterAlt_Key ,
             A.ParameterName ,
             A.ParameterValueAlt_Key ,
             C.ParameterName ParameterValue  ,
             A.ParameterNatureAlt_Key ,
             C.ParameterName NatureName  ,
             UTILS.CONVERT_TO_VARCHAR2(A.From_Date,20,p_style=>103) From_Date  ,
             UTILS.CONVERT_TO_VARCHAR2(A.To_Date,20,p_style=>103) To_Date  ,
             A.ParameterStatusAlt_Key ,
             D.ParameterName StatusName  ,
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key IN ( 16,17,18 ----,20,21
               )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key
      UNION ALL 
      SELECT 'SolutionGlobalHistory' TableName  ,
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
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  
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

                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                AND A.ParameterAlt_key NOT IN ( 1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21 )

                AND A.ParameterAlt_Key = v_ParameterAlt_Key ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOLUTIONGLOBALPARAMETER_HISTORY_04122023" TO "ADF_CDR_RBL_STGDB";
