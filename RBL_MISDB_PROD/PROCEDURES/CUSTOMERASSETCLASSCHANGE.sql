--------------------------------------------------------
--  DDL for Procedure CUSTOMERASSETCLASSCHANGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" 
-- CustomerAssetClassChange '9987880000000001',2

(
  v_CustomerId IN VARCHAR2,
  v_AssetClassChange IN NUMBER
)
AS
   v_Count NUMBER(10,0);
   v_I NUMBER(10,0);
   v_AccountID VARCHAR2(30);
   v_Comments VARCHAR2(4000);
   v_Comments1 VARCHAR2(4000);
   v_RePossessionFlag CHAR(1);
   v_InherentWeaknes CHAR(1);
   v_SARFAESIFlag CHAR(1);
   v_UnusualBounce CHAR(1);
   v_UnclearedEffects CHAR(1);
   v_InterestReceivable NUMBER(18,2);
   v_Timekey NUMBER(10,0);

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   -- Commented by Ravish 27th May 2021. Customer and Account MOC are independent. So removed the validation for checking Degradation flag
   --IF (@AssetClassChange=1)
   --BEGIN
   -- IF OBJECT_ID('TempDB..#temp') IS NOT NULL   DROP TABLE  #temp;
   --Select  ROW_NUMBER() OVER(ORDER BY CustomerAcID) as ID,A.CustomerAcID,A.FlgRestructure as RePossessionFlag,WeakAccount as InherentWeaknessFlag,Sarfaesi as SARFAESIFlag,
   --FlgUnusualBounce as UnusualBounceFlag,FlgUnClearedEffect as UnclearedEffectsFlag
   --INTO #temp
   --FRom Pro.accountcal_Hist A
   --Where A.RefCustomerID=@CustomerId
   --		 AND A.EffectiveFromTimeKey <= @Timekey
   --					   AND A.EffectiveToTimeKey >= @Timekey
   --Select @Count=Count(*) from #temp
   --SET @I=1
   --SET @Comments1=''
   --WHILE (@I<=@Count)
   --BEGIN
   --    Select @AccountID=CustomerAcID, @RePossessionFlag=RePossessionFlag,@InherentWeaknes=InherentWeaknessFlag,@SARFAESIFlag=SARFAESIFlag,@UnusualBounce=UnusualBounceFlag,@UnclearedEffects=UnclearedEffectsFlag
   --	from #temp Where ID=@I
   --	 IF(@RePossessionFlag='Y')
   --	   BEGIN
   --	     SET @Comments1=@Comments1+'Account'+ @AccountID+ ' is marked flag Re-possession,' 
   --       END
   --	 IF(@InherentWeaknes='Y')
   --	   BEGIN
   --	     SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Inherent Weakness,' 
   --       END
   --	 IF(@SARFAESIFlag='Y')
   --	    BEGIN
   --		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag SARFAESI,' 
   --		END
   --	 IF(@UnusualBounce='Y')
   --		BEGIN
   --		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Unusual Bounce,' 
   --		END
   --	 IF(@UnclearedEffects='Y')
   --		BEGIN
   --		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Uncleared Effects,' 
   --		END
   --		SET @I=@I+1
   --END
   --Update CustomerLevelMOC
   --SET NPADate=NULL
   --Where CustomerID=@CustomerId
   --IF (@Comments1<>'')
   --SET @Comments1='You cannot mark the customer as Standard. 1 or more accounts are marked to various degradation flags '+@Comments1+ ' Kindly perform ‘Account level NPA MOC and unmark the mentioned account IDs from the flag'
   --Select @Comments1
   --END
   IF ( v_AssetClassChange = 2 ) THEN

   BEGIN
      IF utils.object_id('TempDB..tt_temp1_6') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_6 ';
      END IF;
      DELETE FROM tt_temp1_6;
      UTILS.IDENTITY_RESET('tt_temp1_6');

      INSERT INTO tt_temp1_6 SELECT ROW_NUMBER() OVER ( ORDER BY AccountID  ) ID  ,
                                    A.AccountID ,
                                    A.InterestReceivable 
           FROM AccountLevelMOC A
                  JOIN AdvAcBasicDetail F   ON A.AccountID = F.CustomerACID
                  JOIN CustomerBasicDetail B   ON B.CustomerEntityId = F.CustomerEntityID
          WHERE  B.CustomerID = v_CustomerId;
      SELECT COUNT(*)  

        INTO v_Count
        FROM tt_temp1_6 ;
      v_I := 1 ;
      v_Comments1 := ' ' ;
      WHILE ( v_I <= v_Count ) 
      LOOP 

         BEGIN
            SELECT AccountID ,
                   InterestReceivable 

              INTO v_AccountID,
                   v_InterestReceivable
              FROM tt_temp1_6 
             WHERE  ID = v_I;
            IF ( v_InterestReceivable IS NOT NULL ) THEN

            BEGIN
               UPDATE AccountLevelMOC
                  SET InterestReceivable = 0,
                      MOCDate = SYSDATE,
                      MOCReason = ' kindly enter ‘Customer level NPA MOC performed. Account changed from Standard to NPA',
                      MOCBy = 'System'
                WHERE  AccountID = v_AccountID;

            END;
            END IF;
            v_I := v_I + 1 ;

         END;
      END LOOP;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERASSETCLASSCHANGE" TO "ADF_CDR_RBL_STGDB";
