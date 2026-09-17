package kr.co.mp.trade;

import java.util.ArrayList;

public class GuaranteeBean {
  GuaranteeDAO dao;
  public GuaranteeBean() {
    this.dao = new GuaranteeDAO();
  }
  public ArrayList<PayMethodVO> CT_MY_PAYMETHOD_PROC(int intCpyId) {
    return this.dao.CT_MY_PAYMETHOD_PROC(intCpyId);		
  }
  public ArrayList<PayMethodVO> M_CT_MY_PAYMETHOD_PROC(int intCpyId) {
    return this.dao.M_CT_MY_PAYMETHOD_PROC(intCpyId);		
  }
  public int GUARANTEE_MASTER_INFO_DROP_PROC(PayMethodVO pvo) {
	return this.dao.GUARANTEE_MASTER_INFO_DROP_PROC(pvo);
  }
  public int GUARANTEE_MASTER_INFO_EXTEND_PROC(PayMethodVO pvo) {
    return this.dao.GUARANTEE_MASTER_INFO_EXTEND_PROC(pvo);
  }
  public int GUARANTEE_MASTER_INFO_ADD_PROC(PayMethodVO vo) {
    return this.dao.GUARANTEE_MASTER_INFO_ADD_PROC(vo);
  }
  public int GUARANTEE_MASTER_INFO_MOD_PROC(PayMethodVO vo) {
    return this.dao.GUARANTEE_MASTER_INFO_MOD_PROC(vo);
  }
  public PayMethodVO GUARANTEE_MASTER_INFO_DETAIL_PROC(PayMethodVO pvo) {
    return this.dao.GUARANTEE_MASTER_INFO_DETAIL_PROC(pvo);
  }
  public ArrayList<PayMethodVO> BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC(String strGuarGubun, String strBankCode) {
    return this.dao.BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC(strGuarGubun, strBankCode);
  }
  public ArrayList<PayMethodVO> M_GUARANTEE_LIST_PROC(PayMethodVO pvo) {
    return this.dao.M_GUARANTEE_LIST_PROC(pvo);
  }
  public ArrayList<PayMethodVO> GUARANTEE_LOCATION_SEARCH_PROC(PayMethodVO pvo) {
	return this.dao.GUARANTEE_LOCATION_SEARCH_PROC(pvo);
  }
  public int GUARANTEE_MASTER_INFO_EXTEND_ALL_PROC(String date, String managerId) {
	return this.dao.GUARANTEE_MASTER_INFO_EXTEND_ALL_PROC(date, managerId);
  }
}
