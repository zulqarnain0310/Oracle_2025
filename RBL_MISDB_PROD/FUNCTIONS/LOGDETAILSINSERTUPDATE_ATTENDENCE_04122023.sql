--------------------------------------------------------
--  DDL for Function LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" /****** Object:  StoredProcedure [dbo].[LogDetailsInsertUpdate]    Script Date: 03/09/2012 17:45:04 ******/
(
  v_BranchCode IN VARCHAR2,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_ReferenceID IN VARCHAR2,
  v_CreatedBy IN VARCHAR2,
  v_ApprovedBy IN VARCHAR2,
  iv_CreatedCheckedDt IN DATE,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityAlt_Key IN NUMBER DEFAULT 16 ,---Adeed by kunj on 29/03/12 for Passing Unique Screen Identity
  v_Flag IN NUMBER,
  v_AuthMode IN CHAR DEFAULT 'N' 
)
RETURN NUMBER
AS
   v_CreatedCheckedDt DATE := iv_CreatedCheckedDt;
   --Declare @EntityKey int,
   v_LogCreationStatus VARCHAR2(2);

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   IF v_AuthMode = 'Y' THEN

   BEGIN
      IF v_Flag = 1
        OR v_Flag = 6 THEN

      BEGIN
         --IF EXISTS(SELECT 1 FROM SysUserActivityLog_Attendence WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key)
         --	BEGIN
         --			UPDATE SysUserActivityLog_Attendence 
         --				SET 
         --					LogCreationStatus='NP'
         --					,LogStatus='P'
         --					,LogCreatedBy=@CreatedBy
         --					,LogCheckedBy= NULL 
         --					,LogCheckedDt= NULL 
         --					,Remark		= NULL 
         --			WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
         --	END
         --ELSE	
         --	BEGIN
         --	SELECT @EntityKey = ISNULL(MAX(EntityKey),0) + 1 FROM SysUserActivityLog_Attendence                        						
         INSERT INTO SysUserActivityLog_Attendence
         --	 EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    --	 @EntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    'NP' ,
                    v_CreatedBy ,
                    v_CreatedCheckedDt ,
                    'P' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      --END	
      IF v_Flag = 2
        OR v_Flag = 3
        OR v_Flag = 8 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('ENTERED IN EDIT MODE');
         IF v_Flag = 2 THEN

         BEGIN
            v_LogCreationStatus := 'MP' ;
            DBMS_OUTPUT.PUT_LINE(2);

         END;
         ELSE
            IF v_Flag = 3
              OR v_Flag = 8 THEN

            BEGIN
               v_LogCreationStatus := 'DP' ;

            END;
            END IF;
         END IF;
         v_CreatedCheckedDt := SYSDATE ;
         --IF EXISTS(SELECT 1 FROM SysUserActivityLog_Attendence WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key)
         --	BEGIN
         --			UPDATE SysUserActivityLog_Attendence SET LogCreationStatus=@LogCreationStatus 
         --				  ,LogStatus='P'
         --				  ,LogCreatedBy=@CreatedBy
         --			WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID 
         --			AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
         --	END
         --IF NOT EXISTS(SELECT 1 FROM SysUserActivityLog_Attendence WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key)
         --	BEGIN
         --	SELECT @EntityKey = ISNULL(MAX(EntityKey),0) + 1 FROM SysUserActivityLog_Attendence
         INSERT INTO SysUserActivityLog_Attendence
         -- EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    -- @EntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    v_LogCreationStatus ,
                    v_CreatedBy ,
                    v_CreatedCheckedDt ,
                    'P' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      --END
      IF v_Flag = 16 THEN

       --OR @Flag =17  -- AUTHORISE OR REJECT
      BEGIN
         --               print 'aaaaaaaaaaa'
         --	IF @ScreenEntityAlt_Key=0 
         --		BEGIN 
         --		   print 1
         --		END
         --	ELSE IF @ScreenEntityAlt_Key=4 --FOR RELATIONSHIP ADITIONAL SCREEN
         --		BEGIN
         --			PRINT 'ADD_REL1'							
         --		END
         --	ELSE
         --		BEGIN
         --			print 'UPDATE  SysUserActivityLog_Attendence'							
         --			PRINT @Remark
         --			UPDATE  SysUserActivityLog_Attendence SET  
         --					LogStatus=CASE WHEN @Flag=16 THEN 'A'  -- AUTHORISE
         --									ELSE 'R' END, -- REJECT
         --					LogCheckedBy= @ApprovedBy,
         --					LogCheckedDt= @CreatedCheckedDt,
         --					Remark		= @Remark 
         --			WHERE BranchCode=@BranchCode 
         --				AND ReferenceID=@ReferenceID
         --				AND MenuID=@MenuID
         --				AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
         --				print 'bjdskdhjfhdlfj'
         -----For Edit,Delete,Authorise,Reject count 	
         --	Select @LogCreationStatus=LogCreationStatus FROM SysUserActivityLog_Attendence 
         --			WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID 
         --			AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
         --			print 'select'
         --	UPDATE SysUserActivityLog_Attendence
         --	SET		DeleteCount= CASE WHEN @LogCreationStatus='DP' THEN ISNULL(DeleteCount,0)+1 ELSE DeleteCount END,
         --			EditCount=CASE WHEN @LogCreationStatus='MP' THEN ISNULL(EditCount,0)+1 ELSE EditCount END
         --	WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID 
         --			AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
         --	UPDATE  SysUserActivityLog_Attendence
         --	SET AuthoriseCount= CASE WHEN @Flag=16 THEN ISNull(AuthoriseCount,0)+1 ELSE  AuthoriseCount END	,
         --	 RejectCount= CASE WHEN @Flag=17 THEN  ISNull(RejectCount,0)+1  ELSE  RejectCount END	
         --	WHERE BranchCode=@BranchCode 
         --		AND ReferenceID=@ReferenceID
         --		AND MenuID=@MenuID
         --		AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key 
         --		END
         ------------------
         INSERT INTO SysUserActivityLog_Attendence
         -- EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    -- @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    '1A' ,
                    v_ApprovedBy ,
                    SYSDATE ,
                    'P' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      IF v_Flag = 17
        OR v_Flag = 21 THEN

      BEGIN
         INSERT INTO SysUserActivityLog_Attendence
         -- EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    -- @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    'R' ,
                    v_ApprovedBy ,
                    SYSDATE ,
                    'R' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      IF v_Flag = 20 THEN

      BEGIN
         INSERT INTO SysUserActivityLog_Attendence
         -- EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    -- @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    'A' ,
                    v_ApprovedBy ,
                    SYSDATE ,
                    'A' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      IF v_Flag = 18 THEN
       DECLARE
         --DECLARE @ExEntityKeyRemark INT
         --	Select @ExEntityKeyRemark = Max(EntityKey) FROM SysUserActivityLog_Attendence 
         --						WHERE MenuID =@MenuID and BranchCode =@BranchCode 
         --						and ReferenceID =@ReferenceID 
         v_SlashPosition NUMBER(10,0);

      BEGIN
         DBMS_OUTPUT.PUT_LINE(11111111);
         DBMS_OUTPUT.PUT_LINE(v_ReferenceID);
         SELECT INSTR(v_ReferenceID, '/', 0) 

           INTO v_SlashPosition
           FROM DUAL ;
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         BEGIN

            BEGIN
               IF v_ScreenEntityAlt_Key = 0
                 OR v_ScreenEntityAlt_Key = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('entity 0');
                  DBMS_OUTPUT.PUT_LINE('END');

               END;
               ELSE
                  IF v_ScreenEntityAlt_Key = 4 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('log @ScreenEntityAlt_Key =4');

                  END;
                  ELSE

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('UPDATE  SysUserActivityLog_Attendence');
                     UPDATE SysUserActivityLog_Attendence 
                        SET Remark = v_Remark
                      WHERE  BranchCode = v_BranchCode
                       AND ReferenceID = v_ReferenceID
                       AND MenuID = v_MenuID
                       AND ScreenEntityAlt_Key = v_ScreenEntityAlt_Key;

                  END;
                  END IF;
               END IF;
               utils.commit_transaction;

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            --select * FROM SysUserActivityLog_Attendence
            --Where BranchCode=@BranchCode 
            --	AND ReferenceID = @ReferenceID
            --	--AND MenuID=@MenuID
            --	--AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
            ROLLBACK;
            utils.resetTrancount;
            RETURN -1;

         END;END;

      END;
      END IF;

   END;
   END IF;
   IF v_AuthMode = 'N' THEN
    DECLARE
      v_LogEntityKey NUMBER(5,0);

   BEGIN
      IF v_Flag = (1) THEN

      BEGIN
         --	SELECT @LogEntityKey = ISNULL(MAX(EntityKey),0) + 1 FROM SysUserActivityLog_Attendence          
         INSERT INTO SysUserActivityLog_Attendence
         -- EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key )
           ( SELECT 
                    -- @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    ' ' ,
                    v_CreatedBy ,
                    SYSDATE ,
                    ' ' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key 
               FROM DUAL  );

      END;
      END IF;
      IF v_Flag = (2) THEN

      BEGIN
         --      IF  NOT EXISTS(SELECT 1 FROM SysUserActivityLog_Attendence WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key)
         --BEGIN
         --SELECT @LogEntityKey = ISNULL(MAX(EntityKey),0) + 1 FROM SysUserActivityLog_Attendence      
         DBMS_OUTPUT.PUT_LINE('insert SysUserActivityLog_Attendence');
         INSERT INTO SysUserActivityLog_Attendence
         --	 EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key, EditCount )
           ( SELECT 
                    -- @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    ' ' ,
                    v_CreatedBy ,
                    SYSDATE ,
                    ' ' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key ,
                    1 
               FROM DUAL  );
         DBMS_OUTPUT.PUT_LINE('done');

      END;
      END IF;
      --END
      --ELSE
      --BEGIN
      -- --     	UPDATE SysUserActivityLog_Attendence
      --	--SET		
      --	--		EditCount=ISNULL(EditCount,0)+1  
      --	--WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID 
      --	--		AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
      --END
      IF v_Flag = (3) THEN

      BEGIN
         --       IF  NOT EXISTS(SELECT 1 FROM SysUserActivityLog_Attendence WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key)
         --BEGIN
         --SELECT @LogEntityKey = ISNULL(MAX(EntityKey),0) + 1 FROM SysUserActivityLog_Attendence    
         INSERT INTO SysUserActivityLog_Attendence
         --	 EntityKey

           ( BranchCode, MenuID, ReferenceID, LogCreationStatus, LogCreatedBy, LogCreatedDt, LogStatus, Remark, ScreenEntityAlt_Key, EditCount )
           ( SELECT 
                    --	 @LogEntityKey
                    v_BranchCode ,
                    v_MenuID ,
                    v_ReferenceID ,
                    ' ' ,
                    v_CreatedBy ,
                    SYSDATE ,
                    ' ' ,
                    v_Remark ,
                    v_ScreenEntityAlt_Key ,
                    1 --END
                    --ELSE
                    --BEGIN
                    --     	UPDATE SysUserActivityLog_Attendence
                    --	SET		
                    --			DeleteCount=ISNULL(DeleteCount,0)+1  
                    --	WHERE BranchCode=@BranchCode AND ReferenceID=@ReferenceID 
                    --			AND MenuID=@MenuID  AND ScreenEntityAlt_Key=@ScreenEntityAlt_Key
                    --END
               FROM DUAL  );

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LOGDETAILSINSERTUPDATE_ATTENDENCE_04122023" TO "ADF_CDR_RBL_STGDB";
