--------------------------------------------------------
--  DDL for Procedure PRECASECUSTOMERDETAILSELECTAUX_06042023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" 
(
  --DECLARE
  v_CustomerID IN VARCHAR2 DEFAULT '170007152' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_BranchName IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerAcID IN VARCHAR2 DEFAULT ' ' ,
  v_DefendentName IN VARCHAR2 DEFAULT ' ' ,
  v_CaseNo IN VARCHAR2 DEFAULT ' ' ,
  v_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_SourceSystem IN VARCHAR2 DEFAULT ' ' ,
  ----
  v_TimeKey IN NUMBER DEFAULT 25703 ,
  v_UserLoginID IN VARCHAR2 DEFAULT 'tf572' ,
  v_Mode IN NUMBER DEFAULT 0 ,
  v_CustType IN VARCHAR2 DEFAULT 'BORROWER' ,
  iv_Result IN NUMBER DEFAULT 0 --OUTPUT
)
AS
   v_Result NUMBER(5,0) := iv_Result;
   v_LocatationCode VARCHAR2(10) := ' ';
   v_Location CHAR(2) := 'HO';
   v_CustomerEntityID NUMBER(10,0) := 0;
   --IF (SELECT COUNT(CustomerEntityId) FROM tt_CustomerEntityId_3)>100
   --	BEGIN
   --			SET @Result=-3  /* If customer DATA IS MORE THAN 100*/
   --			RETURN @Result
   --	END
   v_CntCust NUMBER(10,0) := ( SELECT COUNT(*)  
     FROM tt_CustomerEntityId_3  );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('TEMPDB..tt_CustomerEntityId_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerEntityId_3 ';
   END IF;
   DELETE FROM tt_CustomerEntityId_3;
   IF NVL(v_CustomerID, ' ') <> ' ' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      --SELECT 'TRI'
      INSERT INTO tt_CustomerEntityId_3
        ( CustomerEntityId )
        ( SELECT CustomerEntityID 
          FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND NVL(AuthorisationStatus, 'A') = 'A'
                    AND CustomerID = v_CustomerID
          UNION 
          SELECT CustomerEntityID 
          FROM CustomerBasicDetail_Mod 
           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                    AND CustomerID = v_CustomerID );
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM tt_CustomerEntityId_3 
                              WHERE  1 = 1 );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Result := -1 ;
         /* If customer Id does not exists*/

      END;
      END IF;

   END;
   END IF;
   --RETURN @Result
   IF NVL(v_CustomerName, ' ') <> ' ' THEN

   BEGIN
      INSERT INTO tt_CustomerEntityId_3
        ( CustomerEntityId )
        ( SELECT CustomerEntityId 
          FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND NVL(AuthorisationStatus, 'A') = 'A'
                    AND CustomerName LIKE '%' || v_CustomerName || '%' );

   END;
   END IF;
   IF utils.object_id('Tempdb..tt_CustAcData_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustAcData_3 ';
   END IF;
   DELETE FROM tt_CustAcData_3;
   IF NVL(v_CustomerAcID, ' ') <> ' ' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      INSERT INTO tt_CustAcData_3
        ( SELECT CustomerEntityID ,
                 AuthorisationStatus 
          FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ABD
           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ABD.CustomerEntityId = CASE 
                                                    WHEN v_CustomerEntityID > 0 THEN v_CustomerEntityID
                  ELSE ABD.CustomerEntityId
                     END
                    AND CustomerAcID = v_CustomerAcID
                    AND NVL(AuthorisationStatus, 'A') = 'A'
            GROUP BY CustomerEntityID,AuthorisationStatus
          UNION 
          SELECT A.CustomerEntityID ,
                 A.AuthorisationStatus 
          FROM AdvAcBasicDetail_mod A
                 JOIN ( SELECT MAX(Ac_Key)  Ac_Key  
                        FROM AdvAcBasicDetail_mod A
                         WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey )
                                  AND A.CustomerACID = v_CustomerAcID
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                          GROUP BY A.CustomerACID ) P   ON P.Ac_Key = A.Ac_Key
                 AND ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
                 AND A.CustomerEntityId = CASE 
                                               WHEN v_CustomerEntityID > 0 THEN v_CustomerEntityID
               ELSE A.CustomerEntityId
                  END );
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM tt_CustAcData_3 
                              WHERE  1 = 1 );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Result := -2 ;
         /* aCCOUNT ID DOES NOT EXISTS*/

      END;
      END IF;

   END;
   END IF;
   --RETURN @Result
   IF utils.object_id('Tempdb..tt_CustDefData_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustDefData_3 ';
   END IF;
   DELETE FROM tt_CustDefData_3;
   IF NVL(v_DefendentName, ' ') <> ' ' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      INSERT INTO tt_CustDefData_3
        ( SELECT AAR.CustomerEntityID ,
                 AAR.AuthorisationStatus 
          FROM CurDat_RBL_MISDB_PROD.AdvAcRelations AAR
                 JOIN AdvCustRelationship ACR   ON ( AAR.EffectiveFromTimeKey <= v_TimeKey
                 AND AAR.EffectiveToTimeKey >= v_TimeKey )
                 AND ( ACR.EffectiveFromTimeKey <= v_TimeKey
                 AND ACR.EffectiveToTimeKey >= v_TimeKey )
                 AND ACR.RelationEntityId = AAR.RelationEntityId
                 AND AAR.RelationTypeAlt_Key IN ( 17,60 -- joint borrower,guarantor
                )

                 AND NAME LIKE '%' || v_DefendentName || '%'
                 AND NVL(AAR.AuthorisationStatus, 'A') = 'A'
            GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus
          UNION 
          SELECT AAR.CustomerEntityID ,
                 AAR.AuthorisationStatus 
          FROM AdvAcRelations_Mod AAR
                 JOIN AdvCustRelationship_Mod ACR   ON ( AAR.EffectiveFromTimeKey <= v_TimeKey
                 AND AAR.EffectiveToTimeKey >= v_TimeKey )
                 AND ( ACR.EffectiveFromTimeKey <= v_TimeKey
                 AND ACR.EffectiveToTimeKey >= v_TimeKey )
                 AND ACR.RelationEntityId = AAR.RelationEntityId
                 AND AAR.RelationTypeAlt_Key IN ( 17,60 -- joint borrower,guarantor
                )

                 AND NAME LIKE '%' || v_DefendentName || '%'
                 AND AAR.AuthorisationStatus IN ( 'NP','MP','DP' )

            GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus
          UNION 
          SELECT AAR.CustomerEntityID ,
                 AAR.AuthorisationStatus 
          FROM CurDat_RBL_MISDB_PROD.AdvAcRelations AAR
                 JOIN CurDat_RBL_MISDB_PROD.AdvCustRelationship ACR   ON ( ACR.EffectiveFromTimeKey <= v_TimeKey
                 AND ACR.EffectiveToTimeKey >= v_TimeKey )
                 AND ACR.RelationEntityId = AAR.RelationEntityId
                 AND ACR.NAME LIKE '%' || v_DefendentName || '%'
                 AND NVL(ACR.AuthorisationStatus, 'A') = 'A'
                 JOIN AdvCustCommunicationDetail COMM   ON ( AAR.EffectiveFromTimeKey <= v_TimeKey
                 AND AAR.EffectiveToTimeKey >= v_TimeKey )
                 AND ( COMM.EffectiveFromTimeKey <= v_TimeKey
                 AND COMM.EffectiveToTimeKey >= v_TimeKey )
                 AND COMM.RelationEntityId = AAR.RelationEntityId
                 AND AAR.RelationTypeAlt_Key IN ( 17,60 -- joint borrower,guarantor
                )

                 AND NVL(AAR.AuthorisationStatus, 'A') = 'A'
            GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus
          UNION 
          SELECT AAR.CustomerEntityID ,
                 AAR.AuthorisationStatus 
          FROM CurDat_RBL_MISDB_PROD.AdvAcRelations AAR
                 JOIN CurDat_RBL_MISDB_PROD.AdvCustRelationship ACR   ON ( ACR.EffectiveFromTimeKey <= v_TimeKey
                 AND ACR.EffectiveToTimeKey >= v_TimeKey )
                 AND ACR.RelationEntityId = AAR.RelationEntityId
                 AND ACR.NAME LIKE '%' || v_DefendentName || '%'
                 AND NVL(ACR.AuthorisationStatus, 'A') = 'A'
                 JOIN AdvCustCommunicationDetail_Mod COMM   ON ( AAR.EffectiveFromTimeKey <= v_TimeKey
                 AND AAR.EffectiveToTimeKey >= v_TimeKey )
                 AND ( COMM.EffectiveFromTimeKey <= v_TimeKey
                 AND COMM.EffectiveToTimeKey >= v_TimeKey )
                 AND COMM.RelationEntityId = AAR.RelationEntityId
                 AND AAR.RelationTypeAlt_Key IN ( 17,60 -- joint borrower,guarantor
                )

                 AND AAR.AuthorisationStatus IN ( 'NP','MP','DP' )

            GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus );
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM tt_CustDefData_3 
                              WHERE  1 = 1 );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Result := -3 ;
         /* Defendant doesnot exists*/

      END;
      END IF;

   END;
   END IF;
   --RETURN @Result
   --IF (SELECT COUNT(CustomerEntityId) FROM tt_CustDefData_3)>1000
   --BEGIN
   --		SET @Result=-4  /* If customer defendant DATA IS MORE THAN 100*/
   --		RETURN @Result
   --END
   IF utils.object_id('Tempdb..tt_CustBrData_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustBrData_3 ';
   END IF;
   DELETE FROM tt_CustBrData_3;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_CustomerEntityId_3 
                       WHERE  1 = 1 );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('P1');
      INSERT INTO tt_CustBrData_3
        ( SELECT ABD.CustomerEntityID ,
                 BranchCode 
          FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ABD
                 JOIN tt_CustomerEntityId_3 C   ON ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND NVL(ABD.AuthorisationStatus, 'A') = 'A'
                 AND C.CustomerEntityId = ABD.CustomerEntityId
                 AND ABD.CustomerACID = CASE 
                                             WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
               ELSE ABD.CustomerACID
                  END
                 AND ABD.BranchCode = CASE 
                                           WHEN v_BranchCode <> ' ' THEN v_BranchCode
               ELSE ABD.BranchCode
                  END

          -- AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
          GROUP BY ABD.CustomerEntityID,BranchCode
          UNION 

          --SELECT CustomerEntityID, BranchCode FROM AdvAcBasicDetail		ABD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND BranchCode=@BranchCode

          -- AND ISNULL(AuthorisationStatus,'A')='A'		

          -- AND ABD.CustomerEntityId IN (SELECT CustomerEntityId FROM tt_CustomerEntityId_3 GROUP BY CustomerEntityId)

          -- AND ABD.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE ABD.CustomerACID END 

          -- AND ABD.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE ABD.BranchCode END

          -- AND @CustType IN ('BORROWER','WRITTENOFF')

          -- GROUP BY CustomerEntityID,BranchCode
          SELECT A.CustomerEntityID ,
                 A.BranchCode 
          FROM AdvAcBasicDetail_mod A
                 JOIN ( SELECT MAX(Ac_Key)  Ac_Key  
                        FROM AdvAcBasicDetail_mod A
                         WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey )
                                  AND A.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                              FROM tt_CustomerEntityId_3 
                                                                GROUP BY CustomerEntityId )

                                  AND A.CustomerACID = CASE 
                                                            WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
                                ELSE A.CustomerACID
                                   END
                                  AND A.BranchCode = CASE 
                                                          WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                ELSE A.BranchCode
                                   END

                                  --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                          GROUP BY A.CustomerACID ) P   ON P.Ac_Key = A.Ac_Key
                 AND ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
            GROUP BY A.CustomerEntityID,A.BranchCode
          UNION 
          SELECT CustomerEntityID ,
                 ParentBranchCode 
          FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail CBD
           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND NVL(AuthorisationStatus, 'A') = 'A'
                    AND CBD.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                  FROM tt_CustomerEntityId_3 
                                                    GROUP BY CustomerEntityId )

                    AND CBD.ParentBranchCode = CASE 
                                                    WHEN v_BranchCode <> ' ' THEN v_BranchCode
                  ELSE CBD.ParentBranchCode
                     END
                    AND v_CustType = 'OTHERS'
            GROUP BY CustomerEntityID,ParentBranchCode ----FOR OTHER 

          UNION 
          SELECT A.CustomerEntityID ,
                 A.ParentBranchCode 
          FROM CustomerBasicDetail_Mod A
                 JOIN ( SELECT MAX(Customer_Key)  Customer_Key  
                        FROM CustomerBasicDetail_Mod A
                         WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey )
                                  AND A.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                              FROM tt_CustomerEntityId_3 
                                                                GROUP BY CustomerEntityId )

                                  AND A.ParentBranchCode = CASE 
                                                                WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                ELSE A.ParentBranchCode
                                   END
                                  AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                  AND v_CustType = 'OTHERS'
                          GROUP BY A.CustomerId ) P   ON P.Customer_Key = A.Customer_Key
                 AND ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
            GROUP BY A.CustomerEntityID,A.ParentBranchCode );---FOR OTHER				

   END;

   --SELECT * FROM tt_CustBrData_3
   ELSE
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM tt_CustDefData_3 
                          WHERE  1 = 1 );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('Def');
         INSERT INTO tt_CustBrData_3
           ( SELECT CustomerEntityID ,
                    BranchCode 
             FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ABD
              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey --AND BranchCode=@BranchCode
                      )
                       AND NVL(AuthorisationStatus, 'A') = 'A'
                       AND ABD.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                     FROM tt_CustDefData_3 
                                                       GROUP BY CustomerEntityId )

                       AND ABD.CustomerACID = CASE 
                                                   WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
                     ELSE ABD.CustomerACID
                        END
                       AND ABD.BranchCode = CASE 
                                                 WHEN v_BranchCode <> ' ' THEN v_BranchCode
                     ELSE ABD.BranchCode
                        END

             --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
             GROUP BY CustomerEntityID,BranchCode
             UNION 
             SELECT A.CustomerEntityID ,
                    A.BranchCode 
             FROM AdvAcBasicDetail_mod A
                    JOIN ( SELECT MAX(Ac_Key)  Ac_Key  
                           FROM AdvAcBasicDetail_mod A
                            WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey )
                                     AND A.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                                 FROM tt_CustDefData_3 
                                                                   GROUP BY CustomerEntityId )

                                     AND A.CustomerACID = CASE 
                                                               WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
                                   ELSE A.CustomerACID
                                      END
                                     AND A.BranchCode = CASE 
                                                             WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                   ELSE A.BranchCode
                                      END

                                     --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             GROUP BY A.CustomerACID ) P   ON P.Ac_Key = A.Ac_Key
                    AND ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
               GROUP BY A.CustomerEntityID,A.BranchCode
             UNION 
             SELECT CustomerEntityID ,
                    ParentBranchCode 
             FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail CBD
              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND NVL(AuthorisationStatus, 'A') = 'A'
                       AND CBD.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                     FROM tt_CustDefData_3 
                                                       GROUP BY CustomerEntityId )

                       AND CBD.ParentBranchCode = CASE 
                                                       WHEN v_BranchCode <> ' ' THEN v_BranchCode
                     ELSE CBD.ParentBranchCode
                        END
                       AND v_CustType = 'OTHERS'
               GROUP BY CustomerEntityID,ParentBranchCode ----FOR OTHER 

             UNION 
             SELECT A.CustomerEntityID ,
                    A.ParentBranchCode 
             FROM CustomerBasicDetail_Mod A
                    JOIN ( SELECT MAX(Customer_Key)  Customer_Key  
                           FROM CustomerBasicDetail_Mod A
                            WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey )
                                     AND A.CustomerEntityId IN ( SELECT CustomerEntityId 
                                                                 FROM tt_CustDefData_3 
                                                                   GROUP BY CustomerEntityId )

                                     AND A.ParentBranchCode = CASE 
                                                                   WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                   ELSE A.ParentBranchCode
                                      END
                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                     AND v_CustType = 'OTHERS'
                             GROUP BY A.CustomerId ) P   ON P.Customer_Key = A.Customer_Key
                    AND ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
               GROUP BY A.CustomerEntityID,A.ParentBranchCode );---FOR OTHER				

      END;
      ELSE

      BEGIN
         DBMS_OUTPUT.PUT_LINE('ELSE');
         INSERT INTO tt_CustBrData_3
           ( SELECT CustomerEntityID ,
                    BranchCode 
             FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ABD
              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey --AND BranchCode=@BranchCode
                      )
                       AND NVL(AuthorisationStatus, 'A') = 'A'
                       AND CustomerEntityId = CASE 
                                                   WHEN v_CustomerEntityID > 0 THEN v_CustomerEntityID
                     ELSE CustomerEntityId
                        END
                       AND ABD.CustomerACID = CASE 
                                                   WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
                     ELSE ABD.CustomerACID
                        END
                       AND ABD.BranchCode = CASE 
                                                 WHEN v_BranchCode <> ' ' THEN v_BranchCode
                     ELSE ABD.BranchCode
                        END

             --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
             GROUP BY CustomerEntityID,BranchCode
             UNION 
             SELECT A.CustomerEntityID ,
                    A.BranchCode 
             FROM AdvAcBasicDetail_mod A
                    JOIN ( SELECT MAX(Ac_Key)  Ac_Key  
                           FROM AdvAcBasicDetail_mod A
                            WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey )
                                     AND A.CustomerEntityId = CASE 
                                                                   WHEN v_CustomerEntityID > 0 THEN v_CustomerEntityID
                                   ELSE A.CustomerEntityId
                                      END
                                     AND A.CustomerACID = CASE 
                                                               WHEN v_CustomerAcID <> ' ' THEN v_CustomerAcID
                                   ELSE A.CustomerACID
                                      END
                                     AND A.BranchCode = CASE 
                                                             WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                   ELSE A.BranchCode
                                      END

                                     --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             GROUP BY A.CustomerACID ) P   ON P.Ac_Key = A.Ac_Key
                    AND ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
               GROUP BY A.CustomerEntityID,A.BranchCode
             UNION 
             SELECT CustomerEntityID ,
                    ParentBranchCode 
             FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail CBD
              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND NVL(AuthorisationStatus, 'A') = 'A'
                       AND CBD.CustomerId = CASE 
                                                 WHEN v_CustomerId <> ' ' THEN v_CustomerId
                     ELSE CBD.CustomerId
                        END
                       AND CBD.ParentBranchCode = CASE 
                                                       WHEN v_BranchCode <> ' ' THEN v_BranchCode
                     ELSE CBD.ParentBranchCode
                        END
                       AND v_CustType = 'OTHERS'
               GROUP BY CustomerEntityID,ParentBranchCode ----FOR OTHER 

             UNION 
             SELECT A.CustomerEntityID ,
                    A.ParentBranchCode 
             FROM CustomerBasicDetail_Mod A
                    JOIN ( SELECT MAX(Customer_Key)  Customer_Key  
                           FROM CustomerBasicDetail_Mod A
                            WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey )
                                     AND A.CustomerId = CASE 
                                                             WHEN v_CustomerId <> ' ' THEN v_CustomerId
                                   ELSE A.CustomerId
                                      END
                                     AND A.ParentBranchCode = CASE 
                                                                   WHEN v_BranchCode <> ' ' THEN v_BranchCode
                                   ELSE A.ParentBranchCode
                                      END
                                     AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                     AND v_CustType = 'OTHERS'
                             GROUP BY A.CustomerId ) P   ON P.Customer_Key = A.Customer_Key
                    AND ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey )
               GROUP BY A.CustomerEntityID,A.ParentBranchCode );

      END;
      END IF;
   END IF;
   IF utils.object_id('Tempdb..tt_PreCaseCustData_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PreCaseCustData_3 ';
   END IF;
   DELETE FROM tt_PreCaseCustData_3;
   DBMS_OUTPUT.PUT_LINE('1 PRE');
   DBMS_OUTPUT.PUT_LINE(v_CustomerID);
   --SELECT * FROM tt_CustBrData_3
   --SELECT * FROM tt_CustAcData_3
   INSERT INTO tt_PreCaseCustData_3
     ( CustomerEntityId --1
   , SourceSystem, Ucif_ID, CustomerID --2
   , CustomerName --3
   , CustomerSinceDt, NPADt, BranchCode --4
   , BranchName --5
   , CurrentStage --6
   , NextStage --7
   , CurrStageMenuId, NxtStageMenuId, CurrStageAuthMode, NxtStageAuthMode, CurrStageNonAllowOp, NxtStageNonAllowOp, AuthorisationStatus )
     ( SELECT CBD.CustomerEntityId ,--1

              S.SourceName SourceSystem  ,
              CBD.UCIF_ID ,
              CBD.CustomerID ,--2

              CBD.Customername ,--3

              UTILS.CONVERT_TO_VARCHAR2(CBD.CustomerSinceDt,10,p_style=>103) CustomerSinceDt  ,
              UTILS.CONVERT_TO_VARCHAR2(NPA.NPADt,10,p_style=>103) NPADt  ,
              BR.BranchCode ,--4

              BR.BranchName ,--5

              NVL(DS1.ParameterName, 'Customer') ParameterName ,--6

              --CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE  DS2.ParameterName END      ---7
              DS2.ParameterName ,
              MCur.MenuId CurrStageMenuId  ,
              --,CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE MNxt.MenuId END AS NxtStageMenuId
              MNxt.MenuId NxtStageMenuId  ,
              MCur.EnableMakerChecker CurrStageAuthMode  ,
              MNxt.EnableMakerChecker NxtStageAuthMode  ,
              MCur.NonAllowOperation CurrStageNonAllowOp  ,
              MNxt.NonAllowOperation NxtStageNonAllowOp  ,
              CASE 
                   WHEN T.AuthorisationStatus IN ( 'NP','MP','DP' )
                    THEN T.AuthorisationStatus
              ELSE CBD.AuthorisationStatus
                 END AuthorisationStatus  
       FROM ( SELECT
              --CustomerEntityId,CustomerId,D2kCustomerid,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt,ConsentObtained,ConstitutionAlt_Key
               --,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType,CustSalutationAlt_Key
               --,MaritalStatusAlt_Key,DegUpgFlag,ProcessingFlag,MOCLock,MoveNpaDt,AssetClass,BIITransactionCode,D2K_REF_NO,CustomerNameBackup,ScrCrErrorBackup
               --,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated
               --,ModifiedBy,DateModified,ApprovedBy,DateApproved,FLAG,MocStatus,MocDate,BaselProcessing,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding
               --,ScrCrErrorSeq,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,Remark,CUSTOMER_KEY
               Customer_Key ,
               CustomerEntityId ,
               CustomerId ,
               D2kCustomerid ,
               UCIF_ID ,
               UcifEntityID ,
               ParentBranchCode ,
               CustomerName ,
               CustomerInitial ,
               CustomerSinceDt ,
               ConstitutionAlt_Key ,
               OccupationAlt_Key ,
               ReligionAlt_Key ,
               CasteAlt_Key ,
               FarmerCatAlt_Key ,
               GaurdianSalutationAlt_Key ,
               GaurdianName ,
               GuardianType ,
               CustSalutationAlt_Key ,
               MaritalStatusAlt_Key ,
               AssetClass ,
               BIITransactionCode ,
               D2K_REF_NO ,
               ScrCrError ,
               ReferenceAcNo ,
               CustCRM_RatingAlt_Key ,
               CustCRM_RatingDt ,
               AuthorisationStatus ,
               EffectiveFromTimeKey ,
               EffectiveToTimeKey ,
               CreatedBy ,
               DateCreated ,
               ModifiedBy ,
               DateModified ,
               ApprovedBy ,
               DateApproved ,
               D2Ktimestamp ,
               FLAG ,
               MocStatus ,
               MocDate ,
               MocTypeAlt_Key ,
               CommonMocTypeAlt_Key ,
               LandHolding ,
               ScrCrErrorSeq ,
               Remark ,
               SourceSystemAlt_Key 
              FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                        AND EffectiveToTimeKey >= v_TimeKey )
                        AND NVL(AuthorisationStatus, 'A') = 'A'
              UNION 
              SELECT
              --	CustomerEntityId,CustomerId,D2kCustomerid,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt,ConsentObtained,ConstitutionAlt_Key
               --,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType,CustSalutationAlt_Key
               --,MaritalStatusAlt_Key,DegUpgFlag,ProcessingFlag,MOCLock,MoveNpaDt,AssetClass,BIITransactionCode,D2K_REF_NO,CustomerNameBackup,ScrCrErrorBackup
               --,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated
               --,ModifiedBy,DateModified,ApprovedBy,DateApproved,FLAG,MocStatus,MocDate,BaselProcessing,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding
               --,ScrCrErrorSeq,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,Remark,CUSTOMER_KEY
               Customer_Key ,
               CustomerEntityId ,
               CustomerId ,
               D2kCustomerid ,
               UCIF_ID ,
               UcifEntityID ,
               ParentBranchCode ,
               CustomerName ,
               CustomerInitial ,
               CustomerSinceDt ,
               ConstitutionAlt_Key ,
               OccupationAlt_Key ,
               ReligionAlt_Key ,
               CasteAlt_Key ,
               FarmerCatAlt_Key ,
               GaurdianSalutationAlt_Key ,
               GaurdianName ,
               GuardianType ,
               CustSalutationAlt_Key ,
               MaritalStatusAlt_Key ,
               AssetClass ,
               BIITransactionCode ,
               D2K_REF_NO ,
               ScrCrError ,
               ReferenceAcNo ,
               CustCRM_RatingAlt_Key ,
               CustCRM_RatingDt ,
               AuthorisationStatus ,
               EffectiveFromTimeKey ,
               EffectiveToTimeKey ,
               CreatedBy ,
               DateCreated ,
               ModifiedBy ,
               DateModified ,
               ApprovedBy ,
               DateApproved ,
               D2Ktimestamp ,
               FLAG ,
               MocStatus ,
               MocDate ,
               MocTypeAlt_Key ,
               CommonMocTypeAlt_Key ,
               LandHolding ,
               ScrCrErrorSeq ,
               Remark ,
               SourceSystemAlt_Key 
              FROM CustomerBasicDetail_Mod 
               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                        AND EffectiveToTimeKey >= v_TimeKey )
                        AND AuthorisationStatus IN ( 'NP','MP','DP' )

                        AND Customer_Key IN ( SELECT MAX(Customer_Key)  
                                              FROM CustomerBasicDetail_Mod 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_TimeKey )
                                                        AND AuthorisationStatus IN ( 'NP','MP','DP' )

                                                GROUP BY CustomerId )
             ) CBD
              LEFT JOIN CurDat_RBL_MISDB_PROD.ADVCUSTFINANCIALDETAIL CFD   ON ( CFD.EffectiveFromTimeKey <= v_TimeKey
              AND CFD.EffectiveToTimeKey >= v_TimeKey )
              AND CBD.CustomerEntityId = CFD.CustomerEntityId
              LEFT JOIN tt_CustBrData_3 CBR   ON CBR.CustomerEntityId = CBD.CustomerEntityId
              LEFT JOIN DimBranch BR   ON ( BR.EffectiveFromTimeKey <= v_TimeKey
              AND BR.EffectiveToTimeKey >= v_TimeKey )
              AND BR.BranchCode = CBR.BranchCode
              LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = CBD.SourceSystemAlt_Key
              AND S.EffectiveFromTimeKey <= v_TimeKey
              AND S.EffectiveToTimeKey >= v_TimeKey
            --INNER JOIN CustPreCaseDataStage STG
             --		ON CBD.CustomerEntityId=STG.CustomerEntityId

              LEFT JOIN CustPreCaseDataStage STG   ON CBD.CustomerEntityId = STG.CustomerEntityId
              LEFT JOIN DimParameter DS1   ON ( DS1.EffectiveFromTimeKey <= v_TimeKey
              AND DS1.EffectiveToTimeKey >= v_TimeKey )
              AND DS1.ParameterAlt_Key = STG.CurrentStageAlt_Key
              AND DS1.DimParameterName = 'DimCustPreCaseDataStage'
              LEFT JOIN DimParameter DS2   ON ( DS2.EffectiveFromTimeKey <= v_TimeKey
              AND DS2.EffectiveToTimeKey >= v_TimeKey )
              AND DS2.ParameterAlt_Key = STG.NextStageAlt_Key
              AND DS2.DimParameterName = 'DimCustPreCaseDataStage'
              LEFT JOIN tt_CustAcData_3 T   ON T.CustomerEntityID = CBD.CustomerEntityID
              LEFT JOIN tt_CustDefData_3 D   ON D.CustomerEntityID = CBD.CustomerEntityID
              LEFT JOIN SysCRisMacMenu MCur
            --ON MCur.MenuCaption=DS1.ParameterName
               ON MCur.MenuId = DS1.ParameterShortName
              LEFT JOIN SysCRisMacMenu MNxt
            ---ON MNxt.MenuCaption=DS2.ParameterName	
               ON MCur.MenuId = DS2.ParameterShortName
              LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail NPA   ON ( NPA.EffectiveFromTimeKey <= v_TimeKey
              AND NPA.EffectiveToTimeKey >= v_TimeKey )
              AND CBD.CustomerEntityId = NPA.CustomerEntityId
        WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                 AND CBD.EffectiveToTimeKey >= v_TimeKey )

                 ----AND ISNULL(CBD.AuthorisationStatus,'A')='A'

                 --AND CBD.CustType=@CustType  -- CFD
                 AND ( CustomerID = CASE 
                                         WHEN v_CustomerID <> ' ' THEN v_CustomerID
               ELSE CustomerID
                  END )
                 AND ( CustomerName LIKE CASE 
                                              WHEN v_CustomerName <> ' ' THEN '%' || v_CustomerName || '%'
               ELSE CustomerName
                  END )
                 AND ( NVL(BR.BranchCode, ' ') = CASE 
                                                      WHEN v_BranchCode <> ' ' THEN v_BranchCode
               ELSE NVL(BR.BranchCode, ' ')
                  END )
                 AND ( NVL(BranchName, ' ') LIKE CASE 
                                                      WHEN v_BranchName <> ' ' THEN '%' || v_BranchName || '%'
               ELSE NVL(BranchName, ' ')
                  END )
                 AND ( NVL(T.CustomerEntityID, 0) = CASE 
                                                         WHEN v_CustomerAcid <> ' ' THEN CBD.CustomerEntityId
               ELSE NVL(T.CustomerEntityID, 0)
                  END )
                 AND ( NVL(D.CustomerEntityID, 0) = CASE 
                                                         WHEN v_DefendentName <> ' ' THEN CBD.CustomerEntityId
               ELSE NVL(D.CustomerEntityID, 0)
                  END )
                 AND ( UCIF_ID = CASE 
                                      WHEN v_UCICID <> ' ' THEN v_UCICID
               ELSE UCIF_ID
                  END ) );
   DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
   INSERT INTO tt_PreCaseCustData_3
     ( CustomerEntityId --1
   , CustomerID --2
   , CustomerName --3
   , CustomerSinceDt, NPADt, BranchCode --4
   , BranchName --5
   , CurrentStage --6
   , NextStage --7
   , CurrStageMenuId, NxtStageMenuId, CurrStageAuthMode, NxtStageAuthMode, CurrStageNonAllowOp, NxtStageNonAllowOp, AuthorisationStatus )
     ( SELECT CBD.CustomerEntityId ,--1

              CBD.CustomerId ,--2

              CBD.CustomerName ,--3

              UTILS.CONVERT_TO_VARCHAR2(CBD.CustomerSinceDt,10,p_style=>103) CustomerSinceDt  ,
              UTILS.CONVERT_TO_VARCHAR2(NPA.NPADt,10,p_style=>103) NPADt  ,
              CBR.BranchCode ,--4

              BR.BranchName ,--5

              NVL(DS1.ParameterName, 'Customer' 
              ) ,--6

              --CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE  DS2.ParameterName END,		--7
              DS2.ParameterName ,
              MCur.MenuId CurrStageMenuId  ,
              --,CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE MNxt.MenuId END AS NxtStageMenuId
              MNxt.MenuId NxtStageMenuId  ,
              MCur.EnableMakerChecker CurrStageAuthMode  ,
              MNxt.EnableMakerChecker NxtStageAuthMode  ,
              MCur.NonAllowOperation CurrStageNonAllowOp  ,
              MNxt.NonAllowOperation NxtStageNonAllowOp  ,
              CASE 
                   WHEN T.AuthorisationStatus IN ( 'NP','MP','DP' )
                    THEN T.AuthorisationStatus
              ELSE CBD.AuthorisationStatus
                 END AuthorisationStatus  
       FROM CustomerBasicDetail_Mod CBD
              JOIN ( SELECT MAX(Customer_Key)  Customer_Key  ,
                            CustomerEntityId 
                     FROM CustomerBasicDetail_Mod 
                       GROUP BY CustomerEntityId ) A   ON cbd.CustomerEntityId = A.CustomerEntityId
              AND cbd.Customer_Key = A.Customer_Key
              LEFT JOIN CurDat_RBL_MISDB_PROD.ADVCUSTFINANCIALDETAIL CFD   ON ( CFD.EffectiveFromTimeKey <= v_TimeKey
              AND CFD.EffectiveToTimeKey >= v_TimeKey )
              AND CBD.CustomerEntityId = CFD.CustomerEntityId
              LEFT JOIN tt_CustBrData_3 CBR   ON CBR.CustomerEntityId = CBD.CustomerEntityId
              LEFT JOIN DimBranch BR   ON ( BR.EffectiveFromTimeKey <= v_TimeKey
              AND BR.EffectiveToTimeKey >= v_TimeKey )
              AND BR.BranchCode = CBR.BranchCode
              JOIN CustPreCaseDataStage STG   ON CBD.CustomerEntityId = STG.CustomerEntityId
              LEFT JOIN DimParameter DS1   ON ( DS1.EffectiveFromTimeKey <= v_TimeKey
              AND DS1.EffectiveToTimeKey >= v_TimeKey )
              AND DS1.ParameterAlt_Key = STG.CurrentStageAlt_Key
              AND DS1.DimParameterName = 'DimCustPreCaseDataStage'
              LEFT JOIN DimParameter DS2   ON ( DS2.EffectiveFromTimeKey <= v_TimeKey
              AND DS2.EffectiveToTimeKey >= v_TimeKey )
              AND DS2.ParameterAlt_Key = STG.NextStageAlt_Key
              AND DS2.DimParameterName = 'DimCustPreCaseDataStage'
              LEFT JOIN tt_CustAcData_3 T   ON T.CustomerEntityID = CBD.CustomerEntityId
              LEFT JOIN tt_CustDefData_3 D   ON D.CustomerEntityID = CBD.CustomerEntityId
              LEFT JOIN SysCRisMacMenu MCur
            --ON MCur.MenuCaption=DS1.ParameterName
               ON MCur.MenuId = DS1.ParameterShortName
              LEFT JOIN SysCRisMacMenu MNxt
            --ON MNxt.MenuCaption=DS2.ParameterName
               ON MCur.MenuId = DS2.ParameterShortName
              LEFT JOIN AdvCustNPAdetail_Mod NPA   ON ( NPA.EffectiveFromTimeKey <= v_TimeKey
              AND NPA.EffectiveToTimeKey >= v_TimeKey )
              AND CBD.CustomerEntityId = NPA.CustomerEntityId
        WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                 AND CBD.EffectiveToTimeKey >= v_TimeKey )
                 AND CBD.AuthorisationStatus IN ( 'NP','MP','DP' )


                 --AND CBD.CustType=@CustType  -- CFD
                 AND ( CustomerID = CASE 
                                         WHEN v_CustomerID <> ' ' THEN v_CustomerID
               ELSE CustomerID
                  END )
                 AND ( CustomerName LIKE CASE 
                                              WHEN v_CustomerName <> ' ' THEN '%' || v_CustomerName || '%'
               ELSE CustomerName
                  END )
                 AND ( NVL(BR.BranchCode, ' ') = CASE 
                                                      WHEN v_BranchCode <> ' ' THEN v_BranchCode
               ELSE NVL(BR.BranchCode, ' ')
                  END )
                 AND ( NVL(BranchName, ' ') LIKE CASE 
                                                      WHEN v_BranchName <> ' ' THEN '%' || v_BranchName || '%'
               ELSE NVL(BranchName, ' ')
                  END )
                 AND ( NVL(T.CustomerEntityID, 0) = CASE 
                                                         WHEN v_CustomerAcid <> ' ' THEN CBD.CustomerEntityId
               ELSE NVL(T.CustomerEntityID, 0)
                  END )
                 AND ( NVL(D.CustomerEntityID, 0) = CASE 
                                                         WHEN v_DefendentName <> ' ' THEN CBD.CustomerEntityId
               ELSE NVL(D.CustomerEntityID, 0)
                  END )
                 AND ( UCIF_ID = CASE 
                                      WHEN v_UCICID <> ' ' THEN v_UCICID
               ELSE UCIF_ID
                  END ) );
   DBMS_OUTPUT.PUT_LINE(1111);
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.Customer_Key ,
                        A.CustomerEntityId 
                 FROM CustomerBasicDetail_Mod A
                        JOIN ( SELECT MAX(A.Customer_Key)  Customer_Key  
                               FROM CustomerBasicDetail_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.Customer_Key = A.Customer_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvCustFinancialDetail_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvCustFinancialDetail_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TIMEKEY
                        AND A.EffectiveToTimeKey >= v_TIMEKEY ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvCustNPAdetail_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvCustNPAdetail_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvCustOtherDetail_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvCustOtherDetail_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvCustRelationship_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvCustRelationship_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvCustCommunicationDetail_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvCustCommunicationDetail_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvAcBalanceDetail_mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvAcBalanceDetail_mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityID ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityID ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityID 
                               FROM AdvAcCaseWiseBalanceDetails_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvAcCaseWiseBalanceDetails_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityID ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityID ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvAcFinancialDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvAcFinancialDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityID ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityID ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityID 
                               FROM AdvAcOtherBalanceDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvAcOtherBalanceDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityID ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityID ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvAcOtherDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvAcOtherDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvFacBillDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvFacBillDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvFacCCDetail_mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvFacCCDetail_mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvFacDLDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvFacDLDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvFacNFDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvFacNFDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT D.AuthorisationStatus ,
                        A.Ac_Key ,
                        A.AccountEntityId ,
                        A.CustomerEntityId 
                 FROM AdvAcBasicDetail_mod A
                        JOIN ( SELECT MAX(A.Ac_Key)  Ac_Key  
                               FROM AdvAcBasicDetail_mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.AccountEntityId ) B   ON B.Ac_Key = A.Ac_Key
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey )
                        JOIN ( SELECT A.AuthorisationStatus ,
                                      A.EntityKey ,
                                      A.AccountEntityId 
                               FROM AdvFacPCDetail_Mod A
                                      JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                                             FROM AdvFacPCDetail_Mod A
                                              WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                       AND A.EffectiveToTimeKey >= v_TimeKey )
                                                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                               GROUP BY A.AccountEntityId ) B   ON B.EntityKey = A.EntityKey
                                      AND ( A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) D   ON D.AccountEntityId = A.AccountEntityId ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvSecurityVehicleDetails_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvSecurityVehicleDetails_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   --UPDATE A
   --SET A.AuthorisationStatus= C.AuthorisationStatus
   --FROM tt_PreCaseCustData_3 A
   --INNER JOIN(
   --SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvSecurityValueDetail_Mod A
   --INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvSecurityValueDetail_Mod A
   --            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
   --			     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
   --				 GROUP BY A.CustomerEntityId
   --               ) B  ON B.EntityKey=A.EntityKey AND 
   --			   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
   --		  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvSecuritiesPropertyDetails_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvSecuritiesPropertyDetails_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.CustomerEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, C.AuthorisationStatus
   FROM A ,tt_PreCaseCustData_3 A
          JOIN ( SELECT A.AuthorisationStatus ,
                        A.EntityKey ,
                        A.CustomerEntityId 
                 FROM AdvAcRelations_Mod A
                        JOIN ( SELECT MAX(A.EntityKey)  EntityKey  
                               FROM AdvAcRelations_Mod A
                                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                         AND A.EffectiveToTimeKey >= v_TimeKey )
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                 GROUP BY A.RelationEntityId ) B   ON B.EntityKey = A.EntityKey
                        AND ( A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey ) ) C   ON C.CustomerEntityId = A.CustomerEntityId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = src.AuthorisationStatus;
   IF v_BranchCode = ' ' THEN

   BEGIN
      MERGE INTO T 
      USING (SELECT T.ROWID row_id, CASE 
      WHEN T.BranchCode IS NULL THEN a.BranchCode
      ELSE T.BranchCode
         END AS pos_2, DB.BranchName
      FROM T ,tt_PreCaseCustData_3 T
             JOIN ( SELECT A.CustomerEntityId ,
                           A.BranchCode 
                    FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail a
                           JOIN tt_PreCaseCustData_3 T   ON A.CustomerEntityId = T.CustomerEntityID
                           OR A.BranchCode = T.BranchCode
                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                              AND EffectiveToTimeKey >= v_TimeKey )
                              AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      GROUP BY A.CustomerEntityId,A.BranchCode
                    UNION 
                    SELECT A.CustomerEntityId ,
                           A.BranchCode 
                    FROM AdvAcBasicDetail_mod A
                           JOIN ( SELECT MAX(Ac_Key)  Ac_Key  
                                  FROM AdvAcBasicDetail_mod A
                                   WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                            AND A.EffectiveToTimeKey >= v_TimeKey )
                                            AND A.CustomerACID = v_CustomerAcID
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                    GROUP BY A.CustomerACID ) P   ON P.Ac_Key = A.Ac_Key
                           AND ( A.EffectiveFromTimeKey <= v_TimeKey
                           AND A.EffectiveToTimeKey >= v_TimeKey )
                           JOIN tt_PreCaseCustData_3 T   ON A.CustomerEntityId = T.CustomerEntityID
                           OR A.BranchCode = T.BranchCode ) A   ON A.CustomerEntityId = T.CustomerEntityID
             JOIN DimBranch DB   ON ( DB.EffectiveFromTimeKey <= v_TimeKey
             AND DB.EffectiveToTimeKey >= v_TimeKey )
             AND DB.BranchCode = CASE 
                                      WHEN T.BranchCode IS NULL THEN a.BranchCode
           ELSE T.BranchCode
              END ) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.BranchCode = pos_2,
                                   T.BranchName = src.BranchName;

   END;
   END IF;
   SELECT NVL(UserLocation, ' ') ,
          NVL(UserLocationCode, ' ') 

     INTO v_Location,
          v_LocatationCode
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   IF utils.object_id('Tempdb..tt_TempBrData_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempBrData_8 ';
   END IF;
   DELETE FROM tt_TempBrData_8;
   INSERT INTO tt_TempBrData_8
     ( SELECT BranchCode 
       FROM DimBranch A
        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND v_LocatationCode = CASE 
                                             WHEN v_Location = 'HO' THEN v_LocatationCode
                                             WHEN v_Location = 'ZO' THEN UTILS.CONVERT_TO_VARCHAR2(A.BranchZoneAlt_Key,100)
                                             WHEN v_Location = 'RO' THEN UTILS.CONVERT_TO_VARCHAR2(A.BranchRegionAlt_Key,100)
                                             WHEN v_Location = 'BO' THEN UTILS.CONVERT_TO_VARCHAR2(A.BranchCode,100)   END );
   DELETE FROM tt_BRANCH_3;
   --*******************************************************************************************************************
   --FOR MOC FREEZE Branch Not come in Select Clause For Moc Timekey 
   --Added By Hamid On 31 MAY 2018
   --*******************************************************************************************************************
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_BRANCH_3  --SQLDEV: NOT RECOGNIZED
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM SysDataMatrix 
                       WHERE  Prev_Qtr_key = v_Timekey );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO tt_BRANCH_3
        ( SELECT BranchCode 
          FROM FactBranch_Moc 
           WHERE  TimeKey = v_Timekey
                    AND NVL(ZO_MOC_Frozen, 'N') = 'Y' );

   END;
   END IF;
   --*******************************************************************************************************************
   OPEN  v_cursor FOR
      SELECT A.* ,
             NVL(IsCaseFiled, 'N') IsCaseFiled  
        FROM tt_PreCaseCustData_3 A
               LEFT JOIN ( SELECT CustomerEntityId ,
                                  'Y' IsCaseFiled  
                           FROM SysDataUpdationStatus 
                             GROUP BY CustomerEntityId ) t   ON A.CustomerEntityID = t.CustomerEntityId
       WHERE  A.BranchCode IS NULL
                AND NOT EXISTS ( SELECT B.BranchCode 
                                 FROM tt_BRANCH_3 B
                                  WHERE  A.BranchCode = B.BranchCode )
      UNION 
      SELECT A.* ,
             NVL(IsCaseFiled, 'N') IsCaseFiled  
        FROM tt_PreCaseCustData_3 A
               LEFT JOIN ( SELECT CustomerEntityId ,
                                  'Y' IsCaseFiled  
                           FROM SysDataUpdationStatus 
                             GROUP BY CustomerEntityId ) t   ON A.CustomerEntityID = t.CustomerEntityId
               LEFT JOIN tt_TempBrData_8 BR   ON BR.BranchCode = A.BranchCode
       WHERE  NVL(A.BranchCode, ' ') = CASE 
                                            WHEN v_BranchCode <> ' ' THEN v_BranchCode
              ELSE A.BranchCode
                 END
                AND A.BranchCode IS NOT NULL
                AND ( NVL(A.BranchName, ' ') = CASE 
                                                    WHEN v_BranchName <> ' ' THEN v_BranchName
              ELSE NVL(A.BranchName, ' ')
                 END )
                AND NOT EXISTS ( SELECT B.BranchCode 
                                 FROM tt_BRANCH_3 B
                                  WHERE  A.BranchCode = B.BranchCode ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRECASECUSTOMERDETAILSELECTAUX_06042023" TO "ADF_CDR_RBL_STGDB";
