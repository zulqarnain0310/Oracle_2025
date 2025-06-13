--------------------------------------------------------
--  DDL for Procedure ACCOUNTDISPLAYGRID
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" 
--exec AccountDisplayGrid v_SearchType=1,v_AssetClassNameAlt_key=2,v_SegmentNameAlt_key=1602,v_Cust_Ucic_Acid=N'G6758005',v_Secured_Unsecured=N'Unsecured'

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
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET v_Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   IF ( v_SearchType = 1 ) THEN
    DECLARE
      

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
        
     DELETE FROM GTT_TMP;
         UTILS.IDENTITY_RESET('GTT_TMP');

         INSERT INTO GTT_TMP ( 
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
                 --AND SEG.EffectiveFromTimeKey<=v_Timekey AND SEG.EffectiveToTimeKey>=v_Timekey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  E.CustomerId = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),v_SegmentNameAlt_key)
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
         --AND C.EffectiveFromTimeKey<=v_Timekey And C.EffectiveToTimeKey>=v_Timekey
         DBMS_OUTPUT.PUT_LINE('SAC');
         --Select 'GTT_TMP', * from GTT_TMP
         -- drop table if Exists #AccountCal_Hist
         --select ProvisionAlt_Key,CustomerAcID,EffectiveFromTimeKey,EffectiveToTimeKey
         -- into #AccountCal_Hist from PRo.AccountCal_Hist where EffectiveFromTimeKey<=v_Timekey and EffectiveToTimeKey>=v_Timekey
         -- CREATE NONCLUSTERED INDEX SAC
         -- ON #AccountCal_Hist (ProvisionAlt_Key asc,CustomerAcID asc)
         MERGE INTO GTT_TMP A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM ( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM MAIN_PRO.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                JOIN GTT_TMP A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         --Update A
         --SET A.CurrentProvisionPer=D.ProvisionUnSecured
         --From GTT_TMP A 
         --INNER Join PRO.AccountCal_Hist C with (nolock)
         --ON A.AccountId=C.CustomerAcID 
         --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
         --Where C.EffectiveFromTimeKey<=v_Timekey AND C.EffectiveToTimeKey>=v_Timekey
         --AND A.SecuredUnsecured='UnSecured'
         --Select 'GTT_TMP22',D.ProvisionUnSecured,D.ProvisionAlt_Key
         --From GTT_TMP A 
         --INNER Join PRO.AccountCal_Hist C
         --ON A.AccountId=C.CustomerAcID 
         --Left Join DimProvision_Seg D ON C.ProvisionAlt_Key=D.ProvisionAlt_Key
         --Where C.EffectiveFromTimeKey<=v_Timekey AND C.EffectiveToTimeKey>=v_Timekey
         ----AND A.SecuredUnsecured='UnSecured'
         OPEN  v_cursor FOR
            SELECT * 
              FROM GTT_TMP  ;
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
   --AND C.EffectiveFromTimeKey<=v_Timekey And C.EffectiveToTimeKey>=v_Timekey
   IF ( v_SearchType = 2 ) 
    THEN 
    BEGIN 
        SELECT COUNT(1) INTO v_COUNT FROM AcceleratedProvision_Mod WHERE AccountId = v_Cust_Ucic_Acid AND EffectiveFromTimeKey <= v_Timekey AND EffectiveToTimeKey >= v_Timekey ;
        IF (v_COUNT >0 )
            THEN 
                BEGIN
                    DBMS_OUTPUT.PUT_LINE(v_COUNT);
                END;
            END IF;
            END;
    END IF;
   BEGIN
    DECLARE
      v_temp NUMBER(1, 0) := 0;
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


         INSERT INTO GTT_TMP ( 
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
                 --AND SEG.EffectiveFromTimeKey<=v_Timekey AND SEG.EffectiveToTimeKey>=v_Timekey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  A.CustomerACID = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),v_SegmentNameAlt_key)
                    AND B.Cust_AssetClassAlt_Key = v_AssetClassNameAlt_key
                    AND A.FlgSecured = CASE 
                                            WHEN v_Secured_Unsecured = 'Secured' THEN 'S'
                                            WHEN v_Secured_Unsecured = 'Unsecured' THEN 'U'   END
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey );
         --	AND C.EffectiveFromTimeKey<=v_Timekey And C.EffectiveToTimeKey>=v_Timekey
         MERGE INTO GTT_TMP A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM ( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM MAIN_PRO.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                LEFT JOIN GTT_TMP A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         OPEN  v_cursor FOR
            SELECT * 
              FROM GTT_TMP  ;
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
   
   IF ( v_SearchType = 4 ) 
    THEN 
        BEGIN 
             SELECT COUNT(1) INTO v_COUNT FROM AcceleratedProvision_Mod WHERE UCICID = v_Cust_Ucic_Acid AND EffectiveFromTimeKey <= v_Timekey AND EffectiveToTimeKey >= v_Timekey ;
        END;
    IF v_COUNT>1 
        THEN DBMS_OUTPUT.PUT_LINE(v_COUNT);
        END IF;
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
       
         INSERT INTO GTT_TMP ( 
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
                 --AND SEG.EffectiveFromTimeKey<=v_Timekey AND SEG.EffectiveToTimeKey>=v_Timekey

                   LEFT JOIN DimAssetClass D   ON B.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
         	 WHERE  E.UCIF_ID = v_Cust_Ucic_Acid

                    --AND A.segmentcode=Convert(Varchar(30),v_SegmentNameAlt_key)
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
         --AND C.EffectiveFromTimeKey<=v_Timekey And C.EffectiveToTimeKey>=v_Timekey
         MERGE INTO GTT_TMP A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN A.SecuredUnsecured = 'Secured' THEN D.ProvisionSecured
         WHEN A.SecuredUnsecured = 'Unsecured' THEN D.ProvisionUnSecured   END AS CurrentProvisionPer
         FROM ( SELECT ProvisionAlt_Key ,
                          CustomerAcID ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey 
                   FROM MAIN_PRO.AccountCal_Hist A
                    WHERE  A.EffectiveFromTimeKey <= v_Timekey
                             AND A.EffectiveToTimeKey >= v_Timekey ) X1
                LEFT JOIN GTT_TMP A   ON A.AccountId = X1.CustomerAcID
                LEFT JOIN DimProvision_Seg D   ON X1.ProvisionAlt_Key = D.ProvisionAlt_Key ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentProvisionPer = src.CurrentProvisionPer;
         OPEN  v_cursor FOR
            SELECT * 
              FROM GTT_TMP  ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTDISPLAYGRID" TO "ADF_CDR_RBL_STGDB";
