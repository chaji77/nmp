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
    trimTradeDate(pvo);
    return this.dao.CYCLN_ORDER_LIST_PROC(pvo);
  }
  /**
   * 거래당사자(구매사) 기준 싸이클론 주문 목록. pvo.BC_ID 가 조회 기준 회사다.
   */
  public ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PER_CPY_ID_PROC(CyclnOrderVO pvo) {
    trimTradeDate(pvo);
    return this.dao.CYCLN_ORDER_LIST_PER_CPY_ID_PROC(pvo);
  }
  /** 거래일 조건의 구분자를 제거해 yyyyMMdd 로 맞춘다. */
  private void trimTradeDate(CyclnOrderVO pvo) {
    pvo.TRADEDATE_START = (pvo.TRADEDATE_START==null) ? "" : pvo.TRADEDATE_START.replaceAll("-", "");
    pvo.TRADEDATE_END   = (pvo.TRADEDATE_END==null)   ? "" : pvo.TRADEDATE_END.replaceAll("-", "");
  }
  /**
   * 거래당사자용 싸이클론 발주내역 상세.
   * 주문이 없거나 해당 회사가 구매기업/판매기업이 아니면 null.
   */
  public CyclnOrderDetailVO CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(String strOrderNo, int intCpyId) {
    return this.dao.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
  }
  /**
   * 싸이클론 결제전송관리 상세. 주문이 없으면 null.
   */
  public CyclnOrderDetailVO CYCLN_ORDER_DETAIL_PROC(String strOrderNo) {
    return this.dao.CYCLN_ORDER_DETAIL_PROC(strOrderNo);
  }
}
