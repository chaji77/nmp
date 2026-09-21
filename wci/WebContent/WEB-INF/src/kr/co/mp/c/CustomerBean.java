package kr.co.mp.c;

import java.util.ArrayList;

public class CustomerBean {
  private CustomerDAO dao;
  public CustomerBean() {
    this.dao = new CustomerDAO();
  }
  public static int COMPANY_CNT_PROC() {
	return CustomerDAO.COMPANY_CNT_PROC();
  }
  public int COMPANY_BIZNO_CHECK_PROC(String strBizNo) {
    return this.dao.COMPANY_BIZNO_CHECK_PROC(strBizNo);
  }
  public int COMPANY_LOGIN_ID_CHECK_PROC(String strLoginId) {
    return this.dao.COMPANY_LOGIN_ID_CHECK_PROC(strLoginId);
  }
  public int COMPANY_ADD_PROC(CompanyVO cvo, PersonVO pvo) {
    return this.dao.COMPANY_ADD_PROC(cvo, pvo);
  }
  public int COMPANY_MOD_PROC(CompanyVO cvo, PersonVO pvo) {
    return this.dao.COMPANY_MOD_PROC(cvo, pvo);
  }
  public CompanyVO COMPANY_DETAIL_PROC(int intCpyId) {
    return this.dao.COMPANY_DETAIL_PROC(intCpyId);
  }
  public CompanyVO COMPANY_MOREINFO_PROC(int intCpyId) {
    return this.dao.COMPANY_MOREINFO_PROC(intCpyId);
  }
  public int COMPANY_MOREINFO_MOD_PROC(CompanyVO cvo) {
    return this.dao.COMPANY_MOREINFO_MOD_PROC(cvo);
  }
  public ArrayList<CompanyVO> COMPANY_SEARCH_PROC(CompanyVO cvo) {
    return this.dao.COMPANY_SEARCH_PROC(cvo);
  }
  public ArrayList<CompanyVO> COMPANY_SALES_SEARCH_PROC(CompanyVO cvo) {
    return this.dao.COMPANY_SALES_SEARCH_PROC(cvo);
  }
  public ArrayList<CompanyVO> CT_MYCOMPANY_LIST_PROC(int intCpyId, int intPrsId) {
    return this.dao.CT_MYCOMPANY_LIST_PROC(intCpyId, intPrsId);
  }
  public ArrayList<CompanyVO> CT_MYCOMPANY_ADD_PROC(int intCpyId, int intTargetCpyId) {
    return this.dao.CT_MYCOMPANY_ADD_PROC(intCpyId, intTargetCpyId);
  }
  public int CT_MYCOMPANY_DROP_PROC(int intCpyId, int intTargetCpyId) {
    return this.dao.CT_MYCOMPANY_DROP_PROC(intCpyId, intTargetCpyId);
  }
  public ArrayList<PersonVO> PERSON_LIST_PROC(int intCpyId) {
    return this.dao.PERSON_LIST_PROC(intCpyId);
  }
  public int PERSON_ADD_PROC(int intCpyId, PersonVO pvo) {
    return this.dao.PERSON_ADD_PROC(intCpyId, pvo);
  }
  public int PERSON_MOD_PROC(int intCpyId, PersonVO pvo) {
    return this.dao.PERSON_MOD_PROC(intCpyId, pvo);
  }
  public int PERSON_DROP_PROC(int intCpyId, PersonVO pvo) {
    return this.dao.PERSON_DROP_PROC(intCpyId, pvo);
  }
  public ArrayList<CompanySalesVO> COMPANY_SALES_LIST_PROC(CompanySalesVO cvo) {
    return this.dao.COMPANY_SALES_LIST_PROC(cvo);
  }
  public int COMPANY_SALES_ADD_PROC(CompanySalesVO cvo) {
    return this.dao.COMPANY_SALES_ADD_PROC(cvo);
  }
  public CompanyVO COMPANY_SALEAMT_CHECK_PROC(int intCpyId) {
	return this.dao.COMPANY_SALEAMT_CHECK_PROC(intCpyId);
  }
  public void COMPANY_MOD_NOT_CHANGE_PROC(int intCpyId) {
    this.dao.COMPANY_MOD_NOT_CHANGE_PROC(intCpyId);
  }
  public int COMPANY_MOD_SELLER_CLEAR_YN_PROC(int intSellerCpyId, String strSellerClearYN) {
    return this.dao.COMPANY_MOD_SELLER_CLEAR_YN_PROC(intSellerCpyId, strSellerClearYN);
  }
  public String COMPANY_MEMO_PROC(int intCpyId) {
    return this.dao.COMPANY_MEMO_PROC(intCpyId);
  }
  public int TOBE_COMPANY_TO_LEGACY_COMPANY_PROC(int intCpyId) {
    return this.dao.TOBE_COMPANY_TO_LEGACY_COMPANY_PROC(intCpyId);
  }
}
