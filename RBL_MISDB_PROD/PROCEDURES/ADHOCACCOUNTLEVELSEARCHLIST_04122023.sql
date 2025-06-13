--------------------------------------------------------
--  DDL for Procedure ADHOCACCOUNTLEVELSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" 
--exec [AdhocAccountLevelSearchList] @OperationFlag=16, @UCIF_ID=N'9987801'
 --go

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER,
  v_UCIF_ID IN VARCHAR2,
  iv_TimeKey IN NUMBER DEFAULT 25992 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_RecordinMAIN NUMBER(10,0);
   v_RecordinMOD NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--@SourceSystem   varchar(20)   = ''
--25999 

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CUSTOMERCAL_HIST_7  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CUSTOMERCAL_HIST_7;
   UTILS.IDENTITY_RESET('tt_CUSTOMERCAL_HIST_7');

   INSERT INTO tt_CUSTOMERCAL_HIST_7 ( 
   	SELECT * 
   	  FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
   	 WHERE  UCIF_ID = v_UCIF_ID
              AND EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   SELECT COUNT(1)  

     INTO v_RecordinMAIN
     FROM AdhocACL_ChangeDetails E
    WHERE  E.EffectiveFromTimeKey <= v_TimeKey
             AND E.EffectiveToTimeKey >= v_TimeKey
             AND E.AuthorisationStatus IN ( 'A' )

             AND E.UCIF_ID = v_UCIF_ID;
   SELECT COUNT(1)  

     INTO v_RecordinMOD
     FROM AdhocACL_ChangeDetails_Mod E
    WHERE  E.EffectiveFromTimeKey <= v_TimeKey
             AND E.EffectiveToTimeKey >= v_TimeKey
             AND E.AuthorisationStatus IN ( 'MP','1A' )

             AND E.UCIF_ID = v_UCIF_ID;
   DBMS_OUTPUT.PUT_LINE('@RecordinMAIN');
   DBMS_OUTPUT.PUT_LINE(v_RecordinMAIN);
   DBMS_OUTPUT.PUT_LINE('@RecordinMOD');
   DBMS_OUTPUT.PUT_LINE(v_RecordinMOD);
   BEGIN
      /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

      BEGIN
         IF v_OperationFlag NOT IN ( 16,20 )
          THEN
          IF ( v_RecordinMAIN = 1
           AND v_RecordinMOD = 0 ) THEN

         BEGIN
            DELETE FROM tt_tmp21_4;
            UTILS.IDENTITY_RESET('tt_tmp21_4');

            INSERT INTO tt_tmp21_4 SELECT * 
                 FROM ( SELECT C.CustomerId CustomerId  ,
                               C.UCIF_ID UCICID_Existing  ,
                               C.AssetClassAlt_Key AssetClassAlt_Key_Existing  ,
                               C.NPA_Date NPADate_Existing  ,
                               L.ParameterName MOCReason_Existing  ,
                               ROW_NUMBER() OVER ( PARTITION BY C.UCIF_ID ORDER BY C.UCIF_ID DESC  ) RowNumber  ,
                               D.AssetClassName AssetClass_Existing  ,
                               --,c.ChangeType
                               CASE 
                                    WHEN C.ChangeType = 'Auto' THEN 1
                               ELSE 2
                                  END ChangeType  ,
                               --INTO tt_tmp_4
                               ' ' ChangeFields  
                        FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails C
                               LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = C.AssetClassAlt_Key
                               LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'ModeOfOperationMaster' Tablename  
                                           FROM DimParameter 
                                            WHERE  DimParameterName = 'DimMoRreason'
                                                     AND EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = c.Reason
                         WHERE  C.EffectiveFromTimeKey <= v_TimeKey
                                  AND C.EffectiveToTimeKey >= v_TimeKey
                                  AND C.AuthorisationStatus IN ( 'A' )

                                  AND C.UCIF_ID = v_UCIF_ID ) C
                WHERE  RowNumber = 1
                 ORDER BY C.UCICID_Existing DESC;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_tmp21_4  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         END IF;
         IF ( v_RecordinMOD = 1
           AND v_RecordinMAIN = 1 ) THEN

         BEGIN

            BEGIN
               DELETE FROM tt_tmp22_2;
               UTILS.IDENTITY_RESET('tt_tmp22_2');

               INSERT INTO tt_tmp22_2 SELECT * 
                    FROM ( SELECT C.CustomerId CustomerId  ,
                                  C.UCIF_ID UCICID_Existing  ,
                                  C.AssetClassAlt_Key AssetClassAlt_Key_Existing  ,
                                  C.NPA_Date NPADate_Existing  ,
                                  L.ParameterName MOCReason_Existing  ,
                                  ROW_NUMBER() OVER ( PARTITION BY C.UCIF_ID ORDER BY C.UCIF_ID DESC  ) RowNumber  ,
                                  D.AssetClassName AssetClass_Existing  ,
                                  F.AssetClassName AssetClass_Modified  ,
                                  E.AssetClassAlt_Key AssetClassAlt_Key_Modified  ,
                                  E.NPA_Date NPADate_Modified ,--NPA_Date_Pos

                                  M.ParameterName MOCReason_Modified  ,
                                  --,c.ChangeType
                                  CASE 
                                       WHEN E.ChangeType = 'Auto' THEN 1
                                  ELSE 2
                                     END ChangeType  ,
                                  --INTO tt_tmp_4
                                  ' ' ChangeFields  
                           FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails C
                                  LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = C.AssetClassAlt_Key
                                  LEFT JOIN AdhocACL_ChangeDetails_Mod E   ON C.UCIF_ID = E.UCIF_ID
                                  LEFT JOIN DimAssetClass F   ON E.AssetClassAlt_Key = F.AssetClassAlt_Key
                                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ModeOfOperationMaster' Tablename  
                                              FROM DimParameter 
                                               WHERE  DimParameterName = 'DimMoRreason'
                                                        AND EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = c.Reason
                                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ModeOfOperationMaster' Tablename  
                                              FROM DimParameter 
                                               WHERE  DimParameterName = 'DimMoRreason'
                                                        AND EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey ) M   ON M.ParameterAlt_Key = E.Reason
                            WHERE  C.EffectiveFromTimeKey <= v_TimeKey
                                     AND C.EffectiveToTimeKey >= v_TimeKey
                                     AND E.EffectiveFromTimeKey <= v_TimeKey
                                     AND E.EffectiveToTimeKey >= v_TimeKey

                                     --AND C.AuthorisationStatus in('A')
                                     AND E.AuthorisationStatus IN ( 'MP' )

                                     AND C.UCIF_ID = v_UCIF_ID ) C
                   WHERE  RowNumber = 1
                    ORDER BY C.UCICID_Existing DESC;
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM tt_tmp22_2  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

         END;
         END IF;
         IF ( v_RecordinMOD = 1
           AND v_OperationFlag = 2 ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('MohitPRE');
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT A.CustomerId CustomerId  ,
                               A.UCIF_ID UCICID_Existing  ,
                               NVL(G.Cust_AssetClassAlt_Key, 1) AssetClassAlt_Key_Existing  ,
                               CASE 
                                    WHEN ( G.NPADt = ' '
                                      OR G.NPADt = '01/01/1900'
                                      OR G.NPADt = '1900/01/01' ) THEN NULL
                               ELSE G.NPADt
                                  END NPADate_Existing  ,
                               G.NPA_Reason Reason_Existing  ,
                               L.ParameterName MOCReason_Existing  ,
                               A.CustomerName ,
                               ROW_NUMBER() OVER ( PARTITION BY A.UCIF_ID ORDER BY A.UCIF_ID DESC  ) RowNumber  ,
                               NVL(B.AssetClassName, 'STANDARD') AssetClass_Existing  ,
                               F.AssetClassName AssetClass_Modified  ,
                               E.AssetClassAlt_Key AssetClassAlt_Key_Modified  ,
                               E.NPA_Date NPADate_Modified ,--NPA_Date_Pos

                               E.Reason Reason_Modified  ,
                               --,c.ChangeType
                               CASE 
                                    WHEN E.ChangeType = 'Auto' THEN 1
                               ELSE 2
                                  END ChangeType  ,
                               E.ChangeFields 
                        FROM tt_CUSTOMERCAL_HIST_7 A
                               LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail G   ON A.CustomerEntityId = G.CustomerEntityId
                               AND G.EffectiveFromTimeKey <= v_TimeKey
                               AND G.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimAssetClass B   ON B.AssetClassAlt_Key = G.Cust_AssetClassAlt_Key
                               LEFT JOIN AdhocACL_ChangeDetails C   ON C.UCIF_ID = A.UCIF_ID
                               AND C.EffectiveFromTimeKey <= v_TimeKey
                               AND C.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = C.AssetClassAlt_Key
                               LEFT JOIN AdhocACL_ChangeDetails_Mod E   ON E.UCIF_ID = A.UCIF_ID
                               AND E.EffectiveFromTimeKey <= v_TimeKey
                               AND E.EffectiveToTimeKey >= v_TimeKey
                               LEFT JOIN DimAssetClass F   ON E.AssetClassAlt_Key = F.AssetClassAlt_Key
                               LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                  ParameterName ,
                                                  'ModeOfOperationMaster' Tablename  
                                           FROM DimParameter 
                                            WHERE  DimParameterName = 'DimMoRreason'
                                                     AND EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = c.Reason

                        --LEFT Join (

                        --					Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 

                        --					from DimParameter where DimParameterName='DimMoRreason'

                        --					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M

                        --					ON M.ParameterAlt_Key=E.Reason
                        WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                 AND A.EffectiveToTimeKey >= v_TimeKey
                                 AND A.UCIF_ID = v_UCIF_ID
                                 AND E.AuthorisationStatus = 'MP' ) A
                WHERE  RowNumber = 1
                 ORDER BY A.UCICID_Existing DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF ( v_RecordinMOD = 0
              AND v_OperationFlag = 2 ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('MohitPOST');
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT A.CustomerId CustomerId  ,
                                  A.UCIF_ID UCICID_Existing  ,
                                  NVL(G.Cust_AssetClassAlt_Key, 1) AssetClassAlt_Key_Existing  ,
                                  CASE 
                                       WHEN ( G.NPADt = ' '
                                         OR G.NPADt = '01/01/1900'
                                         OR G.NPADt = '1900/01/01' ) THEN NULL
                                  ELSE G.NPADt
                                     END NPADate_Existing  ,
                                  G.NPA_Reason Reason_Existing  ,
                                  L.ParameterName MOCReason_Existing  ,
                                  A.CustomerName ,
                                  ROW_NUMBER() OVER ( PARTITION BY A.UCIF_ID ORDER BY A.UCIF_ID DESC  ) RowNumber  ,
                                  NVL(B.AssetClassName, 'STANDARD') AssetClass_Existing  ,
                                  --,ChangeType
                                  CASE 
                                       WHEN ChangeType = 'Auto' THEN 1
                                  ELSE 2
                                     END ChangeType  ,
                                  --,F.AssetClassName as AssetClass_Modified
                                  --,E.AssetClassAlt_Key as AssetClassAlt_Key_Modified
                                  --,E.NPA_Date as NPADate_Modified --NPA_Date_Pos
                                  --,E.Reason AS Reason_Modified
                                  ' ' ChangeFields  
                           FROM tt_CUSTOMERCAL_HIST_7 A
                                  LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail G   ON A.CustomerEntityId = G.CustomerEntityId
                                  AND G.EffectiveFromTimeKey <= v_TimeKey
                                  AND G.EffectiveToTimeKey >= v_TimeKey
                                  LEFT JOIN DimAssetClass B   ON B.AssetClassAlt_Key = G.Cust_AssetClassAlt_Key
                                  LEFT JOIN AdhocACL_ChangeDetails C   ON C.UCIF_ID = A.UCIF_ID
                                  AND C.EffectiveFromTimeKey <= v_TimeKey
                                  AND C.EffectiveToTimeKey >= v_TimeKey
                                  LEFT JOIN DimAssetClass D   ON D.AssetClassAlt_Key = C.AssetClassAlt_Key
                                  LEFT JOIN ( 
                                              --	LEFT JOIN AdhocACL_ChangeDetails_MOD E

                                              --	ON E.UCIF_ID=A.UCIF_ID

                                              --LEFT JOIN DimAssetClass F

                                              --	ON E.AssetClassAlt_Key=F.AssetClassAlt_Key
                                              SELECT ParameterAlt_Key ,
                                                     ParameterName ,
                                                     'ModeOfOperationMaster' Tablename  
                                              FROM DimParameter 
                                               WHERE  DimParameterName = 'DimMoRreason'
                                                        AND EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = c.Reason

                           --LEFT Join (

                           --					Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 

                           --					from DimParameter where DimParameterName='DimMoRreason'

                           --					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M

                           --					ON M.ParameterAlt_Key=E.Reason
                           WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                    AND A.EffectiveToTimeKey >= v_TimeKey
                                    AND A.UCIF_ID = v_UCIF_ID ) 
                         --and E.AuthorisationStatus='MP'
                         A
                   WHERE  RowNumber = 1
                    ORDER BY A.UCICID_Existing DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         IF v_OperationFlag = '16' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;


         --IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (AuthorisationStatus IN('NP','NP')))
         BEGIN
            DBMS_OUTPUT.PUT_LINE('Sac1');
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM AdhocACL_ChangeDetails_Mod E
                                WHERE  E.EffectiveFromTimeKey <= v_TimeKey
                                         AND E.EffectiveToTimeKey >= v_TimeKey
                                         AND E.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                         AND E.UCIF_ID = v_UCIF_ID );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DBMS_OUTPUT.PUT_LINE('Sac1-1');
            END IF;
            DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM AdhocACL_ChangeDetails E
                                   WHERE  E.EffectiveFromTimeKey <= v_TimeKey
                                            AND E.EffectiveToTimeKey >= v_TimeKey
                                            AND E.AuthorisationStatus IN ( 'A' )

                                            AND E.UCIF_ID = v_UCIF_ID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Sac1-2');
                  DELETE FROM tt_tmp_4;
                  UTILS.IDENTITY_RESET('tt_tmp_4');

                  INSERT INTO tt_tmp_4 SELECT * 
                       FROM ( SELECT C.CustomerId CustomerId  ,
                                     C.UCIF_ID UCICID_Existing  ,
                                     C.AssetClassAlt_Key AssetClassAlt_Key_Existing  ,
                                     C.NPA_Date NPADate_Existing  ,
                                     C.Reason Reason_Existing  ,
                                     L.ParameterName MOCReason_Existing  ,
                                     ROW_NUMBER() OVER ( PARTITION BY C.UCIF_ID ORDER BY C.UCIF_ID DESC  ) RowNumber  ,
                                     D.AssetClassName AssetClass_Existing  ,
                                     --,c.ChangeType
                                     CASE 
                                          WHEN c.ChangeType = 'Auto' THEN 1
                                     ELSE 2
                                        END ChangeType  ,
                                     --INTO tt_tmp_4
                                     ' ' ChangeFields  
                              FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails C
                                     LEFT JOIN DimAssetClass D   ON C.AssetClassAlt_Key = D.AssetClassAlt_Key
                                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ModeOfOperationMaster' Tablename  
                                                 FROM DimParameter 
                                                  WHERE  DimParameterName = 'DimMoRreason'
                                                           AND EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = c.Reason
                               WHERE  C.EffectiveFromTimeKey <= v_TimeKey
                                        AND C.EffectiveToTimeKey >= v_TimeKey
                                        AND C.AuthorisationStatus IN ( 'A','MP' )

                                        AND C.UCIF_ID = v_UCIF_ID ) C
                      WHERE  RowNumber = 1
                       ORDER BY C.UCICID_Existing DESC;

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Sac2');
                  DELETE FROM tt_tmp_1_2;
                  UTILS.IDENTITY_RESET('tt_tmp_1_2');

                  INSERT INTO tt_tmp_1_2 SELECT * 
                       FROM ( SELECT C.CustomerId CustomerId  ,
                                     C.UCIF_ID UCICID_Existing  ,
                                     c.CustomerName ,
                                     NVL(G.Cust_AssetClassAlt_Key, 1) AssetClassAlt_Key_Existing  ,
                                     CASE 
                                          WHEN ( G.NPADt = ' '
                                            OR G.NPADt = '01/01/1900'
                                            OR G.NPADt = '1900/01/01' ) THEN NULL
                                     ELSE G.NPADt
                                        END NPADate_Existing  ,
                                     ROW_NUMBER() OVER ( PARTITION BY C.UCIF_ID ORDER BY C.UCIF_ID DESC  ) RowNumber  ,
                                     G.NPA_Reason Reason_Existing  ,
                                     NVL(D.AssetClassName, 'STANDARD') AssetClass_Existing  ,
                                     --,NULL ChangeType
                                     --INTO tt_tmp_4_1
                                     ' ' ChangeFields  
                              FROM tt_CUSTOMERCAL_HIST_7 C
                                     LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail G   ON C.CustomerEntityId = G.CustomerEntityId
                                     AND G.EffectiveFromTimeKey <= v_TimeKey
                                     AND G.EffectiveToTimeKey >= v_TimeKey
                                     LEFT JOIN DimAssetClass D   ON G.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
                               WHERE  C.EffectiveFromTimeKey <= v_TimeKey
                                        AND C.EffectiveToTimeKey >= v_TimeKey

                                        --AND C.AuthorisationStatus in('A')
                                        AND C.UCIF_ID = v_UCIF_ID ) C
                      WHERE  RowNumber = 1
                       ORDER BY C.UCICID_Existing DESC;

               END;
               END IF;
               --Select 'tt_tmp_4',* from tt_tmp_4
               DELETE FROM tt_tmp1_2;
               UTILS.IDENTITY_RESET('tt_tmp1_2');

               INSERT INTO tt_tmp1_2 SELECT * 
                    FROM ( SELECT E.CustomerId CustomerId  ,
                                  E.UCIF_ID UCICID_Modified  ,
                                  E.AssetClassAlt_Key AssetClassAlt_Key_Modified  ,
                                  E.NPA_Date NPADate_Modified  ,
                                  E.Reason Reason_Modified  ,
                                  ROW_NUMBER() OVER ( PARTITION BY E.UCIF_ID ORDER BY E.UCIF_ID DESC  ) RowNumber  ,
                                  F.AssetClassName AssetClass_Modified  ,
                                  NVL(E.ModifyBy, E.CreatedBy) CrModBy  ,
                                  NVL(E.DateModified, E.DateCreated) CrModDate  ,
                                  NVL(E.ApprovedBy, E.CreatedBy) CrAppBy  ,
                                  NVL(E.DateApproved, E.DateCreated) CrAppDate  ,
                                  NVL(E.ApprovedBy, E.ModifyBy) ModAppBy  ,
                                  NVL(E.DateApproved, E.DateModified) ModAppDate  ,
                                  NVL(E.FirstLevelApprovedBy, E.CreatedBy) ModAppByFirst  ,
                                  NVL(E.FirstLevelDateApproved, E.DateCreated) ModAppDateFirst  ,
                                  E.FirstLevelApprovedBy ,
                                  E.ApprovedBy ,
                                  --,E.ChangeType
                                  CASE 
                                       WHEN E.ChangeType = 'Auto' THEN 1
                                  ELSE 2
                                     END ChangeType  ,
                                  E.ChangeFields 

                           --into tt_tmp_41
                           FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod E
                                  LEFT JOIN DimAssetClass f   ON E.AssetClassAlt_Key = F.AssetClassAlt_Key
                            WHERE  E.EffectiveFromTimeKey <= v_TimeKey
                                     AND E.EffectiveToTimeKey >= v_TimeKey
                                     AND E.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                     AND E.UCIF_ID = v_UCIF_ID ) E
                   WHERE  RowNumber = 1
                    ORDER BY E.UCICID_Modified DESC;
               --Select 'tt_tmp_4',* from tt_tmp_4
               --Select 'tt_tmp_41',* from tt_tmp_41
               IF utils.object_id('TempDB..tt_tmp_4') IS NOT NULL THEN
                OPEN  v_cursor FOR
                  SELECT A.* ,
                         B.* 
                    FROM tt_tmp1_2 B
                           LEFT JOIN tt_tmp_4 A   ON A.UCICID_Existing = B.UCICID_Modified ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               ELSE
                  OPEN  v_cursor FOR
                     SELECT A.* ,
                            B.* 
                       FROM tt_tmp1_2 B
                              LEFT JOIN tt_tmp_1_2 A   ON A.UCICID_Existing = B.UCICID_Modified ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);
               END IF;

            END;

         END;
         END IF;
         IF v_OperationFlag = '20' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;


         --IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (AuthorisationStatus IN('NP','NP')))
         BEGIN
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM AdhocACL_ChangeDetails_Mod I
                                WHERE  I.EffectiveFromTimeKey <= v_TimeKey
                                         AND I.EffectiveToTimeKey >= v_TimeKey
                                         AND I.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                         AND I.UCIF_ID = v_UCIF_ID );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DBMS_OUTPUT.PUT_LINE('Sac1');
            END IF;
            DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM AdhocACL_ChangeDetails I
                                   WHERE  I.EffectiveFromTimeKey <= v_TimeKey
                                            AND I.EffectiveToTimeKey >= v_TimeKey
                                            AND I.AuthorisationStatus IN ( 'A','MP' )

                                            AND I.UCIF_ID = v_UCIF_ID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('J');
                  DELETE FROM tt_tmp2_9;
                  UTILS.IDENTITY_RESET('tt_tmp2_9');

                  INSERT INTO tt_tmp2_9 SELECT * 
                       FROM ( SELECT G.CustomerId CustomerId  ,
                                     G.UCIF_ID UCICID_Existing  ,
                                     G.AssetClassAlt_Key AssetClassAlt_Key_Existing  ,
                                     G.NPA_Date NPADate_Existing  ,
                                     G.Reason Reason_Existing  ,
                                     L.ParameterName MOCReason_Existing  ,
                                     ROW_NUMBER() OVER ( PARTITION BY G.UCIF_ID ORDER BY G.UCIF_ID DESC  ) RowNumber  ,
                                     H.AssetClassName AssetClass_Existing  ,
                                     --,G.ChangeType
                                     --,CASE WHEN G.ChangeType='Auto' THEN 1 ELSE 2 END ChangeType
                                     --INTO tt_tmp_42
                                     ' ' ChangeFields  
                              FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails G
                                     LEFT JOIN DimAssetClass H   ON G.AssetClassAlt_Key = H.AssetClassAlt_Key
                                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                        ParameterName ,
                                                        'ModeOfOperationMaster' Tablename  
                                                 FROM DimParameter 
                                                  WHERE  DimParameterName = 'DimMoRreason'
                                                           AND EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey ) L   ON L.ParameterAlt_Key = G.Reason
                               WHERE  G.EffectiveFromTimeKey <= v_TimeKey
                                        AND G.EffectiveToTimeKey >= v_TimeKey
                                        AND G.AuthorisationStatus IN ( '1A','MP' )

                                        AND G.UCIF_ID = v_UCIF_ID ) G
                      WHERE  RowNumber = 1
                       ORDER BY G.UCICID_Existing DESC;

               END;
               ELSE

               BEGIN
                  DELETE FROM tt_tmp_2_2;
                  UTILS.IDENTITY_RESET('tt_tmp_2_2');

                  INSERT INTO tt_tmp_2_2 SELECT * 
                       FROM ( SELECT C.CustomerId CustomerId  ,
                                     C.UCIF_ID UCICID_Existing  ,
                                     c.CustomerName ,
                                     --,C.SysAssetClassAlt_Key as AssetClassAlt_Key_Existing
                                     NVL(G.Cust_AssetClassAlt_Key, 1) AssetClassAlt_Key_Existing  ,
                                     CASE 
                                          WHEN ( G.NPADt = ' '
                                            OR G.NPADt = '01/01/1900'
                                            OR G.NPADt = '1900/01/01' ) THEN NULL
                                     ELSE G.NPADt
                                        END NPADate_Existing  ,
                                     ROW_NUMBER() OVER ( PARTITION BY C.UCIF_ID ORDER BY C.UCIF_ID DESC  ) RowNumber  ,
                                     G.NPA_Reason Reason_Existing  ,
                                     D.AssetClassName AssetClass_Existing  ,
                                     --,NULL ChangeType
                                     --INTO tt_tmp_4_2
                                     ' ' ChangeFields  
                              FROM tt_CUSTOMERCAL_HIST_7 C
                                     LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail G   ON C.CustomerEntityId = G.CustomerEntityId
                                     AND G.EffectiveFromTimeKey <= v_TimeKey
                                     AND G.EffectiveToTimeKey >= v_TimeKey
                                     LEFT JOIN DimAssetClass D   ON G.Cust_AssetClassAlt_Key = D.AssetClassAlt_Key
                               WHERE  C.EffectiveFromTimeKey <= v_TimeKey
                                        AND C.EffectiveToTimeKey >= v_TimeKey

                                        --AND C.AuthorisationStatus in('A')
                                        AND C.UCIF_ID = v_UCIF_ID ) C
                      WHERE  RowNumber = 1
                       ORDER BY C.UCICID_Existing DESC;

               END;
               END IF;
               DELETE FROM tt_tmp3_2;
               UTILS.IDENTITY_RESET('tt_tmp3_2');

               INSERT INTO tt_tmp3_2 SELECT * 
                    FROM ( SELECT I.CustomerId CustomerId  ,
                                  I.UCIF_ID UCICID_Modified  ,
                                  I.AssetClassAlt_Key AssetClassAlt_Key_Modified  ,
                                  I.NPA_Date NPADate_Modified  ,
                                  I.Reason Reason_Modified  ,
                                  ROW_NUMBER() OVER ( PARTITION BY I.UCIF_ID ORDER BY I.UCIF_ID DESC  ) RowNumber  ,
                                  J.AssetClassName AssetClass_Modified  ,
                                  NVL(I.ModifyBy, I.CreatedBy) CrModBy  ,
                                  NVL(I.DateModified, I.DateCreated) CrModDate  ,
                                  NVL(I.ApprovedBy, I.CreatedBy) CrAppBy  ,
                                  NVL(I.DateApproved, I.DateCreated) CrAppDate  ,
                                  NVL(I.ApprovedBy, I.ModifyBy) ModAppBy  ,
                                  NVL(I.DateApproved, I.DateModified) ModAppDate  ,
                                  NVL(I.FirstLevelApprovedBy, I.CreatedBy) ModAppByFirst  ,
                                  NVL(I.FirstLevelDateApproved, I.DateCreated) ModAppDateFirst  ,
                                  I.FirstLevelApprovedBy ,
                                  I.ApprovedBy ,
                                  --,I.ChangeType
                                  CASE 
                                       WHEN I.ChangeType = 'Auto' THEN 1
                                  ELSE 2
                                     END ChangeType  ,
                                  I.ChangeFields 

                           --into tt_tmp_43
                           FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod I
                                  LEFT JOIN DimAssetClass J   ON I.AssetClassAlt_Key = J.AssetClassAlt_Key
                            WHERE  I.EffectiveFromTimeKey <= v_TimeKey
                                     AND I.EffectiveToTimeKey >= v_TimeKey
                                     AND I.AuthorisationStatus IN ( '1A' )

                                     AND I.UCIF_ID = v_UCIF_ID ) I
                   WHERE  RowNumber = 1
                    ORDER BY I.UCICID_Modified DESC;
               --Select 'tt_tmp_4_2',* from tt_tmp_4_2
               --Select 'tt_tmp_43',* from tt_tmp_43
               IF utils.object_id('TempDB..tt_tmp_42') IS NOT NULL THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('JAYA');
                  OPEN  v_cursor FOR
                     SELECT C.* ,
                            D.* 
                       FROM tt_tmp3_2 D
                              LEFT JOIN tt_tmp2_9 C   ON C.UCICID_Existing = D.UCICID_Modified ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('DEV');
                  OPEN  v_cursor FOR
                     SELECT C.* ,
                            D.* 
                       FROM tt_tmp3_2 D
                              LEFT JOIN tt_tmp_2_2 C   ON C.UCICID_Existing = D.UCICID_Modified ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;

            END;

         END;
         END IF;

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
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCACCOUNTLEVELSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
