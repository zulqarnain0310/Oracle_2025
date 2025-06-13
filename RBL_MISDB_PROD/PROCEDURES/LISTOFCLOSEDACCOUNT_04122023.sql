--------------------------------------------------------
--  DDL for Procedure LISTOFCLOSEDACCOUNT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN


   BEGIN
      BEGIN

         BEGIN
            IF utils.object_id('TempDB..tt_Account_6') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Account_6 ';
            END IF;
            DELETE FROM tt_Account_6;
            UTILS.IDENTITY_RESET('tt_Account_6');

            INSERT INTO tt_Account_6 ( 
            	SELECT * 
            	  FROM ( SELECT DISTINCT CustomerACID 
                      FROM AdvAcBasicDetail 
                       WHERE  EffectiveToTimeKey <> 49999
                      MINUS 
                      SELECT DISTINCT CustomerACID 
                      FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                       WHERE  EffectiveToTimeKey = 49999 ) X );
            --Select COUNT(1) From tt_Account_6
            IF utils.object_id('TEMPCustHistData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE TEMPCustHistData';

            END;
            END IF;
            DELETE FROM TEMPCustHistData;
            UTILS.IDENTITY_RESET('TEMPCustHistData');

            INSERT INTO TEMPCustHistData SELECT Rownumber ,
                                                UCIF_ID ,
                                                CustomerAcID ,
                                                finalAssetclassAlt_key ,
                                                EffectiveFromTimeKey ,
                                                EffectiveToTimeKey ,
                                                FinalNpaDt ,
                                                Balance ,
                                                CustomerEntityID ,
                                                SourceAlt_Key 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerAcID ORDER BY EffectiveToTimeKey DESC  ) Rownumber  ,
                               A.UCIF_ID ,
                               A.CustomerAcID ,
                               A.finalAssetclassAlt_key ,
                               EffectiveFromTimeKey ,
                               EffectiveToTimeKey ,
                               FinalNpaDt ,
                               Balance ,
                               CustomerEntityID ,
                               SourceAlt_Key 
                        FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                         WHERE  CustomerAcID IN ( SELECT CustomerACID 
                                                  FROM tt_Account_6  )
                       ) X
                WHERE  Rownumber = 1;
            --(Select CustomerACID from tt_Account_6)
            --Select 'tt_Account_6', * from tt_Account_6
            OPEN  v_cursor FOR
               SELECT UCIF_ID ,
                      CustomerName ,
                      RefCustomerID ,
                      CustomerAcID ,
                      SourceName ,
                      CurrentStatus ,
                      Assetclassification ,
                      DPD_Max ,
                      ClosingDate ,
                      FinalNpaDt ,
                      FinacialStress ,
                      MaxAssetclassification ,
                      --,F.SrcSysClassCode as MaxAssetclassification
                      LastNpaDate ,
                      TechnicalWriteoff ,
                      TechnicalWriteoffDate ,
                      NULL Advances  
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerAcID ORDER BY CustomerAcID  ) Rownum_  ,
                               A.UCIF_ID ,
                               B.CustomerName ,
                               B.RefCustomerID ,
                               A.CustomerAcID ,
                               D.SourceName ,
                               'Closed' CurrentStatus  ,
                               CASE 
                                    WHEN A.finalAssetclassAlt_key = 1 THEN 'STD'
                               ELSE 'NPA'
                                  END Assetclassification  ,
                               NULL DPD_Max  ,
                               Z.Date_ ClosingDate  ,
                               A.FinalNpaDt ,
                               NULL FinacialStress  ,
                               CASE 
                                    WHEN A.finalAssetclassAlt_key = 1 THEN 'STD'
                               ELSE 'NPA'
                                  END MaxAssetclassification  ,
                               --,F.SrcSysClassCode as MaxAssetclassification
                               A.FinalNpaDt LastNpaDate  ,
                               CASE 
                                    WHEN C.ACID IS NOT NULL THEN 'Y'
                               ELSE 'N'
                                  END TechnicalWriteoff  ,
                               CASE 
                                    WHEN C.ACID IS NOT NULL THEN C.StatusDate
                               ELSE NULL
                                  END TechnicalWriteoffDate  ,
                               A.Balance Advances  
                        FROM TEMPCustHistData A
                               JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                               LEFT JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = A.SourceAlt_Key
                               LEFT JOIN ExceptionFinalStatusType C   ON C.ACID = A.CustomerAcID
                               AND C.StatusType = 'TWO'
                               JOIN DimAssetClass F   ON F.AssetClassAlt_Key = A.finalAssetclassAlt_key
                               AND F.EffectiveToTimeKey = 49999
                               LEFT JOIN Automate_Advances Z   ON a.EffectiveToTimeKey = Z.Timekey ) X
                WHERE  Rownum_ = 1 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         INSERT INTO RBL_MISDB_PROD.Error_Log
           ( SELECT utils.error_line ErrorLine  ,
                    SQLERRM ErrorMessage  ,
                    SQLCODE ErrorNumber  ,
                    utils.error_procedure ErrorProcedure  ,
                    utils.error_severity ErrorSeverity  ,
                    utils.error_state ErrorState  ,
                    SYSDATE 
               FROM DUAL  );

      END;END;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFCLOSEDACCOUNT_04122023" TO "ADF_CDR_RBL_STGDB";
