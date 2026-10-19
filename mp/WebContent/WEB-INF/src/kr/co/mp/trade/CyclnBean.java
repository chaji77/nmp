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
   * 거래당사자 기준 싸이클론 주문 목록.
   * pvo.CPY_ID 가 기준 회사, pvo.ROLE 이 B 면 발주계약서, S 면 납품내역관리 기준이다.
   * A 면 구매·판매 전체(관리자 회원별 거래화면).
   */
  public ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PER_CPY_ID_PROC(CyclnOrderVO pvo) {
    trimTradeDate(pvo);
    return this.dao.CYCLN_ORDER_LIST_PER_CPY_ID_PROC(pvo);
  }
  /**
   * 발주계약서 등록. 주문번호는 프로시저가 만들어 돌려준다.
   * @return 새 주문번호. 실패하면 빈 문자열.
   */
  public String CYCLN_ORDER_REG_PROC(CyclnOrderRegVO vo) {
    return this.dao.CYCLN_ORDER_REG_PROC(vo, CyclnOrderRegVO.setXml(vo.ITEMS));
  }
  /**
   * 발주계약서 수정·취소. 채워 넘긴 값만 바뀐다.
   * 누가 무엇을 할 수 있는지는 부르는 쪽에서 정한다.
   * @return [0] "ok" 또는 "error", [1] 실패하면 보여줄 사유
   */
  public String[] CYCLN_ORDER_MOD_PROC(CyclnOrderActVO vo) {
    return this.dao.CYCLN_ORDER_MOD_PROC(vo);
  }
  /**
   * 발주계약서 작성 화면의 판매기업 목록. 거래한 적 있는 기업만 최근 거래순으로 나온다.
   * 목록에 없는 기업은 화면의 검색으로 고른다.
   */
  public ArrayList<CyclnSellerVO> CYCLN_SELLER_LIST_PROC(int intCpyId) {
    return this.dao.CYCLN_SELLER_LIST_PROC(intCpyId);
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
  /**
   * CL080(매매계약정보) 전문 등록. 제품정보를 반영하고 전문을 전송대기로 올린다.
   * 누가 무엇을 할 수 있는지와 어떤 상태로 가야 하는지는 부르는 쪽에서 정한다.
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유
   */
  public String[] CYCLN_CL080_PROC(CyclnOrderActVO vo) {
    return this.dao.CYCLN_CL080_PROC(vo);
  }
  /**
   * CL090(결제예정정보) 전문 등록. 구매기업이 은행에 결제를 접수한다.
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유
   */
  public String[] CYCLN_CL090_PROC(CyclnOrderActVO vo) {
    return this.dao.CYCLN_CL090_PROC(vo);
  }
  /**
   * 실패한 CL080·CL090 전문 재전송. 관리자 화면용.
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  public String[] CYCLN_TMSG_RESEND_PROC(String strOrderNo, String strKncd) {
    return this.dao.CYCLN_TMSG_RESEND_PROC(strOrderNo, strKncd);
  }
  /**
   * CL120(한도조회) 전문 등록. 회사의 사업자번호로 기업은행에 약정한도를 묻는다.
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  public String[] CYCLN_CL120_PROC(int intCpyId) {
    return this.dao.CYCLN_CL120_PROC(intCpyId);
  }
  /**
   * CL120(한도조회) 응답. 응답 전이면 STATUS 만 채워진 한 줄, 전문이 없으면 빈 목록.
   */
  public ArrayList<CyclnLimitVO> CYCLN_CL120_RESULT_PROC(String strTmsgSeq, String strReqYmd) {
    return this.dao.CYCLN_CL120_RESULT_PROC(strTmsgSeq, strReqYmd);
  }
  /**
   * CL080·CL090 응답. [0] STATUS, [1] RESP_CD, [2] RES_MSG, [3] ORDERNO, [4] TRX_CLS. 전문이 없으면 null.
   */
  public String[] CYCLN_TMSG_RESULT_PROC(String strKncd, String strTmsgSeq, String strReqYmd) {
    return this.dao.CYCLN_TMSG_RESULT_PROC(strKncd, strTmsgSeq, strReqYmd);
  }
}
