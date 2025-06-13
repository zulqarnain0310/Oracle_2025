--------------------------------------------------------
--  DDL for Procedure PROVISIONCOMPUTATIONREPORT_RDM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" 
AS
   v_Date VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200) 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  Date_ = v_Date );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Date_ = v_Date )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   ----select @LastQtrDateKey
   --select * from sysdaymatrix where timekey=26383
   --IF(OBJECT_ID('TEMPDB..#PrevQtrData')is not null)
   --drop table  #PrevQtrData
   --SELECT  ACCOUNTENTITYID
   --       ,CUSTOMERACID
   --	   ,SecuredAmt
   --	   ,UnSecuredAmt
   --	   ,TotalProvision
   --	   ,Provsecured
   --	   ,ProvUnsecured
   --	   ,Addlprovision
   --	   ,NetBalance
   --	   ,FinalAssetClassAlt_Key----,*
   --into #PrevQtrData 
   ------MAX(EffectiveToTimeKey)
   --FROM PRO.ACCOUNTCAL_HIST
   --WHERE EffectiveFromTimeKey<=@LastQtrDateKey 
   --AND  EffectiveToTimeKey>=@LastQtrDateKey
   --option(recompile)
   ------select @LastQtrDateKey
   --------------------------------------------------------------------------
   --IF OBJECT_ID('TEMPDB..#ProvisonComputation_Report') IS NOT NULL
   --		DROP TABLE #ProvisonComputation_Report
   --Truncate table ProvisonComputation_Report
   --Insert into ProvisonComputation_Report
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CIF_ID  ,
             REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
             --,B.BranchCode as [Branch Code]
             --,REPLACE(BranchName,',','') as  [Branch Name]
             B.CustomerAcID Account_No_  ,
             SourceName Source_System  ,
             --,B.FacilityType as [Facility]
             SchemeType Scheme_Type  ,
             B.ProductCode Scheme_Code  ,
             ProductName Scheme_Description  ,
             --,CASE WHEN B.SecApp ='S' THEN 'SECURED' ELSE 'UNSECURED'  END [Secured/Unsecured]
             ActSegmentCode Seg_Code  ,
             (CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END) Segment_Description  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             --,DPD_Max as [Account DPD]
             ----,CD [Cycle Past due]
             FinalNpaDt NPA_Date  ,
             --,A2.AssetClassName as [Asset Classification]
             --,REFPERIODOVERDUE [NPA Norms]  --NPANorms as [NPA Norms] 
             B.NetBalance Balance_Outstanding  

        --,CurntQtrRv [Customer Security Value]

        -------,SecurityValue as [Account Security Value]   -- TO BE REMOVED

        --,ApprRV as [Security Value Appropriated]

        --,B.SecuredAmt as [Secured Outstanding]

        --,B.UnSecuredAmt as [Unsecured Outstanding]

        --,B.TotalProvision as [Provision Total]

        --,B.Provsecured as [Provision Secured]

        --,B.ProvUnsecured as [Provision Unsecured]

        --,ISNULL((B.NetBalance-B.TotalProvision),0)[Net NPA]

        --,cast((ISNULL((B.Provsecured/NULLIF(B.SecuredAmt,0))*100,0)) as decimal(5,2)) [ProvisionSecured%]

        --,cast((ISNULL((B.ProvUnsecured/NULLIF(B.UnSecuredAmt,0))*100,0))  as decimal(5,2)) [ProvisionUnSecured%]

        --,cast((ISNULL((B.TotalProvision/NULLIF(B.NetBalance,0))*100,0))  as decimal(5,2)) [ProvisionTotal%]

        --,ISNULL(y.NetBalance,0) [Prev. Qtr. Balance Outstanding]

        --,ISNULL(y.SecuredAmt,0)	[Prev. Qtr. Secured Outstanding],

        --ISNULL(y.UnSecuredAmt,0)	[Prev. Qtr. Unsecured Outstanding],

        --ISNULL(y.TotalProvision,0)	[Prev. Qtr.Provision Total],

        --ISNULL(y.Provsecured,0)	[Prev. Qtr.Provision Secured]

        --,ISNULL(y.ProvUnsecured,0)	[Prev. Qtr. Provision Unsecured]

        --,ISNULL(y.NetNPA,0)	[Prev. Qtr. Net NPA]

        ----,CASE WHEN ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) < 0 

        ----			then 0 

        ----		ELSE ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) 

        ----	END NPAIncrease

        ----,CASE WHEN ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) >= 0 then 0 

        ----ELSE ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) END NPADecrease

        ----,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) < 0 then 0 

        ----ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionIncrease

        ----,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) >= 0 then 0 

        ----ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionDecrease

        ----,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - y.NetNPA),0) < 0 then 0 

        ----ELSE ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) END NetNPAIncrease

        ----,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) >= 0 then 0 ELSE ISNULL(((B.NetBalance-B.TotalProvision) - ISNULL(y.NetNPA,0)),0) END NetNPAnDecrease

        ------ADDED ON 26/03/2022

        --,B.AccountBlkCode2 'Block Code V+'

        --,B.Addlprovision 'Additional Provision'

        --,EXPS.StatusType

        ---------PREV QTR DATA

        --,A3.AssetClassName as [PREV QTR Asset Classification]

        --,PREV.Addlprovision 'PREV QTR Additional Provision'

        --,cast((ISNULL((PREV.Provsecured/NULLIF(PREV.SecuredAmt,0))*100,0)) as decimal(5,2)) [PREV. QTR ProvisionSecured%]

        --,cast((ISNULL((PREV.ProvUnsecured/NULLIF(PREV.UnSecuredAmt,0))*100,0))  as decimal(5,2)) [PREV.QTR ProvisionUnSecured%]

        --,cast((ISNULL((PREV.TotalProvision/NULLIF(PREV.NetBalance,0))*100,0))  as decimal(5,2)) [PREV. QTR ProvisionTotal%]

        --,Dimp.ParameterName   TypeofRestructuring

        --,CASE WHEN isnull(A.FlgErosion,'') <> 'Y' Then NULL ELSE 

        --(CASE WHEN A.SysAssetClassAlt_Key=6 then 'Erosion Loss' ELSE 'Erosion D_1' END)END [Erosion Testing]

        --INTO #ProvisonComputation_Report
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(B.WriteOffAmount, 0) = 0
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               AND ( src.EffectiveFromTimeKey <= v_TimeKey
               AND src.EffectiveToTimeKey >= v_TimeKey )
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
             --left join DimAssetClass a1
              --	on a1.EffectiveToTimeKey=49999
              --	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
              --left join DimAssetClass a2
              --	on a2.EffectiveToTimeKey=49999
              --	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key

               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999

      --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999

      --LEFT JOIN (

      --select A. CustomerEntityID,B.AccountEntityID,NetBalance,SecuredAmt,UnSecuredAmt,TotalProvision,Provsecured,ProvUnsecured,(NetBalance-totalprovision)NetNPA

      --FROM PRO.CustomerCal_Hist A with (nolock)

      --INNER JOIN PRO.AccountCal_Hist B with (nolock)

      --	ON A.CustomerEntityID=B.CustomerEntityID --AND a.EffectiveFromTimeKey = b.EffectiveFromTimeKey

      --	WHERE B.EffectiveFromTimeKey <= @LastQtrDateKey AND b.EffectiveToTimeKey >=  @LastQtrDateKey and

      --	B.FinalAssetClassAlt_Key>1 and A.EffectiveFromTimeKey <= @LastQtrDateKey AND A.EffectiveToTimeKey >=  @LastQtrDateKey )Y 

      --	ON B.AccountEntityID = Y.AccountEntityID

      --left join #PrevQtrData   prev            on B.ACCOUNTENTITYID=PREV.ACCOUNTENTITYID

      --left join DimAssetClass a3          	on a3.EffectiveToTimeKey=49999

      --	                                       and a3.AssetClassAlt_Key=prev.FinalAssetClassAlt_Key

      --LEFT JOIN ADVACRESTRUCTUREDETAIL RES ON RES.AccountEntityId=B.AccountEntityId  

      --                           and RES.EffectiveFromTimeKey<=@Timekey and RES.EffectiveToTimeKey>=@Timekey  

      --left join  (select ParameterAlt_Key ,ParameterName  

      --                  From Dimparameter where DimParameterName = 'TypeofRestructuring'   

      --      and EffectiveFromTimeKey<=@Timekey and  EffectiveToTimeKey>=@Timekey)DIMP  

      --      ON DIMP.ParameterAlt_Key=RES.RestructureTypeAlt_Key  

      --LEFT JOIN   (

      --select distinct SourceAlt_Key,CustomerID,ACID,EffectiveToTimeKey,STUFF((SELECT ', ' + B.StatusType

      --from ExceptionFinalStatusType B

      --where B.EffectiveToTimeKey = 49999 and B.ACID = A.ACID

      --Order BY B.ACID

      --FOR XML PATH('')),1,1,'') as StatusType

      --from ExceptionFinalStatusType A  where A.EffectiveToTimeKey=49999) 

      --EXPS    ON EXPS.ACID=B.CustomerAcID  AND EXPS.EffectiveToTimeKey=49999
      WHERE  B.FinalAssetClassAlt_Key > 1
        ORDER BY "Account No." ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--SELECT * FROM ProvisonComputation_Report

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_RDM" TO "ADF_CDR_RBL_STGDB";
