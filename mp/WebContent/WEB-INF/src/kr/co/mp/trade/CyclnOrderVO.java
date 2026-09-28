package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class CyclnOrderVO extends CommonVO {
  public String ORDERNO;      // 주문번호
  public String TRADEDATE;    // 거래일
  public String ORDERNAME;    // 주문명
  public String REQDLVDATE;   // 납기요청일
  public String BC_NAME;      // 구매사명
  public String SC_NAME;      // 판매사명
  public String PURC_PRIC;    // 구매금액(CL080)
  public String FEE_RATE;     // 수수료율(CL090)
  public String SETL_PLN_YMD; // 결제예정일(CL090)
  public String TAX_ISSU_YMD; // 세금계산서발행일(CL090)
  public String STATUS;       // 주문상태(CYCLN_ORDER.STATUS)
  public String TRX_CLS;      // 거래구분(CL100.TRX_CLS) 1-결제, 2-취소
  public String CQ100_STATUS; // 결제상태(CYCLN_QUEUE.STATUS)

  /* FOR SEARCH */
  public String STATUS_CD       = ""; // 화면에서 고른 단일 상태코드
  public String STATUS1         = ""; // 주문상태 조건
  public String STATUS2         = ""; // 결제상태 조건('NUL'이면 전문 없는 건만)
  public String TRX_CLS_COND    = ""; // 거래구분 조건
  public String ORDERNO_COND    = ""; // 주문번호 검색어
  public String TRADEDATE_START = "";
  public String TRADEDATE_END   = "";
  public int    BC_ID           = 0;
  public int    SC_ID           = 0;

  /**
   * 화면 드롭다운용 상태 정의.
   * {상태코드, 표시명, STATUS1, STATUS2, TRX_CLS}
   * STATUS2 의 'NUL' 은 결제 전문이 없는 건(CYCLN_QUEUE.STATUS IS NULL)을 뜻한다.
   */
  public static final String[][] STATUS_FILTERS = {
      {"CT", "발주계약서 작성", "010", "NUL", "" }
    , {"OC", "발주 취소",       "090", "NUL", "" }
    , {"DC", "납품 취소",       "095", "NUL", "" }
    , {"DF", "납품 확정",       "050", "NUL", "" }
    , {"PD", "결제 완료",       "050", "2",   "01"}
    , {"PC", "결제 취소",       "050", "2",   "02"}
  };

  /**
   * 화면에서 넘어온 단일 상태코드를 STATUS1 / STATUS2 / TRX_CLS 조건으로 쪼갠다.
   * 정의에 없는 값이면 전체조회로 둔다.
   */
  public void setStatusCd(String strStatusCd) {
    this.STATUS_CD    = (strStatusCd==null) ? "" : strStatusCd.trim();
    this.STATUS1      = "";
    this.STATUS2      = "";
    this.TRX_CLS_COND = "";
    for (String[] f : STATUS_FILTERS) {
      if (f[0].equals(this.STATUS_CD)) {
        this.STATUS1      = f[2];
        this.STATUS2      = f[3];
        this.TRX_CLS_COND = f[4];
        return;
      }
    }
    this.STATUS_CD = "";
  }

  /**
   * 조회결과 한 건의 상태 표시명을 돌려준다. 매칭되는 정의가 없으면 원본 코드를 그대로 쓴다.
   */
  public String getStatusNm() {
    String strStatus  = (this.STATUS==null)       ? "" : this.STATUS.trim();
    String strQueue   = (this.CQ100_STATUS==null) ? "" : this.CQ100_STATUS.trim();
    String strTrxCls  = (this.TRX_CLS==null)      ? "" : this.TRX_CLS.trim();
    for (String[] f : STATUS_FILTERS) {
      if (!f[2].equals(strStatus)) continue;
      if (f[3].equals("NUL")) { if (!strQueue.equals("")) continue; }
      else                    { if (!f[3].equals(strQueue)) continue; }
      if (!f[4].equals("") && !f[4].equals(strTrxCls)) continue;
      return f[1];
    }
    return strStatus;
  }
}
