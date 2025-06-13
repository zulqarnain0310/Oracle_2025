--------------------------------------------------------
--  DDL for Procedure SP_LOADBACKUPDATAINDWHMAIN_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" 
(
  iv_Date IN VARCHAR2
)
AS
   v_Date VARCHAR2(10) := iv_Date;

BEGIN

   v_Date := UTILS.CONVERT_TO_VARCHAR2(v_Date,200,p_style=>103) ;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_finacle ';
   INSERT INTO dwh_DWH_STG.customer_data_finacle
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_finacle_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data ';
   INSERT INTO dwh_DWH_STG.customer_data
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_visionplus ';
   INSERT INTO dwh_DWH_STG.customer_data_visionplus
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_visionplus_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_ecbf ';
   INSERT INTO dwh_DWH_STG.customer_data_ecbf
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_ecbf_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_ganaseva ';
   INSERT INTO dwh_DWH_STG.customer_data_ganaseva
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_ganaseva_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_FIS ';
   INSERT INTO dwh_DWH_STG.customer_data_FIS
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_FIS_Backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_mifin ';
   INSERT INTO dwh_DWH_STG.customer_data_mifin
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_mifin_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Customer_Data_EIFS ';
   INSERT INTO dwh_DWH_STG.Customer_Data_EIFS
     ( SELECT * 
       FROM dwh_DWH_STG.Customer_data_EIFS_BACKUP 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Account_data_EIFS ';
   INSERT INTO dwh_DWH_STG.Account_data_EIFS
     ( SELECT * 
       FROM dwh_DWH_STG.Account_data_EIFS_BACKUP 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.account_data_finacle ';
   INSERT INTO dwh_DWH_STG.account_data_finacle
     ( SELECT * 
       FROM dwh_DWH_STG.account_data_finacle_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.accounts_data ';
   INSERT INTO dwh_DWH_STG.accounts_data
     ( SELECT * 
       FROM dwh_DWH_STG.accounts_data_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.account_data_visionplus ';
   INSERT INTO dwh_DWH_STG.account_data_visionplus
     ( SELECT * 
       FROM dwh_DWH_STG.account_data_visionplus_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.accounts_data_ecbf ';
   INSERT INTO dwh_DWH_STG.accounts_data_ecbf
     ( SELECT * 
       FROM dwh_DWH_STG.accounts_data_ecbf_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.account_data_ganaseva ';
   INSERT INTO dwh_DWH_STG.account_data_ganaseva
     ( SELECT * 
       FROM dwh_DWH_STG.account_data_ganaseva_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.account_data_FIS ';
   INSERT INTO dwh_DWH_STG.account_data_FIS
     ( SELECT * 
       FROM dwh_DWH_STG.account_data_FIS_Backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.accounts_data_mifin ';
   INSERT INTO dwh_DWH_STG.accounts_data_mifin
     ( SELECT * 
       FROM dwh_DWH_STG.accounts_data_mifin_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.collateral_type_master_finacle ';
   INSERT INTO dwh_DWH_STG.collateral_type_master_finacle
     ( SELECT * 
       FROM DWH_DWH_STG.collateral_type_master_finacle_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.security_data_ecbf ';
   INSERT INTO dwh_DWH_STG.security_data_ecbf
     ( SELECT * 
       FROM DWH_DWH_STG.security_data_ecbf_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.SECURITY_SOURCESYSTEM02 ';
   INSERT INTO dwh_DWH_STG.SECURITY_SOURCESYSTEM02
     ( SELECT * 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM02_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.SECURITY_SOURCESYSTEM04 ';
   INSERT INTO dwh_DWH_STG.SECURITY_SOURCESYSTEM04
     ( SELECT * 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM04_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_DWH_STG.transaction_data_finacle ';
   INSERT INTO DWH_DWH_STG.transaction_data_finacle
     ( SELECT * 
       FROM DWH_DWH_STG.transaction_data_finacle_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.bills_data_stg_fin ';
   INSERT INTO dwh_DWH_STG.bills_data_stg_fin
     ( SELECT * 
       FROM DWH_DWH_STG.bills_data_stg_fin_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_of_Data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.bills_data_stg_scf ';
   INSERT INTO dwh_DWH_STG.bills_data_stg_scf
     ( SELECT * 
       FROM DWH_DWH_STG.bills_data_stg_scf_Backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_of_Data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_DWH_STG.pca_data ';
   INSERT INTO DWH_DWH_STG.pca_data
     ( SELECT * 
       FROM DWH_DWH_STG.pca_data_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_of_Data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.InvestmentBasicDetail ';
   INSERT INTO dwh_DWH_STG.InvestmentBasicDetail
     ( SELECT * 
       FROM dwh_DWH_STG.InvestmentBasicDetail_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.InvestmentFinancialDetails ';
   INSERT INTO dwh_DWH_STG.InvestmentFinancialDetails
     ( SELECT * 
       FROM dwh_DWH_STG.InvestmentFinancialDetails_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.InvestmentIssuerDetail ';
   INSERT INTO dwh_DWH_STG.InvestmentIssuerDetail
     ( SELECT * 
       FROM dwh_DWH_STG.InvestmentIssuerDetail_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Derivative_Cancelled ';
   INSERT INTO dwh_DWH_STG.Derivative_Cancelled
     ( SELECT * 
       FROM dwh_DWH_STG.Derivative_Cancelled_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.MIFINGOLDMASTER ';
   INSERT INTO dwh_DWH_STG.MIFINGOLDMASTER
     ( SELECT * 
       FROM dwh_DWH_STG.MIFINGOLDMASTER_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(dateofdata,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.customer_data_metagrid ';
   INSERT INTO dwh_DWH_STG.customer_data_metagrid
     ( SELECT * 
       FROM dwh_DWH_STG.customer_data_metagrid_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Account_data_metagrid ';
   INSERT INTO dwh_DWH_STG.Account_data_metagrid
     ( SELECT * 
       FROM dwh_DWH_STG.Account_data_metagrid_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.security_data_metagrid ';
   INSERT INTO dwh_DWH_STG.security_data_metagrid
     ( SELECT * 
       FROM dwh_DWH_STG.security_data_metagrid_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Metagrid_Account_Master ';
   INSERT INTO dwh_DWH_STG.Metagrid_Account_Master
     ( SELECT * 
       FROM dwh_DWH_STG.Metagrid_Account_Master_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Metagrid_Customer_Master ';
   INSERT INTO dwh_DWH_STG.Metagrid_Customer_Master
     ( SELECT * 
       FROM dwh_DWH_STG.Metagrid_Customer_Master_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.Metagrid_Security ';
   INSERT INTO dwh_DWH_STG.Metagrid_Security
     ( SELECT * 
       FROM dwh_DWH_STG.Metagrid_Security_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.gsh ';
   INSERT INTO dwh_DWH_STG.gsh
     ( SELECT * 
       FROM dwh_DWH_STG.gsh_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Dt,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.reversefeed_calypso ';
   INSERT INTO dwh_DWH_STG.reversefeed_calypso
     ( SELECT * 
       FROM dwh_DWH_STG.reversefeed_calypso_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master ';
   INSERT INTO dwh_DWH_STG.product_code_master
     ( product_code, scheme_description )
     ( SELECT product_code ,
              scheme_description 
       FROM dwh_DWH_STG.product_code_master_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master_finacle ';
   INSERT INTO dwh_DWH_STG.product_code_master_finacle
     ( schm_code, del_flg, schm_desc, syst_gen_acct_num_flg, acct_prefix, next_acct_num_prefix, acct_opn_form_name, acct_cls_form_name, int_paid_bacid, int_coll_bacid, serv_chrg_bacid, turnover_freq_type, turnover_freq_week_num, turnover_freq_week_day, turnover_freq_start_dd, turnover_hldy_stat, turnover_rcre_date, gl_sub_head_code, tran_rpt_code_flg, tran_ref_num_flg, chq_alwd_flg, acct_turnover_det_flg, schm_supr_user_id, tot_mod_times, serv_chrg_coll_flg, back_date_tran_excp_code, val_date_tran_excp_code, invalid_instrmnt_excp_code, stale_instrmnt_excp_code, acct_frez_excp_code, acct_in_dr_bal_excp_code, acct_in_cr_bal_excp_code, chq_stop_excp_code, chq_cautn_excp_code, chq_not_issu_excp_code, invalid_rpt_code_excp_code, clg_tran_excp_code, cash_tran_excp_code, xfer_tran_excp_code, emp_own_acct_excp_code, override_def_excp_code, introd_not_cust_excp_code, introd_new_cust_excp_code, chq_not_alwd_excp_code, si_pre_fix_chrg_excp_code, dr_against_cc_excp_code, cls_pend_int_excp_code, cls_pend_si_excp_code, cls_pend_cc_excp_code, cls_pend_chq_excp_code, acct_opn_matrix_excp_code, memo_pad_exists_excp_code, sanct_lim_exp_excp_code, sanct_exceed_lim_excp_code, liab_exceed_group_lim_excp, acct_maint_form_name, ofti_schm_rtn_name, minor_chq_issu_excp_code, new_acct_duration, dorm_acct_criteria, min_posting_workclass, schm_type, int_paid_flg, int_coll_flg, staff_schm_flg, nre_schm_flg, merge_int_ptran_flg, lchg_user_id, rcre_user_id, lchg_time, rcre_time, micr_chq_chrg_bacid, insuff_avail_bal_excp_code, fd_cr_bacid, fd_dr_bacid, fx_tran_flg, stp_cr_dr_ind, fcnr_flg, int_pandl_bacid, parking_bacid, int_paid_coll_crncy_flg, cash_wd_wo_chq_excp_code, acct_name_changed_excp_code, xfer_in_int_details_flg, acct_reference_excp_code, dr_oper_acct_if_no_bal_flg, int_dr_cust_diff_excp_code, int_cr_cust_diff_excp_code, iso_user_tod_grnt_excp_code, iso_auto_tod_grnt_excp_code, inter_sol_closure_alwd_flg, levy_tax_pcnt_1, levy_tax_pcnt_2, levy_tax_pcnt_3, levy_tax_desc_1, levy_tax_desc_2, levy_tax_desc_3, levy_tax_bacid_1, levy_tax_bacid_2, levy_tax_bacid_3, levy_tax_merge_ptran_flg, peg_int_for_ac_flg, mod_of_peg_int_allowed_flg, peg_review_pref_from_cust, dflt_int_par_chng_excp_code, cls_pend_reversal_excp_code, chq_issued_ack_excp_code, acct_closure_chrg_days, acct_closure_chrg_mnths, acct_maint_period, min_commit_chrg_util_pcnt, commit_calc_method, inactive_acct_chrg_days, inactive_acct_chrg_mnths, dormant_acct_chrg_days, dormant_acct_chrg_mnths, partition_mandatory_flg, book_tran_script, intcalc_tran_script, advance_int_bacid, tds_parking_bacid, penal_pandl_bacid, dflt_clg_tran_code, dflt_inst_type, chq_unusable_excp_code, int_pandl_bacid_cr, int_pandl_bacid_dr, bel_min_bal_excp_code, pen_chrg_ncalc_excp_code, int_freq_type_cr, int_freq_week_num_cr, int_freq_week_day_cr, int_freq_start_dd_cr, int_freq_hldy_stat_cr, int_freq_type_dr, int_freq_week_num_dr, int_freq_week_day_dr, int_freq_start_dd_dr, int_freq_hldy_stat_dr, pd_gl_sub_head_code, pd_int_calc_excp_code, pd_dr_tran_excp_code, lim_level_int_flg, eefc_flg, ts_cnt, cs_schm_mesg1, cs_schm_mesg2, ps_freq_type, ps_freq_week_num, ps_freq_week_day, ps_freq_start_dd, ps_freq_hldy_stat, auto_renewal_period_flg, product_group, principal_lossline_bacid, recover_lossline_bacid, chrge_off_bacid, dealer_contr_bacid, int_waiver_bacid, daily_comp_int_flg, qis_int_flg, stock_int_flg, unverified_spp_excp_code, ovdu_int_paid_bacid, ovdu_int_pandl_bacid_cr, comp_date_flg, disc_rate_flg, START_DATE, end_date, set_id, cs_schm_natl_mesg1, cs_schm_natl_mesg2, stp_dr_int_recalc, stp_cr_int_recalc, fixedterm_mnths, fixedterm_years, repricing_plan, repricing_freq_mnths, repricing_freq_days, repricing_year_ind, float_int_tbl_code, repricing_excp_code, float_repricing_freq_mnths, float_repricing_freq_days, script_value_date_excp_code, cust_min_age, cust_max_age, age_range_excp_code, schm_short_name, pref_lang_code, pref_lang_schm_desc, pref_lang_schm_short_name, tenor_ind_flg, rule_code, secured_flg, lookback_perd_for_pastdue, bank_id, negative_lien_excp_code, chq_reject_excp_code, pen_coll_flg, syn_agent_scheme, pen_coll_bacid, product_concept, acct_linked_invt_id_excp_code, penal_int_coll_bacid, past_due_int_coll_bacid, past_due_penal_int_coll_bacid, schm_nature, ps_freq_cal_base, additional_cal_base, int_freq_cal_base_cr, int_freq_cal_base_dr, mud_pool_prod_flg, alt1_schm_short_name, alt1_schm_desc, product_srl_num, product_id, islamic_product_type, product_type, int_compounding_frq_cr, int_compounding_rest_flg_cr, disc_rate_flg_cr, konformna_flg, overide_def_min_bal_param_excp, chq_prov_by_bank_flg, product_code, int_freq_months_dr, int_freq_days_dr, nr_schm_type )
     ( SELECT schm_code ,
              del_flg ,
              schm_desc ,
              syst_gen_acct_num_flg ,
              acct_prefix ,
              next_acct_num_prefix ,
              acct_opn_form_name ,
              acct_cls_form_name ,
              int_paid_bacid ,
              int_coll_bacid ,
              serv_chrg_bacid ,
              turnover_freq_type ,
              turnover_freq_week_num ,
              turnover_freq_week_day ,
              turnover_freq_start_dd ,
              turnover_hldy_stat ,
              turnover_rcre_date ,
              gl_sub_head_code ,
              tran_rpt_code_flg ,
              tran_ref_num_flg ,
              chq_alwd_flg ,
              acct_turnover_det_flg ,
              schm_supr_user_id ,
              tot_mod_times ,
              serv_chrg_coll_flg ,
              back_date_tran_excp_code ,
              val_date_tran_excp_code ,
              invalid_instrmnt_excp_code ,
              stale_instrmnt_excp_code ,
              acct_frez_excp_code ,
              acct_in_dr_bal_excp_code ,
              acct_in_cr_bal_excp_code ,
              chq_stop_excp_code ,
              chq_cautn_excp_code ,
              chq_not_issu_excp_code ,
              invalid_rpt_code_excp_code ,
              clg_tran_excp_code ,
              cash_tran_excp_code ,
              xfer_tran_excp_code ,
              emp_own_acct_excp_code ,
              override_def_excp_code ,
              introd_not_cust_excp_code ,
              introd_new_cust_excp_code ,
              chq_not_alwd_excp_code ,
              si_pre_fix_chrg_excp_code ,
              dr_against_cc_excp_code ,
              cls_pend_int_excp_code ,
              cls_pend_si_excp_code ,
              cls_pend_cc_excp_code ,
              cls_pend_chq_excp_code ,
              acct_opn_matrix_excp_code ,
              memo_pad_exists_excp_code ,
              sanct_lim_exp_excp_code ,
              sanct_exceed_lim_excp_code ,
              liab_exceed_group_lim_excp ,
              acct_maint_form_name ,
              ofti_schm_rtn_name ,
              minor_chq_issu_excp_code ,
              new_acct_duration ,
              dorm_acct_criteria ,
              min_posting_workclass ,
              schm_type ,
              int_paid_flg ,
              int_coll_flg ,
              staff_schm_flg ,
              nre_schm_flg ,
              merge_int_ptran_flg ,
              lchg_user_id ,
              rcre_user_id ,
              lchg_time ,
              rcre_time ,
              micr_chq_chrg_bacid ,
              insuff_avail_bal_excp_code ,
              fd_cr_bacid ,
              fd_dr_bacid ,
              fx_tran_flg ,
              stp_cr_dr_ind ,
              fcnr_flg ,
              int_pandl_bacid ,
              parking_bacid ,
              int_paid_coll_crncy_flg ,
              cash_wd_wo_chq_excp_code ,
              acct_name_changed_excp_code ,
              xfer_in_int_details_flg ,
              acct_reference_excp_code ,
              dr_oper_acct_if_no_bal_flg ,
              int_dr_cust_diff_excp_code ,
              int_cr_cust_diff_excp_code ,
              iso_user_tod_grnt_excp_code ,
              iso_auto_tod_grnt_excp_code ,
              inter_sol_closure_alwd_flg ,
              levy_tax_pcnt_1 ,
              levy_tax_pcnt_2 ,
              levy_tax_pcnt_3 ,
              levy_tax_desc_1 ,
              levy_tax_desc_2 ,
              levy_tax_desc_3 ,
              levy_tax_bacid_1 ,
              levy_tax_bacid_2 ,
              levy_tax_bacid_3 ,
              levy_tax_merge_ptran_flg ,
              peg_int_for_ac_flg ,
              mod_of_peg_int_allowed_flg ,
              peg_review_pref_from_cust ,
              dflt_int_par_chng_excp_code ,
              cls_pend_reversal_excp_code ,
              chq_issued_ack_excp_code ,
              acct_closure_chrg_days ,
              acct_closure_chrg_mnths ,
              acct_maint_period ,
              min_commit_chrg_util_pcnt ,
              commit_calc_method ,
              inactive_acct_chrg_days ,
              inactive_acct_chrg_mnths ,
              dormant_acct_chrg_days ,
              dormant_acct_chrg_mnths ,
              partition_mandatory_flg ,
              book_tran_script ,
              intcalc_tran_script ,
              advance_int_bacid ,
              tds_parking_bacid ,
              penal_pandl_bacid ,
              dflt_clg_tran_code ,
              dflt_inst_type ,
              chq_unusable_excp_code ,
              int_pandl_bacid_cr ,
              int_pandl_bacid_dr ,
              bel_min_bal_excp_code ,
              pen_chrg_ncalc_excp_code ,
              int_freq_type_cr ,
              int_freq_week_num_cr ,
              int_freq_week_day_cr ,
              int_freq_start_dd_cr ,
              int_freq_hldy_stat_cr ,
              int_freq_type_dr ,
              int_freq_week_num_dr ,
              int_freq_week_day_dr ,
              int_freq_start_dd_dr ,
              int_freq_hldy_stat_dr ,
              pd_gl_sub_head_code ,
              pd_int_calc_excp_code ,
              pd_dr_tran_excp_code ,
              lim_level_int_flg ,
              eefc_flg ,
              ts_cnt ,
              cs_schm_mesg1 ,
              cs_schm_mesg2 ,
              ps_freq_type ,
              ps_freq_week_num ,
              ps_freq_week_day ,
              ps_freq_start_dd ,
              ps_freq_hldy_stat ,
              auto_renewal_period_flg ,
              product_group ,
              principal_lossline_bacid ,
              recover_lossline_bacid ,
              chrge_off_bacid ,
              dealer_contr_bacid ,
              int_waiver_bacid ,
              daily_comp_int_flg ,
              qis_int_flg ,
              stock_int_flg ,
              unverified_spp_excp_code ,
              ovdu_int_paid_bacid ,
              ovdu_int_pandl_bacid_cr ,
              comp_date_flg ,
              disc_rate_flg ,
              START_DATE ,
              end_date ,
              set_id ,
              cs_schm_natl_mesg1 ,
              cs_schm_natl_mesg2 ,
              stp_dr_int_recalc ,
              stp_cr_int_recalc ,
              fixedterm_mnths ,
              fixedterm_years ,
              repricing_plan ,
              repricing_freq_mnths ,
              repricing_freq_days ,
              repricing_year_ind ,
              float_int_tbl_code ,
              repricing_excp_code ,
              float_repricing_freq_mnths ,
              float_repricing_freq_days ,
              script_value_date_excp_code ,
              cust_min_age ,
              cust_max_age ,
              age_range_excp_code ,
              schm_short_name ,
              pref_lang_code ,
              pref_lang_schm_desc ,
              pref_lang_schm_short_name ,
              tenor_ind_flg ,
              rule_code ,
              secured_flg ,
              lookback_perd_for_pastdue ,
              bank_id ,
              negative_lien_excp_code ,
              chq_reject_excp_code ,
              pen_coll_flg ,
              syn_agent_scheme ,
              pen_coll_bacid ,
              product_concept ,
              acct_linked_invt_id_excp_code ,
              penal_int_coll_bacid ,
              past_due_int_coll_bacid ,
              past_due_penal_int_coll_bacid ,
              schm_nature ,
              ps_freq_cal_base ,
              additional_cal_base ,
              int_freq_cal_base_cr ,
              int_freq_cal_base_dr ,
              mud_pool_prod_flg ,
              alt1_schm_short_name ,
              alt1_schm_desc ,
              product_srl_num ,
              product_id ,
              islamic_product_type ,
              product_type ,
              int_compounding_frq_cr ,
              int_compounding_rest_flg_cr ,
              disc_rate_flg_cr ,
              konformna_flg ,
              overide_def_min_bal_param_excp ,
              chq_prov_by_bank_flg ,
              product_code ,
              int_freq_months_dr ,
              int_freq_days_dr ,
              nr_schm_type 
       FROM dwh_DWH_STG.product_code_master_finacle_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master_ganaseva ';
   INSERT INTO dwh_DWH_STG.product_code_master_ganaseva
     ( SOURCE, scheme_code, scheme_Desc )
     ( SELECT SOURCE ,
              scheme_code ,
              scheme_Desc 
       FROM dwh_DWH_STG.product_code_master_ganaseva_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master_FIS ';
   INSERT INTO dwh_DWH_STG.product_code_master_FIS
     ( SOURCE, scheme_code, scheme_Desc )
     ( SELECT SOURCE ,
              scheme_code ,
              scheme_Desc 
       FROM dwh_DWH_STG.product_code_master_FIS_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master_mifin ';
   INSERT INTO dwh_DWH_STG.product_code_master_mifin
     ( producttype, product_code, product_description )
     ( SELECT producttype ,
              product_code ,
              product_description 
       FROM dwh_DWH_STG.product_code_master_mifin_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_code_master_visionplus ';
   INSERT INTO dwh_DWH_STG.product_code_master_visionplus
     ( logo, Product_Name, pdt_cat1 )
     ( SELECT logo ,
              Product_Name ,
              pdt_cat1 
       FROM dwh_DWH_STG.product_code_master_visionplus_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );
   --Declare @Date date = '2022-06-07'
   -------------- START ------------------
   --------------- END -------------------
   -------------- START ---------------------
   --------------- END -------------------
   -------------- START ---------------------
   --------------- END ----------------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.product_master_ecbf ';
   INSERT INTO dwh_DWH_STG.product_master_ecbf
     ( producttype, product_code, product_description )
     ( SELECT producttype ,
              product_code ,
              product_description 
       FROM dwh_DWH_STG.product_master_ecbf_backup 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) = v_Date );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_LOADBACKUPDATAINDWHMAIN_04122023" TO "ADF_CDR_RBL_STGDB";
