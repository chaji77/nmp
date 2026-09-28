package kr.co.mp.trade;

import java.util.ArrayList;

public class CyclnBean {
  CyclnDAO dao;
  public CyclnBean() {
    this.dao = new CyclnDAO();
  }
  /**
   * 싸이클론 주문 목록. 거래일은 yyyy-MM-dd 로 넘어와도 되도록 구분자를 제거한다.
   */
  public ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PROC(CyclnOrderVO pvo) {
    pvo.TRADEDATE_START = (pvo.TRADEDATE_START==null) ? "" : pvo.TRADEDATE_START.replaceAll("-", "");
    pvo.TRADEDATE_END   = (pvo.TRADEDATE_END==null)   ? "" : pvo.TRADEDATE_END.replaceAll("-", "");
    return this.dao.CYCLN_ORDER_LIST_PROC(pvo);
  }
}
