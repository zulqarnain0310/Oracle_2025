--------------------------------------------------------
--  DDL for Procedure COLLATERALVALUEINSERT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  iv_CollateralID IN NUMBER DEFAULT 0 ,
  v_CollateralValueatSanctioninRs IN NUMBER,
  v_CollateralValueasonNPAdateinRs IN NUMBER,
  v_CollateralValueatthetimeoflastreviewinRs IN NUMBER,
  v_ValuationDate IN VARCHAR2 DEFAULT ' ' ,
  v_LatestCollateralValueinRs IN NUMBER,
  v_ExpiryBusinessRule IN VARCHAR2 DEFAULT ' ' ,
  v_Periodinmonth IN NUMBER DEFAULT 0 ,
  iv_ValueExpirationDate IN VARCHAR2 DEFAULT ' ' ,
  v_AuthorisationStatus IN VARCHAR2 DEFAULT NULL ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_CreatedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateCreated IN DATE DEFAULT NULL ,
  v_ModifiedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateModified IN DATE DEFAULT NULL ,
  v_ApprovedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateApproved IN DATE DEFAULT NULL ,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  --,@EffectiveFromTimeKey		INT		= 0--,@EffectiveToTimeKey		INT		= 0
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_ValueExpirationDate VARCHAR2(30) := iv_ValueExpirationDate;
   v_CollateralID NUMBER(10,0) := iv_CollateralID;
   --	SET NOCOUNT ON;
   --		PRINT 1
   --		SET DATEFORMAT DMY
   --@AuthorisationStatus		varchar(5)			= NULL 
   --,@CreatedBy					VARCHAR(20)		= NULL
   --,@DateCreated				SMALLDATETIME	= NULL
   --,@ModifiedBy				VARCHAR(20)		= NULL
   --,@DateModified				SMALLDATETIME	= NULL
   --,@ApprovedBy				VARCHAR(20)		= NULL
   --,@DateApproved				SMALLDATETIME	= NULL
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   --DECLARE			
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   --,@Entity_Key            Int
   v_ValuationDateChar VARCHAR2(12);
   v_SecurityEntityID NUMBER(19,0);

BEGIN

   --SET @ScreenName = 'Collateral'
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   v_ValuationDateChar := UTILS.CONVERT_TO_VARCHAR2(v_ValuationDate,12,p_style=>101) ;
   v_ValuationDateChar := SUBSTR(v_ValuationDateChar, 7, 4) || '-' || SUBSTR(v_ValuationDateChar, 4, 2) || '-' || SUBSTR(v_ValuationDateChar, 1, 2) ;
   v_ValueExpirationDate := UTILS.CONVERT_TO_VARCHAR2(v_ValueExpirationDate,12,p_style=>101) ;
   v_ValueExpirationDate := SUBSTR(v_ValueExpirationDate, 7, 4) || '-' || SUBSTR(v_ValueExpirationDate, 4, 2) || '-' || SUBSTR(v_ValueExpirationDate, 1, 2) ;
   --AS
   IF ( v_OperationFlag = 1 ) THEN

   BEGIN
      SELECT MAX(NVL(SecurityEntityID, 0))  

        INTO v_SecurityEntityID
        FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod ;
      IF ( v_SecurityEntityID IS NULL ) THEN
       v_SecurityEntityID := 1 ;
      ELSE
         v_SecurityEntityID := v_SecurityEntityID + 1 ;
      END IF;
      IF v_OperationFlag = 1
        AND NVL(v_CollateralID, ' ') = ' ' THEN

      BEGIN
         SELECT CollateralID 

           INTO v_CollateralID
           FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
          WHERE  SecurityEntityID IN ( SELECT MAX(SecurityEntityID)  
                                       FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod  )
         ;

      END;
      END IF;
      DBMS_OUTPUT.PUT_LINE('@CollateralID');
      DBMS_OUTPUT.PUT_LINE(v_CollateralID);
      IF v_ValuationDate <> ' ' THEN
       DECLARE
         v_collateralCount NUMBER(10,0);

      BEGIN
         INSERT INTO RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
           ( CollateralID
         --CollateralValueatthetimeoflastreviewinRs
         , SecurityEntityID, ValuationDate, CurrentValue, ValuationExpiryDate, ExpiryBusinessRule, Periodinmonth, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, ApprovedBy, DateApproved )
           ( SELECT v_CollateralID ,
                    --@CollateralValueatthetimeoflastreviewinRs
                    v_SecurityEntityID ,
                    v_ValuationDateChar ,
                    v_LatestCollateralValueinRs ,
                    UTILS.CONVERT_TO_VARCHAR2(v_ValueExpirationDate,200) ,
                    v_ExpiryBusinessRule ,
                    v_Periodinmonth ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    'NP' ,
                    v_ApprovedBy ,
                    SYSDATE 
               FROM DUAL  );
         SELECT COUNT(*)  

           INTO v_collateralCount
           FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod 
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND EffectiveFromTimeKey = v_TimeKey
                   AND CollateralID = v_CollateralID;
         DBMS_OUTPUT.PUT_LINE('@collateralCount');
         DBMS_OUTPUT.PUT_LINE(v_collateralCount);
         IF v_collateralCount > 2 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Sachin');
            UPDATE RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
               SET EffectiveFromTimeKey = v_Timekey - 1,
                   EffectiveToTimeKey = v_Timekey - 1
             WHERE  CollateralID = v_CollateralID
              AND SecurityEntityID IN ( SELECT MIN(AdvSecurityValueDetail_Mod.SecurityEntityID)  
                                        FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod 
                                         WHERE  ( AdvSecurityValueDetail_Mod.EffectiveFromTimeKey <= v_TimeKey
                                                  AND AdvSecurityValueDetail_Mod.EffectiveToTimeKey >= v_TimeKey )
                                                  AND AdvSecurityValueDetail_Mod.EffectiveFromTimeKey = v_TimeKey
                                                  AND AdvSecurityValueDetail_Mod.CollateralID = v_CollateralID )
            ;

         END;
         END IF;

      END;
      END IF;

   END;
   END IF;

   BEGIN
      v_Result := 0 ;

   END;

   BEGIN
      v_Result := 1 ;

   END;
   IF ( v_OperationFlag = 17 ) THEN

   BEGIN
      UPDATE RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
         SET EffectiveToTimeKey = v_Timekey - 1,
             AuthorisationStatus = 'R'
       WHERE  CollateralID = v_CollateralID
        AND AuthorisationStatus IN ( 'NP','MP','1A' )
      ;

   END;
   END IF;
   IF ( v_OperationFlag = 21 ) THEN

   BEGIN
      UPDATE RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
         SET EffectiveToTimeKey = v_Timekey - 1,
             AuthorisationStatus = 'R'
       WHERE  CollateralID = v_CollateralID
        AND AuthorisationStatus IN ( 'NP','MP''1A' )
      ;

   END;
   END IF;
   IF ( v_OperationFlag = 2 ) THEN

   BEGIN
      SELECT MAX(NVL(SecurityEntityID, 0))  

        INTO v_SecurityEntityID
        FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod ;
      --Select @Entity_Key=MAX(Entity_Key) from Curdat.AdvSecurityValueDetail      
      --Where CollateralID=@CollateralID      
      UPDATE RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
         SET EffectiveFromTimeKey = v_Timekey - 1,
             EffectiveToTimeKey = v_Timekey - 1,
             AuthorisationStatus = 'R'
       WHERE  CollateralID = v_CollateralID;
      UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
         SET EffectiveFromTimeKey = v_Timekey - 1,
             EffectiveToTimeKey = v_Timekey - 1,
             AuthorisationStatus = 'R'
       WHERE  CollateralID = v_CollateralID;
      IF ( v_SecurityEntityID IS NULL ) THEN
       v_SecurityEntityID := 1 ;
      ELSE
         v_SecurityEntityID := v_SecurityEntityID + 1 ;
      END IF;
      DBMS_OUTPUT.PUT_LINE('@SecurityEntityID');
      DBMS_OUTPUT.PUT_LINE(v_SecurityEntityID);
      --   PRINT '@ValuationDateChar' 
      --PRINT @ValuationDateChar 
      --   PRINT '@LatestCollateralValueinRs' 
      --PRINT @LatestCollateralValueinRs 
      --   PRINT '@ValueExpirationDate' 
      --PRINT @ValueExpirationDate
      --SET DATEFORMAT DMY         
      INSERT INTO RBL_MISDB_PROD.AdvSecurityValueDetail_Mod
        ( CollateralID, SecurityEntityID, ValuationDate, CurrentValue, ValuationExpiryDate, ExpiryBusinessRule, Periodinmonth, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, ApprovedBy, DateApproved )
        ( SELECT v_CollateralID ,
                 v_SecurityEntityID ,
                 v_ValuationDateChar ,
                 v_LatestCollateralValueinRs ,
                 UTILS.CONVERT_TO_VARCHAR2(v_ValueExpirationDate,200) ,
                 v_ExpiryBusinessRule ,
                 v_Periodinmonth ,
                 v_EffectiveFromTimeKey ,
                 v_EffectiveToTimeKey ,
                 'MP' ,
                 v_ApprovedBy ,
                 SYSDATE 
            FROM DUAL  );
      UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
         SET AuthorisationStatus = 'MP'
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
        AND EffectiveToTimeKey >= v_TimeKey )
        AND CollateralID = v_CollateralID;

      BEGIN
         v_Result := 0 ;

      END;

      BEGIN
         v_Result := 1 ;

      END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_04122023" TO "ADF_CDR_RBL_STGDB";
