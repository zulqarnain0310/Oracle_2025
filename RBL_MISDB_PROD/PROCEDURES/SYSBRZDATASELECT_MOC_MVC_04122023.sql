--------------------------------------------------------
--  DDL for Procedure SYSBRZDATASELECT_MOC_MVC_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" 
(
  v_Condition IN NVARCHAR2 DEFAULT ' ' ,
  --@Code   INT=0,
  v_Code IN VARCHAR2 DEFAULT ' ' ,
  iv_Top IN NUMBER DEFAULT 0 
)
AS
   v_Top NUMBER(10,0) := iv_Top;
   --DECLARE @AllowLogin CHAR(1)  
   --SET @AllowLogin='Y'   
   v_AllowMakerChecker CHAR(1);
   -- For MOC
   v_MOC_TimeKey NUMBER(5,0);
   v_HO_MOC_Frozen CHAR(1) := 'N';
   v_cursor SYS_REFCURSOR;

BEGIN

   IF v_Top = 0 THEN

   BEGIN
      v_Top := 99999 ;

   END;
   END IF;
   v_AllowMakerChecker := 'Y' ;
   SELECT MAX(TimeKey)  

     INTO v_MOC_TimeKey
     FROM SysDataMatrix 
    WHERE  IsClosingDay = 'Y';
   SELECT MOC_Frozen 

     INTO v_HO_MOC_Frozen
     FROM SysDataMatrix 
    WHERE  TimeKey = v_MOC_TimeKey;
   --Y
   --3377
   --N
   --1
   DBMS_OUTPUT.PUT_LINE(v_AllowMakerChecker);
   DBMS_OUTPUT.PUT_LINE(v_MOC_TimeKey);
   DBMS_OUTPUT.PUT_LINE(v_HO_MOC_Frozen);
   DBMS_OUTPUT.PUT_LINE(v_Top);
   DBMS_OUTPUT.PUT_LINE(v_Code);
   IF v_Condition = 'BranchCode' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('Banu');
      OPEN  v_cursor FOR
         SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                BranchZone ZoneName  ,
                NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                BranchRegion RegionName  ,
                RBL_MISDB_PROD.DimBranch.BranchCode ,
                RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                'N' MOCLock  ,
                '00' MnthFreez  ,
                'N' Mechanize  ,
                NVL(BranchDistrictName, 'N') DistrictName  ,
                RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                BranchStateName StateName  ,
                RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                DimBranch.EffectiveFromTimeKey ,
                DimBranch.EffectiveToTimeKey ,
                NULL PrevLevelMoc ,-- ,ISNULL(FactBranch.UnderAudit,'N') AS		PrevLevelMoc

                NULL CurrLevelMoc -- ,ISNULL(FactBranch.BO_MOC_Frozen,'N') AS	CurrLevelMoc

           FROM RBL_MISDB_PROD.DimBranch 

         --  	LEFT OUTER JOIN FactBranch 

         --ON FactBranch.BranchCode =DimBranch.BranchCode 

         --AND FactBranch.TimeKey=@MOC_TimeKey
         WHERE  RBL_MISDB_PROD.DimBranch.BranchCode = v_Code
                ----AND  ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin         
                 --AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

           ORDER BY RBL_MISDB_PROD.DimBranch.BranchName
           FETCH FIRST v_Top ROWS ONLY ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      IF v_Condition = 'RegionCode' THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('Malsa');
         OPEN  v_cursor FOR
            SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                   BranchZone ZoneName  ,
                   NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                   BranchRegion RegionName  ,
                   RBL_MISDB_PROD.DimBranch.BranchCode ,
                   RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                   RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                   RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                   RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                   NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                   'N' MOCLock  ,
                   '00' MnthFreez  ,
                   'N' Mechanize  ,
                   NVL(BranchDistrictName, 'N') DistrictName  ,
                   RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                   NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                   BranchStateName StateName  ,
                   RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                   NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                   RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                   DimBranch.EffectiveFromTimeKey ,
                   DimBranch.EffectiveToTimeKey ,
                   NULL PrevLevelMoc ,--	,ISNULL(FactBranch.BO_MOC_Frozen,'N') AS PrevLevelMoc

                   NULL CurrLevelMoc --	,ISNULL(FactBranch.RO_MOC_Frozen,'N') AS CurrLevelMoc 

              FROM RBL_MISDB_PROD.DimBranch 

            --LEFT OUTER JOIN FactBranch 

            --	ON FactBranch.BranchCode =DimBranch.BranchCode 

            --	AND FactBranch.TimeKey=@MOC_TimeKey 
            WHERE  BranchRegionAlt_Key = v_Code
                   -- AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

              ORDER BY RBL_MISDB_PROD.DimBranch.BranchName
              FETCH FIRST v_Top ROWS ONLY ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         IF v_Condition = 'ZoneCode' THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                      BranchZone ZoneName  ,
                      NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                      BranchRegion RegionName  ,
                      RBL_MISDB_PROD.DimBranch.BranchCode ,
                      RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                      RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                      RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                      RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                      NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                      'N' MOCLock  ,
                      '00' MnthFreez  ,
                      'N' Mechanize  ,
                      NVL(BranchDistrictName, 'N') DistrictName  ,
                      RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                      NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                      BranchStateName StateName  ,
                      RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                      NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                      RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                      DimBranch.EffectiveFromTimeKey ,
                      DimBranch.EffectiveToTimeKey ,
                      NULL PrevLevelMoc ,--	,ISNULL(FactBranch.RO_MOC_Frozen,'N') AS PrevLevelMoc

                      NULL CurrLevelMoc --	,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS CurrLevelMoc

                 FROM RBL_MISDB_PROD.DimBranch 

               --LEFT OUTER JOIN FactBranch 

               --			ON FactBranch.BranchCode =DimBranch.BranchCode 

               --			AND FactBranch.TimeKey=@MOC_TimeKey 
               WHERE  BranchZoneAlt_Key = v_Code
                      ---- AND  ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin       
                       --	AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

                 ORDER BY RBL_MISDB_PROD.DimBranch.BranchName
                 FETCH FIRST v_Top ROWS ONLY ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF v_Condition = ' '
              OR v_Condition = 'BANK'
              OR v_Condition = '0' THEN

            BEGIN
               IF v_Top = 99999 THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                            BranchZone ZoneName  ,
                            NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                            BranchRegion RegionName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode ,
                            RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                            RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                            RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                            RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                            NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                            'N' MOCLock  ,
                            '00' MnthFreez  ,
                            'N' Mechanize  ,
                            NVL(BranchDistrictName, 'N') DistrictName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                            NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                            BranchStateName StateName  ,
                            RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                            NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                            RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                            DimBranch.EffectiveFromTimeKey ,
                            DimBranch.EffectiveToTimeKey ,
                            NULL PrevLevelMoc ,--,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS PrevLevelMoc

                            NULL CurrLevelMoc --,ISNULL(@HO_MOC_Frozen,'N') AS CurrLevelMoc

                       FROM DimBranch
                            --LEFT OUTER JOIN FactBranch 
                             --	ON FactBranch.BranchCode =DimBranch.BranchCode 
                             --	AND FactBranch.TimeKey=@MOC_TimeKey 
                             --WHERE --ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin  
                             --ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

                       ORDER BY DimBranch.BranchName ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('MArtya');
                  OPEN  v_cursor FOR
                     SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                            BranchZone ZoneName  ,
                            NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                            BranchRegion RegionName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode ,
                            RBL_MISDB_PROD.DimBranch.BranchName || '[' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                            RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                            RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                            RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                            NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                            'N' MOCLock  ,
                            '00' MnthFreez  ,
                            'N' Mechanize  ,
                            NVL(BranchDistrictName, 'N') DistrictName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                            NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                            BranchStateName StateName  ,
                            RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                            NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                            RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                            DimBranch.EffectiveFromTimeKey ,
                            DimBranch.EffectiveToTimeKey ,
                            NULL PrevLevelMoc ,--,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS PrevLevelMoc

                            NULL CurrLevelMoc --,ISNULL(@HO_MOC_Frozen,'N') AS CurrLevelMoc

                       FROM DimBranch
                            --LEFT OUTER JOIN FactBranch 
                             --	ON FactBranch.BranchCode =DimBranch.BranchCode 
                             --	AND FactBranch.TimeKey=@MOC_TimeKey 
                             --WHERE --ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin  
                             --ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

                       ORDER BY DimBranch.BranchName
                       FETCH FIRST v_Top ROWS ONLY ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;

            END;
            ELSE
               IF v_Condition = ' '
                 OR v_Condition = 'HICode'
                 OR v_Condition = '0' THEN

               BEGIN
                  OPEN  v_cursor FOR
                     SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                            BranchZone ZoneName  ,
                            NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                            BranchRegion RegionName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode ,
                            RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                            RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                            RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                            RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                            NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                            'N' MOCLock  ,
                            '00' MnthFreez  ,
                            'N' Mechanize  ,
                            NVL(BranchDistrictName, 'N') DistrictName  ,
                            RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                            NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                            BranchStateName StateName  ,
                            RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                            NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                            RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                            DimBranch.EffectiveFromTimeKey ,
                            DimBranch.EffectiveToTimeKey 
                       FROM DimBranch
                            --WHERE 
                             --      ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

                       ORDER BY DimBranch.BranchName
                       FETCH FIRST v_Top ROWS ONLY ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);
                  OPEN  v_cursor FOR
                     SELECT InspCentreAlt_Key ,
                            BranchName RIName  
                       FROM DimBranch 
                      WHERE  BranchType = 'RI'
                       ORDER BY BranchName ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE
                  IF v_Condition = 'RICode' THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT NVL(BranchZoneAlt_Key, 0) ZoneAltKey  ,
                               BranchZone ZoneName  ,
                               NVL(BranchRegionAlt_Key, 0) RegionAltKey  ,
                               BranchRegion RegionName  ,
                               RBL_MISDB_PROD.DimBranch.BranchCode ,
                               RBL_MISDB_PROD.DimBranch.BranchName || ' [' || RBL_MISDB_PROD.DimBranch.BranchCode || ']' BranchName  ,
                               RBL_MISDB_PROD.DimBranch.BranchBusinessCategory ,
                               RBL_MISDB_PROD.DimBranch.BranchCode2 ,
                               RBL_MISDB_PROD.DimBranch.AllowPreDisb ,
                               NVL(BranchDistrictAlt_Key, 0) DistrictAlt_Key  ,
                               'N' MOCLock  ,
                               '00' MnthFreez  ,
                               'N' Mechanize  ,
                               NVL(BranchDistrictName, 'N') DistrictName  ,
                               RBL_MISDB_PROD.DimBranch.BranchCode || '_' || BranchRegion || '_' || BranchZone ShowValue  ,
                               NVL(BranchStateAlt_Key, 0) StateAltKey  ,
                               BranchStateName StateName  ,
                               RBL_MISDB_PROD.DimBranch.Branch_Key BranchKey  ,
                               NVL(BranchAreaCategoryAlt_Key, 0) AreaAltKey  ,
                               RBL_MISDB_PROD.DimBranch.BranchType BranchType  ,
                               DimBranch.EffectiveFromTimeKey ,
                               DimBranch.EffectiveToTimeKey 
                          FROM RBL_MISDB_PROD.DimBranch
                               -- WHERE dbo.DimBranch.InspCentreAlt_Key=@Code  
                                ----AND  ISNULL(dbo.DimBranch.AllowLogin,'N')=@AllowLogin          
                                --AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  

                          ORDER BY RBL_MISDB_PROD.DimBranch.BranchName
                          FETCH FIRST v_Top ROWS ONLY ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);
                     OPEN  v_cursor FOR
                        SELECT InspCentreAlt_Key ,
                               BranchName RIName  
                          FROM DimBranch 
                         WHERE  BranchCode = v_Code ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
   IF v_Top <> 1 THEN
    DECLARE
      v_DataEffectiveToDate VARCHAR2(200);

   BEGIN
      SELECT MonthTable.DataEffectiveToDate 

        INTO v_DataEffectiveToDate
        FROM ( SELECT MAX(DataEffectiveToDate)  DataEffectiveToDate  ,
                      Month ,
                      YEAR 
               FROM SysDataMatrix 
                WHERE  CurrentStatus = 'C'
                 GROUP BY Month,YEAR ) 
             --where CurrentStatus in ('C','U') group by [Month],Year
             MonthTable;
      --- DimYear
      OPEN  v_cursor FOR
         SELECT DISTINCT YEAR Code  ,
                         YEAR DESCRIPTION  
           FROM SysDataMatrix 
          WHERE  CurrentStatus IN ( 'C','U' )

           ORDER BY Code DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      IF v_Condition = 'RICode'
        OR v_Condition = 'HICode' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT DISTINCT CASE 
                                 WHEN utils.month_(MonthLastDate) <= 9 THEN '0' || UTILS.CONVERT_TO_VARCHAR2(utils.month_(MonthLastDate),30)
                            ELSE UTILS.CONVERT_TO_VARCHAR2(utils.month_(MonthLastDate),30)
                               END || UTILS.CONVERT_TO_VARCHAR2(utils.year_(MonthLastDate),30) Code  ,
                            YEAR ,
                            MONTH DESCRIPTION  ,
                            MonthLastDate ,
                            MonthFirstDate ,
                            UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,12,p_style=>103) MonthCaption  ,
                            MAX(TimeKey)  TimeKey  ,
                            MIN(DataEffectiveFromTimeKey)  EffectiveFromTimeKey  ,
                            currentstatus 
              FROM SysDataMatrix 
             WHERE  DataEffectiveToDate = v_DataEffectiveToDate
              GROUP BY YEAR,MonthLastDate,MonthFirstDate,MONTH,CurrentStatus
              ORDER BY MonthLastDate DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT DISTINCT CASE 
                                 WHEN utils.month_(MonthLastDate) <= 9 THEN '0' || UTILS.CONVERT_TO_VARCHAR2(utils.month_(MonthLastDate),30)
                            ELSE UTILS.CONVERT_TO_VARCHAR2(utils.month_(MonthLastDate),30)
                               END || UTILS.CONVERT_TO_VARCHAR2(utils.year_(MonthLastDate),30) Code  ,
                            YEAR ,
                            MONTH DESCRIPTION  ,
                            MonthLastDate ,
                            MonthFirstDate ,
                            UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,12,p_style=>103) MonthCaption  ,
                            MAX(Timekey)  Timekey  ,
                            MIN(DataEffectiveFromTimeKey)  EffectiveFromTimeKey  ,
                            currentstatus 
              FROM SysDataMatrix 

            -- WHERE CurrentStatus = 'C' 
            WHERE  ( currentstatus = 'U'
                     OR currentstatus = 'C' )

                     --AND DataEffectiveToDate =@DataEffectiveToDate
                     AND DataEffectiveToDate IN ( SELECT MonthTable.DataEffectiveToDate 
                                                  FROM ( SELECT MAX(DataEffectiveToDate)  DataEffectiveToDate  ,
                                                                Month ,
                                                                YEAR 
                                                         FROM SysDataMatrix 
                                                          WHERE  CurrentStatus IN ( 'C','U' )

                                                           GROUP BY Month,YEAR ) MonthTable )


            -- GROUP BY Year,MonthLastDate, monthfirstdate,Month,currentstatus
            GROUP BY YEAR,currentstatus,MonthLastDate,monthfirstdate,MONTH,currentstatus
              ORDER BY MonthLastDate DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --- DimDate
      OPEN  v_cursor FOR
         SELECT CASE 
                     WHEN utils.month_(DataEffectiveToDate) <= 9 THEN '0' || UTILS.CONVERT_TO_VARCHAR2(utils.month_(DataEffectiveToDate),30)
                ELSE UTILS.CONVERT_TO_VARCHAR2(utils.month_(DataEffectiveToDate),30)
                   END || UTILS.CONVERT_TO_VARCHAR2(utils.year_(DataEffectiveToDate),30) MonthYear  ,
                DataEffectiveFromTimeKey Code  ,
                UTILS.CONVERT_TO_VARCHAR2(SYSDATE,10,p_style=>103) DESCRIPTION  ,
                --CONVERT(VARCHAR(10),DataEffectiveToDate,103) AS Description,
                DataEffectiveToDate ,
                CurrentStatus ,
                MONTH Month  ,
                TimeKey ,
                YEAR ,
                NVL(Month_Key, 0) MonthEndTimeKey  
           FROM SysDataMatrix 
          WHERE  DataEffectiveFromTimeKey IS NOT NULL -- DATENAME LIKE '%Friday%'

                   AND ( currentstatus = 'U'
                   OR currentstatus = 'C' --AND 
                  )
           ORDER BY DataEffectiveToDate DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      -- SELECT TimeKey,    
      --	[Month],
      --	[Year]
      --FROM SysDataMatrix 
      OPEN  v_cursor FOR
         SELECT ParameterName ,
                ParameterValue 
           FROM SysSolutionParameter 
          WHERE  ParameterName IN ( 'TierValue','RegionCap','AllowHigherLevelAuth' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SYSBRZDATASELECT_MOC_MVC_04122023" TO "ADF_CDR_RBL_STGDB";
