--------------------------------------------------------
--  DDL for Procedure ADHOCASSETCLASSQUICKSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" /****** Object:  StoredProcedure [dbo].[ADHOCASSETCLASSQuickSearchList]    Script Date: 11-12-2021 14:56:45 ******/
(
  --declare
  v_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  v_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_newPage IN NUMBER DEFAULT 1 ,
  v_pageSize IN NUMBER DEFAULT 30000 
)
AS
   v_Timekey NUMBER(10,0);
   v_PageFrom NUMBER(10,0);
   v_PageTo NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   v_PageFrom := (v_pageSize * v_newPage) - (v_pageSize) + 1 ;
   v_PageTo := v_pageSize * v_newPage ;
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 19/08/2023 ----------------
   IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
    ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
      ACLProcessStatusCheck() ;

   END;
   END IF;
   IF ( ( v_CustomerId = ' '
     OR ( v_CustomerId IS NULL ) )
     AND ( v_UCICID = ' '
     OR ( v_UCICID IS NULL ) )
     AND ( v_operationflag NOT IN ( 16,20 )
    ) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('111');
      OPEN  v_cursor FOR
         SELECT A.CustomerID CustomerId  ,
                CH.CustomerName ,
                A.UCIF_ID UCICID  ,
                CASE 
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                      THEN 'MP'
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                      THEN '1A'
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                      THEN 'A'
                ELSE 'No MOC Done'
                   END AuthorisationStatus  ,
                CASE 
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                      THEN '1st Approval Pending'
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                      THEN '2nd Approval Pending'
                     WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                      THEN 'Authorised'
                ELSE 'No MOC Done'
                   END AuthorisationStatusDesc  ,
                'CustomerLevel' TableName  ,
                A.CreatedBy ,
                A.DateCreated ,
                A.ApprovedBy ,
                A.DateApproved ,
                A.ModifyBy ,
                A.DateModified ,
                A.FirstLevelApprovedBy ,
                A.FirstLevelDateApproved ,
                ' ' ChangeFields  
           FROM AdhocACL_ChangeDetails A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail CH   ON A.CustomerID = CH.CustomerID
                  AND CH.EffectiveFromTimeKey <= v_Timekey
                  AND CH.EffectiveToTimeKey >= v_Timekey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'A' )

         UNION 
         SELECT DISTINCT A.CustomerID CustomerId  ,
                         CH.CustomerName ,
                         A.UCIF_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN 'MP'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '1A'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'A'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatusDesc  ,
                         'CustomerLevel' TableName  ,
                         A.CreatedBy ,
                         A.DateCreated ,
                         A.ApprovedBy ,
                         A.DateApproved ,
                         A.ModifyBy ,
                         A.DateModified ,
                         --,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
                         --,IsNull(A.DateModified,A.DateCreated)as CrModDate
                         --,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
                         --,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
                         --,ISNULL(A.FirstLevelApprovedBy,A.ModifyBy) as ModAppBy
                         --,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
                         A.FirstLevelApprovedBy ,
                         A.FirstLevelDateApproved ,
                         A.ChangeFields 
           FROM AdhocACL_ChangeDetails_Mod A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail CH   ON A.CustomerID = CH.CustomerID
                  AND CH.EffectiveFromTimeKey <= v_Timekey
                  AND CH.EffectiveToTimeKey >= v_Timekey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT DISTINCT A.CUSTOMERid CustomerId  ,
                         A.CustomerName ,
                         A.UCIF_ID UCICID  ,
                         CASE 
                              WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN 'MP'
                              WHEN NVL(B.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '1A'
                              WHEN NVL(B.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'A'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatusDesc  ,
                         'CustomerLevel' TableName  ,
                         --,Z.CreatedBy 
                         --,Z.DateCreated
                         --	,Z.ApprovedBy
                         --	,Z.DateApproved
                         --	,Z.ModifyBy
                         --	,Z.DateModified
                         --	,Z.FirstLevelApprovedBy
                         --	,Z.FirstLevelDateApproved
                         NVL(B.ModifyBy, B.CreatedBy) CrModBy  ,
                         NVL(B.DateModified, B.DateCreated) CrModDate  ,
                         NVL(B.FirstLevelApprovedBy, B.CreatedBy) CrAppBy  ,
                         NVL(B.FirstLevelDateApproved, B.DateCreated) CrAppDate  ,
                         NVL(B.FirstLevelApprovedBy, B.ModifyBy) ModAppBy  ,
                         NVL(B.FirstLevelDateApproved, B.DateModified) ModAppDate  ,
                         B.ChangeFields 
           FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail A
                  LEFT JOIN AdhocACL_ChangeDetails_Mod B   ON A.CUSTOMERid = B.CustomerId
                  AND B.EffectiveFromTimeKey <= v_Timekey
                  AND B.EffectiveToTimeKey >= v_Timekey
                  AND B.AuthorisationStatus IN ( 'MP','NP','1A','A' )

          WHERE  ( ( A.CUSTOMERid = v_CustomerId )
                   OR ( A.UCIF_ID = v_UCICID ) )
                   AND A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND v_OperationFlag NOT IN ( 16,17,20 )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 16 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT DISTINCT A.CustomerId CustomerId  ,
                         CH.CustomerName ,
                         A.UCIF_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN 'MP'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '1A'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'A'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatusDesc  ,
                         'CustomerLevel' TableName  ,
                         NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                         NVL(A.DateModified, A.DateCreated) CrModDate  ,
                         NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                         NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                         NVL(A.FirstLevelApprovedBy, A.ModifyBy) ModAppBy  ,
                         NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                         A.FirstLevelApprovedBy ,
                         A.FirstLevelDateApproved ,
                         A.ChangeFields 
           FROM AdhocACL_ChangeDetails_Mod A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail CH   ON A.CustomerId = CH.CustomerID
                  AND CH.EffectiveFromTimeKey <= v_Timekey
                  AND CH.EffectiveToTimeKey >= v_Timekey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT DISTINCT A.CustomerId CustomerId  ,
                         CH.CustomerName ,
                         A.UCIF_ID UCICID  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN 'MP'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '1A'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'A'
                         ELSE 'No MOC Done'
                            END AuthorisationStatus  ,
                         CASE 
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'MP','NP' )
                               THEN '1st Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( '1A' )
                               THEN '2nd Approval Pending'
                              WHEN NVL(A.AuthorisationStatus, ' ') IN ( 'A' )
                               THEN 'Authorised'
                         ELSE 'No MOC Done'
                            END AuthorisationStatusDesc  ,
                         'CustomerLevel' TableName  ,
                         NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                         NVL(A.DateModified, A.DateCreated) CrModDate  ,
                         NVL(A.FirstLevelApprovedBy, A.CreatedBy) CrAppBy  ,
                         NVL(A.FirstLevelDateApproved, A.DateCreated) CrAppDate  ,
                         NVL(A.FirstLevelApprovedBy, A.ModifyBy) ModAppBy  ,
                         NVL(A.FirstLevelDateApproved, A.DateModified) ModAppDate  ,
                         A.FirstLevelApprovedBy ,
                         A.FirstLevelDateApproved ,
                         A.ChangeFields 
           FROM AdhocACL_ChangeDetails_Mod A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail CH   ON A.CustomerId = CH.CustomerID
                  AND CH.EffectiveFromTimeKey <= v_Timekey
                  AND CH.EffectiveToTimeKey >= v_Timekey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
