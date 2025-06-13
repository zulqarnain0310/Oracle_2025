--------------------------------------------------------
--  DDL for Function ACCELERATEDPROVISION_DETAILS_18112023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" 
(
  v_SearchType IN NUMBER DEFAULT 0 ,
  v_Cust_Ucic_Acid IN VARCHAR2 DEFAULT ' ' ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --IF OBJECT_ID('TempDB..#temp') IS NOT NULL  
   --             DROP TABLE  #temp;  
   v_BorrowerName VARCHAR2(80) := ' ';
   v_CustomerEntityId NUMBER(10,0) := 0;
   v_AccountEntityId NUMBER(10,0) := 0;
   v_segmentcode VARCHAR2(100) := ' ';
   v_AssetClassName VARCHAR2(50) := ' ';
   v_segmentDescription VARCHAR2(50) := ' ';
   v_TimeKey NUMBER(10,0);
   v_Count NUMBER(10,0) := 0;
   v_SecuredUnsecured VARCHAR2(20) := ' ';
   v_Provision NUMBER(5,2) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   IF utils.object_id('TempDB..tt_tmp2_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp2_3 ';
   END IF;
   DELETE FROM tt_tmp2_3;
   IF ( v_SearchType = 1 ) THEN

   BEGIN

      BEGIN
         SELECT COUNT(1)  

           INTO v_Count
           FROM RBL_MISDB_PROD.CustomerBasicDetail 
          WHERE  CustomerId = v_Cust_Ucic_Acid
                   AND EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey;
         IF ( v_Count <= 0 ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SAC1');
            OPEN  v_cursor FOR
               SELECT 6 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            v_Result := 6 ;
            RETURN v_Result;

         END;
         END IF;

      END;
      SELECT CustomerName 

        INTO v_BorrowerName
        FROM RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  CustomerId = v_Cust_Ucic_Acid
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey 
        FETCH FIRST 1 ROWS ONLY;
      --Select @segmentcode=segmentcode from [CurDat].[Advacbasicdetail]
      --where CustomerEntityId=@CustomerEntityId
      --Select @segmentDescription=AcBuSegmentDescription from DimAcBuSegment
      --Where AcBuSegmentCode=@segmentcode
      --Select @AssetClassName=B.AssetClassAlt_Key  from AcceleratedProvision A
      --INNER JOIN DimAssetClass B ON A.AssetClassNameAlt_key =B.AssetClassAlt_Key 
      --Where A.CustomerEntityId=@CustomerEntityId
      --IF (@AssetClassName='')
      --    BEGIN
      --	   SET @AssetClassName='STANDARD'
      --	END
      INSERT INTO tt_tmp2_3
        VALUES ( 'BorrowerName', v_BorrowerName, 'CustomerDetail' );
      --INSERT INTO  tt_tmp2_3 Values('SegmentDescription',@segmentcode,'CustomerDetail')
      --INSERT INTO  tt_tmp2_3 Values('AssetClassName',@AssetClassName,'CustomerDetail')
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp2_3  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --Select @Result As result  
   IF ( v_SearchType = 2 ) THEN

   BEGIN

      BEGIN
         SELECT COUNT(1)  

           INTO v_Count
           FROM RBL_MISDB_PROD.AdvAcBasicDetail 
          WHERE  CustomerACID = v_Cust_Ucic_Acid
                   AND EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey;
         IF ( v_Count <= 0 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT 7 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            v_Result := 7 ;
            RETURN v_Result;

         END;
         END IF;

      END;
      SELECT AccountEntityId ,
             CustomerEntityId ,
             CASE 
                  WHEN FlgSecured = 'U' THEN 'Unsecured'
                  WHEN FlgSecured = 'S' THEN 'Secured'   END 

        INTO v_AccountEntityId,
             v_CustomerEntityId,
             v_SecuredUnsecured
        FROM RBL_MISDB_PROD.AdvAcBasicDetail 
       WHERE  CustomerACID = v_Cust_Ucic_Acid
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;
      SELECT CustomerName 

        INTO v_BorrowerName
        FROM RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  CustomerEntityId = v_CustomerEntityId
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;
      SELECT segmentcode 

        INTO v_segmentcode
        FROM RBL_MISDB_PROD.AdvAcBasicDetail 
       WHERE  AccountEntityId = v_AccountEntityId
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey;
      DBMS_OUTPUT.PUT_LINE('@segmentcode');
      DBMS_OUTPUT.PUT_LINE(v_segmentcode);
      SELECT AcBuRevisedSegmentCode 

        INTO v_segmentDescription
        FROM DimAcBuSegment 
       WHERE  AcBuSegmentCode = v_segmentcode;
      --AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
      SELECT B.AssetClassAlt_Key 

        INTO v_AssetClassName
        FROM RBL_MISDB_PROD.AdvCustNPADetail A
               JOIN DimAssetClass B   ON A.Cust_AssetClassAlt_Key = B.AssetClassAlt_Key
       WHERE  A.CustomerEntityId = v_CustomerEntityId
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey;
      DBMS_OUTPUT.PUT_LINE('@AssetClassName');
      DBMS_OUTPUT.PUT_LINE(v_AssetClassName);
      IF ( v_SecuredUnsecured = 'Secured' ) THEN

      BEGIN
         SELECT D.ProvisionSecured 

           INTO v_Provision
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.CustomerACID = C.CustomerACID
                  LEFT JOIN DimProvision_Seg D   ON A.ProvisionAlt_Key = D.ProvisionAlt_Key
          WHERE  A.CustomerAcID = v_Cust_Ucic_Acid
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND C.FlgSecured = CASE 
                                           WHEN v_SecuredUnsecured = 'Secured' THEN 'S'
                                           WHEN v_SecuredUnsecured = 'Unsecured' THEN 'U'   END
                   AND C.EffectiveFromTimeKey <= v_Timekey
                   AND C.EffectiveToTimeKey >= v_Timekey;

      END;
      END IF;
      IF ( v_SecuredUnsecured = 'UnSecured' ) THEN

      BEGIN
         SELECT D.ProvisionUnSecured 

           INTO v_Provision
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.CustomerACID = C.CustomerACID
                  LEFT JOIN DimProvision_Seg D   ON A.ProvisionAlt_Key = D.ProvisionAlt_Key
          WHERE  A.CustomerAcID = v_Cust_Ucic_Acid
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND C.FlgSecured = CASE 
                                           WHEN v_SecuredUnsecured = 'Secured' THEN 'S'
                                           WHEN v_SecuredUnsecured = 'Unsecured' THEN 'U'   END
                   AND C.EffectiveFromTimeKey <= v_Timekey
                   AND C.EffectiveToTimeKey >= v_Timekey;

      END;
      END IF;
      INSERT INTO tt_tmp2_3
        VALUES ( 'BorrowerName', v_BorrowerName, 'CustomerDetail' );
      INSERT INTO tt_tmp2_3
        VALUES ( 'SegmentDescription', v_segmentDescription, 'CustomerDetail' );
      INSERT INTO tt_tmp2_3
        VALUES ( 'AssetClassName', v_AssetClassName, 'CustomerDetail' );
      INSERT INTO tt_tmp2_3
        VALUES ( 'SecuredUnsecured', v_SecuredUnsecured, 'CustomerDetail' );
      INSERT INTO tt_tmp2_3
        VALUES ( 'CurrentProVision', v_Provision, 'CustomerDetail' );
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp2_3  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --Select @Result As result  
   --Select @Result As result  
   IF ( v_SearchType = 4 ) THEN

   BEGIN

      BEGIN
         SELECT COUNT(1)  

           INTO v_Count
           FROM RBL_MISDB_PROD.CustomerBasicDetail 
          WHERE  UCIF_ID = v_Cust_Ucic_Acid
                   AND EffectiveFromTimeKey <= v_Timekey
                   AND EffectiveToTimeKey >= v_Timekey;
         IF ( v_Count <= 0 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT 8 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            v_Result := 8 ;
            RETURN v_Result;

         END;
         END IF;

      END;
      SELECT CustomerName 

        INTO v_BorrowerName
        FROM RBL_MISDB_PROD.CustomerBasicDetail 
       WHERE  UCIF_ID = v_Cust_Ucic_Acid
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey 
        FETCH FIRST 1 ROWS ONLY;
      --Select @segmentcode=segmentcode from [CurDat].[Advacbasicdetail]
      --where CustomerEntityId=@CustomerEntityId
      --Select @segmentDescription=AcBuSegmentDescription from DimAcBuSegment
      --Where AcBuSegmentCode=@segmentcode
      --Select @AssetClassName=B.AssetClassAlt_Key  from AcceleratedProvision A
      --INNER JOIN DimAssetClass B ON A.AssetClassNameAlt_key =B.AssetClassAlt_Key 
      --Where A.CustomerEntityId=@CustomerEntityId
      --IF (@AssetClassName='')
      --    BEGIN
      --	   SET @AssetClassName='STANDARD'
      --	END
      INSERT INTO tt_tmp2_3
        VALUES ( 'BorrowerName', v_BorrowerName, 'CustomerDetail' );
      --INSERT INTO  tt_tmp2_3 Values('SegmentDescription',@segmentcode,'CustomerDetail')
      --INSERT INTO  tt_tmp2_3 Values('AssetClassName',@AssetClassName,'CustomerDetail')
      OPEN  v_cursor FOR
         SELECT * 
           FROM tt_tmp2_3  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--Select @Result As result  

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISION_DETAILS_18112023" TO "ADF_CDR_RBL_STGDB";
