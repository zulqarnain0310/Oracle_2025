--------------------------------------------------------
--  DDL for Procedure LISTOFOPENACCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN


   BEGIN
      BEGIN

         BEGIN
            IF utils.object_id('TEMPCustHistData1') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE TEMPCustHistData1';

            END;
            END IF;
            DELETE FROM TEMPCustHistData1;
            UTILS.IDENTITY_RESET('TEMPCustHistData1');

            INSERT INTO TEMPCustHistData1 SELECT Rownumber ,
                                                 UCIF_ID ,
                                                 CustomerAcID ,
                                                 finalAssetclassAlt_key ,
                                                 EffectiveFromTimeKey ,
                                                 EffectiveToTimeKey ,
                                                 FinalNpaDt ,
                                                 Balance ,
                                                 CustomerEntityID ,
                                                 SourceAlt_Key ,
                                                 AcOpenDt ,
                                                 DPD_Max 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerAcID ORDER BY EffectiveToTimeKey DESC  ) Rownumber  ,
                               A.UCIF_ID ,
                               A.CustomerAcID ,
                               A.FinalAssetClassAlt_Key ,
                               EffectiveFromTimeKey ,
                               EffectiveToTimeKey ,
                               FinalNpaDt ,
                               Balance ,
                               CustomerEntityID ,
                               SourceAlt_Key ,
                               AcOpenDt ,
                               DPD_Max 
                        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                         WHERE  CustomerAcID IN ( SELECT DISTINCT CustomerACID 
                                                  FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                                                   WHERE  EffectiveToTimeKey = 49999 )
                       ) X
                WHERE  Rownumber = 1;
            --(Select CustomerACID from #Account)
            --Select '#Account', * from #Account
            OPEN  v_cursor FOR
               SELECT UCIF_ID ,
                      CustomerName ,
                      RefCustomerID ,
                      CustomerAcID ,
                      SourceName ,
                      CurrentStatus ,
                      AcOpenDt ,
                      Assetclassification ,
                      DPD_Max ,
                      FinalNpaDt ,
                      FinacialStress ,
                      MaxAssetclassification ,
                      --,F.SrcSysClassCode as MaxAssetclassification
                      LastNpaDate ,
                      TechnicalWriteoff ,
                      TechnicalWriteoffDate ,
                      Advances 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerAcID ORDER BY CustomerAcID  ) Rownum_  ,
                               A.UCIF_ID ,
                               B.CustomerName ,
                               B.RefCustomerID ,
                               A.CustomerAcID ,
                               D.SourceName ,
                               'Open' CurrentStatus  ,
                               UTILS.CONVERT_TO_VARCHAR2(A.AcOpenDt,10,p_style=>103) AcOpenDt  ,
                               CASE 
                                    WHEN A.finalAssetclassAlt_key = 1 THEN 'STD'
                               ELSE 'NPA'
                                  END Assetclassification  ,
                               A.DPD_Max ,
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
                        FROM TEMPCustHistData1 A
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."LISTOFOPENACCOUNT" TO "ADF_CDR_RBL_STGDB";
