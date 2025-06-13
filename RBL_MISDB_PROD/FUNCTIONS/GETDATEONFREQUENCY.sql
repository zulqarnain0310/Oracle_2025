--------------------------------------------------------
--  DDL for Function GETDATEONFREQUENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."GETDATEONFREQUENCY" 
(
  v_TimeKey IN NUMBER,
  v_Frequency IN VARCHAR2
)
RETURN RBL_MISDB_PROD.GetdateOnFrequency_pkg.tt_v_Result_type PIPELINED
AS
   v_MonthLastDate VARCHAR2(10) := ' ';
   v_MonthFirstDate VARCHAR2(10) := ' ';
   v_temp SYS_REFCURSOR;
   v_temp_1 TT_V_RESULT%ROWTYPE;

BEGIN
   IF v_Frequency = 'MONTHLY' THEN

   BEGIN
      SELECT MonthLastDate ,
             monthfirstdate 

        INTO v_MonthLastDate,
             v_MonthFirstDate

        --MAX(A.Timekey) AS Timekey
        FROM SysDataMatrix A
               JOIN ( SELECT TimeKey ,
                             Date_ 
                      FROM SysDayMatrix  ) D   ON A.MonthLastDate = D.Date_
       WHERE  currentstatus IN ( 'U','C' )

                AND A.TimeKey = v_TimeKey
        GROUP BY YEAR,MonthLastDate,monthfirstdate,MONTH
        ORDER BY MonthLastDate DESC;

   END;
   ELSE
      IF v_Frequency = 'QUARTERLY' THEN

      BEGIN
         --select 
         --	@MonthLastDate=MonthLastDate,
         --	@MonthFirstDate=monthfirstdate
         --	 from sysdatamatrix A
         --	 INNER JOIN 	(	 Select Cast(CurQtrDate as date) as [Date] from SysDayMatrix  Group by CurQtrDate )
         --		B ON A.MonthLastDate=B.Date 
         -- where currentstatus IN( 'U' ,'C') --AND Month_Key >= 2922 AND Month_Key <= 2922
         --  AND A.TimeKey=@TimeKey
         --  GROUP BY Year,MonthLastDate, monthfirstdate,Month,currentstatus
         -- order by MonthLastDate desc
         SELECT DISTINCT B.MonthLastDate ,
                         utils.dateadd('DAY', 1, SysDataMatrix.MonthLastDate) 

           INTO v_MonthLastDate,
                v_monthfirstdate
           FROM SysDataMatrix 
                  JOIN ( SELECT Prev_Qtr_key ,
                                SysDataMatrix.MonthLastDate 
                         FROM SysDataMatrix 
                                JOIN ( SELECT MonthLastDate 

                                       --monthfirstdate
                                       FROM SysDataMatrix A
                                              JOIN ( SELECT UTILS.CONVERT_TO_VARCHAR2(CurQtrDate,200) Date_  
                                                     FROM SysDayMatrix 
                                                       GROUP BY CurQtrDate ) B   ON A.MonthLastDate = B.Date_
                                        WHERE  currentstatus IN ( 'U','C' --AND Month_Key >= 2922 AND Month_Key <= 2922
                                                )

                                                 AND A.TimeKey = v_TimeKey
                                         GROUP BY YEAR,MonthLastDate,MONTH,currentstatus ) A   ON SysDataMatrix.MonthLastDate = A.MonthLastDate ) B   ON SysDataMatrix.TimeKey = B.Prev_Qtr_key;

      END;
      ELSE
         IF v_Frequency = 'YEARLY' THEN

         BEGIN
            SELECT LastDayOfYear ,
                   StartOfYear 

              INTO v_MonthLastDate,
                   v_monthfirstdate
              FROM ( SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('YY', utils.datediff('YY', 0, MonthLastDate), 0),200) StartOfYear  ,
                                     UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('YY', utils.datediff('YY', 0, MonthLastDate) + 1, -1),200) LastDayOfYear  
                     FROM SysDataMatrix 
                      WHERE  CurrentStatus IN ( 'C','U' )

                               AND Timekey = v_TimeKey ) YearlyFrequncy;

         END;
         ELSE
            IF v_Frequency = 'FINYEARLY' THEN

            BEGIN
               SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 1, EOMONTH(utils.dateadd('MONTH', -12, MonthFirstDate), 0)),200,p_style=>103),10) ,
                      UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,200,p_style=>105) 

                 INTO v_monthfirstdate,
                      v_MonthLastDate
                 FROM SysDataMatrix SDM
                        JOIN ( SELECT Fiscal_Year_key FINKEY  ,
                                      YEAR 
                               FROM SysDataMatrix 
                                WHERE  MONTH = 'MARCH'
                                         AND CurrentStatus IN ( 'C','U' )

                                 GROUP BY Fiscal_Year_key,YEAR ) D   ON SDM.TimeKey = D.FINKEY
                WHERE  TimeKey = v_TimeKey;

            END;
            ELSE
               IF v_Frequency = 'DAILY' THEN

               BEGIN
                  SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_,200) ,
                         UTILS.CONVERT_TO_VARCHAR2(DATE_ - 1,200) 

                    INTO v_MonthLastDate,
                         v_monthfirstdate
                    FROM SysDayMatrix 
                   WHERE  TIMEKEY = v_TimeKey;

               END;
               ELSE
                  IF v_Frequency = 'WEEKLY' THEN

                  BEGIN
                     SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_ - 6,200) ,
                            UTILS.CONVERT_TO_VARCHAR2(DATE_,200) 

                       INTO v_monthfirstdate,
                            v_MonthLastDate
                       FROM SysDayMatrix 
                      WHERE  TIMEKEY = v_TimeKey
                               AND DATENAME LIKE '%Friday%';

                  END;
                  ELSE
                     IF v_Frequency = 'YEARLY_PERIOD' THEN

                     BEGIN
                        SELECT MonthFirstDate ,
                               MonthLastDate 

                          INTO v_MonthFirstDate,
                               v_MonthLastDate
                          FROM ( SELECT A.TimeKey Code  ,
                                        UTILS.CONVERT_TO_VARCHAR2(B.Date_,10,p_style=>103) DESCRIPTION  ,
                                        CASE 
                                             WHEN utils.month_(B.Date_) <= 9 THEN '0' || UTILS.CONVERT_TO_VARCHAR2(utils.month_(B.Date_),30)
                                        ELSE UTILS.CONVERT_TO_VARCHAR2(utils.month_(B.Date_),30)
                                           END || UTILS.CONVERT_TO_VARCHAR2(utils.year_(B.Date_),30) MonthYear  ,
                                        S.Month ,
                                        A.TimeKey ,
                                        S.Year ,
                                        S.CurrentStatus ,
                                        UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 1, EOMONTH(utils.dateadd('MONTH', -12, B.DATE_), 0)),200,p_style=>103) MonthFirstDate  ,
                                        UTILS.CONVERT_TO_VARCHAR2(B.Date_,200,p_style=>103) MonthLastDate  
                                 FROM SysDayMatrix A
                                        JOIN ( SELECT MonthLastDate DATE_  
                                               FROM SysDataMatrix 
                                                WHERE  MONTH IN ( 'SEPTEMBER','MARCH' )
                                              ) B   ON A.Date_ = B.Date_
                                        JOIN SysDataMatrix S   ON A.Date_ = S.MonthLastDate
                                        AND S.CurrentStatus IN ( 'U','C' )

                                   GROUP BY A.TimeKey,B.Date_,S.Month,S.Year,S.CurrentStatus ) 
                               --order by B.Date Desc
                               H
                         WHERE  H.TimeKey = v_TimeKey;

                     END;
                     ELSE
                        IF v_Frequency = 'HALFYEARLY' THEN
                         DECLARE
                           v_Prev_Qtr_key NUMBER(10,0);
                           v_Prev_Qtr_key2 NUMBER(10,0);
                           v_HalfYearStartdate VARCHAR2(10);
                           v_HalfYearEnddate VARCHAR2(10);

                        BEGIN
                           SELECT Prev_Qtr_key ,
                                  MonthLastDate 

                             INTO v_Prev_Qtr_key,
                                  v_HalfYearEnddate
                             FROM SysDataMatrix 
                            WHERE  CurrentStatus IN ( 'C','U' )

                                     AND Timekey = v_TimeKey;
                           --SELECT @Prev_Qtr_key2=Prev_Qtr_key FROM sysdatamatrix WHERE CurrentStatus in('C','U')  AND Timekey=@Prev_Qtr_key
                           --SELECT @HalfYearStartdate=MonthFirstDate FROM sysdatamatrix WHERE CurrentStatus in('C','U')  AND Timekey=@Prev_Qtr_key2
                           SELECT DISTINCT utils.dateadd('DAY', 1, SysDataMatrix.MonthLastDate) 

                             INTO 
                                  --@MonthLastDate=B.MonthLastDate,
                                  v_HalfYearStartdate
                             FROM SysDataMatrix 
                                    JOIN ( SELECT Prev_Qtr_key ,
                                                  SysDataMatrix.MonthLastDate 
                                           FROM SysDataMatrix 
                                                  JOIN ( SELECT MonthLastDate 

                                                         --monthfirstdate
                                                         FROM SysDataMatrix A
                                                                JOIN ( SELECT UTILS.CONVERT_TO_VARCHAR2(CurQtrDate,200) Date_  
                                                                       FROM SysDayMatrix 
                                                                         GROUP BY CurQtrDate ) B   ON A.MonthLastDate = B.Date_
                                                          WHERE --currentstatus IN( 'U' ,'C') AND--AND Month_Key >= 2922 AND Month_Key <= 2922
                                                           A.TimeKey = v_Prev_Qtr_key
                                                           GROUP BY YEAR,MonthLastDate,MONTH,currentstatus ) A   ON SysDataMatrix.MonthLastDate = A.MonthLastDate ) B   ON SysDataMatrix.TimeKey = B.Prev_Qtr_key;
                           v_MonthFirstDate := v_HalfYearStartdate ;
                           v_MonthLastDate := v_HalfYearEnddate ;

                        END;
                        ELSE
                           IF v_Frequency = 'HALFYEAR' THEN

                           BEGIN
                              SELECT MonthFirstDate ,
                                     MonthLastDate 

                                INTO v_MonthFirstDate,
                                     v_MonthLastDate
                                FROM ( SELECT A.TimeKey Code  ,
                                              UTILS.CONVERT_TO_VARCHAR2(B.Date_,10,p_style=>103) DESCRIPTION  ,
                                              CASE 
                                                   WHEN utils.month_(B.Date_) <= 9 THEN '0' || UTILS.CONVERT_TO_VARCHAR2(utils.month_(B.Date_),30)
                                              ELSE UTILS.CONVERT_TO_VARCHAR2(utils.month_(B.Date_),30)
                                                 END || UTILS.CONVERT_TO_VARCHAR2(utils.year_(B.Date_),30) MonthYear  ,
                                              S.Month ,
                                              A.TimeKey ,
                                              S.Year ,
                                              S.CurrentStatus ,
                                              UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 1, EOMONTH(utils.dateadd('MONTH', -6, B.DATE_), 0)),200,p_style=>103) MonthFirstDate  ,
                                              UTILS.CONVERT_TO_VARCHAR2(B.Date_,200,p_style=>103) MonthLastDate  
                                       FROM SysDayMatrix A
                                              JOIN ( SELECT MonthLastDate DATE_  
                                                     FROM SysDataMatrix 
                                                      WHERE  MONTH IN ( 'JUNE','DECEMBER' )
                                                    ) B   ON A.Date_ = B.Date_
                                              JOIN SysDataMatrix S   ON A.Date_ = S.MonthLastDate
                                              AND S.CurrentStatus IN ( 'U','C' )

                                         GROUP BY A.TimeKey,B.Date_,S.Month,S.Year,S.CurrentStatus ) 
                                     --order by B.Date Desc
                                     H
                               WHERE  H.TimeKey = v_TimeKey;

                           END;

                           ------ADDED BY SATHEESH 
                           ELSE
                              IF v_Frequency = 'FORTNIGHTLY' THEN
                               DECLARE
                                 v_Sysdate VARCHAR2(200);

                              BEGIN
                                 SELECT DATE_ 

                                   INTO v_Sysdate
                                   FROM SysDayMatrix 
                                  WHERE  TimeKey = v_TimeKey;
                                 SELECT UTILS.CONVERT_TO_VARCHAR2(MonthFirstDate,200,p_style=>105) ,
                                        UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,200,p_style=>105) 

                                   INTO v_MonthFirstDate,
                                        v_MonthLastDate
                                   FROM ( SELECT CASE 
                                                      WHEN v_Sysdate = UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 15, EOMONTH(utils.dateadd('MONTH', -1, MonthLastDate), 0)),10,p_style=>105) THEN UTILS.CONVERT_TO_VARCHAR2(A.MonthFirstDate,10,p_style=>105)
                                                      WHEN v_Sysdate <> UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 15, EOMONTH(utils.dateadd('MONTH', -1, MonthLastDate), 0)),10,p_style=>105) THEN UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 16, EOMONTH(utils.dateadd('MONTH', -1, v_Sysdate), 0)),10,p_style=>105)   END MonthFirstDate  ,
                                                 CASE 
                                                      WHEN v_Sysdate <> UTILS.CONVERT_TO_VARCHAR2(A.MonthLastDate,10,p_style=>105) THEN v_Sysdate
                                                      WHEN v_Sysdate = UTILS.CONVERT_TO_VARCHAR2(A.MonthLastDate,10,p_style=>105) THEN v_Sysdate   END MonthLastDate  
                                          FROM SysDataMatrix A
                                                 RIGHT JOIN SysDayMatrix B   ON A.Fortnight_Key = v_TimeKey
                                                 AND A.Week_Key = B.LastWkDateKey
                                           WHERE  A.CurrentStatus IN ( 'U','C' )

                                            GROUP BY A.MonthFirstDate,A.MonthLastDate ) A;

                              END;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
   INSERT INTO tt_v_Result
     VALUES ( v_MonthLastDate, v_MonthFirstDate );
   OPEN v_temp FOR
      SELECT * 
        FROM tt_v_Result;

   LOOP
      FETCH v_temp INTO v_temp_1;
      EXIT WHEN v_temp%NOTFOUND;
      PIPE ROW ( v_temp_1 );
   END LOOP;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETDATEONFREQUENCY" TO "ADF_CDR_RBL_STGDB";
