package kr.co.mp.mgr.sales;

import java.util.ArrayList;

public class SalesMemoBean {
  private SalesMemoDAO dao;
  public SalesMemoBean() {
    this.dao = new SalesMemoDAO();
  }
  public ArrayList<SalesMemoVO> SALES_MEMO_LIST_PER_CPY_ID_PROC(SalesMemoVO pvo) {
    return this.dao.SALES_MEMO_LIST_PER_CPY_ID_PROC(pvo);
  }
  public int SALES_MEMO_ADD_PROC(SalesMemoVO pvo) {
    return this.dao.SALES_MEMO_ADD_PROC(pvo);
  }
  public int SALES_MEMO_MOD_PROC(SalesMemoVO pvo) {
    return this.dao.SALES_MEMO_MOD_PROC(pvo);
  }
}
