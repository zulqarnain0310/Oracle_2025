--------------------------------------------------------
--  DDL for Procedure TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" 
AS

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM ';
   INSERT INTO RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM
     ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
     ( SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM01_STG 
       UNION 

       ----SOURCESYSSTEM02
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM02_STG 
       UNION 
       ----SOURCESYSSTEM03
       ALL 
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM03_STG 
       UNION 
       ------SOURCESYSSTEM04
       ALL 
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM04_STG 
       UNION  /*
       ---------------------SOURCESYSSTEM05
       union all
       SELECT	
       DateOfData
       ,SourceSystem
       ,UCIC_ID
       ,CustomerID
       ,CustomerName
       ,Constitution
       ,Gender
       ,SegmentCode
       ,PANNO
       ,PrevQtrRV
       ,CurrQtrRV
       ,AssetClass
       ,NPADate
       ,DBT_LOS_Date
       ,AlwaysNPA
       From CUSTOMER_SOURCESYSTEM05_STG
       */

       ----------------------SOURCESYSSTEM06
       ALL 
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM06_STG 
       UNION 
       ----metagrid
       ALL 
       SELECT Date_Of_Data ,
              Source_System ,
              UCIC_ID ,
              Customer_ID ,
              Customer_Name ,
              Customer_Constitution ,
              Gender ,
              Customer_Segment_Code ,
              PAN_No ,
              NULL ,
              NULL ,
              Asset_Class ,
              NPA_Date ,
              DBT_LOS_Date ,
              Always_NPA 
       FROM metagrid_customer_master_STG 
        WHERE  Date_of_Data IN ( SELECT DISTINCT DateofData 
                                 FROM CUSTOMER_SOURCESYSTEM01_STG  )

       UNION ALL 
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM07_STG 
       UNION 
       ----------------------SOURCESYSSTEM08  ADDED By- Mandeep For EIFS Source Date-22-09-2022 
       ALL 
       SELECT DateOfData ,
              SourceSystem ,
              UCIC_ID ,
              CustomerID ,
              CustomerName ,
              Constitution ,
              Gender ,
              SegmentCode ,
              PANNO ,
              PrevQtrRV ,
              CurrQtrRV ,
              AssetClass ,
              NPADate ,
              DBT_LOS_Date ,
              AlwaysNPA 
       FROM CUSTOMER_SOURCESYSTEM08_STG  );
   ---Remove Duplicates---------
   DELETE FROM CUSTOMER_ALL_SOURCE_SYSTEM WHERE ROWID NOT IN ( SELECT MIN(ROWID)
     FROM CUSTOMER_ALL_SOURCE_SYSTEM  
     GROUP BY SOURCESYSTEM, CUSTOMERID) 
      ;
   MERGE INTO CUSTOMER_ALL_SOURCE_SYSTEM A 
   USING (SELECT a.ROWID row_id, A.CustomerID
   FROM CUSTOMER_ALL_SOURCE_SYSTEM A 
    WHERE UCIC_ID IS NULL) src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.ucIC_id = src.CustomerID;
   ---------------------As discussed with Nimish and modified by Prashant-------------------29-06-2022----------------------
   UPDATE RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM
      SET AssetClass = 'STD'
    WHERE  SourceSystem = 'VisionPlus'
     AND ( AssetClass IS NULL
     OR AssetClass = ' ' );---------------------------------------END-------------------------------------------

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_CUSTOMER_ALL_SOURCE_SYSTEM" TO "ADF_CDR_RBL_STGDB";
