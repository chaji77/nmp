package kr.co.mp.mgr.customer;

import java.util.ArrayList;

import kr.co.mp.c.CompanyVO;
import kr.co.mp.c.RelationCompanyVO;

public class MgrCustomerBean {
  private MgrCustomerDAO dao;
  public MgrCustomerBean() {
	this.dao = new MgrCustomerDAO();
  }
  public int M_COMPANY_DISHONOR_MOD_PROC(CompanyVO cvo) {
    return this.dao.M_COMPANY_DISHONOR_MOD_PROC(cvo);
  }
  public int M_COMPANY_CONFIRM_SETTLE_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_CONFIRM_SETTLE_MOD_PROC(cvo);
  }
  public int M_COMPANY_MPTAX_MONTH_USE_YN_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_MPTAX_MONTH_USE_YN_MOD_PROC(cvo);
  }
  public int M_COMPANY_CU_USE_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_CU_USE_MOD_PROC(cvo);
  }
  public int M_RELATION_COMPANY_ADD_PROC(RelationCompanyVO vo) {
	return this.dao.M_RELATION_COMPANY_ADD_PROC(vo);
  }
  public ArrayList<RelationCompanyVO> M_RELATION_COMPANY_LIST_PROC(RelationCompanyVO vo) {
	return this.dao.M_RELATION_COMPANY_LIST_PROC(vo);
  }
  public RelationCompanyVO M_RELATION_COMPANY_DETAIL_PROC(int seq) {
	return this.dao.M_RELATION_COMPANY_DETAIL_PROC(seq);
  }
  public int M_RELATION_COMPANY_MOD_PROC(RelationCompanyVO vo) {
	return this.dao.M_RELATION_COMPANY_MOD_PROC(vo);
  }
  public int M_COMPANY_MOBILE_YN_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_MOBILE_YN_MOD_PROC(cvo);
  }
  public int M_COMPANY_REVERSE_YN_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_REVERSE_YN_MOD_PROC(cvo);
  }
  public int M_COMPANY_SIGN_EXCLUDE_YN_MOD_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_SIGN_EXCLUDE_YN_MOD_PROC(cvo);
  }
  public int M_COMPANY_MPTAX_REG_PROC(CompanyVO cvo) {
	return this.dao.M_COMPANY_MPTAX_REG_PROC(cvo); 
  }
  public int M_COMPANY_APPROVE_REGISTRATION(int cpyId) {
	return this.dao.M_COMPANY_APPROVE_REGISTRATION(cpyId);
  }
  public int M_COMPANY_MEMO_MOD_PROC(CompanyVO cvo) {
    return this.dao.M_COMPANY_MEMO_MOD_PROC(cvo);
  }
  public ArrayList<BusinessPersonVO> M_BUSINESS_PERSON_LIST_PROC(int intCpyId) {
    BusinessPersonVO cvo = new BusinessPersonVO();
    cvo.CPY_ID = intCpyId;
    return this.dao.M_BUSINESS_PERSON_LIST_PROC(cvo);
  }
  public int M_BUSINESS_PERSON_ADD_PROC(BusinessPersonVO cvo) {
    return this.dao.M_BUSINESS_PERSON_ADD_PROC(cvo);
  }
  public int M_BUSINESS_PERSON_MOD_PROC(BusinessPersonVO cvo) {
    return this.dao.M_BUSINESS_PERSON_MOD_PROC(cvo);
  }
  public int M_BUSINESS_PERSON_DROP_PROC(BusinessPersonVO cvo) {
    return this.dao.M_BUSINESS_PERSON_DROP_PROC(cvo);
  }
}
