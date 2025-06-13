--------------------------------------------------------
--  DDL for Procedure SELECTSMAPARAMETER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" 
(
  --Declare
  v_CustomerACID IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
--,@OperationFlag  INT         = 17

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN
      DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM DimSMA 
                             WHERE  CUSTOMERACID = v_CustomerACID
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                                      AND AuthorisationStatus <> 'DP' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT * 
                        FROM ( SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 1 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 2 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value1' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 3 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value2' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 4 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value3' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 5 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value4' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 6 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value5' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 7 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value6' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 8 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value7' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 9 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value8' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 10 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value9' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 11 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value10' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 12 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value11' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 13 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value12' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 14 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value13' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') = 'A' ) A
                         WHERE  A.CustomerACID = v_CustomerACID
                        UNION 
                        SELECT * 
                        FROM ( SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 1 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 2 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value1' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 3 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value2' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 4 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value3' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 5 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value4' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 6 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value5' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 7 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value6' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 8 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value7' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 9 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value8' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 10 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value9' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 11 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value10' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 12 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value11' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 13 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value12' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                               UNION ALL 
                               SELECT D.SourceAlt_Key ,
                                      D.SourceName ,
                                      A.CustomerACID ,
                                      A.CustomerId ,
                                      A.CustomerName ,
                                      B.SMAParameterAlt_Key ,
                                      B.ParameterName ,
                                      C.ParameterAlt_Key ,
                                      C.ParameterName VALUE  ,
                                      'AccountDetails' TableName  ,
                                      A.AuthorisationStatus ,
                                      A.CreatedBy ,
                                      A.DateCreated ,
                                      A.ModifiedBy ,
                                      A.DateModified ,
                                      A.ApprovedBy ,
                                      A.DateApproved 
                               FROM DimSMA_Mod A
                                      LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                                      AND D.EffectiveFromTimeKey <= v_TimeKey
                                      AND D.EffectiveToTimeKey >= v_TimeKey
                                      LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                                      AND B.SMAParameterAlt_Key IN ( 14 )

                                      LEFT JOIN ( SELECT Parameter_Key ,
                                                         ParameterAlt_Key ,
                                                         ParameterName ,
                                                         'value13' TableName  
                                                  FROM DimParameter 
                                                   WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey
                                                            AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
                              ) B
                         WHERE  B.CustomerACID = v_CustomerACID ) C
                WHERE  C.SMAParameterAlt_Key IS NOT NULL
                 ORDER BY LENGTH(AuthorisationStatus) DESC,
                          DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE


         ---------

         --	IF (@OperationFlag in (16,17))
         BEGIN
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 1 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 2 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value1' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 3 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value2' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 4 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value3' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 5 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value4' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 6 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value5' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 7 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value6' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 8 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value7' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 9 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value8' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 10 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value9' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 11 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value10' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 12 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value11' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 13 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value12' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )

                        UNION ALL 
                        SELECT D.SourceAlt_Key ,
                               D.SourceName ,
                               A.CustomerACID ,
                               A.CustomerId ,
                               A.CustomerName ,
                               B.SMAParameterAlt_Key ,
                               B.ParameterName ,
                               C.ParameterAlt_Key ,
                               C.ParameterName VALUE  ,
                               'AccountDetails' TableName  ,
                               A.AuthorisationStatus ,
                               A.CreatedBy ,
                               A.DateCreated ,
                               A.ModifiedBy ,
                               A.DateModified ,
                               A.ApprovedBy ,
                               A.DateApproved 
                        FROM DimSMA_Mod A
                               LEFT JOIN DIMSOURCEDB D   ON A.SourceAlt_Key = D.SourceAlt_Key
                               AND D.EffectiveFromTimeKey <= v_TimeKey
                               AND D.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimSMAParameter B   ON A.ParameterNameAlt_Key = B.SMAParameterAlt_Key
                               AND B.SMAParameterAlt_Key IN ( 14 )

                               LEFT JOIN ( SELECT Parameter_Key ,
                                                  ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'value13' TableName  
                                           FROM DimParameter 
                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                     AND DimParameterName = 'Holidays' ) C   ON A.ValueAlt_Key = UTILS.CONVERT_TO_VARCHAR2(C.ParameterAlt_key,100)
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                                  AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
                       ) A
                WHERE  A.CustomerACID = v_CustomerACID
                 ORDER BY LENGTH(AuthorisationStatus) DESC,
                          DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTSMAPARAMETER_04122023" TO "ADF_CDR_RBL_STGDB";
