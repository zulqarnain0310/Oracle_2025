--------------------------------------------------------
--  DDL for Procedure INVESTMENTBASICQUICKSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" 
(
  --Declare
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT ' ' ,
  v_InvID IN VARCHAR2 DEFAULT ' ' ,
  v_InstrumentType IN VARCHAR2 DEFAULT ' ' ,
  v_ISIN IN VARCHAR2 DEFAULT ' ' ,
  --,@InvID    Varchar (100)  = ''  --,@InstrTypeAlt_key Varchar (100)  = ''  --,@ISIN    varchar (100)  = ''  
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_InstrTypeName VARCHAR2(50) := CASE 
   WHEN v_InstrumentType = ' ' THEN ' '
   ELSE ( SELECT DISTINCT InstrumentTypeName 
     FROM DimInstrumentType 
    WHERE  InstrumentTypeAlt_Key = v_InstrumentType
             AND EffectiveFromTimeKey <= v_Timekey
             AND EffectiveToTimeKey >= v_Timekey )
      END;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
         IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
            ACLProcessStatusCheck() ;

         END;
         END IF;
         IF ( v_OperationFlag NOT IN ( 16,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_165') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_165 ';
            END IF;
            DBMS_OUTPUT.PUT_LINE('SAC1');
            DELETE FROM tt_temp_165;
            UTILS.IDENTITY_RESET('tt_temp_165');

            INSERT INTO tt_temp_165 ( 
            	SELECT A.EntityKey ,
                    A.BranchCode ,
                    A.SourceAlt_key ,
                    a.SourceName ,
                    A.IssuerID ,
                    A.IssuerName ,
                    A.InvID ,
                    A.ISIN ,
                    A.InstrTypeAlt_Key ,
                    A.InstrumentTypeName ,
                    A.InstrName ,
                    --A.Currency_AltKey,  
                    --B.CurrencyName as Currency,  
                    A.InvestmentNature ,
                    A.Sector ,
                    A.Industry_AltKey ,
                    A.Industry ,
                    A.ExposureType ,
                    A.SecurityValue ,
                    UTILS.CONVERT_TO_VARCHAR2(A.MaturityDt,30,p_style=>103) MaturityDt  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.ReStructureDate,30,p_style=>103) ReStructureDate  ,
                    ----------------------------------------------------------------------------  
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.changeFields 
            	  FROM ( SELECT A.EntityKey ,
                             b.BranchCode ,
                             B.SourceAlt_key ,
                             v.SourceName ,
                             A.RefIssuerID IssuerID  ,
                             B.IssuerName ,
                             A.InvID ,
                             A.ISIN ,
                             A.InstrTypeAlt_Key ,
                             D.InstrumentTypeName ,
                             A.InstrName ,
                             --A.Currency_AltKey,  
                             --B.CurrencyName as Currency,  
                             --A.InvestmentNature,  
                             DN.ParameterAlt_Key InvestmentNature  ,
                             A.Sector ,
                             A.Industry_AltKey ,
                             C.IndustryName Industry  ,
                             EXP.ParameterAlt_Key ExposureType  ,
                             A.SecurityValue ,
                             A.MaturityDt ,
                             A.ReStructureDate ,
                             ----------------------------------------------------------------------------  
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             ' ' changeFields  
                      FROM RBL_MISDB_PROD.InvestmentBasicDetail A
                             LEFT JOIN RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.RefIssuerID = B.IssuerID
                             AND A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimInstrumentType D   ON A.InstrTypeAlt_Key = D.InstrumentTypeAlt_Key
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DIMSOURCEDB v   ON b.SourceAlt_Key = v.SourceAlt_Key
                             AND V.EffectiveFromTimeKey <= v_TimeKey
                             AND V.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimIndustry C   ON A.Industry_ALtKey = C.IndustryAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'ExposureType' TableName  
                                         FROM DimParameter 
                                          WHERE  dimparametername = 'dimexposuretype'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) EXP   ON EXP.ParameterName = A.ExposureType
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName 
                                         FROM DimParameter 
                                          WHERE  dimParameterName = 'diminstrumentnature' ) DN   ON A.InvestmentNature = DN.ParameterName
                       WHERE  NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND NVL(b.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.EntityKey ,
                             B.BranchCode ,
                             B.SourceAlt_key ,
                             v.SourceName ,
                             A.RefIssuerID IssuerID  ,
                             B.IssuerName ,
                             A.InvID ,
                             A.ISIN ,
                             A.InstrTypeAlt_Key ,
                             D.InstrumentTypeName ,
                             A.InstrName ,
                             --A.Currency_AltKey,  
                             --B.CurrencyName as Currency,  
                             --A.InvestmentNature,  
                             DN.ParameterAlt_Key InvestmentNature  ,
                             A.Sector ,
                             A.Industry_AltKey ,
                             C.IndustryName Industry  ,
                             EXP.ParameterAlt_Key ExposureType  ,
                             A.SecurityValue ,
                             A.MaturityDt ,
                             A.ReStructureDate ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             a.changeFields 
                      FROM InvestmentBasicDetail_mod A
                             LEFT JOIN InvestmentIssuerDetail_Mod B   ON A.RefIssuerID = B.IssuerID
                             AND A.EffectiveFromTimeKey <= v_TimeKey
                             AND A.EffectiveToTimeKey >= v_TimeKey
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimInstrumentType D   ON A.InstrTypeAlt_Key = D.InstrumentTypeAlt_Key
                             AND D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DIMSOURCEDB V   ON b.SourceAlt_Key = V.SourceAlt_Key
                             AND V.EffectiveFromTimeKey <= v_TimeKey
                             AND V.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN DimIndustry C   ON A.Industry_ALtKey = C.IndustryAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'ExposureType' TableName  
                                         FROM DimParameter 
                                          WHERE  dimparametername = 'dimexposuretype'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) EXP   ON EXP.ParameterName = A.ExposureType
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName 
                                         FROM DimParameter 
                                          WHERE  dimParameterName = 'diminstrumentnature' ) DN   ON A.InvestmentNature = DN.ParameterName
                       WHERE
                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                       --AND
                        A.EntityKey IN ( SELECT MAX(EntityKey)  
                                         FROM InvestmentBasicDetail_mod 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                   AND NVL(b.AuthorisationStatus, 'A') = 'A'
                                           GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.BranchCode,A.SourceAlt_key,a.SourceName,A.IssuerID,A.IssuerName,A.InvID,A.ISIN,A.InstrTypeAlt_Key,A.InstrumentTypeName,A.InstrName
                        --A.Currency_AltKey,  
                         --B.CurrencyName as Currency,  
                        ,A.InvestmentNature,A.Sector,A.Industry_AltKey,A.Industry,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate
                        ----------------------------------------------------------------------------  
                        ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.changefields );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Entitykey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'InvestmentCodeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_165 A
                                WHERE  ( NVL(InvID, ' ') LIKE '%' || v_InvID || '%'
                                         AND NVL(IssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                         AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                         AND NVL(InstrumentTypeName, ' ') LIKE '%' || v_InstrTypeName || '%' --Changes Done By Sachin on 16022023   

                                         AND NVL(ISIN, ' ') LIKE '%' || v_ISIN || '%' ) ) 
                             --OR(InvID =@InvID)      

                             --OR(InstrTypeAlt_key  =@InstrTypeAlt_key)   

                             --OR(ISIN  =@ISIN)  
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  

         --      AND RowNumber <= (@PageNo * @PageSize);  
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_16516') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_126 ';
               END IF;
               DELETE FROM tt_temp16_126;
               UTILS.IDENTITY_RESET('tt_temp16_126');

               INSERT INTO tt_temp16_126 ( 
               	SELECT A.EntityKey ,
                       A.BranchCode ,
                       A.SourceAlt_key ,
                       a.SourceName ,
                       A.IssuerID ,
                       A.IssuerName ,
                       A.InvID ,
                       A.ISIN ,
                       A.InstrTypeAlt_Key ,
                       A.InstrumentTypeName ,
                       A.InstrName ,
                       --A.Currency_AltKey,  
                       --B.CurrencyName as Currency,  
                       A.InvestmentNature ,
                       A.Sector ,
                       A.Industry_AltKey ,
                       A.Industry ,
                       A.ExposureType ,
                       A.SecurityValue ,
                       UTILS.CONVERT_TO_VARCHAR2(A.MaturityDt,30,p_style=>103) MaturityDt  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.ReStructureDate,30,p_style=>103) ReStructureDate  ,
                       ----------------------------------------------------------------------------  
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.changefields 
               	  FROM ( SELECT A.EntityKey ,
                                B.BranchCode ,
                                B.SourceAlt_key ,
                                v.SourceName ,
                                A.RefIssuerID IssuerID  ,
                                B.IssuerName ,
                                A.InvID ,
                                A.ISIN ,
                                A.InstrTypeAlt_Key ,
                                D.InstrumentTypeName ,
                                A.InstrName ,
                                --A.Currency_AltKey,  
                                --B.CurrencyName as Currency,  
                                --A.InvestmentNature,  
                                DN.ParameterAlt_Key InvestmentNature  ,
                                A.Sector ,
                                A.Industry_AltKey ,
                                C.IndustryName Industry  ,
                                EXP.ParameterAlt_Key ExposureType  ,
                                A.SecurityValue ,
                                A.MaturityDt ,
                                A.ReStructureDate ,
                                ----------------------------------------------------------------------------  
                                A.AuthorisationStatus ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                a.changefields 
                         FROM InvestmentBasicDetail_mod A
                                LEFT JOIN InvestmentIssuerDetail_Mod B   ON A.RefIssuerID = B.IssuerID
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimInstrumentType D   ON A.InstrTypeAlt_Key = D.InstrumentTypeAlt_Key
                                AND D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DIMSOURCEDB V   ON b.SourceAlt_key = V.SourceAlt_Key
                                AND V.EffectiveFromTimeKey <= v_TimeKey
                                AND V.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN DimIndustry C   ON A.Industry_AltKey = C.IndustryAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'ExposureType' TableName  
                                            FROM DimParameter 
                                             WHERE  dimparametername = 'dimexposuretype'
                                                      AND EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey ) EXP   ON EXP.ParameterName = A.ExposureType
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName 
                                            FROM DimParameter 
                                             WHERE  dimParameterName = 'diminstrumentnature' ) DN   ON A.InvestmentNature = DN.ParameterName
                          WHERE
                         --A.EffectiveFromTimeKey <= @TimeKey  
                          --                     AND A.EffectiveToTimeKey >= @TimeKey  
                          --                     --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                          --AND
                           A.EntityKey IN ( SELECT MAX(EntityKey)  
                                            FROM InvestmentBasicDetail_mod 
                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                      AND NVL(b.AuthorisationStatus, 'A') = 'A'
                                              GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.EntityKey,A.BranchCode,A.SourceAlt_key,a.SourceName,A.IssuerID,A.IssuerName,A.InvID,A.ISIN,A.InstrTypeAlt_Key,A.InstrumentTypeName,A.InstrName
                           --A.Currency_AltKey,  
                            --B.CurrencyName as Currency,  
                           ,A.InvestmentNature,A.Sector,A.Industry_AltKey,A.Industry,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate
                           ----------------------------------------------------------------------------  
                           ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.changefields );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Entitykey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'InvestmentCodeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_126 A
                                   WHERE  ( NVL(InvID, ' ') LIKE '%' || v_InvID || '%'
                                            AND NVL(IssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                            AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                            AND NVL(InstrumentTypeName, ' ') LIKE '%' || v_InstrTypeName || '%' --Changes Done By Sachin on 16022023   

                                            AND NVL(ISIN, ' ') LIKE '%' || v_ISIN || '%' ) ) 
                                --OR(InvID =@InvID)      

                                --OR(InstrTypeAlt_key  =@InstrTypeAlt_key)   

                                --OR(ISIN  =@ISIN)  
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  

            --      AND RowNumber <= (@PageNo * @PageSize)  
            ELSE
               IF ( v_OperationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_16520') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_91 ';
                  END IF;
                  DELETE FROM tt_temp20_91;
                  UTILS.IDENTITY_RESET('tt_temp20_91');

                  INSERT INTO tt_temp20_91 ( 
                  	SELECT A.EntityKey ,
                          A.BranchCode ,
                          A.SourceAlt_key ,
                          a.SourceName ,
                          A.IssuerID ,
                          A.IssuerName ,
                          A.InvID ,
                          A.ISIN ,
                          A.InstrTypeAlt_Key ,
                          A.InstrumentTypeName ,
                          A.InstrName ,
                          --A.Currency_AltKey,  
                          --B.CurrencyName as Currency,  
                          A.InvestmentNature ,
                          A.Sector ,
                          A.Industry_AltKey ,
                          A.Industry ,
                          A.ExposureType ,
                          A.SecurityValue ,
                          UTILS.CONVERT_TO_VARCHAR2(A.MaturityDt,30,p_style=>103) MaturityDt  ,
                          UTILS.CONVERT_TO_VARCHAR2(A.ReStructureDate,30,p_style=>103) ReStructureDate  ,
                          ----------------------------------------------------------------------------  
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.ApprovedBy ,
                          A.DateApproved 
                  	  FROM ( SELECT A.EntityKey ,
                                   B.BranchCode ,
                                   B.SourceAlt_key ,
                                   v.SourceName ,
                                   A.RefIssuerID IssuerID  ,
                                   B.IssuerName ,
                                   A.InvID ,
                                   A.ISIN ,
                                   A.InstrTypeAlt_Key ,
                                   D.InstrumentTypeName ,
                                   A.InstrName ,
                                   --A.Currency_AltKey,  
                                   --B.CurrencyName as Currency,  
                                   -- A.InvestmentNature,  
                                   DN.ParameterAlt_Key InvestmentNature  ,
                                   A.Sector ,
                                   A.Industry_AltKey ,
                                   C.IndustryName Industry  ,
                                   EXP.ParameterAlt_Key ExposureType  ,
                                   A.SecurityValue ,
                                   A.MaturityDt ,
                                   A.ReStructureDate ,
                                   ----------------------------------------------------------------------------  
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   a.changefields 
                            FROM InvestmentBasicDetail_mod A
                                   LEFT JOIN InvestmentIssuerDetail_Mod B   ON A.RefIssuerID = B.IssuerID
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimInstrumentType D   ON A.InstrTypeAlt_Key = D.InstrumentTypeAlt_Key
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DIMSOURCEDB V   ON b.SourceAlt_key = V.SourceAlt_Key
                                   AND V.EffectiveFromTimeKey <= v_TimeKey
                                   AND V.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN DimIndustry C   ON A.Industry_AltKey = C.IndustryAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                      ParameterName ,
                                                      'ExposureType' TableName  
                                               FROM DimParameter 
                                                WHERE  dimparametername = 'dimexposuretype'
                                                         AND EffectiveFromTimeKey <= v_TimeKey
                                                         AND EffectiveToTimeKey >= v_TimeKey ) EXP   ON EXP.ParameterName = A.ExposureType
                                   LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                      ParameterName 
                                               FROM DimParameter 
                                                WHERE  dimParameterName = 'diminstrumentnature' ) DN   ON A.InvestmentNature = DN.ParameterName
                             WHERE
                            --A.EffectiveFromTimeKey <= @TimeKey  
                             --                        AND A.EffectiveToTimeKey >= @TimeKey  
                             --                        AND 
                              NVL(a.AuthorisationStatus, 'A') IN ( '1A' )

                                AND NVL(b.AuthorisationStatus, 'A') = 'A'
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM InvestmentBasicDetail_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                                               AND NVL(b.AuthorisationStatus, 'A') = 'A'
                                                       GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.EntityKey,A.BranchCode,A.SourceAlt_key,a.SourceName,A.IssuerID,A.IssuerName,A.InvID,A.ISIN,A.InstrTypeAlt_Key,A.InstrumentTypeName,A.InstrName
                              --A.Currency_AltKey,  
                               --B.CurrencyName as Currency,  
                              ,A.InvestmentNature,A.Sector,A.Industry_AltKey,A.Industry,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate
                              ----------------------------------------------------------------------------  
                              ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Entitykey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'InvestmentCodeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_91 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                                   DataPointOwner ) DataPointOwner ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
            END IF;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
      --      AND RowNumber <= (@PageNo * @PageSize)  
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
