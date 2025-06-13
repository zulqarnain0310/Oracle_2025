--------------------------------------------------------
--  DDL for Procedure ACCOUNTDISPLAYGRID_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" 
--exec AccountDisplayGrid @SearchType=1,@AssetClassNameAlt_key=2,@SegmentNameAlt_key=1602,@Cust_Ucic_Acid=N'G6758005',@Secured_Unsecured=N'Unsecured'

(
  v_SearchType IN NUMBER DEFAULT 0 ,
  v_Cust_Ucic_Acid IN VARCHAR2 DEFAULT ' ' ,
  v_SegmentNameAlt_key IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassNameAlt_key IN NUMBER DEFAULT 0 ,
  v_Secured_Unsecured IN VARCHAR2 DEFAULT ' ' 
)
AS
   --IF OBJECT_ID('TempDB..#temp') IS NOT NULL  
   --             DROP TABLE  #temp;  
   v_BorrowerName VARCHAR2(80) := ' ';
   v_CustomerEntityId NUMBER(10,0) := 0;
   v_AccountEntityId NUMBER(10,0) := 0;
   v_segmentcode VARCHAR2(100) := ' ';
   v_AssetClassName VARCHAR2(50) := ' ';
   v_segmentDescription VARCHAR2(10) := ' ';
   v_TimeKey NUMBER(10,0);
   v_Count NUMBER(10,0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   IF ( v_SearchType = 1 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM AcceleratedProvision_Mod 
                              WHERE  CustomerId = v_Cust_Ucic_Acid
                                       AND EffectiveFromTimeKey <= v_Timekey
                                       AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('Search1');
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_tmp21_2  --SQLDEV: NOT RECOGNIZED
         tt_tmp21_2 TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_tmp_222  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_tmp21_2;
         UTILS.IDENTITY_RESET('tt_tmp21_2');

         INSERT INTO tt_tmp21_2 ( 
         	SELECT A.CustomerACID AccountId  ,
                 SEG.AcBuRevisedSegmentCode SegmentDescription  ,
                 D.AssetClassName ,
                 v_Secured_Unsecured SecuredUnsecured  ,
                 ' ' AdditionalProvision  ,
                 ' ' AdditionalProvACCT  ,
                 UTILS.CONVERT_TO_NUMBER(0,10,2) CurrentProvisionPer  ,
                 ' ' AcceProDuration  
         	  FROM RBL_MISDB_PROD.AdvAcBasicDetail A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail E   ON A.CustomerEntityId = E.CustomerEntityId
                   LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
                   JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
                   AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key
                 --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  E.CustomerId = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),@SegmentNameAlt_key)
                    AND B.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                    AND A.FlgSecured = CASE 
                                            WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                            WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
                    AND E.EffectiveFromTimeKey <= v_TimeKey
                    AND E.EffectiveToTimeKey >= v_TimeKey );
         --AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
         DBMS_OUTPUT.PUT_LINE('SAC');
         --Select 'tt_tmp21_2', * from tt_tmp21_2
         -- drop table if Exists #AccountCal_Hist
         --select ProvisionAlt_Key,CustomerAcID,EffectiveFromTimeKey,EffectiveToTimeKey
         -- into #AccountCal_Hist from PRo.AccountCal_Hist where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
         -- CREATE NONCLUSTERED INDEX SAC
         -- ON #AccountCal_Hist (ProvisionAlt_Key asc,CustomerAcID asc)
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM A ,( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                JOIN tt_tmp21_2 A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         --Update A
         --SET A.CurrentProvisionPer=D.ProvisionUnSecured
         --From tt_tmp21_2 A 
         --INNER Join PRO.AccountCal_Hist C with (nolock)
         --ON A.AccountId=C.CustomerAcID 
         --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
         --Where C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey
         --AND A.SecuredUnsecured='UnSecured'
         --Select 'tt_tmp_222',D.ProvisionUnSecured,D.ProvisionAlt_Key
         --From tt_tmp21_2 A 
         --INNER Join PRO.AccountCal_Hist C
         --ON A.AccountId=C.CustomerAcID 
         --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
         --Where C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey
         ----AND A.SecuredUnsecured='UnSecured'
         OPEN  v_cursor FOR
            SELECT * 
              FROM tt_tmp21_2  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM AcceleratedProvision_Mod 
                          WHERE  CustomerId = v_Cust_Ucic_Acid
                                   AND EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT A.AccountId AccountId  ,
                   C.AcBuRevisedSegmentCode SegmentDescription  ,
                   D.AssetClassName ,
                   Secured_Unsecured SecuredUnsecured  ,
                   AdditionalProvision ,
                   AdditionalProvACCT ,
                   CurrentProvisionPer ,
                   AcceProDuration 
              FROM AcceleratedProvision_Mod A
                     LEFT JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuSegmentCode
                     LEFT JOIN DimAssetClass D   ON A.AssetClassNameAlt_key = D.AssetClassAlt_Key
             WHERE  CustomerId = v_Cust_Ucic_Acid
                      AND A.SegmentNameAlt_key = UTILS.CONVERT_TO_VARCHAR2(v_SegmentNameAlt_key,30)
                      AND A.AssetClassNameAlt_key = v_AssetClassNameAlt_key
                      AND A.Secured_Unsecured = v_Secured_Unsecured
                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   --AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
   IF ( @SearchType = 2 ) BEGIN IF NOT EXISTS ( SELECT 1 FROM AcceleratedProvision_Mod WHERE AccountId = @Cust_Ucic_Acid AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey ) BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED ( v_SearchType = 2 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM AcceleratedProvision_Mod 
                              WHERE  AccountId = v_Cust_Ucic_Acid
                                       AND EffectiveFromTimeKey <= v_Timekey
                                       AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         IF tt_tmp_2  --SQLDEV: NOT RECOGNIZED
         tt_tmp_2 TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_tmp_21  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_tmp_2;
         UTILS.IDENTITY_RESET('tt_tmp_2');

         INSERT INTO tt_tmp_2 ( 
         	SELECT A.CustomerACID ACcountID  ,
                 SEG.AcBuRevisedSegmentCode SegmentDescription  ,
                 D.AssetClassName ,
                 v_Secured_Unsecured SecuredUnsecured  ,
                 ' ' AdditionalProvision  ,
                 ' ' AdditionalProvACCT  ,
                 UTILS.CONVERT_TO_NUMBER(0,10,2) CurrentProvisionPer  ,
                 ' ' AcceProDuration  
         	  FROM RBL_MISDB_PROD.AdvAcBasicDetail A
                   LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
                   JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
                   AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key
                 --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  A.CustomerACID = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),@SegmentNameAlt_key)
                    AND B.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                    AND A.FlgSecured = CASE 
                                            WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                            WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey );
         --	AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM A ,( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                LEFT JOIN tt_tmp_2 A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         OPEN  v_cursor FOR
            SELECT * 
              FROM tt_tmp_2  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM AcceleratedProvision_Mod 
                          WHERE  AccountId = v_Cust_Ucic_Acid
                                   AND EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SAC');
         OPEN  v_cursor FOR
            SELECT A.AccountId AccountId  ,
                   C.AcBuSegmentDescription SegmentDescription  ,
                   D.AssetClassName ,
                   Secured_Unsecured SecuredUnsecured  ,
                   AdditionalProvision ,
                   AdditionalProvACCT ,
                   CurrentProvisionPer ,
                   AcceProDuration 
              FROM AcceleratedProvision_Mod A
                     LEFT JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuSegmentCode
                     LEFT JOIN DimAssetClass D   ON A.AssetClassNameAlt_key = D.AssetClassAlt_Key
             WHERE  AccountId = v_Cust_Ucic_Acid
                      AND A.SegmentNameAlt_key = UTILS.CONVERT_TO_VARCHAR2(v_SegmentNameAlt_key,30)
                      AND A.AssetClassNameAlt_key = v_AssetClassNameAlt_key
                      AND A.Secured_Unsecured = v_Secured_Unsecured
                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   IF ( @SearchType = 4 ) BEGIN IF NOT EXISTS ( SELECT 1 FROM AcceleratedProvision_Mod WHERE UCICID = @Cust_Ucic_Acid AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey ) BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED ( v_SearchType = 4 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM AcceleratedProvision_Mod 
                              WHERE  UCICID = v_Cust_Ucic_Acid
                                       AND EffectiveFromTimeKey <= v_Timekey
                                       AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         IF tt_tmp_211  --SQLDEV: NOT RECOGNIZED
         tt_tmp_211 TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_tmp_212  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_tmp11_2;
         UTILS.IDENTITY_RESET('tt_tmp11_2');

         INSERT INTO tt_tmp11_2 ( 
         	SELECT A.CustomerACID AccountId  ,
                 SEG.AcBuRevisedSegmentCode SegmentDescription  ,
                 D.AssetClassName ,
                 v_Secured_Unsecured SecuredUnsecured  ,
                 ' ' AdditionalProvision  ,
                 ' ' AdditionalProvACCT  ,
                 UTILS.CONVERT_TO_NUMBER(0,10,2) CurrentProvisionPer  ,
                 ' ' AcceProDuration  
         	  FROM RBL_MISDB_PROD.AdvAcBasicDetail A
                   JOIN RBL_MISDB_PROD.CustomerBasicDetail E   ON A.CustomerEntityId = E.CustomerEntityId
                   LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
                   JOIN DimAcBuSegment SEG   ON A.segmentcode = SEG.AcBuSegmentCode
                   AND SEG.AcBuRevisedSegmentCode = v_SegmentNameAlt_key
                 --AND SEG.EffectiveFromTimeKey<=@TimeKey AND SEG.EffectiveToTimeKey>=@TimeKey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  E.UCIF_ID = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),@SegmentNameAlt_key)
                    AND B.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                    AND A.FlgSecured = CASE 
                                            WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                            WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
                    AND E.EffectiveFromTimeKey <= v_TimeKey
                    AND E.EffectiveToTimeKey >= v_TimeKey );
         --AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM A ,( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                LEFT JOIN tt_tmp11_2 A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         OPEN  v_cursor FOR
            SELECT * 
              FROM tt_tmp11_2  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM AcceleratedProvision_Mod 
                          WHERE  UCICID = v_Cust_Ucic_Acid
                                   AND EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT A.AccountId ,
                   A.UCICID UCICID  ,
                   C.AcBuSegmentDescription SegmentDescription  ,
                   D.AssetClassName ,
                   Secured_Unsecured SecuredUnsecured  ,
                   AdditionalProvision ,
                   AdditionalProvACCT ,
                   CurrentProvisionPer ,
                   AcceProDuration 
              FROM AcceleratedProvision_Mod A
                     LEFT JOIN DimAcBuSegment C   ON A.SegmentNameAlt_key = C.AcBuSegmentCode
                     LEFT JOIN DimAssetClass D   ON A.AssetClassNameAlt_key = D.AssetClassAlt_Key
             WHERE  UCICID = v_Cust_Ucic_Acid
                      AND A.SegmentNameAlt_key = UTILS.CONVERT_TO_VARCHAR2(v_SegmentNameAlt_key,30)
                      AND A.AssetClassNameAlt_key = v_AssetClassNameAlt_key
                      AND A.Secured_Unsecured = v_Secured_Unsecured
                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                      AND A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey
                      AND C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID_04122023" TO "ADF_CDR_RBL_STGDB";
