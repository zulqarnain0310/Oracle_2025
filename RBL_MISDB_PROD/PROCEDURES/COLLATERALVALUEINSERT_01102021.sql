--------------------------------------------------------
--  DDL for Procedure COLLATERALVALUEINSERT_01102021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_CollateralID IN NUMBER DEFAULT 0 ,
  v_CollateralValueatSanctioninRs IN NUMBER,
  v_CollateralValueasonNPAdateinRs IN NUMBER,
  v_CollateralValueatthetimeoflastreviewinRs IN NUMBER,
  v_ValuationDate IN VARCHAR2 DEFAULT ' ' ,
  v_LatestCollateralValueinRs IN NUMBER,
  v_ExpiryBusinessRule IN VARCHAR2 DEFAULT ' ' ,
  v_Periodinmonth IN NUMBER DEFAULT 0 ,
  v_ValueExpirationDate IN VARCHAR2,
  iv_AuthorisationStatus IN VARCHAR2 DEFAULT NULL ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_CreatedBy IN VARCHAR2 DEFAULT NULL ,
  iv_DateCreated IN DATE DEFAULT NULL ,
  iv_ModifiedBy IN VARCHAR2 DEFAULT NULL ,
  iv_DateModified IN DATE DEFAULT NULL ,
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
   v_CreatedBy VARCHAR2(20) := iv_CreatedBy;
   v_DateCreated DATE := iv_DateCreated;
   v_ModifiedBy VARCHAR2(20) := iv_ModifiedBy;
   v_DateModified DATE := iv_DateModified;
   v_AuthorisationStatus VARCHAR2(5) := iv_AuthorisationStatus;
   --AND AuthorisationStatus IN('MP','DP','RM') 	
   v_DelStatus CHAR(2) := ' ';

BEGIN

   DECLARE
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
      v_SecurityEntityID NUMBER(5,0);
      v_Entity_Key NUMBER(10,0);
      v_temp NUMBER(1, 0) := 0;

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
      --AS
      IF ( v_OperationFlag = 1 ) THEN

      BEGIN
         SELECT MAX(NVL(SecurityEntityID, 0))  

           INTO v_SecurityEntityID
           FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail ;
         IF ( v_SecurityEntityID IS NULL ) THEN
          v_SecurityEntityID := 1 ;
         ELSE
            v_SecurityEntityID := v_SecurityEntityID + 1 ;
         END IF;
         INSERT INTO CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
           ( CollateralValueatthetimeoflastreviewinRs, SecurityEntityID, ValuationDate, CurrentValue, ValuationExpiryDate, ExpiryBusinessRule, Periodinmonth, EffectiveFromTimeKey, EffectiveToTimeKey, ApprovedBy, DateApproved )
           ( SELECT v_CollateralValueatthetimeoflastreviewinRs ,
                    v_SecurityEntityID ,
                    v_ValuationDateChar ,
                    v_LatestCollateralValueinRs ,
                    v_ValueExpirationDate ,
                    v_ExpiryBusinessRule ,
                    v_Periodinmonth ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    v_ApprovedBy ,
                    SYSDATE 
               FROM DUAL  );

      END;
      END IF;

      BEGIN
         v_Result := 0 ;

      END;

      BEGIN
         v_Result := 1 ;

      END;
      /*

      if (@OperationFlag =2)

      		BEGIN

      			PRINT @CreatedBy

      PRINT @ModifiedBy

      PRINT @ApprovedBy



      		   Select @SecurityEntityID=SecurityEntityID from AdvSecurityDetail

      		                                      Where CollateralID=@CollateralID

                            ---20

      		   --select * from AdvSecurityDetail where SecurityEntityID=9

      		   --update AdvSecurityDetail set EffectiveToTimeKey=25998 where  SecurityEntityID=9





      		   IF  EXISTS (select 1 from dbo.AdvSecurityValueDetail where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey

      		                                                        and SecurityEntityID=@SecurityEntityID

      																 and CollateralID=@CollateralID)

           BEGIN 

      	 Print '1'

      		   Update AdvSecurityValueDetail

      		         SET 

      				 --SecurityEntityID=@SecurityEntityID

      			     --EffectiveFromTimeKey=@Timekey,

      			     EffectiveToTimeKey=@Timekey-1

                       Where SecurityEntityID=@SecurityEntityID

      				    --and CollateralID=@CollateralID





           END 

      	 ELSE



      --select * from SysDayMatrix where timekey=25999	

      		 --IF (@SecurityEntityID IS NULL)

      		 --BEGIN 

      			--			--SET   @SecurityEntityID=1





      			--		 --   SET    @SecurityEntityID=isnull(@SecurityEntityID,0)+1

      			--			 ----SET    @SecurityEntityID=@SecurityEntityID

      			--END	

      				Print '2'			



      			insert into dbo.AdvSecurityValueDetail

      					(

      					CollateralID

      					,CollateralValueatthetimeoflastreviewinRs

      					,SecurityEntityID

      					,ValuationDate

      					,CurrentValue

      					,ValuationExpiryDate

      					,ExpiryBusinessRule

      					,Periodinmonth



      					,EffectiveFromTimeKey

      					,EffectiveToTimeKey



      					,ApprovedBy

      					,DateApproved)



      			Select   @CollateralID

      			         ,@CollateralValueatthetimeoflastreviewinRs

      					 ,@SecurityEntityID

      			         ,@ValuationDateChar	

      			        ,@LatestCollateralValueinRs	

      					,@ValueExpirationDate			

      					,@ExpiryBusinessRule						

      					,@Periodinmonth	



      					,@EffectiveFromTimeKey	

      					,@EffectiveToTimeKey	



      						,@ApprovedBy			

      						,GETDATE()		

      		    BEGIN

      				SET @Result=0

      			END



      			BEGIN

      				SET @Result=1

      			END

      		END

      END



      */
      IF ( v_OperationFlag = 2
        OR v_OperationFlag = 3 )
        AND v_AuthMode = 'Y' --EDIT AND DELETE
       THEN
       SELECT SecurityEntityID 

        INTO v_SecurityEntityID
        FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail 
       WHERE  CollateralID = v_CollateralID;
      END IF;
      IF ( v_Entity_Key IS NULL ) THEN

      BEGIN
         --SET   @SecurityEntityID=1
         v_Entity_Key := NVL(v_Entity_Key, 0) + 1 ;

      END;
      END IF;

      BEGIN
         DBMS_OUTPUT.PUT_LINE(4);
         v_CreatedBy := v_CrModApBy ;
         v_DateCreated := SYSDATE ;
         v_Modifiedby := v_CrModApBy ;
         v_DateModified := SYSDATE ;
         DBMS_OUTPUT.PUT_LINE(5);
         --IF @OperationFlag = 2
         --	BEGIN
         --		PRINT 'Edit'
         --		SET @AuthorisationStatus ='MP'
         --	END
         --ELSE
         --	BEGIN
         --		PRINT 'DELETE'
         --		SET @AuthorisationStatus ='DP'
         --	END
         ---FIND CREATED BY FROM MAIN TABLE
         SELECT CreatedBy ,
                DateCreated 

           INTO v_CreatedBy,
                v_DateCreated
           FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND CollateralID = v_CollateralID;
         ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
         IF NVL(v_CreatedBy, ' ') = ' ' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
            SELECT CreatedBy ,
                   DateCreated 

              INTO v_CreatedBy,
                   v_DateCreated
              FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey )
                      AND CollateralID = v_CollateralID;

         END;

         --AND AuthorisationStatus IN('NP','MP','A','RM')
         ELSE

          ---IF DATA IS AVAILABLE IN MAIN TABLE
         BEGIN
            DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
            ----UPDATE FLAG IN MAIN TABLES AS MP
            UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
               SET AuthorisationStatus = v_AuthorisationStatus
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey )
              AND CollateralID = v_CollateralID;

         END;
         END IF;

      END;
      --UPDATE NP,MP  STATUS 
      --IF @OperationFlag=2
      --BEGIN	
      --	UPDATE AdvSecurityValueDetail
      --		SET AuthorisationStatus='FM'
      --		,ModifiedBy=@Modifiedby
      --		,DateModified=@DateModified
      --	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
      --			AND CollateralID =@CollateralID
      --			AND AuthorisationStatus IN('NP','MP','RM')
      --END
      --GOTO GLProductMaster_Insert
      --GLProductMaster_Insert_Edit_Delete:
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_Timekey )
                                   AND CollateralID = v_CollateralID );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
            SET AuthorisationStatus = 'A'
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
           AND EffectiveToTimeKey >= v_TimeKey )
           AND CollateralID = v_CollateralID;

      END;
      END IF;

   END;
   IF v_DelStatus <> 'DP'
     OR v_AuthMode = 'N' THEN
    DECLARE
      v_IsAvailable CHAR(1) := 'N';
      v_IsSCD2 CHAR(1) := 'N';
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND CollateralID = v_CollateralID );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         v_IsAvailable := 'Y' ;
         --SET @AuthorisationStatus='A'
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_TimeKey
                                      AND CollateralID = v_CollateralID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('BBBB');
            UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
               SET
               --ecurityEntityID							   = @SecurityEntityID						
             ValuationDate = v_ValuationDateChar,
             CurrentValue = v_LatestCollateralValueinRs,
             ValuationExpiryDate = v_ValueExpirationDate,
             CollateralValueatthetimeoflastreviewinRs = v_CollateralValueatthetimeoflastreviewinRs,
             CollateralID = v_CollateralID,
             ExpiryBusinessRule = v_ExpiryBusinessRule,
             Periodinmonth = v_Periodinmonth,
             ModifiedBy = v_ModifiedBy,
             DateModified = v_DateModified,
             ApprovedBy = CASE 
                               WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
             ELSE NULL
                END,
             DateApproved = CASE 
                                 WHEN v_AuthMode = 'Y' THEN v_DateApproved
             ELSE NULL
                END,
             AuthorisationStatus = CASE 
                                        WHEN v_AuthMode = 'Y' THEN 'A'
             ELSE NULL
                END
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey )
              AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
              AND CollateralID = v_CollateralID;

         END;
         ELSE

         BEGIN
            v_IsSCD2 := 'Y' ;

         END;
         END IF;

      END;
      END IF;
      IF v_IsAvailable = 'N'
        OR v_IsSCD2 = 'Y' THEN

      BEGIN
         SELECT MAX(NVL(SecurityEntityID, 0))  

           INTO v_SecurityEntityID
           FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail ;
         IF ( v_SecurityEntityID IS NULL ) THEN
          v_SecurityEntityID := 1 ;
         ELSE
            v_SecurityEntityID := v_SecurityEntityID + 1 ;
         END IF;
         INSERT INTO CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
           ( ENTITYKEY, SecurityEntityID, ValuationSourceAlt_Key, ValuationDate, CurrentValue, ValuationExpiryDate, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
         --,D2Ktimestamp
         , CurrentValueSource, CollateralValueatthetimeoflastreviewinRs, CollateralID, ExpiryBusinessRule, Periodinmonth )
           ( SELECT v_Entity_Key ,
                    v_SecurityEntityID ,
                    NULL ,
                    v_ValuationDateChar ,
                    v_LatestCollateralValueinRs ,
                    v_ValueExpirationDate ,
                    CASE 
                         WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
                    ELSE NULL
                       END col  ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    v_CreatedBy ,
                    v_DateCreated ,
                    CASE 
                         WHEN v_AuthMode = 'Y'
                           OR v_IsAvailable = 'Y' THEN v_ModifiedBy
                    ELSE NULL
                       END col  ,
                    CASE 
                         WHEN v_AuthMode = 'Y'
                           OR v_IsAvailable = 'Y' THEN v_DateModified
                    ELSE NULL
                       END col  ,
                    CASE 
                         WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
                    ELSE NULL
                       END col  ,
                    CASE 
                         WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
                    ELSE NULL
                       END col  ,
                    --,D2Ktimestamp
                    NULL ,
                    v_CollateralValueatthetimeoflastreviewinRs ,
                    v_CollateralID ,
                    v_ExpiryBusinessRule ,
                    v_Periodinmonth 
               FROM DUAL  );

      END;
      END IF;
      IF v_IsSCD2 = 'Y' THEN

      BEGIN
         UPDATE CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail
            SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                AuthorisationStatus = CASE 
                                           WHEN v_AUTHMODE = 'Y' THEN 'A'
                ELSE NULL
                   END
          WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
           AND EffectiveToTimeKey >= v_TimeKey )
           AND CollateralID = v_CollateralID
           AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEINSERT_01102021" TO "ADF_CDR_RBL_STGDB";
