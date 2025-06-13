--------------------------------------------------------
--  DDL for Procedure SP_DWHBACKUPDAILY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" 
AS
   --Declare @Date date = (select cast(getdate()-2 as date))  
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_of_data 
     FROM DWH_DWH_STG.account_data_finacle  );

BEGIN

   --Declare @Date1 date = (select cast(getdate()-7 as date))  
   DELETE DWH_DWH_STG.customer_data_finacle_backup

    WHERE  date_of_data IN ( v_Date )
   ;
   INSERT INTO DWH_DWH_STG.customer_data_finacle_backup
     ( SELECT * 
       FROM DWH_DWH_STG.customer_data_finacle 
        WHERE  date_of_data IN ( v_Date )
      );/*
   Delete from DWH_STG.DWH.customer_data_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_Backup  
   select *  from DWH_STG.DWH.customer_data where date_of_data in (@Date)  

   Delete from  DWH_STG.DWH.customer_data_visionplus_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_visionplus_Backup  
   select *  from DWH_STG.DWH.customer_data_visionplus where date_of_data in (@Date)  

   Delete from  DWH_STG.DWH.customer_data_ecbf_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_ecbf_Backup  
   select *  from DWH_STG.DWH.customer_data_ecbf where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.customer_data_ganaseva_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_ganaseva_Backup  
   select *  from DWH_STG.DWH.customer_data_ganaseva where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.customer_data_FIS_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_FIS_Backup  
   select *  from DWH_STG.DWH.customer_data_FIS where date_of_data in (@Date) 


   Delete from DWH_STG.DWH.customer_data_mifin_Backup where dateofdata in (@Date)  
   INSERT INTO  DWH_STG.DWH.customer_data_mifin_Backup  
   select *  from DWH_STG.DWH.customer_data_mifin where dateofdata in (@Date)  

   --------------------------

   Delete from [DWH_STG].[DWH].[Customer_data_EIFS_BACKUP] where Date_of_Data in (@Date)  
   INSERT INTO  [DWH_STG].[DWH].[Customer_data_EIFS_BACKUP]  
   select *  from [DWH_STG].[DWH].[Customer_data_EIFS] where Date_of_Data in (@Date) 



   Delete from [DWH_STG].[DWH].[Account_data_EIFS_BACKUP] where Date_of_Data in (@Date)  
   INSERT INTO  [DWH_STG].[DWH].[Account_data_EIFS_BACKUP]  
   select *  from [DWH_STG].[DWH].[Account_data_EIFS] where Date_of_Data in (@Date) 
   ------------------------------------

   Delete from DWH_STG.DWH.account_data_finacle_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.account_data_finacle_Backup  
   select *  from DWH_STG.DWH.account_data_finacle where date_of_data in (@Date)  


   Delete from DWH_STG.DWH.accounts_data_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.accounts_data_Backup  
   select *  from DWH_STG.DWH.accounts_data where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.account_data_visionplus_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.account_data_visionplus_Backup  
   select *  from DWH_STG.DWH.account_data_visionplus where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.accounts_data_ecbf_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.accounts_data_ecbf_Backup  
   select *  from DWH_STG.DWH.accounts_data_ecbf where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.account_data_FIS_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.account_data_FIS_Backup  
   select *  from DWH_STG.DWH.account_data_FIS where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.accounts_data_mifin_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.accounts_data_mifin_Backup  
   select *  from DWH_STG.DWH.accounts_data_mifin where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.collateral_type_master_finacle_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.collateral_type_master_finacle_Backup  
   select * FROM DWH_STG.DWH.collateral_type_master_finacle where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.security_data_ecbf_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.security_data_ecbf_Backup  
   select *  FROM DWH_STG.DWH.security_data_ecbf where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.SECURITY_SOURCESYSTEM02_Backup where dateofdata in (@Date)  
   INSERT INTO  DWH_STG.DWH.SECURITY_SOURCESYSTEM02_Backup  
   select *  FROM DWH_STG.DWH.SECURITY_SOURCESYSTEM02 where dateofdata in (@Date)  

   Delete from DWH_STG.DWH.SECURITY_SOURCESYSTEM04_Backup where dateofdata in (@Date)  
   INSERT INTO  DWH_STG.DWH.SECURITY_SOURCESYSTEM04_Backup  
   select *  FROM DWH_STG.DWH.SECURITY_SOURCESYSTEM04 where dateofdata in (@Date)  

   Delete from DWH_STG.DWH.transaction_data_finacle_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.transaction_data_finacle_Backup  
   select *  FROM DWH_STG.DWH.transaction_data_finacle where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.bills_data_stg_fin_Backup where [Date of Data] in (@Date)  
   INSERT INTO  DWH_STG.DWH.bills_data_stg_fin_Backup  
   select *  FROM DWH_STG.DWH.bills_data_stg_fin where [Date of Data] in (@Date)  

   -------------- START ------------------
   Delete from DWH_STG.DWH.bills_data_stg_scf_Backup where Date_Of_Data in (@Date)  
   INSERT INTO  DWH_STG.DWH.bills_data_stg_scf_Backup  
   select *  FROM DWH_STG.DWH.bills_data_stg_scf where Date_Of_Data in (@Date)  
   --------------- END -------------------

   Delete from DWH_STG.DWH.pca_data_Backup where [Date of Data] in (@Date)  
   INSERT INTO  DWH_STG.DWH.pca_data_Backup  
   select *  FROM DWH_STG.DWH.pca_data where [Date of Data] in (@Date)  

   Delete from DWH_STG.DWH.InvestmentBasicDetail_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.InvestmentBasicDetail_Backup  
   select *  FROM DWH_STG.DWH.InvestmentBasicDetail where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.InvestmentFinancialDetails_Backup where DateofData in (@Date)  
   INSERT INTO  DWH_STG.DWH.InvestmentFinancialDetails_Backup  
   select *  FROM DWH_STG.DWH.InvestmentFinancialDetails where dateofdata in (@Date)  

   Delete from DWH_STG.DWH.InvestmentIssuerDetail_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.InvestmentIssuerDetail_Backup  
   select *  FROM DWH_STG.DWH.InvestmentIssuerDetail where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.Derivative_Cancelled_Backup where dateofdata in (@Date)  
   INSERT INTO  DWH_STG.DWH.Derivative_Cancelled_Backup  
   select *  FROM DWH_STG.DWH.Derivative_Cancelled where dateofdata in (@Date)  

   Delete from DWH_STG.DWH.MIFINGOLDMASTER_Backup where dateofdata in (@Date)  
   INSERT INTO  DWH_STG.DWH.MIFINGOLDMASTER_Backup  
   select *  FROM DWH_STG.DWH.MIFINGOLDMASTER where dateofdata in (@Date)  

   Delete from DWH_STG.DWH.account_data_metagrid_backup where date_of_data in (@Date)    
   INSERT INTO  DWH_STG.DWH.account_data_metagrid_backup    
   select *  FROM DWH_STG.DWH.account_data_metagrid where date_of_data in (@Date) 

   Delete from DWH_STG.DWH.customer_data_metagrid_backup where date_of_data in (@Date)    
   INSERT INTO  DWH_STG.DWH.customer_data_metagrid_backup    
   select *  FROM DWH_STG.DWH.customer_data_metagrid where date_of_data in (@Date) 

   Delete from DWH_STG.DWH.security_data_metagrid_backup where date_of_data in (@Date)    
   INSERT INTO  DWH_STG.DWH.security_data_metagrid_backup    
   select *  FROM DWH_STG.DWH.security_data_metagrid where date_of_data in (@Date) 


   Delete from DWH_STG.DWH.Metagrid_Account_Master_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.Metagrid_Account_Master_Backup  
   select *  FROM DWH_STG.DWH.Metagrid_Account_Master where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.Metagrid_Customer_Master_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.Metagrid_Customer_Master_Backup  
   select *  FROM DWH_STG.DWH.Metagrid_Customer_Master where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.Metagrid_Security_Backup where date_of_data in (@Date)  
   INSERT INTO  DWH_STG.DWH.Metagrid_Security_Backup  
   select *  FROM DWH_STG.DWH.Metagrid_Security where date_of_data in (@Date)  


   Delete from DWH_STG.DWH.gsh_Backup where dt in (@Date)  
   INSERT INTO  DWH_STG.DWH.gsh_Backup  
   select *  from DWH_STG.DWH.gsh where dt in (@Date)  


   Delete from DWH_STG.DWH.reversefeed_calypso_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.reversefeed_calypso_backup 
   select *  from DWH_STG.DWH.reversefeed_calypso where date_of_data in (@Date)  

   Delete from DWH_STG.DWH.product_code_master_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_backup  (product_code,	scheme_description,	date_of_data,	CreatedDate)
   select product_code,	scheme_description,	@Date,	getdate()  from DWH_STG.DWH.product_code_master  

   Delete from DWH_STG.DWH.product_code_master_finacle_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_finacle_backup (schm_code,	del_flg,	schm_desc,	syst_gen_acct_num_flg,	acct_prefix,	next_acct_num_prefix,	acct_opn_form_name,	acct_cls_form_name,	int_paid_bacid,	int_coll_bacid,	serv_chrg_bacid,	turnover_freq_type,	turnover_freq_week_num,	turnover_freq_week_day,	turnover_freq_start_dd,	turnover_hldy_stat,	turnover_rcre_date,	gl_sub_head_code,	tran_rpt_code_flg,	tran_ref_num_flg,	chq_alwd_flg,	acct_turnover_det_flg,	schm_supr_user_id,	tot_mod_times,	serv_chrg_coll_flg,	back_date_tran_excp_code,	val_date_tran_excp_code,	invalid_instrmnt_excp_code,	stale_instrmnt_excp_code,	acct_frez_excp_code,	acct_in_dr_bal_excp_code,	acct_in_cr_bal_excp_code,	chq_stop_excp_code,	chq_cautn_excp_code,	chq_not_issu_excp_code,	invalid_rpt_code_excp_code,	clg_tran_excp_code,	cash_tran_excp_code,	xfer_tran_excp_code,	emp_own_acct_excp_code,	override_def_excp_code,	introd_not_cust_excp_code,	introd_new_cust_excp_code,	chq_not_alwd_excp_code,	si_pre_fix_chrg_excp_code,	dr_against_cc_excp_code,	cls_pend_int_excp_code,	cls_pend_si_excp_code,	cls_pend_cc_excp_code,	cls_pend_chq_excp_code,	acct_opn_matrix_excp_code,	memo_pad_exists_excp_code,	sanct_lim_exp_excp_code,	sanct_exceed_lim_excp_code,	liab_exceed_group_lim_excp,	acct_maint_form_name,	ofti_schm_rtn_name,	minor_chq_issu_excp_code,	new_acct_duration,	dorm_acct_criteria,	min_posting_workclass,	schm_type,	int_paid_flg,	int_coll_flg,	staff_schm_flg,	nre_schm_flg,	merge_int_ptran_flg,	lchg_user_id,	rcre_user_id,	lchg_time,	rcre_time,	micr_chq_chrg_bacid,	insuff_avail_bal_excp_code,	fd_cr_bacid,	fd_dr_bacid,	fx_tran_flg,	stp_cr_dr_ind,	fcnr_flg,	int_pandl_bacid,	parking_bacid,	int_paid_coll_crncy_flg,	cash_wd_wo_chq_excp_code,	acct_name_changed_excp_code,	xfer_in_int_details_flg,	acct_reference_excp_code,	dr_oper_acct_if_no_bal_flg,	int_dr_cust_diff_excp_code,	int_cr_cust_diff_excp_code,	iso_user_tod_grnt_excp_code,	iso_auto_tod_grnt_excp_code,	inter_sol_closure_alwd_flg,	levy_tax_pcnt_1,	levy_tax_pcnt_2,	levy_tax_pcnt_3,	levy_tax_desc_1,	levy_tax_desc_2,	levy_tax_desc_3,	levy_tax_bacid_1,	levy_tax_bacid_2,	levy_tax_bacid_3,	levy_tax_merge_ptran_flg,	peg_int_for_ac_flg,	mod_of_peg_int_allowed_flg,	peg_review_pref_from_cust,	dflt_int_par_chng_excp_code,	cls_pend_reversal_excp_code,	chq_issued_ack_excp_code,	acct_closure_chrg_days,	acct_closure_chrg_mnths,	acct_maint_period,	min_commit_chrg_util_pcnt,	commit_calc_method,	inactive_acct_chrg_days,	inactive_acct_chrg_mnths,	dormant_acct_chrg_days,	dormant_acct_chrg_mnths,	partition_mandatory_flg,	book_tran_script,	intcalc_tran_script,	advance_int_bacid,	tds_parking_bacid,	penal_pandl_bacid,	dflt_clg_tran_code,	dflt_inst_type,	chq_unusable_excp_code,	int_pandl_bacid_cr,	int_pandl_bacid_dr,	bel_min_bal_excp_code,	pen_chrg_ncalc_excp_code,	int_freq_type_cr,	int_freq_week_num_cr,	int_freq_week_day_cr,	int_freq_start_dd_cr,	int_freq_hldy_stat_cr,	int_freq_type_dr,	int_freq_week_num_dr,	int_freq_week_day_dr,	int_freq_start_dd_dr,	int_freq_hldy_stat_dr,	pd_gl_sub_head_code,	pd_int_calc_excp_code,	pd_dr_tran_excp_code,	lim_level_int_flg,	eefc_flg,	ts_cnt,	cs_schm_mesg1,	cs_schm_mesg2,	ps_freq_type,	ps_freq_week_num,	ps_freq_week_day,	ps_freq_start_dd,	ps_freq_hldy_stat,	auto_renewal_period_flg,	product_group,	principal_lossline_bacid,	recover_lossline_bacid,	chrge_off_bacid,	dealer_contr_bacid,	int_waiver_bacid,	daily_comp_int_flg,	qis_int_flg,	stock_int_flg,	unverified_spp_excp_code,	ovdu_int_paid_bacid,	ovdu_int_pandl_bacid_cr,	comp_date_flg,	disc_rate_flg,	start_date,	end_date,	set_id,	cs_schm_natl_mesg1,	cs_schm_natl_mesg2,	stp_dr_int_recalc,	stp_cr_int_recalc,	fixedterm_mnths,	fixedterm_years,	repricing_plan,	repricing_freq_mnths,	repricing_freq_days,	repricing_year_ind,	float_int_tbl_code,	repricing_excp_code,	float_repricing_freq_mnths,	float_repricing_freq_days,	script_value_date_excp_code,	cust_min_age,	cust_max_age,	age_range_excp_code,	schm_short_name,	pref_lang_code,	pref_lang_schm_desc,	pref_lang_schm_short_name,	tenor_ind_flg,	rule_code,	secured_flg,	lookback_perd_for_pastdue,	bank_id,	negative_lien_excp_code,	chq_reject_excp_code,	pen_coll_flg,	syn_agent_scheme,	pen_coll_bacid,	product_concept,	acct_linked_invt_id_excp_code,	penal_int_coll_bacid,	past_due_int_coll_bacid,	past_due_penal_int_coll_bacid,	schm_nature,	ps_freq_cal_base,	additional_cal_base,	int_freq_cal_base_cr,	int_freq_cal_base_dr,	mud_pool_prod_flg,	alt1_schm_short_name,	alt1_schm_desc,	product_srl_num,	product_id,	islamic_product_type,	product_type,	int_compounding_frq_cr,	int_compounding_rest_flg_cr,	disc_rate_flg_cr,	konformna_flg,	overide_def_min_bal_param_excp,	chq_prov_by_bank_flg,	product_code,	int_freq_months_dr,	int_freq_days_dr,	nr_schm_type,	date_of_data,	CreatedDate) 
   select schm_code,	del_flg,	schm_desc,	syst_gen_acct_num_flg,	acct_prefix,	next_acct_num_prefix,	acct_opn_form_name,	acct_cls_form_name,	int_paid_bacid,	int_coll_bacid,	serv_chrg_bacid,	turnover_freq_type,	turnover_freq_week_num,	turnover_freq_week_day,	turnover_freq_start_dd,	turnover_hldy_stat,	turnover_rcre_date,	gl_sub_head_code,	tran_rpt_code_flg,	tran_ref_num_flg,	chq_alwd_flg,	acct_turnover_det_flg,	schm_supr_user_id,	tot_mod_times,	serv_chrg_coll_flg,	back_date_tran_excp_code,	val_date_tran_excp_code,	invalid_instrmnt_excp_code,	stale_instrmnt_excp_code,	acct_frez_excp_code,	acct_in_dr_bal_excp_code,	acct_in_cr_bal_excp_code,	chq_stop_excp_code,	chq_cautn_excp_code,	chq_not_issu_excp_code,	invalid_rpt_code_excp_code,	clg_tran_excp_code,	cash_tran_excp_code,	xfer_tran_excp_code,	emp_own_acct_excp_code,	override_def_excp_code,	introd_not_cust_excp_code,	introd_new_cust_excp_code,	chq_not_alwd_excp_code,	si_pre_fix_chrg_excp_code,	dr_against_cc_excp_code,	cls_pend_int_excp_code,	cls_pend_si_excp_code,	cls_pend_cc_excp_code,	cls_pend_chq_excp_code,	acct_opn_matrix_excp_code,	memo_pad_exists_excp_code,	sanct_lim_exp_excp_code,	sanct_exceed_lim_excp_code,	liab_exceed_group_lim_excp,	acct_maint_form_name,	ofti_schm_rtn_name,	minor_chq_issu_excp_code,	new_acct_duration,	dorm_acct_criteria,	min_posting_workclass,	schm_type,	int_paid_flg,	int_coll_flg,	staff_schm_flg,	nre_schm_flg,	merge_int_ptran_flg,	lchg_user_id,	rcre_user_id,	lchg_time,	rcre_time,	micr_chq_chrg_bacid,	insuff_avail_bal_excp_code,	fd_cr_bacid,	fd_dr_bacid,	fx_tran_flg,	stp_cr_dr_ind,	fcnr_flg,	int_pandl_bacid,	parking_bacid,	int_paid_coll_crncy_flg,	cash_wd_wo_chq_excp_code,	acct_name_changed_excp_code,	xfer_in_int_details_flg,	acct_reference_excp_code,	dr_oper_acct_if_no_bal_flg,	int_dr_cust_diff_excp_code,	int_cr_cust_diff_excp_code,	iso_user_tod_grnt_excp_code,	iso_auto_tod_grnt_excp_code,	inter_sol_closure_alwd_flg,	levy_tax_pcnt_1,	levy_tax_pcnt_2,	levy_tax_pcnt_3,	levy_tax_desc_1,	levy_tax_desc_2,	levy_tax_desc_3,	levy_tax_bacid_1,	levy_tax_bacid_2,	levy_tax_bacid_3,	levy_tax_merge_ptran_flg,	peg_int_for_ac_flg,	mod_of_peg_int_allowed_flg,	peg_review_pref_from_cust,	dflt_int_par_chng_excp_code,	cls_pend_reversal_excp_code,	chq_issued_ack_excp_code,	acct_closure_chrg_days,	acct_closure_chrg_mnths,	acct_maint_period,	min_commit_chrg_util_pcnt,	commit_calc_method,	inactive_acct_chrg_days,	inactive_acct_chrg_mnths,	dormant_acct_chrg_days,	dormant_acct_chrg_mnths,	partition_mandatory_flg,	book_tran_script,	intcalc_tran_script,	advance_int_bacid,	tds_parking_bacid,	penal_pandl_bacid,	dflt_clg_tran_code,	dflt_inst_type,	chq_unusable_excp_code,	int_pandl_bacid_cr,	int_pandl_bacid_dr,	bel_min_bal_excp_code,	pen_chrg_ncalc_excp_code,	int_freq_type_cr,	int_freq_week_num_cr,	int_freq_week_day_cr,	int_freq_start_dd_cr,	int_freq_hldy_stat_cr,	int_freq_type_dr,	int_freq_week_num_dr,	int_freq_week_day_dr,	int_freq_start_dd_dr,	int_freq_hldy_stat_dr,	pd_gl_sub_head_code,	pd_int_calc_excp_code,	pd_dr_tran_excp_code,	lim_level_int_flg,	eefc_flg,	ts_cnt,	cs_schm_mesg1,	cs_schm_mesg2,	ps_freq_type,	ps_freq_week_num,	ps_freq_week_day,	ps_freq_start_dd,	ps_freq_hldy_stat,	auto_renewal_period_flg,	product_group,	principal_lossline_bacid,	recover_lossline_bacid,	chrge_off_bacid,	dealer_contr_bacid,	int_waiver_bacid,	daily_comp_int_flg,	qis_int_flg,	stock_int_flg,	unverified_spp_excp_code,	ovdu_int_paid_bacid,	ovdu_int_pandl_bacid_cr,	comp_date_flg,	disc_rate_flg,	start_date,	end_date,	set_id,	cs_schm_natl_mesg1,	cs_schm_natl_mesg2,	stp_dr_int_recalc,	stp_cr_int_recalc,	fixedterm_mnths,	fixedterm_years,	repricing_plan,	repricing_freq_mnths,	repricing_freq_days,	repricing_year_ind,	float_int_tbl_code,	repricing_excp_code,	float_repricing_freq_mnths,	float_repricing_freq_days,	script_value_date_excp_code,	cust_min_age,	cust_max_age,	age_range_excp_code,	schm_short_name,	pref_lang_code,	pref_lang_schm_desc,	pref_lang_schm_short_name,	tenor_ind_flg,	rule_code,	secured_flg,	lookback_perd_for_pastdue,	bank_id,	negative_lien_excp_code,	chq_reject_excp_code,	pen_coll_flg,	syn_agent_scheme,	pen_coll_bacid,	product_concept,	acct_linked_invt_id_excp_code,	penal_int_coll_bacid,	past_due_int_coll_bacid,	past_due_penal_int_coll_bacid,	schm_nature,	ps_freq_cal_base,	additional_cal_base,	int_freq_cal_base_cr,	int_freq_cal_base_dr,	mud_pool_prod_flg,	alt1_schm_short_name,	alt1_schm_desc,	product_srl_num,	product_id,	islamic_product_type,	product_type,	int_compounding_frq_cr,	int_compounding_rest_flg_cr,	disc_rate_flg_cr,	konformna_flg,	overide_def_min_bal_param_excp,	chq_prov_by_bank_flg,	product_code,	int_freq_months_dr,	int_freq_days_dr,	nr_schm_type,	@Date,	getdate()  from DWH_STG.DWH.product_code_master_finacle  

   Delete from DWH_STG.DWH.product_code_master_ganaseva_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_ganaseva_backup(source,	scheme_code,	scheme_Desc,	date_of_data,	CreatedDate)
   select source,	scheme_code,	scheme_Desc,	@Date,	getdate()  from DWH_STG.DWH.product_code_master_ganaseva  

   Delete from DWH_STG.DWH.product_code_master_FIS_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_FIS_backup(source,	scheme_code,	scheme_Desc,	date_of_data,	CreatedDate)
   select source,	scheme_code,	scheme_Desc,	@Date,	getdate()  from DWH_STG.DWH.product_code_master_FIS 

   Delete from DWH_STG.DWH.product_code_master_mifin_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_mifin_backup (producttype,	product_code,	product_description,	date_of_data,	CreatedDate)  
   select producttype,	product_code,	product_description,	@Date,	getdate()  from DWH_STG.DWH.product_code_master_mifin  

   Delete from DWH_STG.DWH.product_code_master_visionplus_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_code_master_visionplus_backup(logo,	Product_Name,	pdt_cat1,	date_of_data,	CreatedDate) 
   select logo,	Product_Name,	pdt_cat1,	@Date,	getdate()  from DWH_STG.DWH.product_code_master_visionplus  

   Delete from DWH_STG.DWH.product_master_ecbf_backup where date_of_data in (@Date)  
   INSERT INTO DWH_STG.DWH.product_master_ecbf_backup (producttype,	product_code,	product_description,	date_of_data,	CreatedDate)
   select producttype,	product_code,	product_description,	@Date,	getdate() from DWH_STG.DWH.product_master_ecbf  
     */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_DWHBACKUPDAILY" TO "ADF_CDR_RBL_STGDB";
