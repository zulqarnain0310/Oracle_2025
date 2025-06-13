--------------------------------------------------------
--  DDL for Procedure INVESTMENTISSUERQUICKSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" 
--exec [InvestmentIssuerQuickSearchlist] '0706','','',16

(
  --Declare
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT 'RAM' ,
  v_PanNo IN VARCHAR2 DEFAULT ' ' ,
  --,@InvID				Varchar (100)		= ''--,@InstrTypeAlt_key	Varchar (100)		= ''--,@ISIN				varchar (100)		= ''
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   BEGIN

      BEGIN
         --		 	IF ((@PanNo ='') AND  (@IssuerID='') AND (@IssuerName ='' ) AND  (@operationflag not in(16,20)))
         --		BEGIN
         --		print '111'
         --				 SELECT    A.SourceAlt_key,
         --							B.SourceName,
         --                            A.UcifId,
         --                            A.PanNo,
         --				            A.EntityKey,
         --                            A.BranchCode,
         --                            A.IssuerID,
         --                            A.IssuerName,
         --                            A.Ref_Txn_Sys_Cust_ID,
         --                            A.Issuer_Category_Code,
         --							S.IssuerCategoryName,
         --                            A.GrpEntityOfBank,                       			
         --                            A.AuthorisationStatus,
         --                            A.EffectiveFromTimeKey,
         --                            A.EffectiveToTimeKey,
         --								A.CreatedBy,
         --								A.DateCreated,
         --								A.ModifiedBy,
         --								A.DateModified,
         --								A.ApprovedBy,
         --								A.DateApproved
         --                     INTO		#TEMP55
         --InvestmentIssuerDetail_mod
         --                     FROM		curdat.InvestmentIssuerDetail A 
         --					 Left join	DimsourceDb B on A.SourceAlt_Key=B.SourceAlt_Key										 
         --					left join DimIssuerCategory S on A.Issuer_Category_Code = S.IssuerCategoryAlt_Key
         --					  WHERE A.EffectiveFromTimeKey <= @TimeKey
         --                           AND A.EffectiveToTimeKey >= @TimeKey
         --                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
         --					 UNION
         --                     SELECT		
         --                          A.SourceAlt_key,
         --							B.SourceName,
         --                            A.UcifId,
         --                            A.PanNo,
         --				            A.EntityKey,
         --                            A.BranchCode,
         --                            A.IssuerID,
         --                            A.IssuerName,
         --                            A.Ref_Txn_Sys_Cust_ID,
         --                            A.Issuer_Category_Code,
         --							S.IssuerCategoryName,
         --                            A.GrpEntityOfBank,                       
         --                            A.AuthorisationStatus,
         --                            A.EffectiveFromTimeKey,
         --                            A.EffectiveToTimeKey,
         --								A.CreatedBy,
         --								A.DateCreated,
         --								A.ModifiedBy,
         --								A.DateModified,
         --								A.ApprovedBy,
         --								A.DateApproved
         --                    FROM InvestmentIssuerDetail_Mod A 
         --					 Left join DimsourceDb B on A.SourceAlt_Key=B.SourceAlt_Key										
         --						left join DimIssuerCategory S on A.Issuer_Category_Code = S.IssuerCategoryAlt_Key
         --						Where A.EffectiveFromTimeKey <= @TimeKey
         --                           AND A.EffectiveToTimeKey >= @TimeKey
         --						AND A.EntityKey IN
         --                     (
         --                         SELECT MAX(EntityKey)
         --                         FROM InvestmentIssuerDetail_Mod
         --                         WHERE EffectiveFromTimeKey <= @TimeKey
         --                               AND EffectiveToTimeKey >= @TimeKey
         --                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')							  
         --                         GROUP BY EntityKey
         --                     )
         --					        SELECT *
         --                 FROM
         --                 (
         --                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
         --                            COUNT(*) OVER() AS TotalCount, 
         --                            'InvestmentCodeMaster' TableName, 
         --                            *
         --                     FROM
         --                     (
         --                         SELECT *
         --                         FROM tt_temp_17455 A
         --                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
         --                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
         --                     ) AS DataPointOwner
         --                 ) AS DataPointOwner
         --                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --                 --      AND RowNumber <= (@PageNo * @PageSize);
         --				 return;
         --		END
         --		--	IF @PanNo =''
         --		--   SET @PanNo=NULL
         --		--IF @IssuerID =''
         --		--   SET @IssuerID=NULL
         --		--IF @IssuerName =''
         --		--   SET @IssuerName=NULL
         --		   --IF @InvID =''
         --		   --SET @InvID=NULL
         --		   --IF @ISIN =''
         --		   --SET @ISIN=NULL
         --		   --		   IF @InstrTypeAlt_key =''
         --		   --SET @InstrTypeAlt_key=NULL
         --		   print '1'
         --/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
         IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
            ACLProcessStatusCheck() ;

         END;
         END IF;
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_174') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_174 ';
            END IF;
            DELETE FROM tt_temp_174;
            UTILS.IDENTITY_RESET('tt_temp_174');

            INSERT INTO tt_temp_174 ( 
            	SELECT
            	--A.CustomerACID,
            	 --A.CustomerID,
            	 --A.CustomerName,
            	 --A.DerivativeRefNo,
            	 --A.Duedate,
            	 --A.DueAmt,
            	 --A.OsAmt,
            	 --A.POS,
            	 ---------------------------------
            	 A.SourceAlt_key ,
              A.SourceName ,
              A.UcifId ,
              A.PanNo ,
              A.EntityKey ,
              A.BranchCode ,
              A.IssuerEntityId ,
              A.IssuerID ,
              A.IssuerName ,
              A.Ref_Txn_Sys_Cust_ID ,
              A.Issuer_Category_Code ,
              A.IssuerCategoryName ,
              A.GrpEntityOfBank ,
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
            	  FROM ( SELECT
                      --E.CustomerACID,
                       --E.CustomerID,
                       --E.CustomerName,
                       --E.DerivativeRefNo,
                       --E.Duedate,
                       --E.DueAmt,
                       --E.OsAmt,
                       --E.POS,
                       ---------------------------------
                       A.SourceAlt_key ,
                       B.SourceName ,
                       A.UcifId ,
                       A.PanNo ,
                       A.EntityKey ,
                       A.BranchCode ,
                       A.IssuerEntityId ,
                       A.IssuerID ,
                       A.IssuerName ,
                       A.Ref_Txn_Sys_Cust_ID ,
                       S.IssuerCategoryAlt_Key Issuer_Category_Code  ,
                       S.IssuerCategoryName ,
                       A.GrpEntityOfBank ,
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
                       --select * from  curdat.Advacbasicdetail
                       ' ' changeFields  
                      FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail A
                             LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             LEFT JOIN DimIssuerCategory S   ON A.Issuer_Category_Code = S.IssuerCategoryName
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 

                      --OR(InvID	=@InvID)				

                      --OR(InstrTypeAlt_key		=@InstrTypeAlt_key)	

                      --OR(ISIN		=@ISIN)
                      SELECT A.SourceAlt_key ,
                             B.SourceName ,
                             A.UcifId ,
                             A.PanNo ,
                             A.EntityKey ,
                             A.BranchCode ,
                             A.IssuerEntityId ,
                             A.IssuerID ,
                             A.IssuerName ,
                             A.Ref_Txn_Sys_Cust_ID ,
                             S.IssuerCategoryAlt_Key Issuer_Category_Code  ,
                             S.IssuerCategoryName ,
                             A.GrpEntityOfBank ,
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
                      FROM InvestmentIssuerDetail_Mod A
                             LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                           --Left join DimIndustry H on C.Industry_AltKey=H.IndustryAlt_Key
                            --Left join DimInstrumentType G on C.InstrTypeAlt_Key=G.InstrumentTypeAlt_Key
                            -- Left join Dimcurrency E on D.currencyAlt_Key=E.CurrencyAlt_Key
                            -- Left join DimAssetClass F on D.AssetClass_AltKey=F.AssetClassAlt_Key
                            -- left join DimParameter P on D.HoldingNature = P.ParameterName
                            --  left join DimParameter Q on D.PartialRedumptionSettledY_N = Q.ParameterName
                            --   left join DimParameter R on C.InvestmentNature = R.ParameterName

                             LEFT JOIN DimIssuerCategory S   ON A.Issuer_Category_Code = S.IssuerCategoryName

                      --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey

                               --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                               --   AND (

                               --(A.PanNo   = @PanNo)				

                               --  OR (IssuerID =@IssuerID)			

                               --OR (IssuerName like '%' + @IssuerName+ '%')		

                               ----OR(InvID	=@InvID)				

                               ----OR(InstrTypeAlt_key		=@InstrTypeAlt_key)	

                               ----OR(ISIN		=@ISIN)

                               --)
                               AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                    FROM InvestmentIssuerDetail_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                      GROUP BY EntityKey )
                     ) A
            	  GROUP
            	--A.CustomerACID,
            	 --A.CustomerID,
            	 --A.CustomerName,
            	 --A.DerivativeRefNo,
            	 --A.Duedate,
            	 --A.DueAmt,
            	 --A.OsAmt,
            	 --A.POS,
            	 ---------------------------------
            	 BY A.SourceAlt_key,A.SourceName,A.UcifId,A.PanNo,A.EntityKey,A.BranchCode,A.IssuerEntityId,A.IssuerID,A.IssuerName,A.Ref_Txn_Sys_Cust_ID,A.Issuer_Category_Code,A.IssuerCategoryName,A.GrpEntityOfBank
                 ----------------------------------------------------------------------------
                 ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.changeFields );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'InvestmentCodeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_174 A
                                WHERE  NVL(IssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                         AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                         AND NVL(PanNo, ' ') LIKE '%' || v_PanNo || '%' ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
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
               IF utils.object_id('TempDB..tt_temp_17416') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_133 ';
               END IF;
               DELETE FROM tt_temp16_133;
               UTILS.IDENTITY_RESET('tt_temp16_133');

               INSERT INTO tt_temp16_133 ( 
               	SELECT
               	--A.CustomerACID,
               	 --A.CustomerID,
               	 --A.CustomerName,
               	 --A.DerivativeRefNo,
               	 --A.Duedate,
               	 --A.DueAmt,
               	 --A.OsAmt,
               	 --A.POS,
               	 ---------------------------------
               	 A.SourceAlt_key ,
                 A.SourceName ,
                 A.UcifId ,
                 A.PanNo ,
                 A.EntityKey ,
                 A.BranchCode ,
                 A.IssuerEntityId ,
                 A.IssuerID ,
                 A.IssuerName ,
                 A.Ref_Txn_Sys_Cust_ID ,
                 A.Issuer_Category_Code ,
                 A.IssuerCategoryName ,
                 A.GrpEntityOfBank ,
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
               	  FROM ( SELECT
                         --E.CustomerACID,
                          --E.CustomerID,
                          --E.CustomerName,
                          --E.DerivativeRefNo,
                          --E.Duedate,
                          --E.DueAmt,
                          --E.OsAmt,
                          --E.POS,
                          ---------------------------------
                          A.SourceAlt_key ,
                          B.SourceName ,
                          A.UcifId ,
                          A.PanNo ,
                          A.EntityKey ,
                          A.BranchCode ,
                          A.IssuerEntityId ,
                          A.IssuerID ,
                          A.IssuerName ,
                          A.Ref_Txn_Sys_Cust_ID ,
                          S.IssuerCategoryAlt_Key Issuer_Category_Code  ,
                          S.IssuerCategoryName ,
                          A.GrpEntityOfBank ,
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
                         FROM InvestmentIssuerDetail_Mod A
                                LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_key = B.SourceAlt_Key
                              --Left join DimIndustry H on C.Industry_AltKey=H.IndustryAlt_Key
                               --Left join DimInstrumentType G on C.InstrTypeAlt_Key=G.InstrumentTypeAlt_Key
                               -- Left join Dimcurrency E on D.currencyAlt_Key=E.CurrencyAlt_Key
                               -- Left join DimAssetClass F on D.AssetClass_AltKey=F.AssetClassAlt_Key
                               -- left join DimParameter P on D.HoldingNature = P.ParameterName
                               --  left join DimParameter Q on D.PartialRedumptionSettledY_N = Q.ParameterName
                               --   left join DimParameter R on C.InvestmentNature = R.ParameterName

                                LEFT JOIN DimIssuerCategory S   ON A.Issuer_Category_Code = S.IssuerCategoryName

                         --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey

                                  --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                  AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                       FROM InvestmentIssuerDetail_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                         GROUP BY EntityKey )
                        ) A
               	  GROUP
               	--A.CustomerACID,
               	 --A.CustomerID,
               	 --A.CustomerName,
               	 --A.DerivativeRefNo,
               	 --A.Duedate,
               	 --A.DueAmt,
               	 --A.OsAmt,
               	 --A.POS,
               	 BY A.SourceAlt_key,A.SourceName,A.UcifId,A.PanNo,A.EntityKey,A.BranchCode,A.IssuerEntityId,A.IssuerID,A.IssuerName,A.Ref_Txn_Sys_Cust_ID,A.Issuer_Category_Code,A.IssuerCategoryName,A.GrpEntityOfBank
                    ----------------------------------------------------------------------------
                    ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved,A.changeFields );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'InvestmentCodeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_133 A
                                   WHERE  NVL(IssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                            AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                            AND NVL(PanNo, ' ') LIKE '%' || v_PanNo || '%' ) 
                                --AND ISNULL(ISIN, '')				LIKE '%'+@ISIN+'%' 

                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_17420') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_98 ';
                  END IF;
                  DELETE FROM tt_temp20_98;
                  UTILS.IDENTITY_RESET('tt_temp20_98');

                  INSERT INTO tt_temp20_98 ( 
                  	SELECT A.SourceAlt_key ,
                          A.SourceName ,
                          A.UcifId ,
                          A.PanNo ,
                          A.EntityKey ,
                          A.BranchCode ,
                          A.IssuerEntityId ,
                          A.IssuerID ,
                          A.IssuerName ,
                          A.Ref_Txn_Sys_Cust_ID ,
                          A.Issuer_Category_Code ,
                          A.IssuerCategoryName ,
                          A.GrpEntityOfBank ,
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
                  	  FROM ( SELECT
                            --E.CustomerACID,
                             --E.CustomerID,
                             --E.CustomerName,
                             --E.DerivativeRefNo,
                             --E.Duedate,
                             --E.DueAmt,
                             --E.OsAmt,
                             --E.POS,
                             ---------------------------------
                             A.SourceAlt_key ,
                             B.SourceName ,
                             A.UcifId ,
                             A.PanNo ,
                             A.EntityKey ,
                             A.BranchCode ,
                             A.IssuerEntityId ,
                             A.IssuerID ,
                             A.IssuerName ,
                             A.Ref_Txn_Sys_Cust_ID ,
                             S.IssuerCategoryAlt_Key Issuer_Category_Code  ,
                             S.IssuerCategoryName ,
                             A.GrpEntityOfBank ,
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
                            FROM InvestmentIssuerDetail_Mod A
                                   LEFT JOIN DIMSOURCEDB B   ON A.SourceAlt_key = B.SourceAlt_Key
                                 --Left join DimIndustry H on C.Industry_AltKey=H.IndustryAlt_Key
                                  --Left join DimInstrumentType G on C.InstrTypeAlt_Key=G.InstrumentTypeAlt_Key
                                  -- Left join Dimcurrency E on D.currencyAlt_Key=E.CurrencyAlt_Key
                                  -- Left join DimAssetClass F on D.AssetClass_AltKey=F.AssetClassAlt_Key
                                  -- left join DimParameter P on D.HoldingNature = P.ParameterName
                                  --  left join DimParameter Q on D.PartialRedumptionSettledY_N = Q.ParameterName
                                  --   left join DimParameter R on C.InvestmentNature = R.ParameterName

                                   LEFT JOIN DimIssuerCategory S   ON A.Issuer_Category_Code = S.IssuerCategoryName
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM InvestmentIssuerDetail_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.SourceAlt_key,A.SourceName,A.UcifId,A.PanNo,A.EntityKey,A.BranchCode,A.IssuerEntityId,A.IssuerID,A.IssuerName,A.Ref_Txn_Sys_Cust_ID,A.Issuer_Category_Code,A.IssuerCategoryName,A.GrpEntityOfBank
                              ----------------------------------------------------------------------------
                              ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.ApprovedBy,A.DateApproved );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'InvestmentCodeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_98 A
                                      WHERE  NVL(IssuerID, ' ') LIKE '%' || v_IssuerID || '%'
                                               AND NVL(IssuerName, ' ') LIKE '%' || v_IssuerName || '%'
                                               AND NVL(PanNo, ' ') LIKE '%' || v_PanNo || '%' ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERQUICKSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
