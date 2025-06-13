--------------------------------------------------------
--  DDL for Procedure PRODUCTADDITION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."PRODUCTADDITION" 
AS
   --      DECLARE @TIMEKEY INT=(SELECT TIMEKEY FROM [RBL_MISDB].dbo.Automate_Advances WHERE EXT_FLG='Y')
   --DECLARE @ProcessDate Date=(SELECT Date FROM [RBL_MISDB].dbo.Automate_Advances WHERE EXT_FLG='Y')
   -----------Added By Prashant---07112024--------
   v_ProcessDate VARCHAR2(200) ;
   v_TIMEKEY NUMBER(10,0) ;
   --------------------------END-----------------------
   v_Counter NUMBER(10,0);
   v_FinalCounter NUMBER(10,0) ;
    v_Productcode VARCHAR2(20) ;
    v_SecuredStatus VARCHAR2(30);
    v_ProductGroup VARCHAR2(30);
    v_SourceAlt_Key NUMBER(10,0);
    v_ProductName VARCHAR2(100);
    v_SchemeType VARCHAR2(200) ;
    v_FacilityType VARCHAR2(200) ;
    v_BranchCode VARCHAR2(20);
    v_SegmentCode VARCHAR2(20) ;
    v_SourceAlt_Key_Seg NUMBER(10,0);
BEGIN

SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(DateofData,200) INTO v_ProcessDate
     FROM ACCOUNT_ALL_SOURCE_SYSTEM  ;
     
   SELECT TIMEKEY INTO v_TIMEKEY 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  DATE_ = v_ProcessDate ;

   SELECT COUNT(*)  INTO v_FinalCounter 
     FROM ( SELECT DISTINCT Scheme_ProductCode 
            FROM ACCOUNT_ALL_SOURCE_SYSTEM 
            MINUS 
            SELECT DISTINCT productcode 
            FROM RBL_MISDB_PROD.DimProduct  ) A ;

   v_Counter := 1 ;
   WHILE ( v_Counter <= v_FinalCounter ) 
   LOOP 

               SELECT DISTINCT Scheme_ProductCode INTO v_Productcode
                  FROM ACCOUNT_ALL_SOURCE_SYSTEM 
                  MINUS 
                  SELECT DISTINCT productcode 
                  FROM RBL_MISDB_PROD.DimProduct A 
                  WHERE ROWNUM=1
           ;
         SELECT DISTINCT (CASE 
                                 WHEN SecuredStatus = 'U' THEN 'UNSECURED'
                           ELSE 'SECURED'
                              END) INTO v_SecuredStatus
           FROM ACCOUNT_ALL_SOURCE_SYSTEM 
          WHERE  Scheme_ProductCode = v_Productcode 
          ;
         SELECT DISTINCT SchemeType INTO v_ProductGroup
           FROM ACCOUNT_ALL_SOURCE_SYSTEM 
          WHERE  Scheme_ProductCode = v_Productcode 
          ;
         -------------------------------------------------------------------------------------------------------------
         SELECT DISTINCT SourceAlt_Key INTO v_SourceAlt_Key 
           FROM ACCOUNT_ALL_SOURCE_SYSTEM a
                  JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON a.SourceSystem = b.SourceName
          WHERE  Scheme_ProductCode = v_Productcode 
          AND ROWNUM=1
           ;
         v_ProductName := ' ';
         SELECT DISTINCT SchemeType INTO v_SchemeType 
           FROM ACCOUNT_ALL_SOURCE_SYSTEM a
          WHERE  Scheme_ProductCode = v_Productcode 
          AND ROWNUM=1
           ;
         SELECT DISTINCT FacilityType INTO v_FacilityType 
           FROM ACCOUNT_ALL_SOURCE_SYSTEM a
          WHERE  Scheme_ProductCode = v_Productcode 
          AND ROWNUM=1
           ;

      BEGIN
         SELECT schm_desc 
           INTO v_ProductName
           FROM DWH_STG.product_code_master_finacle 
          WHERE  schm_code = v_Productcode;
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            SELECT scheme_description 

              INTO v_ProductName
              FROM DWH_STG.product_code_master 
             WHERE  product_code = v_Productcode;

         END;
         END IF;
         --Set @ProductName=(select schm_desc from DWH_STG.dwh.product_code_master_finacle	
         --									where schm_code=@Productcode)
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            SELECT product_description 

              INTO v_ProductName
              FROM DWH_STG.product_code_master_mifin 
             WHERE  product_code = v_Productcode;

         END;
         END IF;
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            SELECT scheme_Desc 

              INTO v_ProductName
              FROM DWH_STG.product_code_master_FIS 
             WHERE  scheme_code = v_Productcode;

         END;
         END IF;
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            SELECT Product_Name 

              INTO v_ProductName
              FROM DWH_STG.product_code_master_visionplus 
             WHERE  logo = v_Productcode;

         END;
         END IF;
         ----------------- Product Description Added By Satwaji as on 02/08/2023 for ECBF ---------------
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            SELECT product_description 

              INTO v_ProductName
              FROM DWH_STG.product_master_ecbf 
             WHERE  product_code = v_Productcode;

         END;
         END IF;
         IF ( NVL(v_ProductName, ' ') = ' ' ) THEN

         BEGIN
            v_ProductName := v_Productcode ;

         END;
         END IF;
         --Declare @NPA_Norms varchar(100)=(select  distinct top 1 isnull(AssetClassNorm,'90') from ACCOUNT_ALL_SOURCE_SYSTEM a
         --							      where           Scheme_ProductCode = @Productcode)
         --Declare @Agrischeme varchar(100)=(select  case when @NPA_Norms='365.000000' then 'Y' else 'N' end
         --								  from    ACCOUNT_ALL_SOURCE_SYSTEM a
         --							      where           Scheme_ProductCode = @Productcode)
         --------------------------------------------------------------------------------------------------------------------
         INSERT INTO RBL_MISDB_PROD.DimProduct
           ( ProductAlt_Key, ProductCode, ProductName, ProductGroup, ProductSubGroup, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, SourceAlt_Key, RBL_ProductGroup, SchemeType, FacilityType --,NPANorms,Agrischeme)
          )
           ( SELECT MAX(ProductAlt_key)  + 1 ,
                    v_Productcode ,
                    v_ProductName ,
                    v_ProductGroup ,
                    v_SecuredStatus ,
                    v_TIMEKEY ,
                    49999 ,
                    'D2K' ,
                    SYSDATE ,
                    v_SourceAlt_Key ,
                    v_ProductGroup ,
                    v_SchemeType ,
                    v_FacilityType --,@NPA_Norms,@Agrischeme

             FROM RBL_MISDB_PROD.DimProduct  );
         v_Counter := v_Counter + 1 ;

      END;
   END LOOP;
   --------------------------------Added by Sudesh 11032023---------Branch New Insertion-----
   v_Counter := 1 ;
   SELECT COUNT(*)  

     INTO v_FinalCounter
     FROM ( SELECT DISTINCT BranchCode 
            FROM RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM 
            MINUS 
            SELECT DISTINCT CAST(BranchCode AS VARCHAR2(10))
            FROM RBL_MISDB_PROD.DimBranch  ) A;
   WHILE ( v_Counter <= v_FinalCounter ) 
   LOOP 
          
           SELECT DISTINCT BranchCode INTO v_BranchCode
                  FROM ACCOUNT_ALL_SOURCE_SYSTEM 
                  MINUS 
                  SELECT DISTINCT CAST(BranchCode AS VARCHAR2(10))
                  FROM RBL_MISDB_PROD.DimBranch  A 
           ;

      BEGIN
         --------------------------------------------------------------------------------------------
         INSERT INTO RBL_MISDB_PROD.DimBranch
           ( BranchAlt_Key, BranchCode, BranchName, BranchOpenDt, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated --,NPANorms,Agrischeme)
          )
           ( SELECT MAX(BranchAlt_key)  + 1 ,
                    v_BranchCode ,
                    v_BranchCode ,
                    SYSDATE ,
                    v_TIMEKEY ,
                    49999 ,
                    'D2K' ,
                    SYSDATE 

             --,@NPA_Norms,@Agrischeme
             FROM RBL_MISDB_PROD.DimBranch  );
         v_Counter := v_Counter + 1 ;

      END;
   END LOOP;
   ----------START CURRENCY RATE MASTER-----Added by Prashant--06032024--------------------------------
   --DECLARE @ProcessDate Date=(SELECT Date FROM [RBL_MISDB_PROD].dbo.Automate_Advances WHERE EXT_FLG='Y')
   --select @ProcessDate
   DELETE RBL_MISDB_PROD.DimCurrencyRateDaily

    WHERE  date_ = v_ProcessDate;
   INSERT INTO RBL_MISDB_PROD.DimCurrencyRateDaily
     ( Date_, currency, Rate )
     ( SELECT rate_date ,
              ccy_code1 ,
              rate 
       FROM DWH_STG.Currency_Rate_master 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(rate_date,200) = v_ProcessDate

                 --    and         ccy_code1='USD' 
                 AND ccy_code2 = 'INR' );
   ------------------------------------------------------------------------------------
   ----------START Segment code insertion-----Added by Prashant--06032024--------------------------
   v_Counter := 1 ;
   SELECT COUNT(*)  

     INTO v_FinalCounter
     FROM ( SELECT DISTINCT AcSegmentcode 
            FROM ACCOUNT_ALL_SOURCE_SYSTEM 
            MINUS 
            SELECT DISTINCT AcBuSegmentCode 
            FROM RBL_MISDB_PROD.DimAcBuSegment 
             WHERE  EffectiveToTimeKey = 49999 ) A;
   WHILE ( v_Counter <= v_FinalCounter ) 
   LOOP 
      
           SELECT * INTO v_SegmentCode
           FROM ( SELECT DISTINCT AcSegmentcode 
                  FROM ACCOUNT_ALL_SOURCE_SYSTEM 
                  MINUS 
                  SELECT DISTINCT AcBuSegmentCode 
                  FROM RBL_MISDB_PROD.DimAcBuSegment 
                   WHERE  EffectiveToTimeKey = 49999 ) A 
           ;
         SELECT DISTINCT SourceAlt_Key INTO v_SourceAlt_Key_Seg
           FROM ACCOUNT_ALL_SOURCE_SYSTEM a
                  JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON a.SourceSystem = b.SourceName
          WHERE  AcSegmentCode = v_SegmentCode 
           ;

      BEGIN
         INSERT INTO RBL_MISDB_PROD.DimAcBuSegment
           ( AcBuSegment_Key, AcBuSegmentAlt_Key, AcBuSegmentCode, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, SourceAlt_Key --,NPANorms,Agrischeme)
          )
           ( SELECT MAX(AcBuSegment_Key)  + 1 ,
                    MAX(AcBuSegmentAlt_Key)  + 1 ,
                    v_SegmentCode ,
                    'A' ,
                    v_TIMEKEY ,
                    49999 ,
                    'D2K' ,
                    SYSDATE ,
                    v_SourceAlt_Key_Seg 

             --,@NPA_Norms,@Agrischeme
             FROM RBL_MISDB_PROD.DimAcBuSegment  );
         v_Counter := v_Counter + 1 ;------------------------------------------------------------------------------------

      END;
   END LOOP;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."PRODUCTADDITION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."PRODUCTADDITION" TO "ADF_CDR_RBL_STGDB";
