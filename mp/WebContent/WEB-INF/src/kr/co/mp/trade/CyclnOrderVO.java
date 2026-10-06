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
  public String MTR_YMD;      // 만기일(CL100)
  public String SETL_PLN_PRIC;// 결제예정금액(CL090)
  public String SETL_PRIC;    // 실결제금액(CL100)
  public String STATUS;       // 주문상태(CYCLN_ORDER.STATUS)
  public String TRX_CLS;      // 거래구분(CL100.TRX_CLS) 1-결제, 2-취소
  public String CQ100_STATUS; // 결제상태(CYCLN_QUEUE.STATUS)
  public String REGTIME;      // 등록일시(CYCLN_ORDER.CRETIME)
  public String PAYTIME;      // 결제일시(CYCLN_SETTLE.CRETIME)
  public String CODE_NM;      // 상태 표시명(CYCLN_ORDER_STATUS)

  /* 거래당사자 구분. 같은 상태코드라도 구매사/판매사 화면의 표시명이 다르다. */
  public static final String ROLE_BUYER  = "B";
  public static final String ROLE_SELLER = "S";
  /* 구매·판매 구분 없이 한 회사의 거래를 모두 본다. 관리자 회원별 거래화면용. */
  public static final String ROLE_ALL    = "A";

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
  public int    CPY_ID          = 0;  // 거래당사자 화면의 로그인 회사
  public String STATUS_COND     = ""; // 주문상태 코드 조건(ORDER_STATUS 의 코드)
  public String CPY_NAME_COND   = ""; // 거래상대 기업명 검색어
  public String ROLE            = ROLE_BUYER; // 조회 기준. ROLE_BUYER-발주계약서, ROLE_SELLER-납품내역관리, ROLE_ALL-전체

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
   * 검색 드롭다운용 상태코드 목록. {상태코드, 표시명}
   * 표시명은 CYCLN_ORDER_STATUS 가 갖고 있지만, 검색조건 목록까지 조회하기는 과해서
   * 코드 목록만 여기 둔다. 조회결과 한 건의 표시명은 프로시저의 CODE_NM 을 쓴다.
   */
  public static final String[][] ORDER_STATUS = {
      {"010", "승인대기"    }
    , {"020", "구매사 변경요청"}
    , {"025", "판매사 변경요청"}
    , {"030", "판매사 취소요청"}
    , {"035", "구매사 취소요청"}
    , {"050", "확정"        }
    , {"090", "구매사 취소"  }
    , {"095", "판매사 취소"  }
  };

  /** 조회결과 한 건의 상태 표시명. 프로시저가 준 CODE_NM 에 결제전문 상태를 덮어쓴다. */
  public String getOrderStatusNm() {
    return getOrderStatusNm(this.CODE_NM, this.STATUS, this.CQ100_STATUS, this.TRX_CLS);
  }

  /**
   * 결제전문 상태까지 반영한 거래당사자 화면용 표시명.
   * 결제전문이 나간 건만 결제 정의(STATUS_FILTERS)로 덮어쓰고, 나머지는 프로시저가 준
   * CYCLN_ORDER_STATUS 의 표시명을 그대로 쓴다. 그 테이블에는 결제전문 상태가 없기 때문이다.
   *
   * @param strCodeNm  프로시저가 준 CODE_NM(역할에 맞는 BCNAME/SCNAME)
   * @param strStatus  CYCLN_ORDER.STATUS
   * @param strQueue   CYCLN_QUEUE.STATUS. 전문이 없으면 빈값
   * @param strTrxCls  CYCLN_CL100.TRX_CLS
   */
  public static String getOrderStatusNm(String strCodeNm, String strStatus, String strQueue, String strTrxCls) {
    if (strQueue!=null && !strQueue.trim().equals("")) {
      String strNm = matchStatusFilter(strStatus, strQueue, strTrxCls);
      if (strNm!=null) return strNm;
    }
    String strBase = oneLine(strCodeNm);
    if (!strBase.equals("")) return strBase;
    return (strStatus==null) ? "" : strStatus.trim(); // 상태코드 정의가 없는 건
  }

  /**
   * CYCLN_ORDER_STATUS 의 표시명을 한 줄로 편다.
   * DB 값이 '구매사 <BR>발주상태' 처럼 줄바꿈 앞뒤에 공백을 갖고 있어 공백도 하나로 줄인다.
   */
  private static String oneLine(String strNm) {
    if (strNm==null) return "";
    return strNm.replaceAll("(?i)<br\\s*/?>", " ").replaceAll("\\s+", " ").trim();
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
