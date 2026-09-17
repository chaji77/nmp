package kr.co.mp.mgr.sales;

import java.util.ArrayList;

public class CommissionBean {
  private CommissionDAO dao;
  public CommissionBean() {
    this.dao = new CommissionDAO();
  }
  public int INFO_COMMISSION_ADD_PROC(CommissionVO pvo) {
    return this.dao.INFO_COMMISSION_ADD_PROC(pvo);
  }
  public int INFO_COMMISSION_MOD_PROC(CommissionVO pvo) {
    return this.dao.INFO_COMMISSION_MOD_PROC(pvo);
  }
  public CommissionVO INFO_COMMISSION_DETAIL_PROC(int intCommId) {
    return this.dao.INFO_COMMISSION_DETAIL_PROC(intCommId);
  }
  public ArrayList<CommissionVO> INFO_COMMISSION_LIST_PER_CPY_ID_PROC(int intCpyId) {
    return this.dao.INFO_COMMISSION_LIST_PER_CPY_ID_PROC(intCpyId);
  }
  public int INFO_COMMISSION_DROP_PROC(int intCommId, String strManagerId) {
    return this.dao.INFO_COMMISSION_DROP_PROC(intCommId, strManagerId);
  }
  public ArrayList<MastOffCommissionVO> MAST_OFF_COMMISSION_LIST_PER_CPY_ID_PROC(int intCpyId, int intPage, int intRowCnt) {
    return this.dao.MAST_OFF_COMMISSION_LIST_PER_CPY_ID_PROC(intCpyId, intPage, intRowCnt);
  }
  public ArrayList<CommissionVO> INFO_COMMISSION_LIST_PROC(int intCpyId, CommissionVO pvo) {
    return this.dao.INFO_COMMISSION_LIST_PROC(intCpyId, pvo);
  }
  public int MAST_OFF_COMMISSION_ADD_PROC(MastOffCommissionVO pvo) {
    return this.dao.MAST_OFF_COMMISSION_ADD_PROC(pvo);
  }
  public int MAST_OFF_COMMISSION_DROP_PROC(MastOffCommissionVO pvo) {
    return this.dao.MAST_OFF_COMMISSION_DROP_PROC(pvo);
  }
  public CommissionVO CHECK_COMM_METHOD_D10_PERIOD(int intCtid) {
    return this.dao.CHECK_COMM_METHOD_D10_PERIOD(intCtid);
  }
  public CommissionVO CHECK_MPFEE_TOTALAMT_SUM_PROC(String strCpyBuyer) {
    return this.dao.CHECK_MPFEE_TOTALAMT_SUM_PROC(strCpyBuyer);
  }
  public int INFO_COMMISSION_RENEW_PROC(int intCommId, String strWriterLoginId) {
    return this.dao.INFO_COMMISSION_RENEW_PROC(intCommId, strWriterLoginId);
  }
}
