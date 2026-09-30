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
  public String CRETIME;      // 등록일시

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
  public String STATUS_COND     = ""; // 주문상태 코드 조건(ORDER_STATUS 의 코드)
  public String SC_NAME_COND    = ""; // 판매사명 검색어

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

  /* 거래당사자 구분. 같은 상태코드라도 구매사/판매사 화면의 표시명이 다르다. */
  public static final String ROLE_BUYER  = "B";
  public static final String ROLE_SELLER = "S";

  /**
   * CYCLN_ORDER.STATUS 코드 정의.
   * {상태코드, 구매사 표시명, 판매사 표시명}
   */
  public static final String[][] ORDER_STATUS = {
      {"010", "발주내역 승인대기", "구매사 발주상태"  }
    , {"020", "구매사 변경요청",   "구매사 변경요청"  }
    , {"025", "판매사 변경요청",   "판매사 변경요청"  }
    , {"030", "판매사 취소요청",   "판매사 취소요청"  }
    , {"035", "구매사 취소요청",   "구매사 취소요청"  }
    , {"050", "발주확정",         "납품확정"        }
    , {"090", "구매사 취소",      "구매사 취소"     }
    , {"095", "판매사 취소",      "판매사 취소"     }
  };

  /**
   * 상태코드를 해당 역할의 표시명으로 바꾼다.
   * 정의에 없는 코드는 원본을 그대로 돌려준다.
   *
   * @param strStatus 상태코드
   * @param strRole   ROLE_BUYER 또는 ROLE_SELLER. 그 외 값은 구매사로 본다.
   */
  public static String getOrderStatusNm(String strStatus, String strRole) {
    String strCode = (strStatus==null) ? "" : strStatus.trim();
    int    nIdx    = ROLE_SELLER.equals(strRole) ? 2 : 1;
    for (String[] f : ORDER_STATUS) {
      if (f[0].equals(strCode)) return f[nIdx];
    }
    return strCode;
  }

  /** 조회결과 한 건의 상태 표시명(거래당사자 화면용). */
  public String getOrderStatusNm(String strRole) {
    return getOrderStatusNm(this.STATUS, strRole);
  }

  /**
   * 결제전문 상태까지 반영한 거래당사자 화면용 표시명.
   * 결제전문이 있는 건만 결제 정의(STATUS_FILTERS)를 쓰고, 나머지는 역할별 주문상태명(ORDER_STATUS)을 쓴다.
   * 두 정의는 010 / 050 / 090 / 095 에서 겹치는데, 전문이 없으면 거래당사자 화면 용어가 맞다.
   *
   * @param strStatus  CYCLN_ORDER.STATUS
   * @param strQueue   CYCLN_QUEUE.STATUS. 전문이 없으면 빈값
   * @param strTrxCls  CYCLN_CL100.TRX_CLS
   * @param strRole    ROLE_BUYER 또는 ROLE_SELLER
   */
  public static String getOrderStatusNm(String strStatus, String strQueue, String strTrxCls, String strRole) {
    if (strQueue!=null && !strQueue.trim().equals("")) {
      String strNm = matchStatusFilter(strStatus, strQueue, strTrxCls);
      if (strNm!=null) return strNm;
    }
    return getOrderStatusNm(strStatus, strRole);
  }

  /**
   * STATUS_FILTERS 에서 한 건에 맞는 정의를 찾아 표시명을 돌려준다. 없으면 null.
   */
  private static String matchStatusFilter(String strStatus, String strQueue, String strTrxCls) {
    strStatus = (strStatus==null) ? "" : strStatus.trim();
    strQueue  = (strQueue==null)  ? "" : strQueue.trim();
    strTrxCls = (strTrxCls==null) ? "" : strTrxCls.trim();
    for (String[] f : STATUS_FILTERS) {
      if (!f[2].equals(strStatus)) continue;
      if (f[3].equals("NUL")) { if (!strQueue.equals("")) continue; }
      else                    { if (!f[3].equals(strQueue)) continue; }
      if (!f[4].equals("") && !f[4].equals(strTrxCls)) continue;
      return f[1];
    }
    return null;
  }

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
    String strNm = matchStatusFilter(this.STATUS, this.CQ100_STATUS, this.TRX_CLS);
    return (strNm!=null) ? strNm : ((this.STATUS==null) ? "" : this.STATUS.trim());
  }
}
